api_key="`cat ../.tinify_api_key`"
for file in `ls files`; do
  echo "Compressing $file...."
  response="`curl --progress-bar --user api:$api_key --data-binary @files/$file --output api_response.txt -i https://api.tinify.com/shrink`"
  download_url="`cat api_response.txt | grep location | awk '{print $2}'`"
  curl $download_url  --progress-bar --user api:$api_key --header "Content-Type: application/json" --data '{ "preserve": ["location", "creation"] }' --output compressed/$file
  echo "Done compressing $file"
  rm api_response.txt
done
echo "All files compressed!"
