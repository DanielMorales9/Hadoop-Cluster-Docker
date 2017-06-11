FROM tenentedan9/ubuntu_jdk-7:latest

ARG HADOOP_VERSION=2.8.0
ARG SOURCE=http://it.apache.contactlab.it/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

USER root

WORKDIR /usr/local/

RUN wget $SOURCE && \
    tar -xzvf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION hadoop && \
    rm hadoop-$HADOOP_VERSION.tar.gz

WORKDIR /
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/
RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/entrypoint.sh ~/entrypoint.sh
RUN chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x ~/entrypoint.sh

RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

EXPOSE 50070 9001 8088

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD ["sh", "-c", "~/entrypoint.sh"]
