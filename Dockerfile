FROM ubuntu:trusty

# Update base image
# Update again in case package manager was updated.
RUN     apt-get update

# Install requirements
RUN apt-get install -y \
            git \
            nginx \
            php5-cli 

RUN apt-get install -y \
            php5-fpm \
            php5-mysql \
	    php5-gd \
            php5-curl 
#            python-pygments \

# Send email
RUN apt-get install -y postfix 
RUN apt-get install -y openssh-server

# Set up the Phabricator code base
RUN mkdir /var/phabricator
#USER git
WORKDIR /var/phabricator
RUN git clone http://github.com/phacility/libphutil.git
RUN git clone http://github.com/phacility/arcanist.git
RUN git clone http://github.com/phacility/phabricator.git

# Expose Nginx on port 80 and 443
EXPOSE 80
#EXPOSE 443

# Add files
#ADD nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
COPY phabricator.conf /etc/nginx/sites-enabled/phabricator.conf
# Add user
RUN echo "phd:x:1000:1000::/nonexistent:/bin/bash" >> /etc/passwd
RUN echo "git:x:2000:2000::/var/repo:/bin/bash" >> /etc/passwd
RUN echo "git ALL=(phd) SETENV: NOPASSWD: /usr/bin/git-upload-pack, /usr/bin/git-receive-pack" >> /etc/sudoers
RUN mkdir /var/run/sshd 

# Expose SSH port 24 (Git SSH will be on 22, regular SSH on 24)
#EXPOSE 24
# Move the default SSH to port 24
#RUN echo "Port 24" >> /etc/ssh/sshd_config

# Configure Phabricator SSH service
COPY sshd_config.phabricator /etc/ssh/sshd_config.phabricator
COPY phabricator-ssh-hook.sh /phabricator-ssh-hook.sh

WORKDIR /var
RUN mkdir repo phabricator_files && \
	chown git repo && \
	chown www-data phabricator_files

#RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY test_dbms_started.sh /test_dbms_started.sh 
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
