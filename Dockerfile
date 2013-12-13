# DOCKER-VERSION 0.6.1
# VERSION        0.3

FROM ubuntu
MAINTAINER Justin Plock <jplock@gmail.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y -q openjdk-7-jre-headless wget
RUN wget -q -O /opt/zookeeper-3.4.5.tar.gz http://www.dsgnwrld.com/am/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz
RUN tar -xzf /opt/zookeeper-3.4.5.tar.gz -C /opt

# Create config directories for all three so we can choose which to run from docker run
# This is necessary because the zkServer.sh only allows you to specify the config on the command line
# The config specifies the data directory
# The myid file in the data directory specifies which instance this is
# If ZK ever allows us to specify myid on the command line, we will only need one configuration with one data directory

# Modify the stock cfg file to run a 3 node ensemble
RUN cp /opt/zookeeper-3.4.5/conf/zoo_sample.cfg /opt/zookeeper-3.4.5/conf/zoo0n.cfg
# RUN echo "server.01=zoo01:2888:3888" >> /opt/zookeeper-3.4.5/conf/zoo0n.cfg
# RUN echo "server.02=zoo02:2888:3888" >> /opt/zookeeper-3.4.5/conf/zoo0n.cfg
# RUN echo "server.03=zoo03:2888:3888" >> /opt/zookeeper-3.4.5/conf/zoo0n.cfg

# Create all three data diretories with the proper myid file contents.
RUN mkdir -p /tmp/zookeeper/data/01
RUN echo 01 > /tmp/zookeeper/data/01/myid
RUN mkdir -p /tmp/zookeeper/data/02
RUN echo 02 > /tmp/zookeeper/data/02/myid
RUN mkdir -p /tmp/zookeeper/data/03
RUN echo 03 > /tmp/zookeeper/data/03/myid

# Point each config to its respective data dir
RUN sed 's/tmp\/zookeeper/tmp\/zookeeper\/data\/01/g' /opt/zookeeper-3.4.5/conf/zoo0n.cfg > /opt/zookeeper-3.4.5/conf/zoo01.cfg
RUN sed 's/tmp\/zookeeper/tmp\/zookeeper\/data\/02/g' /opt/zookeeper-3.4.5/conf/zoo0n.cfg > /opt/zookeeper-3.4.5/conf/zoo02.cfg
RUN sed 's/tmp\/zookeeper/tmp\/zookeeper\/data\/03/g' /opt/zookeeper-3.4.5/conf/zoo0n.cfg > /opt/zookeeper-3.4.5/conf/zoo03.cfg

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

EXPOSE 2181 2888 3888

ENTRYPOINT ["/opt/zookeeper-3.4.5/bin/zkServer.sh"]
# CMD ["start-foreground"]
