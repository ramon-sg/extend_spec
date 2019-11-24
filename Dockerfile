FROM qixtand/debian-stretch-ruby:2.4.5

ARG CRYSTAL_URL=https://github.com/crystal-lang/crystal/releases/download/0.30.1/crystal_0.30.1-1_amd64.deb

# Crystal
RUN apt-get update
RUN apt-get -y install wget libcryptsetup4

# pkill
RUN apt-get -y install procps

RUN wget -O ./crystal.deb -q ${CRYSTAL_URL}
RUN apt -y install ./crystal.deb
RUN rm ./crystal.deb

# DEV
RUN gem install guard-exec

ADD . /src
WORKDIR /src