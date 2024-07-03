#!/bin/bash

# Function to start the Spark master
start_master() {
  echo "Starting History Server..."
  start-history-server.sh

  # echo "Starting Livy Server..."
  # $LIVY_HOME/bin/livy-server start

  echo "Starting Spark Connect Server..."
  $SPARK_HOME/sbin/start-connect-server.sh --packages org.apache.spark:spark-connect_2.12:3.5.1

  # echo "Starting thrift server..."
  # $SPARK_HOME/sbin/start-thriftserver.sh --packages org.apache.spark:spark-thriftserver_2.12:3.5.1 --master spark://master:7077

  echo "Starting Spark Master..."
  $SPARK_HOME/bin/spark-class org.apache.spark.deploy.master.Master --ip 0.0.0.0 --port 7077 --webui-port 8080


}

# Function to start the Spark worker
start_worker() {
  echo "Waiting for Spark Master to be ready..."
  while ! getent hosts master; do
    echo "Spark Master not ready, sleeping..."
    sleep 5
  done

  echo "Starting Spark Worker..."
  $SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker spark://master:7077 --webui-port 8081
}

start_thrift_server() {
  echo "Starting thrift server..."
  $SPARK_HOME/sbin/start-thriftserver.sh --driver-java-options '-Dhive.metastore.uris=thrift://metastore:9083' --master spark://master:7077 
}


# Check the SPARK_ROLE environment variable to determine which role to start
if [ "$SPARK_ROLE" == "master" ]; then
  start_master
elif [ "$SPARK_ROLE" == "worker" ]; then
  start_worker
elif [ "$SPARK_ROLE" == "thriftserver" ]; then
  sleep 10
  start_thrift_server
  && tail -f /dev/null
else
  echo "SPARK_ROLE environment variable not set or invalid. Please set it to 'master' or 'worker'."
  exit 1
fi