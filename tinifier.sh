#!/bin/sh
API_LIMIT="500"
api_key="../.tinify_api_key"

log_info(){
  printf "[\e[36m%s\e[0m] [\e[32mINFO\e[0m] $*" "$(date +'%H:%M:%S')"
}

log_warn(){
  printf "[\e[36m%s\e[0m] [\e[33mWARNING\e[0m] $*" "$(date +'%H:%M:%S')"
}

log_error(){
  printf "[\e[36m%s\e[0m] [\e[91mERROR\e[0m] $*" "$(date +'%H:%M:%S')"
}

process_image(){
  j=0
  while [ ! -f compressed/"$file" ]; do
    j="$((j + 1))"
    if [ "$j" -gt 1 ]; then
      log_info "Re-try $((j - 1))\n"
    fi
    if [ "$j" -gt 10 ]; then
      log_error "Too many re-tries! Exiting....\n"
      exit 1
    fi
    file="$(echo "$file" | cut -d '/' -f 2)"
    orig_size="$(($(stat --printf="%s" files/"$file") / 1024))"
    if [ "$orig_size" -gt 1024 ]; then
      orig_size_display="$(printf "%0.2f\n" "$(awk "BEGIN {print ($orig_size)/1024}")") MB"
    else
      orig_size_display="$orig_size KB"
    fi
    log_info "Compressing \"$file\".... (${orig_size_display}) ($i of $files_count)\n"
    curl --progress-bar --user api:"$api_key" --data-binary @files/"$file" --output api_response.txt -i https://api.tinify.com/shrink
    if [ -f api_response.txt ]; then
      status_code=$(< api_response.txt  head -1 | awk '{print $2}')
    else
      status_code="1"
    fi
    if [ "$status_code" != 201 ]; then
      log_warn "Something went wrong! Error code: $status_code Retrying....\n"
      if [ -f api_response.txt ]; then
        rm api_response.txt 2> /dev/null
      fi
      continue
    fi
    download_url="$(< api_response.txt grep location | awk '{print $2}')"
    compression_count="$(< api_response.txt grep compression-count | awk '{print $2}')"
    log_info "Total API Requests: $compression_count/$API_LIMIT\n"
    if [ "$compression_count" -gt "$((API_LIMIT - 1))" ]; then
      log_error "API Limit Reached! Exiting....\n"
      rm api_response.txt
      exit 1
    fi
    curl "$download_url"  --progress-bar --user api:"$api_key" --header "Content-Type: application/json" --data '{ "preserve": ["location", "creation"] }' --output compressed/"$file"
    new_size="$(stat --printf="%s" compressed/"$file")"
    if [ "$new_size" = "" ]; then
      new_size=1
    fi
    new_size="$((new_size / 1024))"
    if [ "$new_size" -gt 1024 ]; then
      new_size_display="$(printf "%0.2f\n" "$(awk "BEGIN {print ($new_size)/1024}")") MB"
    else
      new_size_display="$new_size KB"
    fi
    log_info "Done compressing \"$file\" (${new_size_display})\n"
    rm api_response.txt
    echo ""
  done
}

if [ -f "$api_key" ]; then
  api_key="$(cat $api_key)"
else
  log_error "API Key not found. Please save API key at \e[1m$api_key\e[0m"
  exit 1
fi

mkdir -p compressed
log_info "Starting compression....\n"

# shellcheck disable=SC2039
files="$(ls files/*.{jpg,jpeg,png,JPG,JPEG,PNG} 2> /dev/null)"
if [ ! "$files" ]; then
  log_error "No pictures found! Exiting....\n"
  exit 1
fi

files_count="$(echo \""$files"\" | wc -l)"
i=0
# shellcheck disable=SC2039
while read -r file; do
  i="$((i + 1))"
  process_image
done <<< "$files"
log_info "All files compressed!\n"
