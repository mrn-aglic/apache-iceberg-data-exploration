FROM python:3.10-bullseye as spark-base

ARG SPARK_VERSION=3.3.2

# Install tools required by the OS
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo \
      curl \
      vim \
      unzip \
      rsync \
      openjdk-11-jdk \
      build-essential \
      software-properties-common \
      ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Setup the directories for our Spark and Hadoop installations
ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

# Download and install Spark
RUN curl https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -o spark-${SPARK_VERSION}-bin-hadoop3.tgz \
 && tar xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz --directory /opt/spark --strip-components 1 \
 && rm -rf spark-${SPARK_VERSION}-bin-hadoop3.tgz



FROM spark-base as pyspark-base

# Install python deps
COPY requirements/requirements.txt .
RUN pip3 install -r requirements.txt



FROM pyspark-base as pyspark

# Setup Spark related environment variables
ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_MASTER="spark://spark-iceberg:7077"
ENV SPARK_MASTER_HOST spark-iceberg
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

# Copy the default configurations into $SPARK_HOME/conf
COPY spark-defaults.conf "$SPARK_HOME/conf"

RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

# Copy appropriate entrypoint script
COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]


FROM pyspark as spark-iceberg

# Download iceberg spark runtime
RUN curl https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.3_2.12/1.1.0/iceberg-spark-runtime-3.3_2.12-1.1.0.jar -Lo /opt/spark/jars/iceberg-spark-runtime-3.3_2.12-1.1.0.jar

ENV TABULAR_VERSION=0.50.4

RUN curl https://tabular-repository-public.s3.amazonaws.com/releases/io/tabular/tabular-client-runtime/${TABULAR_VERSION}/tabular-client-runtime-${TABULAR_VERSION}.jar -Lo /opt/spark/jars/tabular-client-runtime-${TABULAR_VERSION}.jar

# Download Java AWS SDK
RUN curl https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.17.257/bundle-2.17.257.jar -Lo /opt/spark/jars/bundle-2.17.257.jar

# Download URL connection client required for S3FileIO
RUN curl https://repo1.maven.org/maven2/software/amazon/awssdk/url-connection-client/2.17.257/url-connection-client-2.17.257.jar -Lo /opt/spark/jars/url-connection-client-2.17.257.jar

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && sudo ./aws/install \
 && rm awscliv2.zip \
 && rm -rf aws/

# Add iceberg spark runtime jar to IJava classpath
ENV IJAVA_CLASSPATH=/opt/spark/jars/*

RUN mkdir -p /home/iceberg/localwarehouse /home/iceberg/notebooks /home/iceberg/warehouse /home/iceberg/spark-events /home/iceberg
#COPY notebooks/ /home/iceberg/notebooks

## Add a notebook command
#RUN echo '#! /bin/sh' >> /bin/notebook \
# && echo 'export PYSPARK_DRIVER_PYTHON=jupyter-notebook' >> /bin/notebook \
# && echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"--notebook-dir=/home/iceberg/notebooks --ip='*' --NotebookApp.token='' --NotebookApp.password='' --port=8888 --no-browser --allow-root\"" >> /bin/notebook \
# && echo "pyspark" >> /bin/notebook \
# && chmod u+x /bin/notebook
#
## Add a pyspark-notebook command (alias for notebook command for backwards-compatibility)
#RUN echo '#! /bin/sh' >> /bin/pyspark-notebook \
# && echo 'export PYSPARK_DRIVER_PYTHON=jupyter-notebook' >> /bin/pyspark-notebook \
# && echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"--notebook-dir=/home/iceberg/notebooks --ip='*' --NotebookApp.token='' --NotebookApp.password='' --port=8888 --no-browser --allow-root\"" >> /bin/pyspark-notebook \
# && echo "pyspark" >> /bin/pyspark-notebook \
# && chmod u+x /bin/pyspark-notebook

ARG jupyterlab_version=3.6.1

RUN apt-get update -y && \
    apt-get install -y python3-pip python3-dev && \
    pip3 install --upgrade pip && \
    pip3 install wget jupyterlab==${jupyterlab_version}

# Add a notebook command
RUN echo '#! /bin/sh' >> /bin/notebook \
 && echo 'export PYSPARK_DRIVER_PYTHON=jupyter' >> /bin/notebook \
 && echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"lab --notebook-dir=/home/iceberg/notebooks --ip='0.0.0.0' --NotebookApp.token='' --port=8888 --no-browser --allow-root\"" >> /bin/notebook \
 && echo 'pyspark' >> /bin/notebook \
 && chmod u+x /bin/notebook

#CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=


COPY .pyiceberg.yaml /root/.pyiceberg.yaml

ENTRYPOINT ["./entrypoint.sh"]
CMD ["notebook"]