FROM phusion/baseimage:0.9.22
MAINTAINER Tatsuya Kawano

ENV HOME /root

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y language-pack-en
ENV LANG en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN (mv /etc/localtime /etc/localtime.org && \
     ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime)

RUN (apt-get update && \
     DEBIAN_FRONTEND=noninteractive \
     apt-get install -y build-essential software-properties-common \
                        zlib1g-dev libssl-dev libreadline-dev libyaml-dev \
                        libxml2-dev libxslt-dev \
                        git byobu wget curl unzip tree \
                        python)

# Install WebVim dependencies
RUN (DEBIAN_FRONTEND=noninteractive \
	apt-get install -y vim vim-runtime && \
	apt-get install -y build-essential cmake python-dev exuberant-ctags)

# Install nodejs
#RUN (curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && \
#	apt-get install -y nodejs)
RUN (curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
	apt-get install -y nodejs)

# Add nodejs packages( some common pacakges )
RUN (npm install -g eslint csslint jshint jsonlint handlebars)

# Add a non-root user
RUN (useradd -m -d /home/docker -s /bin/bash docker && \
     echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers)

USER docker
ENV HOME /home/docker
WORKDIR /home/docker

# for user docker: Install WebVim
RUN (cd /home/docker && \
	git clone https://github.com/krampstudio/webvim.git ~/.vim &&\
	ln -s ~/.vim/.vimrc ~/.vimrc &&\
	ln -s ~/.vim/.tern-project ~/.tern-project)

# trick to install vim with command ( without interactive mode )
# RUN (echo |echo | vim +PlugInstall +qall &>/dev/null)
RUN (echo | vim +PlugInstall +qall && echo 0)

# trick to invoke select "1" for WebVim installation interactive mode 
#RUN (echo :q | echo 1 | vim &&\
#		echo "done install webvim")

USER root
ADD service /etc/service
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
