#!/bin/bash
export APP_CREATION_TIMEOUT=400 # if an app is not created after 30 seconds then something went wrong
export SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
export JMETER_TESTPLAN=Myplan.jmx
JMETER_VERSION=2.11
JMETER_TARBALL=`ls | egrep "apache-jmeter.*gz"`
JMETER_EXECUTABLE=`which jmeter 2>/dev/null`


# Make sure the tools are installed\
GEM=`which gem`
RHC=`which rhc`
HEROKU=`which heroku`
WGET=`which wget`

if [[ ! $GEM ]]
then
  echo "Unable to find gem executable. Please installed rubygems"
  exit 255
fi

if [[ ! $HEROKU ]]
then
  gem install heroku
fi

if [[ ! $RHC ]]
then
  gem install rhc
else
  rhc --version
  which rhc
fi

if [[ ! $WGET ]]
then
  echo "Please, install wget"
  exit 255
fi


# Now download jmeter
if [[ ! $JMETER_TARBALL ]] || [[ ! $JMETER_EXECUTABLE ]]
then
  wget http://apache.miloslavbrada.cz/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
  tar -xzf apache-jmeter-${JMETER_VERSION}.tgz
  export PATH=$PATH:$PWD/apache-jmeter-${JMETER_VERSION}/bin
fi



# Let's declare some functions to be used later

function create_heroku_app() {
  # $1 - app name
  # $2 - app type
  # $3 - addon (database) cartridge 
  # $4 - from code
  # $5 - app_creation_stdout file

  database=`echo $3 | sed 's/\-[0-9]\.[0-9]//'` 
  # heroku's database notation is something like: postgresql, mysql,
  # oracle, unlike openshift with it's postgresql-9.2, mysql-5.5, etc
  if [[ $4 ]]
  then
    mkdir $1
    cd $1
    git init
    git remote add origin $4
    git pull origin master
#    # Ugly workaround for heroku failing to build rails apps with sqlite as a dependency.
#    # See http://stackoverflow.com/questions/10455527/sqlite3-h-missing-when-pushing-rails-app-to-heroku
#    # for details why
#    if [[ -f Gemfile ]] # if this is a ruby app
#    then
#      sed -i "s/^ruby.*//" Gemfile
#      sed -i "s/.*sqlite3.*//" Gemfile
#      sed -i "s/.*sqlite3.*//" Gemfile.lock
#      if [[ $3 = "postgresql" ]]
#      then
#        echo "gem 'pg'" >> Gemfile
#      else
#        echo "Addons other than postgresql are not yet supported by this tool"
#      fi
#      bundle config build.nokogiri --use-system-libraries
#      bundle install
#      git commit -am "a mega-hack"
#    fi
    # End of workaround

  else
    if [[ $2 =~ ruby ]]
    then
      rails new $1 --database=$database
      cd $1
      git init
      git add .
      git commit -am "initial commit"
    else
      echo "Not yet implemented"
    fi
  fi
  URL=`heroku apps:create $1 |tee $5 | awk '/http/ {print $1}'`
  git push heroku master
  if [[ ! $? = 0 ]] 
  # Sometimes heroku sucks and simply refuses to create an application from a
  # particular git url. 
  then
    cd ..
    return 255
  fi
  cd ..
}

function app_clean() {
  if [[ $PRODUCT != "heroku" ]]
  then
    rhc app delete $APP_NAME --confirm -l $RH_LOGIN -p $RH_PASSWORD --server $BROKER -k
  else
    heroku apps:destroy $APP_NAME --confirm $APP_NAME
  fi
}



