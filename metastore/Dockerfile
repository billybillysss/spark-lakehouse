FROM apache/hive:3.1.3

USER root
RUN apt-get update && apt-get install -y wget

COPY entrypoint.sh /entrypoint.sh

ENV HADOOP_AWS_VERSION=3.1.0 \
    AWS_JAVA_SDK_VERSION=1.11.271 \
    SERVICE_NAME=metastore \
    DB_DRIVER=postgres \
    HIVE_CUSTOM_CONF_DIR=/opt/hive/conf \
    POSGTGRSQL_DRIVER_VERSION=42.7.3

WORKDIR /opt/hive/lib
RUN wget -O hadoop-aws-${HADOOP_AWS_VERSION}.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar
RUN wget -O aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar
RUN wget -O postgresql-${POSGTGRSQL_DRIVER_VERSION}.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/${POSGTGRSQL_DRIVER_VERSION}/postgresql-${POSGTGRSQL_DRIVER_VERSION}.jar

RUN mkdir -p /tmp/hive

RUN chown -R hive:hive /opt
RUN chown -R hive:hive /tmp/hive

RUN chmod -R 755 /opt
RUN chmod -R 777 /tmp/hive

USER hive

WORKDIR /opt

EXPOSE 9083

ENTRYPOINT ["bash", "/entrypoint.sh"]
