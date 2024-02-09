FROM apache/airflow:2.8.1-python3.11

USER root

# Install OpenJDK 17 & Remove unnecessary packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends openjdk-17-jre-headless \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER airflow

# Install Provider - apache-airflow-providers-apache-spark
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" apache-airflow-providers-apache-spark==4.7.1 pyspark==3.5.0 



