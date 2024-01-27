#!/bins/sh

echo "INPUT_BUCKETS=$INPUT_BUCKETS"
echo "COPY_DIR=$COPY_DIR"

while ! /usr/bin/mc config host add minios3 http://minio-s3:9000 $USER $PASSWORD;
  do echo 'MinIO not up and running yet...' && sleep 1;
done;

echo 'Added mc host config.';

echo "Variable COPY_DIR is set to $COPY_DIR"

mc alias list

if [ "$COPY_DIR" = "true" ]
then
  bucket="data"

  /usr/bin/mc mb "minios3/$bucket";
  /usr/bin/mc mirror /data/ "minios3/$bucket";
else
  buckets=( $(echo $INPUT_BUCKETS | tr "," " ") )
  copy_data=( $(echo $COPY_DATA | tr "," " ") )

  length_buckets=${#buckets[@]}
  length_data=${#copy_data[@]}
  echo "The length of the arrays is: $length_buckets and $length_data"

  end=$((length_buckets - 1))

  for i in $(seq 0 $end);
  do
    bucket=${buckets[i]}
    bucket=$(echo "$bucket" | tr -d "[:blank:]()")

    file=${copy_data[i]}
    # shellcheck disable=SC2006
    file=`echo "$file" | tr -d "[:blank:]()"`

    echo "Printing file and bucket"
    echo "$file" and "$bucket"

    /usr/bin/mc mb "minios3/$bucket"
    mc stat --json minios3/iceberg-data

    if [ -n "${file}" ]
    then
      echo "ENTERED IF"
      /usr/bin/mc cp "/data/$file" "minios3/$bucket"
    fi
  done;
fi

echo "Bucket created"

mc ls --json minios3



exit 0;
