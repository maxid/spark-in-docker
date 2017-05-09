FROM frolvlad/alpine-oraclejdk8:slim

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

RUN apk --update upgrade \
 && apk add libstdc++ bash curl tar git file rsync \
 && mkdir -p /opt

# ANACONDA
ENV CONDA_VERSION 4.2.0
ENV CONDA_DIR /opt/anaconda
ENV PATH $CONDA_DIR/bin:$PATH
ENV LD_LIBRARY_PATH /opt/anaconda/lib:{LD_LIBRARY_PATH}
RUN mkdir -p "$CONDA_DIR" \
 && curl -sL --retry 3 \
   "https://repo.continuum.io/archive/Anaconda3-${CONDA_VERSION}-Linux-x86_64.sh" -o anaconda_installer.sh \
 && bash anaconda_installer.sh -f -b -p $CONDA_DIR \
 && conda update --all --yes \
 && conda clean --all --yes \
 && pip install py4j \
 && rm -rf /tmp/* \
 && rm -rf $(find $CONDA_DIR/pkgs/ -maxdepth 1 -name "python-3*" | sort | head -n -1)

# HADOOP
ENV HADOOP_VERSION 2.7.3
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar x -C /opt/ \
 && rm -rf $HADOOP_HOME/share/doc \
 && chown -R root:root $HADOOP_HOME

# SPARK
ENV SPARK_VERSION 2.1.0
ENV SPARK_PACKAGE spark-$SPARK_VERSION-bin-without-hadoop
ENV SPARK_HOME /opt/spark-$SPARK_VERSION
ENV PYSPARK_PYTHON python3
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*" \
    PATH=$PATH:$SPARK_HOME/bin
RUN curl -sL --retry 3 \
  "http://d3kbcqa49mib13.cloudfront.net/$SPARK_PACKAGE.tgz" \
  | gunzip \
  | tar x -C /opt/ \
 && mv /opt/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME

WORKDIR $SPARK_HOME
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
