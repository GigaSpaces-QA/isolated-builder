FROM ubuntu

#Replace dash with bash

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

MAINTAINER Barak Bar Orion <barak.bar@gmail.com>

# Install Java.

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

RUN apt-get install -y oracle-java8-installer ca-certificates


ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


RUN apt-get -y install wget

RUN wget --no-verbose -O /tmp/apache-maven-3.0.5.tar.gz \
    http://archive.apache.org/dist/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz

# stop building if md5sum does not match
RUN echo "94c51f0dd139b4b8549204d0605a5859  /tmp/apache-maven-3.0.5.tar.gz" | \
    md5sum -c

# install in /opt/maven
RUN mkdir -p /opt/maven

RUN tar xzf /tmp/apache-maven-3.0.5.tar.gz --strip-components=1 \
    -C /opt/maven

RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.0.5.tar.gz


RUN sudo apt-get -y install git

WORKDIR /tmp
RUN wget --no-verbose -O /tmp/apache-ant-1.8.4-bin.tar.gz http://archive.apache.org/dist/ant/binaries/apache-ant-1.8.4-bin.tar.gz


RUN tar -xzf /tmp/apache-ant-1.8.4-bin.tar.gz && \
  mv /tmp/apache-ant-1.8.4 /opt/apache-ant

RUN rm -rf /tmp/apache-ant-1.8.4-bin.tar.gz

# install svn to checkout TFRepository
RUN apt-get update && apt-get install -y subversion

ENV ANT_HOME /opt/apache-ant
ENV PATH $PATH:$ANT_HOME/bin

ADD empty.zip /opt/empty.zip
ADD build.xml /opt/empty_build.xml

RUN mkdir  /root/.ssh
ADD ssh/* /root/.ssh/

VOLUME ["/sources"]
VOLUME ["/root/counter"]

ENV M2_HOME /opt/maven/

WORKDIR /sources

ADD xap.sh /root/xap.sh
ADD counter.sh /root/counter.sh
ADD counter.tmp /root/counter.tmp

WORKDIR /root

CMD ["./xap.sh"]

#CMD ["bash"]

