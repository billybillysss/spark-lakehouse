#!/bin/bash

# Function to ensure correct permissions for password file
ensure_passwd_file_permissions() {
    local passwd_file="$1"
    if [ -f "$passwd_file" ]; then
        # Change ownership to sparker 
        sudo chown -R sparker:sparker /home/sparker/.passwd-s3fs

        # Set permissions to 600
        sudo chmod 600 "$passwd_file"
        echo "Set permissions 600 and ownership for $passwd_file"
    else
        echo "Warning: Password file $passwd_file does not exist"
        return 1
    fi
}

# Function to mount a single bucket
mount_s3fs() {
    local bucket="$1"
    local mount_point="$2"
    local minio_url="$3"
    local passwd_file="$4"
    local debug_level="$5"

    # Ensure password file has correct permissions
    if ! ensure_passwd_file_permissions "$passwd_file"; then
        echo "Failed to set correct permissions for $passwd_file. Skipping mount for $bucket"
        return 1
    fi

    # Create mount point if it doesn't exist
    if [ ! -d "$mount_point" ]; then
        sudo mkdir -p "$mount_point"
        sudo chown -R sparker:sparker "$mount_point"
        echo "Created directory: $mount_point"
    fi

    s3fs "$bucket" "$mount_point" \
        -o passwd_file="$passwd_file" \
        -o url="$minio_url" \
        -o use_path_request_style \
        -o dbglevel="$debug_level" \
        -o curldbg &

    echo "Mounted $bucket to $mount_point"
}

# Function to mount all buckets from YAML config
mount_all_buckets() {
    local config_file="$1"
    local buckets_count=$(yq e '.buckets | length' "$config_file")
    local default_minio_url=$(yq e '.default_minio_url' "$config_file")
    local default_passwd_file=$(yq e '.default_passwd_file' "$config_file")

    # Ensure default password file has correct permissions
    ensure_passwd_file_permissions "$default_passwd_file"

    for ((i=0; i<$buckets_count; i++)); do
        local bucket=$(yq e ".buckets[$i].name" "$config_file")
        local mount_point=$(yq e ".buckets[$i].mount_point" "$config_file")
        local minio_url=$(yq e ".buckets[$i].minio_url // \"$default_minio_url\"" "$config_file")
        local passwd_file=$(yq e ".buckets[$i].passwd_file // \"$default_passwd_file\"" "$config_file")
        local debug_level=$(yq e ".buckets[$i].debug_level // \"info\"" "$config_file")

        mount_s3fs "$bucket" "$mount_point" "$minio_url" "$passwd_file" "$debug_level"
    done
}


# Function to start the Spark master
start_master() {
  echo "Waiting for S3 buckets to be mounted..."
  mount_all_buckets /mnt/mount-conf.yml

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
  tail -f /dev/null
else
  echo "SPARK_ROLE environment variable not set or invalid. Please set it to 'master' or 'worker'."
  exit 1
fi