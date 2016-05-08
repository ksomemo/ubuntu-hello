# Pull base image.
FROM ubuntu:16.04

MAINTAINER ksomemo

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

# Ruby dependencies
RUN \
  apt-get update && \
  apt-get install -y \
    git tar gcc openssl \
    libssl-dev zlib1g-dev libyaml-dev \
    libreadline-dev libffi-dev libxml2-dev libxslt-dev

# Ruby
RUN git clone https://github.com/rbenv/ruby-build.git
RUN ./ruby-build/install.sh
RUN  ruby-build 2.3.1 /usr/local
  #apt-get update && \
  #apt-get install -y ruby2.3 ruby2.3-dev

# Install Nginx.
RUN \
  add-apt-repository -y ppa:nginx/stable && \
  apt-get update && \
  apt-get install -y nginx && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# serverspec
# Add files.
ADD .gemrc ~/.gemrc
ADD Gemfile Gemfile

RUN gem update --system
RUN gem install bundler
RUN bundle install
#  bundle exec serverspec-init

# Set environment variables.
ENV HOME /root

# Define mountable directories.
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# Define working directory.
WORKDIR /etc/nginx

# Expose ports.
EXPOSE 80
EXPOSE 443

# Define default command.
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

