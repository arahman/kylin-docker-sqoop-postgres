#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Docker image for apache kylin, based on the Hadoop image
FROM hadoop2.7-all-in-one

ENV KYLIN_VERSION 3.0.1
ENV KYLIN_HOME /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x

ENV SQOOP_HOME /home/admin/sqoop-1.4.7.bin__hadoop-2.6.0
ENV HCAT_HOME /home/admin/apache-hive-1.2.1-bin/hcatalog

# Download released Kylin
RUN wget https://archive.apache.org/dist/kylin/apache-kylin-$KYLIN_VERSION/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz \
    && tar -zxvf /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz \
    && rm -f /home/admin/apache-kylin-$KYLIN_VERSION-bin-hbase1x.tar.gz

RUN echo "kylin.engine.spark-conf.spark.executor.memory=1G" >> $KYLIN_HOME/conf/kylin.properties \
    && echo "kylin.engine.spark-conf-mergedict.spark.executor.memory=1.5G" >>  $KYLIN_HOME/conf/kylin.properties \
    && echo "kylin.engine.livy-conf.livy-url=http://127.0.0.1:8998" >>  $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.livy-conf.livy-key.file=hdfs://localhost:9000/kylin/livy/kylin-job-$KYLIN_VERSION.jar >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.livy-conf.livy-arr.jars=hdfs://localhost:9000/kylin/livy/hbase-client-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-common-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-hadoop-compat-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-hadoop2-compat-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/hbase-server-$HBASE_VERSION.jar,hdfs://localhost:9000/kylin/livy/htrace-core-*-incubating.jar,hdfs://localhost:9000/kylin/livy/metrics-core-*.jar >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.source.hive.quote-enabled=false >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.eventLog.dir=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.engine.spark-conf.spark.history.fs.logDirectory=hdfs://localhost:9000/kylin/spark-history >> $KYLIN_HOME/conf/kylin.properties \
    && echo kylin.source.hive.redistribute-flat-table=false >> $KYLIN_HOME/conf/kylin.properties

# Download released Sqoop
RUN wget https://downloads.apache.org/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz \
    && tar -zxvf /home/admin/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz \
    && rm -f /home/admin/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz \
    && cp /home/admin/sqoop-1.4.7.bin__hadoop-2.6.0/sqoop-1.4.7.jar /home/admin/sqoop-1.4.7.bin__hadoop-2.6.0/lib/ \
    && wget https://jdbc.postgresql.org/download/postgresql-42.2.12.jar \
    && cp postgresql-42.2.12.jar $KYLIN_HOME/lib/ \
    && cp postgresql-42.2.12.jar /home/admin/sqoop-1.4.7.bin__hadoop-2.6.0/lib/


COPY ./entrypoint.sh /home/admin/entrypoint.sh
RUN chmod u+x /home/admin/entrypoint.sh

ENTRYPOINT ["/home/admin/entrypoint.sh"]
