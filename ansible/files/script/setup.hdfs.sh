#!/bin/bash

export HADOOP_HOME=/etc/hadoop
export PATH=$PATH:$HADOOP_HOME/bin

kinit -k -t /etc/nn.service.keytab nn/my.example.com@EXAMPLE.COM

# /user
hdfs dfs -mkdir /user
hdfs dfs -chown hdfs:hadoop /user
hdfs dfs -chmod 755 /user
# /user/hdfs
hdfs dfs -mkdir /user/hdfs
hdfs dfs -chown hdfs:hadoop /user/hdfs
hdfs dfs -chmod 700 /user/hdfs
# /user/yarn
hdfs dfs -mkdir /user/yarn
hdfs dfs -chown yarn:hadoop /user/yarn
hdfs dfs -chmod 700 /user/yarn
# /user/mapred
hdfs dfs -mkdir /user/mapred
hdfs dfs -chown mapred:hadoop /user/mapred
hdfs dfs -chmod 700 /user/mapred

# /tmp
hdfs dfs -mkdir /tmp
hdfs dfs -chown hdfs:hadoop /tmp
hdfs dfs -chmod 1777 /tmp

# yarn.nodemanager.remote-app-log-dir
hdfs dfs -mkdir /tmp/logs
hdfs dfs -chown yarn:hadoop /tmp/logs
hdfs dfs -chmod 1777 /tmp/logs
# mapreduce.jobhistory
hdfs dfs -mkdir /mr-history
hdfs dfs -chown mapred:hadoop /mr-history
hdfs dfs -chmod 1777 /mr-history
# mapreduce.jobhistory.intermediate-done-dir
hdfs dfs -mkdir /mr-history/tmp
hdfs dfs -chown mapred:hadoop /mr-history/tmp
hdfs dfs -chmod 1777 /mr-history/tmp
# mapreduce.jobhistory.done-dir
hdfs dfs -mkdir /mr-history/done
hdfs dfs -chown mapred:hadoop /mr-history/done
hdfs dfs -chmod 750 /mr-history/done
