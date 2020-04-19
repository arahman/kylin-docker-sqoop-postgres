Copied from https://github.com/apache/kylin/tree/master/docker.

In order to allow users to easily try Kylin, and to facilitate developers to verify and debug after modifying the source code. We provide the all-in-one Kylin docker image. In this image, each service that Kylin relies on is properly installed and deployed, including:

- Jdk 1.8
- Hadoop 2.7.0
- Hive 1.2.1
- Hbase 1.1.2
- Spark 2.3.1
- Zookeeper 3.4.6
- Kafka 1.1.1
- MySQL 5.1.73
- Maven 3.6.1
- Sqoop 1.4.7
- PostgreSQL 42.2.12 (JDBC driver)

## Quickly try Kylin with pre-built images

Build the docker images by running

```
./build_image.sh
```

After the build is successful, execute the following command with the correct database details to start the container:

```
docker run -d \
--name kylin \
-v /tmp/kylin:/opt/kylin \
-m 8G \
-p 7070:7070 \
-p 8088:8088 \
-p 50070:50070 \
-p 8032:8032 \
-p 8042:8042 \
-p 16010:16010 \
-e JDBC_URL='jdbc:postgresql://localhost:5437/mydb' \
-e JDBC_USER='dbuser' \
-e JDBC_PASSWORD='dbpassword' \
apache-kylin-standalone-sqoop
```

The following in the above command are environment variables that you should replace with your environment specific values:

```
-e JDBC_URL='jdbc:postgresql://localhost:5437/mydb' \
-e JDBC_USER='dbuser' \
-e JDBC_PASSWORD='dbpassword' \
```


The following services are automatically started when the container starts: 

- NameNode, DataNode
- ResourceManager, NodeManager
- HBase
- Kafka
- Kylin

and run automatically `$KYLIN_HOME/bin/sample.sh `, create a kylin_streaming_topic topic in Kafka and continue to send data to this topic. This is to let the users start the container and then experience the batch and streaming way to build the cube and query.

After the container is started, we can enter the container through the `docker exec` command. Of course, since we have mapped the specified port in the container to the local port, we can open the pages of each service directly in the native browser, such as: 

- Kylin Web UI: [http://127.0.0.1:7070/kylin/login](http://127.0.0.1:7070/kylin/login)
- HDFS NameNode Web UI: [http://127.0.0.1:50070](http://127.0.0.1:50070/)
- YARN ResourceManager Web UI: [http://127.0.0.1:8088](http://127.0.0.1:8088/)
- HBase Web UI: [http://127.0.0.1:16010](http://127.0.0.1:16010/)

In the container, the relevant environment variables are as follows: 

```
JAVA_HOME=/home/admin/jdk1.8.0_141
HADOOP_HOME=/home/admin/hadoop-2.7.0
KAFKA_HOME=/home/admin/kafka_2.11-1.1.1
SPARK_HOME=/home/admin/spark-2.3.1-bin-hadoop2.6
HBASE_HOME=/home/admin/hbase-1.1.2
HIVE_HOME=/home/admin/apache-hive-1.2.1-bin
SQOOP_HOME=/home/admin/sqoop-1.4.7.bin__hadoop-2.6.0
```

After about 1 to 2 minutes, all the services should be started. At the Kylin login page (http://127.0.0.1:7070/kylin), enter ADMIN:KYLIN to login, select the "learn_kylin" project. In the "Model" tab, you should be able to see two sample cubes: "kylin_sales_cube" and "kylin_streaming_cube". If they don't appear, go to the "System" tab, and then click "Reload metadata", they should be loaded.

In the "Model" tab, you can click "Build" to build the two sample cubes. After the cubes be built, try some queries in the "Insight" tab.

If you want to login into the Docker container, run "docker ps" to get the container id:

```
> docker ps
CONTAINER ID        IMAGE                                              COMMAND                  CREATED             STATUS              PORTS                                                                                                                                                NAMES
3a0213a540fd        apache-kylin-standalone-sqoop               "/home/admin/entrypo…"   11 hours ago        Up 11 hours         0.0.0.0:7070->7070/tcp, 0.0.0.0:8032->8032/tcp, 0.0.0.0:8042->8042/tcp, 0.0.0.0:8088->8088/tcp, 0.0.0.0:16010->16010/tcp, 0.0.0.0:50070->50070/tcp   kylin
```

Then run "docker -it <container id> bash" to login it with bash:

```
> docker exec -it kylin bash
[root@c15d10ff6bf1 admin]# ls
apache-hive-1.2.1-bin                  apache-maven-3.6.1  first_run     hbase-1.1.2   kafka_2.11-1.1.1
apache-kylin-3.0.0-alpha2-bin-hbase1x  entrypoint.sh       hadoop-2.7.0  jdk1.8.0_141  spark-2.3.1-bin-hadoop2.6
```

## Build Docker image in local

You can build the docker image by yourself with the provided Dockerfile. Here we separate the scripts into several files:

- Dockerfile_hadoop: build a Hadoop image with Hadoop/Hive/HBase/Spark/Kafka and other components installed;
- Dockerfile: based on the Hadoop image, download Kylin from apache website and then start all services.
- Dockerfile_dev: similar with "Dockerfile", instead of downloading the released version, it copies local built Kylin package to the image.

Others:
- conf/: the Hadoop/HBase/Hive/Maven configuration files for this docker; Will copy them into the image on 'docker build';
- entrypoint.sh: the entrypoint script, which will start all the services;

The build is very simple:

```
./build_image.sh
```
The script will build the Hadoop image first, and then build Kylin image based on it. Depends on the network bandwidth, the first time may take a while.

## Customize the Docker image

You can customize these scripts and Dockerfile to make your image.

For example, if you made some code change in Kylin, you can make a new binary package in local with:

```
./build/scripts/package.sh
```

The new package is generated in "dist/" folder; Copy it to the "docker" folder:

```
cp ./dist/apache-kylin-3.1.0-SNAPSHOT-bin.tar.gz ./docker
```

Use the "Dockerfile_dev" file to build:

```
docker build -f Dockerfile_dev -t apache-kylin-standalone:test .

```