function runme() {
  export APP_CREATION_STDOUT=stdout_from_app_creation_${item}.txt
  export APP_CREATION_OUTFILE=app_creation_${item}.txt
  # create an app and measure the time of this operation
  export APP_NAME=`date | md5sum | cut -c 1-25 | sed 's/[0-9]//g'` 
  export started=`date +%s`
  if [[ $PRODUCT = "heroku" ]]
  then
    create_heroku_app $APP_NAME $APP_TYPE $ADDON_CARTS $FROM_CODE $APP_CREATION_STDOUT
  else
    RHC_FROM_CODE="--from-code $FROM_CODE"
    timeout $APP_CREATION_TIMEOUT rhc app create $APP_NAME $APP_TYPE $ADDON_CARTS $SCALABLE -g $GEAR_PROFILE $ENVVARS $RHC_FROM_CODE -l $RH_LOGIN -p $RH_PASSWORD --server $BROKER -k --noprompt > $APP_CREATION_STDOUT
    if [[ $? > 0 ]]
    then # App creation failed
      return 255
    fi
    export URL=`awk '/URL:/ {print $2}' $APP_CREATION_STDOUT | tail -n 1`
  fi
  env > env_list_0.txt
  if [[ $URL ]] 
  # we managed to create an app
  # let's wait till the app is available
  then
    enddate=$(expr `date +%s` + 20) # 20 seconds should be enough
    while true
    do
      curl -kIf X GET $URL
      if [[ $? = 0 ]] 
      then
        export finished=`date +%s`
        export elapsed=$(expr $finished - $started)
        break
      elif [[ `date +%s` = $enddate ]]
      then
        export ACCESS_FAILED=true
        env > env_list_1.txt
        app_clean
        break
      fi
      echo "waiting till the app is available at $URL..."
    done

    # Now if we are unable to access the app then all the rest has no sence:
    # exiting

    if [[ $ACCESS_FAILED = "true" ]]
    then
      echo -e  "App creation failed\nUnable to access the app url: $URL" > $APP_CREATION_OUTFILE
      return 255
    fi

    # For scalable openshift apps tell the app not to autoscale otherwise the
    # comparison between scaled and not scaled app would be inadequate
    if [[ $SCALABLE ]] && [[ $PRODUCT = "openshift" ]]  
    then
      cd $APP_NAME
      echo "===================="
      echo "We are now in `pwd`"
      echo "===================="
      touch .openshift/markers/DISABLE_AUTO_SCALING
      git add .
      git commit -am "disabled auto-scaling"
      git push
      cd ..
      echo "Disabled auto_scaling"
    fi

    echo "App creation lasted $elapsed seconds" > $APP_CREATION_OUTFILE
    # Now let's flood the app a bit
    export JMETER_OUTFILE=jmeter_output_before_${item}
    export TARGET_URL=$URL # If relative url is provided, we can add it to the TARGET_URL
    TARGET=`echo $TARGET_URL | awk 'BEGIN { FS = "/" } ; { print $3 }'`
    jmeter -n -t $JMETER_TESTPLAN -Jconcurrency=$CONCURRENCY \
    -Jtimelimit=$REQUESTCOUNT -Jtarget_url=$TARGET -Joutfile=$JMETER_OUTFILE  \
    -Jduration=$DURATION
    if [[ $SCALABLE ]] 
    then
      APP_SCALE_RESULTS=app_scale_results
      #Now scale up the app
      for i in $(seq 1 $TIMES_SCALE)
      do
        TIMETOSLEEP=$(expr $CONCURRENCY / 10)
        sleep $TIMETOSLEEP 
        # To make sure all tcp connections are gone and the app has recovered
        export JMETER_OUTFILE_AFTER=jmeter_output_after_${i}_scaling_${item}
        exitcode=0
        if [[ $PRODUCT = "heroku" ]]
        then
          heroku ps:scale web+1 worker+1 --app $APP_NAME &>> $APP_SCALE_RESULTS
          exitcode=$?
        else
          echo -e "\n======================================\n" >> $APP_SCALE_RESULTS 
          rhc app-scale-up -a $APP_NAME -l $RH_LOGIN -p $RH_PASSWORD --server $BROKER -k --noprompt >> $APP_SCALE_RESULTS
          exitcode=$?
        fi
        #####################################################################
        # Now actually flood it
        if [[ $exitcode == 0 ]]
        then
          jmeter -n -t $JMETER_TESTPLAN -Jconcurrency=$CONCURRENCY -Jtimelimit=$REQUESTCOUNT -Jtarget_url=$TARGET -Joutfile=$JMETER_OUTFILE_AFTER -Jduration=$DURATION
          sleep 10
        else # failed to scale the app
          echo "Failed to scale up the $APP_NAME app" > $APP_SCALE_RESULTS
        fi
      done
    fi
  else # App creation failed
    echo "App creation failed" > $APP_CREATION_OUTFILE
    return 255
  fi # End of checking for ap creation result

  # Now let's clean up a bit
  app_clean

  if [[ $SLAVE ]]
  then
    # Create a folder for the results
    # Upload results
    DST_FOLDER=~/build_results/${BUILD_NUMBER}
    ssh $SSH_OPTS -p $SSH_PORT $SSH_URL "mkdir -p $DST_FOLDER"
    scp -P $SSH_PORT $APP_CREATION_STDOUT $SSH_URL:${DST_FOLDER}/app_creation_stdout_${HOSTNAME}_${item}
    scp -P $SSH_PORT $APP_CREATION_OUTFILE $SSH_URL:${DST_FOLDER}/app_creation_result_${HOSTNAME}_${item}
    if [[ -f $JMETER_OUTFILE ]]
    then
      scp -P $SSH_PORT $JMETER_OUTFILE $SSH_URL:${DST_FOLDER}/jmeter_output_before_${HOSTNAME}_${item}.csv
    fi
    if [[ $APP_SCALE_RESULTS ]]
    then
      scp -P $SSH_PORT $APP_SCALE_RESULTS $SSH_URL:${DST_FOLDER}/app_scaling_results_${HOSTNAME}_${item}
    fi
    for i in `ls | grep output_after`
    do
      scp -P $SSH_PORT $i $SSH_URL:${DST_FOLDER}/${i}_${HOSTNAME}.csv
    done
  else
    echo "Please find raw results in the current folder"
    # Process the results in place
  fi
}

