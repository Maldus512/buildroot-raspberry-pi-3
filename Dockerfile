FROM buildroot/base:latest
USER root
RUN apt-get update
RUN apt-get -y install python3
