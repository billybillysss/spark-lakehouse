ARG kyuubi_uid=10009

FROM apache/kyuubi:1.9.1-spark

USER root

ENV SCALA_VERSION=2.12 \
    HADOOP_AWS_VERSION=3.3.6 \
    HADOOP_COMMON_VERSION=3.3.6 \
    AWS_JAVA_SDK_VERSION=1.12.362 \
    DELTA_SPARK_VERSION=3.2.0 \
    DELTA_STORAGE_VERSION=3.2.0 \
    KYUUBI_VERSION=1.9.1

WORKDIR /opt/kyuubi/jars

# Download the hadoop-aws JAR, aws-java-sdk-bundle JAR, hadoop-common JAR and delta-spark JAR using wget
RUN wget -O hadoop-aws-${HADOOP_AWS_VERSION}.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar
RUN wget -O aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar
RUN wget -O hadoop-common-${HADOOP_COMMON_VERSION}.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/${HADOOP_COMMON_VERSION}/hadoop-common-${HADOOP_COMMON_VERSION}.jar
RUN wget -O delta-spark_${SCALA_VERSION}-${DELTA_SPARK_VERSION}.jar https://repo1.maven.org/maven2/io/delta/delta-spark_${SCALA_VERSION}/${DELTA_SPARK_VERSION}/delta-spark_${SCALA_VERSION}-${DELTA_SPARK_VERSION}.jar
RUN wget -O delta-storage-${DELTA_STORAGE_VERSION}.jar https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_STORAGE_VERSION}/delta-storage-${DELTA_STORAGE_VERSION}.jar
# RUN wget -O spark-hadoop-cloud_${SCALA_VERSION}-${APACHE_SPARK_VERSION}.jar https://repo1.maven.org/maven2/org/apache/spark/spark-hadoop-cloud_${SCALA_VERSION}/${APACHE_SPARK_VERSION}/spark-hadoop-cloud_${SCALA_VERSION}-${APACHE_SPARK_VERSION}.jar
RUN wget -O kyuubi-spark-sql-engine_${SCALA_VERSION}-${KYUUBI_VERSION}.jar https://repo1.maven.org/maven2/org/apache/kyuubi/kyuubi-spark-sql-engine_${SCALA_VERSION}/${KYUUBI_VERSION}/kyuubi-spark-sql-engine_${SCALA_VERSION}-${KYUUBI_VERSION}.jar

WORKDIR ${KYUUBI_HOME}
RUN chown -R kyuubi:root ${KYUUBI_HOME} && \
    chmod ug+rw -R ${KYUUBI_HOME} && \
    chmod a+rwx -R ${KYUUBI_WORK_DIR_ROOT}

CMD [ "./bin/kyuubi", "run" ]

USER ${kyuubi_uid}