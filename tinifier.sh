API_LIMIT="500"
api_key="`cat ../.tinify_api_key`"

mkdir -p compressed
echo "`date +'%Y/%m/%d %H:%M:%S'` Starting compression...."

files="`ls files/*.{jpg,jpeg,png,JPG,JPEG,PNG} 2> /dev/null`"
if [ ! "$files" ]; then
  echo "No pictures found! Exiting...."
  exit 1
fi

files_count="`echo $files | wc -w`"
i=0
for file in $files; do
  i="`expr $i + 1`"
  file="`echo $file | cut -d '/' -f 2`"
  orig_size="`expr $(stat --printf="%s" files/$file) / 1024`"
  echo "`date +'%Y/%m/%d %H:%M:%S'` Compressing $file.... (${orig_size}KB) ($i of $files_count)"
  curl --progress-bar --user api:$api_key --data-binary @files/$file --output api_response.txt -i https://api.tinify.com/shrink
  if [ $? != 0 ]; then
    echo "Something went wrong! Exiting...."
    rm api_response.txt 2> /dev/null
    exit 1
  fi
  download_url="`cat api_response.txt | grep location | awk '{print $2}'`"
  compression_count="`cat api_response.txt | grep compression-count | awk '{print $2}'`"
  echo "`date +'%Y/%m/%d %H:%M:%S'` Total API Requests: $compression_count/$API_LIMIT"
  if [ "$compression_count" -gt "`expr $API_LIMIT - 1`" ]; then
    echo "`date +'%Y/%m/%d %H:%M:%S'` API Limit Reached! Exiting...."
    rm api_response.txt
    exit 1
  fi
  curl $download_url  --progress-bar --user api:$api_key --header "Content-Type: application/json" --data '{ "preserve": ["location", "creation"] }' --output compressed/$file
  new_size="`expr $(stat --printf="%s" compressed/$file) / 1024`"
  echo "`date +'%Y/%m/%d %H:%M:%S'` Done compressing $file (${new_size}KB)"
  rm api_response.txt
  echo ""
done
echo "`date +'%Y/%m/%d %H:%M:%S'` All files compressed!"
