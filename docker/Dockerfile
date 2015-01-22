FROM fedora
RUN yum install -y ruby rubygems make gcc tar ip-utils
RUN yum install -y ruby-devel bindutils which check git vim
RUN yum install -y java-1.7.0-openjdk-headless wget openssh-server
#RUN useradd -m -g sshd robot
#RUN sed -i "s/.*requiretty/#Defaults requiretty/" /etc/sudoers
#RUN echo 'robot ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#RUN sed -ir 's/.*ssh_host_ecdsa_key//' /etc/ssh/sshd_config
#RUN chgrp sshd /etc/ssh
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
ADD .ssh /root/.ssh
#ADD docker_includes/.netrc /home/robot/.netrc
RUN chown -R root /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/config
#RUN chown robot /home/robot/.netrc
ENV HOME /root
WORKDIR /root
RUN wget http://mirror.hosting90.cz/apache//jmeter/binaries/apache-jmeter-2.11.tgz
RUN tar -xzf apache*
RUN mv `ls | grep apache | head -n 1` jmeter
ENV GEM_HOME $HOME/.gem
ENV PATH $PATH:$GEM_HOME/bin:$HOME/jmeter/bin
RUN gem install rhc heroku rails
RUN git config --global user.name "Vasya Pupkin"
RUN git config --global user.email "cucushift.robot@example.com"
RUN git config --global push.default matching
ADD docker_includes/Myplan.jmx /root/Myplan.jmx
ADD docker_includes/runbenchmark.sh /root/runbenchmark.sh
RUN chmod +x /root/runbenchmark.sh
CMD /bin/bash