# OK, now, that functions are declared, let's rock-n-roll!

if [[ $LOG_SERVER ]]
then
  if [[ $LOG_SERVER_USERNAME ]]
  then
    SSH_URL="$LOG_SERVER_USERNAME@$LOG_SERVER"
  else
    SSH_URL="$LOG_SERVER"
  fi
fi

if [ -z "$SSH_PORT" ]
then
  export SSH_PORT=22
fi



if [[ ! $SLAVE ]] && [[ ! $BUILD_NUMBER ]] 
# We are running it manually - nut under rails app or under jenkins
then
  # Parse commandline arguments
  while getopts ":w:a:m:g:s:l:p:t:c:u:e:r:d:x:h" optval "$@"
  do
    case $optval in
      "w")
        export APP_TYPE=$OPTARG
        ;;
      "a")
        export ADDON_CARTS=$OPTARG
        ;;
      "m")
        if [[ $OPTARG =~ heroku ]] 
        # TODO: pass $mode directly once there will be support for some other
        # PaaS provider
        then
          export PRODUCT=heroku
        elif [[ $OPTARG =~ openshift ]]
        then
          export PRODUCT=openshift
        fi
        ;;
      "g")
        export GEAR_PROFILE=$OPTARG
        ;;
      "s")
        export SCALABLE="-s"
        export TIMES_SCALE=$OPTARG
        ;;
      "l")
        export RH_LOGIN=$OPTARG
        ;;
      "p")
        export RH_PASSWORD=$OPTARG
        ;;
      "d")
        export BROKER=$OPTARG
        ;;
      "t")
        export REQUESTCOUNT=$OPTARG
        ;;
      "c")
        export CONCURRENCY=$OPTARG
        ;;
      "u")
        export FROM_CODE=$OPTARG
        ;;
      "e")
        variables=`echo $OPTARG | sed 's/,/ /g'`
        export ENVVARS="-e $variables"
        # Should be space delimited list of env vars
        # with their values. For example: SOMEONE=1 ANOTHER=2
        ;;
      "r")
        export REPEAT=$OPTARG
        ;;
      "x")
        export DURATION=$OPTARG
        ;;
      "h")
