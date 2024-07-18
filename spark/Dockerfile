FROM python:3.11.9-slim-bookworm

USER root
# Enable noninteractive package installation
ENV DEBIAN_FRONTEND=noninteractive

# Spark dependencies
ENV APACHE_SPARK_VERSION=3.5.1 \
    HADOOP_VERSION=3 \
    HADOOP_AWS_VERSION=3.3.4 \
    HADOOP_COMMON_VERSION=3.3.4 \
    AWS_JAVA_SDK_VERSION=1.12.262 \
    APACHE_LIVY_VERSION=0.8.0 \
    SCALA_VERSION=2.12 \
    DELTA_SPARK_VERSION=3.2.0 \
    DELTA_STORAGE_VERSION=3.2.0

WORKDIR /tmp

# Install Python dependencies
ADD requirements.txt requirements.txt
RUN pip3 install --upgrade pip &&  pip3 install -r requirements.txt

# Update and install necessary packages
RUN apt-get update && apt-get install -y wget gnupg2

# Add the Debian sid repository
RUN echo "deb http://deb.debian.org/debian/ sid main" >> /etc/apt/sources.list

# Install Python 3.11
RUN apt-get update -y && \
    apt-get install -y \
    openjdk-8-jdk \
    bash \
    unzip \
    s3fs \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin
RUN echo $JAVA_HOME

#Install yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq
    
# Install Apache Livy
RUN wget -q $(wget -qO- https://www.apache.org/dyn/closer.lua/incubator/livy/${APACHE_LIVY_VERSION}-incubating/apache-livy-${APACHE_LIVY_VERSION}-incubating_${SCALA_VERSION}-bin.zip\?as_json | \
    python -c "import sys, json; content=json.load(sys.stdin); print(content['preferred']+content['path_info'])") && \
    echo "467c977d4c72c67c2f7fa08134b9d0eeb5123b843cba67b5840620dba521e7f8cd532e7ab00b97b3e73cd737658f8937b0fea6e8179242a5f1a6ce29ba7b1d4f  apache-livy-${APACHE_LIVY_VERSION}-incubating_${SCALA_VERSION}-bin.zip" | sha512sum -c - && \
    unzip "apache-livy-${APACHE_LIVY_VERSION}-incubating_${SCALA_VERSION}-bin.zip" -d /opt  && \
    rm "apache-livy-${APACHE_LIVY_VERSION}-incubating_${SCALA_VERSION}-bin.zip"

# Install Spark
RUN wget -q $(wget -qO- https://www.apache.org/dyn/closer.lua/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz\?as_json | \
    python -c "import sys, json; content=json.load(sys.stdin); print(content['preferred']+content['path_info'])") && \
    echo "3d8e3f082c602027d540771e9eba9987f8ea955e978afc29e1349eb6e3f9fe32543e3d3de52dff048ebbd789730454c96447c86ff5b60a98d72620a0f082b355 *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
    tar xzf "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -C /opt --owner root --group root --no-same-owner && \
    rm "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"


WORKDIR /opt

# Set SPARK_HOME & Livy_HOME
RUN ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" spark && \
    ln -s "apache-livy-${APACHE_LIVY_VERSION}-incubating_${SCALA_VERSION}-bin" livy

WORKDIR /opt/spark/jars

# Download the hadoop-aws JAR and aws-java-sdk-bundle JAR using wget
RUN wget -O hadoop-aws-${HADOOP_AWS_VERSION}.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar
RUN wget -O aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar
RUN wget -O hadoop-common-${HADOOP_COMMON_VERSION}.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/${HADOOP_COMMON_VERSION}/hadoop-common-${HADOOP_COMMON_VERSION}.jar
RUN wget -O delta-spark_${SCALA_VERSION}-${DELTA_SPARK_VERSION}.jar https://repo1.maven.org/maven2/io/delta/delta-spark_${SCALA_VERSION}/${DELTA_SPARK_VERSION}/delta-spark_${SCALA_VERSION}-${DELTA_SPARK_VERSION}.jar
RUN wget -O delta-storage-${DELTA_STORAGE_VERSION}.jar https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_STORAGE_VERSION}/delta-storage-${DELTA_STORAGE_VERSION}.jar
RUN wget -O spark-hadoop-cloud_${SCALA_VERSION}-${APACHE_SPARK_VERSION}.jar https://repo1.maven.org/maven2/org/apache/spark/spark-hadoop-cloud_${SCALA_VERSION}/${APACHE_SPARK_VERSION}/spark-hadoop-cloud_${SCALA_VERSION}-${APACHE_SPARK_VERSION}.jar

# Configure Spark
ENV SPARK_HOME=/opt/spark \
    LIVY_HOME=/opt/livy
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9-src.zip \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH=$PATH:$SPARK_HOME/bin \
    PATH=$PATH:$SPARK_HOME/sbin

# Create Spark history and Livy logs directory
RUN mkdir -p /opt/spark/history && \
    mkdir -p /opt/livy/logs

# Add sparker user
RUN useradd -m -s /bin/bash sparker && \
    usermod -aG root sparker && \
    usermod -aG users sparker

RUN chown -R sparker:sparker /opt && \
    chmod -R 775 /opt

RUN chown -R sparker:sparker /mnt
RUN usermod -aG sudo sparker && \
    echo "sparker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/sparker && \
    chmod 0440 /etc/sudoers.d/sparker

USER sparker
WORKDIR /home/sparker

ADD conf/.passwd-s3fs /home/sparker/.passwd-s3fs
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
