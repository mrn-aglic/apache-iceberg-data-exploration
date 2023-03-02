# Setting up minio buckets and data

The `entrypoint.sh` script is based upon the commands that
I found while reading the book Data Pipelines with Apache
Airflow (I actually think that I expanded on it a fair
amount).
The code for the book is here:
https://github.com/BasPH/data-pipelines-with-apache-airflow
You can get the book here:
https://www.manning.com/books/data-pipelines-with-apache-airflow

The shell commands in the book are given in the docker-compose
file. I extracted them to the `entrypoint.sh` file and expanded
the file a bit.

It supports the following options:
- `PASSWORD` - to set the password for the minio user.
- `COPY_DIR` - when set to true, the dataset folder is mirrored
to minio s3. If not set to true, then provide the options
INPUT_BUCKETS and COPY_DATA.
- `INPUT_BUCKETS` - the buckets to create
- `COPY_DATA` - the data files to copy into the buckets

**NOTE:** the lengths of the `INPUT_BUCKETS` and `COPY_DATA`
arrays need to be the same. Each file in `COPY_DATA` will be
copied to the corresponding bucket by list index.
Elements are separated with a comma.

In case that more buckets are listed than files, the
shell script should create empty bucket for every element
whose index is >= then the number of files listed.

An example to define the two variables:
- `INPUT_BUCKETS=test,foo,bar`
- `COPY_DATA=movies.csv,ratings_smaller.csv,movies.csv`

For `COPY_DATA` it is assumed that the files in the /data
directory in the docker container.

You'll also need to create a .env file. You can copy
.env.backup.