cat<<EOF
This is the openshift benchmarking tool. It will create one or more apps, flood
them using apache jmeter, then optionally scale them up and flood them
again. All the results will be recorded to the files in you current working
directory
Usage:
   -w Web cartridge, for example: ruby-1.9
   -a addon cartridge, like postgresql-9.2
   -m mode. possible values: heroku, openshift. Defaults to openshift, whern
   this option is not passed
   -g gear profile. possible values are: small, medium, large. Valid only for
   openshift
   -s scaling level (integer). 1 would add one gear/dyno to the app, 2 - 2
   gears, etc.
   -l login to create an app. Valid only for openshift. For heroku you need to
   have ~/.netrc with your credentials set
   -p password to create an app. Same as above
   -d destination (broker) address. Only valid for openshift
   -t number of http requests per thread
   -c thread count (Number of emulated users)
   -u the source code for the app (link to git url)
   -e environmental variables. Should be coma delimited list of env vars
   with their values. For example: SOMEONE=1,ANOTHER=2
   -r repeat r times (integer) - How many test cycles to perform.
   -x critical request duration. Integer value in milliseconds. Requests longer
   than this value would be considered failed. Default is 4000 ms (4 seconds)
   -h I don't understand anything, could you repeat once more?
Example for openshift:
  ./runbenchmark.sh -m openshift -w ruby-1.9 -a postgresql-9.2 -l ofayans@redhat.com -p redhat 
  -d openshift.redhat.com -t 200 -c 500 -r 3 -g medium
  -u https://github.com/openshift/rails-example.git -s 2 -x 2000
Example for heroku:
  ./runbenchmark.sh -m heroku -a postgresql -t 200 -c 500  -r 3 
  -u https://github.com/RailsApps/rails-bootstrap.git -x 2000
Please note: since for heroku you would usually create your app locally and
then push it to the server, there is no sense in benchmarking it: you would
measure the performance of your hardware. That's why for benchmarking heroku we
always specify the git url from which to create an application.
EOF
        exit 0
        ;;
      *)
        $0 -h
        exit 255
        ;;
    esac
  done
else
  # Otherwise all the env vars are already passed to the container, we only
  # need to fix some of them to use with the script
  # prepare .netrc file for heroku and confiure git
  git config --global user.name "Vasya Pupkin"
  git config --global user.email "cucushift.robot@example.com"

  if [[ $LOG_SERVER ]]
  then
    cat >> ~/.ssh/config<<EOF

Host $LOG_SERVER
    StrictHostKeyChecking no
    ControlMaster no
    IdentityFile ~/.ssh/id_rsa
EOF
  fi

  if [[ $HEROKU_NETRC ]]
  then
    echo -e $HEROKU_NETRC >> ~/.netrc
    chmod 0600 ~/.netrc
    cat >> ~/.ssh/config <<EOL

Host heroku.com
  StrictHostKeyChecking no
EOL
  fi
  # configure ssh to accept heroku keys

fi 

if [[ ! -f $JMETER_TESTPLAN ]]
then
  if [[ $WORKSPACE ]]
  then
    # We are under jenkins and the user forgot to submit the testplan. Most
    # probably, the testplan can be found under user's home folder
    if [[ -f docker/docker_includes/$JMETER_TESTPLAN ]]
    then
      echo "===============================================================" 
      echo "Found Jmeter testplasn in the standard folder. Copying it to workspace"
      cp docker/docker_includes/$JMETER_TESTPLAN $WORKPLACE
      echo "==============================================================="
    else
      # There was no default testplan. Exit
      echo "Please upload $JMETER_TESTPLAN"
      exit 255
    fi
  else
    echo "Please put $JMETER_TESTPLAN in your working directory"
    exit 255
  fi
fi

if [[ ! $REPEAT ]] # repeat is not set
then
  export REPEAT=1
fi

if [[ ! $DURATION ]] # set default duration
then
  DURATION=4000
fi

if [[ -z $APP_TYPE ]]
# for Heroku we do not necessarily provide app type, rather a link to git repo.
then
  APP_TYPE=dummy
fi

# now let's escape some special characters in RH_PASSWORD
#export RH_PASSWORD=$(echo $RH_PASSWORD | sed -e 's/\!/\\\!/')
for item in `seq $REPEAT`
  # Begin of iteration
do
  runme
  if [[ $? > 0 ]]
  then
    exit $?
  fi
done

