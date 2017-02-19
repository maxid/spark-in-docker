# spark-in-docker

alpine based Spark Docker container.

This image is large and contains:

* Spark 2.1.0
* Hadoop 2.7.3
* Anaconda 4.3.0 (full packages with matplotlib)
* PySpark support with Python 3.6

### usage

```
docker run --rm -p 4040:4040 sofianito/spark
```
