#!/bins/sh

echo "INPUT_BUCKETS=$INPUT_BUCKETS"
echo "COPY_DIR=$COPY_DIR"

while ! /usr/bin/mc config host add locals3 http://minio:9000 $USER $PASSWORD;
  do echo 'MinIO not up and running yet...' && sleep 1;
done;

echo 'Added mc host config.';

echo "Variable COPY_DIR is set to $COPY_DIR"


if [ "$COPY_DIR" = "true" ]
then
  /usr/bin/mc mb locals3/locals3;
  /usr/bin/mc mirror /data/ locals3/locals3/;
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

    echo "$file" and "$bucket"

    /usr/bin/mc mb "locals3/$bucket"

    echo "$file"
    if [ -n "${file}" ]
    then
      echo "ENTERED IF"
      /usr/bin/mc cp "/data/$file" "locals3/$bucket"
    fi
  done;
fi


exit 0;