# Now prepare a summary report
SUMMARY_REPORT=summary_report.txt
echo "Summary report for performance testrun against $PRODUCT" > $SUMMARY_REPORT
echo "The testrun had the following parameters:" >> $SUMMARY_REPORT
echo -e " Request count per thread: $REQUESTCOUNT\n Number of threads: $CONCURRENCY\n APP_TYPE: $APP_TYPE\n ADDON_CARTS: $ADDON_CARTS" >> $SUMMARY_REPORT 
echo -e " Critical request duration, milliseconds: $DURATION"
echo -e " All requests longer than this value are considered \"slow\""
echo -e " Test repeated $REPEAT times\n Application scaled up $TIMES_SCALE gear(s)" >> $SUMMARY_REPORT
echo -e " Git URL the app was created from:" >> $SUMMARY_REPORT
echo $FROM_CODE >> $SUMMARY_REPORT
if [[ $PRODUCT = "openshift" ]]
then
  echo " Gear profile used in apps: $GEAR_PROFILE" >> $SUMMARY_REPORT
fi
if [[ -z $FAILED ]]
then
  PYTHON_CMD="\"import sys;array = [float(l) for l in sys.stdin.read().split(' ')];print round(sum(array)/len(array), 2);\""
  echo -e "Application creation time in seconds:" >> $SUMMARY_REPORT
  app_creation_values=`awk '{print $4}' app_creation_*`
  printf -- '%s\n' "${app_creation_values[@]}" >> $SUMMARY_REPORT
  echo "Mean value:" >> $SUMMARY_REPORT
  echo $app_creation_values | eval python -c $PYTHON_CMD >> $SUMMARY_REPORT
  echo "Mean request duration before scaling (milliseconds):" >> $SUMMARY_REPORT
  values=`awk 'BEGIN {FS=","}; /text/ {print $1}' jmeter_output_before_*`
  echo $values | eval python -c $PYTHON_CMD >> $SUMMARY_REPORT 
  echo 'percentage of "slow" requests before scaling:' >> $SUMMARY_REPORT
  fast=`grep "true" $JMETER_OUTFILE | wc -l`
  slow=`grep "false" $JMETER_OUTFILE | wc -l`
  total=$(expr $fast + $slow)
  percentage=$(expr $slow \* 100 / $total)
  echo "${percentage}%" >> $SUMMARY_REPORT
  if [[ $SCALABLE ]]
  then
    for i in $(seq 1 $TIMES_SCALE)
    do
      echo "Mean request duration after $i scaling (milliseconds):" >> $SUMMARY_REPORT
      values=`awk 'BEGIN {FS=","}; /text/ {print $1}' jmeter_output_after_${i}*`
      echo $values | eval python -c $PYTHON_CMD >> $SUMMARY_REPORT
      echo "percentage of \"slow\" requests after $i scaling:" >> $SUMMARY_REPORT
      fast=`grep "true" jmeter_output_after_${i}* | wc -l`
      slow=`grep "false" jmeter_output_after_${i}* | wc -l`
      total=$(expr $fast + $slow)
      percentage=$(expr $slow \* 100 / $total)
      echo "${percentage}%" >> $SUMMARY_REPORT
    done
  fi
else
  echo "App run failed" >> $SUMMARY_REPORT
fi
# Now put everything in one place
URID=`date | md5sum | cut -c 1-20 | sed 's/[0-9]//g'`
if [[ $BUILD_NUMBER ]]
then
  DST=$BUILD_NUMBER
else
  DST=${PRODUCT}_${URID}
fi
mkdir $DST
mv app_* $DST
mv stdout_* $DST
mv jmeter_* $DST
mv $SUMMARY_REPORT $DST

for i in `ls`
# remove app folders. 
do
  if [[ -d $i ]] && [[ ! $i = $DST ]]
  then
    rm -rf $i
  fi
done
# Now archive the results so that they will not be lost at next run
tar -cvzf ${DST}.tar.gz $DST

# Now let's upload summary report and result archives to the server
if [[ $SLAVE ]] || [[ $BUILD_NUMBER ]]# We are working with rails frontend
then
  scp -P $SSH_PORT $DST/summary_report.txt $SSH_URL:~/build_results/$BUILD_NUMBER/
  scp -P $SSH_PORT ${DST}.tar.gz $SSH_URL:~/build_results/
fi
