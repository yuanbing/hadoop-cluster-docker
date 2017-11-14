FROM ubuntu:latest

MAINTAINER Bing Yuan <bing.yuan@huawei.com>

WORKDIR /root

# install openssh-server, openjdk8 and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget

ARG HADOOP_VERSION=3.0.0-beta1
ARG HADOOP_DIST_URL=https://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz

# install hadoop
# if the hadoop dist package has already been downloaded, comment out this section and uncomment the following section
RUN wget ${HADOOP_DIST_URL} && \
    tar -xzvf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /usr/local/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# The following section uses the already downloaded hadoop dist package
#COPY $HADOOP_BINARY_PACKAGE .
#RUN tar -xzvf $HADOOP_BINARY_PACKAGE && \
#    mv $HADOOP_TMP_DIR /usr/local/hadoop && \
#    rm $HADOOP_BINARY_PACKAGE

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin 

# HDFS related environment variables
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_DATANODE_SECURE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root

# YARN related environment variables
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir ${HADOOP_HOME}/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml && \
    mv /tmp/workers ${HADOOP_HOME}/etc/hadoop/workers && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x ${HADOOP_HOME}/sbin/start-dfs.sh && \
    chmod +x ${HADOOP_HOME}/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

