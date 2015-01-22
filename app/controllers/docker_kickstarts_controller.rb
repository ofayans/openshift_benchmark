require "docker"

class DockerKickstartsController < ApplicationController
  def initialize(run, dockerservers_attributes, password, heroku_netrc)
    @run = run
    @dockerservers_attributes = dockerservers_attributes
    @password = password
    @heroku_netrc = heroku_netrc

  end


  def docker_kickstart
    #Configure the docker parameters to pass through the remote API. These will form a HTTP header.
    #
    #For each docker server provided, create a desired amount of containers
    #based on an image id specified for each particular server
#    logserver = Logserver.find_by(:id => @run.logserver_id).hostname
#    logserver_username = Logserver.find_by(:id => @run.logserver_id).username
    global_counter = 0 # count total amount of containers: needed for analyzing exit status of all logs
    @dockerservers_attributes.each do |key, value|
      @run.envvars.gsub!(",", " ") # standartize the environment variable format
      product = Product.find_by(:id=>@run.product_id).name
      gear_profile = GearProfile.find_by(:id => @run.gear_profile_id).name
      begin
        app_type = AppType.find_by(:id => @run.app_type_id).name
      rescue NoMethodError
        if @run.from_code.empty?
          raise "Either from_code or app_type should be declared"
        else
          app_type = "dummy" # will be ignored by the app_creation process for heroku
        end
      end
      addon_cart = Addon.find_by(:id => @run.addon_id).name
      docker_opts = {}
      docker_opts['Env'] = []
      docker_opts['Env'] << "RH_LOGIN=#{@run.login}"
      docker_opts['Env'] << "RH_PASSWORD=#{@password}"
      docker_opts['Env'] << "BROKER=#{@run.broker}"
      if @heroku_netrc # is passed
        docker_opts['Env'] << "HEROKU_NETRC=#{@heroku_netrc}"
      end
      docker_opts['Env'] << "PRODUCT=#{product}"
      docker_opts['Env'] << "APP_TYPE=#{app_type}"
      docker_opts['Env'] << "ADDON_CARTS=#{addon_cart}"
      docker_opts['Env'] << "GEAR_PROFILE=#{gear_profile}"
      if not @run.envvars.empty?
        docker_opts['Env'] << "ENVVARS=#{@run.envvars}"
      end
      if @run.scale and @run.scale > 0
        docker_opts['Env'] << "SCALABLE=-s"
        docker_opts['Env'] << "TIMES_SCALE=#{@run.scale}"
      end
      if not @run.from_code.empty?
        docker_opts['Env'] << "FROM_CODE=#{@run.from_code}"
      end
#      docker_opts['Env'] << "DEBUG=#{@run.debug}"
      docker_opts['Env'] << "BUILD_NUMBER=#{@run.id}"
      docker_opts['Image'] = value["image_id"]
      docker_opts['Env'] << "LOG_SERVER=#{ENV['OPENSHIFT_GEAR_DNS']}"
      docker_opts['Env'] << "LOG_SERVER_USERNAME=#{ENV['OPENSHIFT_APP_UUID']}"
      docker_opts['Env'] << "DURATION=#{@run.duration_threshold}"
      docker_opts['Env'] << "REQUESTCOUNT=#{@run.requestcount}"
      docker_opts['Env'] << "CONCURRENCY=#{@run.concurrency}"
      docker_opts['Env'] << "SLAVE=true" # Tell the slave to take all params from env variables
      if ENV['SSH_PORT']
        docker_opts['Env'] << "SSH_PORT=#{ENV['SSH_PORT']}"
      else
        docker_opts['Env'] << "SSH_PORT=22"
      end
      docker_opts['Cmd'] = ['sh','./runbenchmark.sh']
#      docker_opts['Cmd'] = ['/bin/bash']
      Docker.url = Dockerserver.find_by(:id => value["dockerserver_id"]).url
      containers = []
      value["jobcount"].to_i.times do |local_counter|
        containers << Docker::Container.create(docker_opts)
      end
      #Create and run the new container
      #Capture and display the output of the run.
      local_counter = containers.size
      global_counter += local_counter
      fork do
        containers.each do |container|
          begin
            # TODO: implement debug mode to keep track of realtime output
            container.start
            # Now give it maximum 6 hours to run
            container.wait(21600)
          rescue Exception => e
            puts e.message
          ensure
          #Once the run is complete, clean up and remove the containers to free up space.
            container.tap(&:stop)
            container.remove
          end
        end
      end
    end
    return global_counter
  end
end
