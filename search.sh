#!/bin/bash

	#| egrep -o '[^"]+/@[^"]+' \

hashtag=$1
comand=$2
hosts="hosts.lst"

trap "sort $hashtag.out.txt | uniq | sort > $hashtag.tmp.txt; mv $hashtag.tmp.txt $hashtag.out.txt" EXIT SIGINT SIGQUIT SIGABRT SIGTERM


function explore() {
	hashtag=$2
	url="https://$1/explore/$hashtag"
	echo $url >&2
	curl -s "$url" \
	| sed '-nre/@/s/^.+https:\/\/([^/]+)\/(@[^"<>]+).+$/\2@\1/p' \
	| tee -a $hashtag.out.txt
}
export -f explore


function tags() {
	hashtag=$2
	url="https://$1/tags/$hashtag.rss"
	echo $url >&2
	curl -s "$url" \
	| sed '-nre/guid/s/^.+https:\/\/([^/]+)\/(@[^/"<>]+).+$/\2@\1/p' \
	| tee -a $hashtag.out.txt
}
export -f tags


if [ ! -f hosts.lst ]; then
		curl -s https://fediverse.network/mastodon \
			| awk -F'<|>' '/href/ && /<\/td>/ {print $3}'
			> "$hosts"
fi

if [ "$comand" == "" ]; then
	cat "$hosts" | parallel --timeout=5 --jobs=400% explore {} "$hashtag"
	cat "$hosts" | parallel --timeout=5 --jobs=400% tags {} "$hashtag"
else
	cat "$hosts" | parallel --timeout=5 --jobs=400% $comand {} "$hashtag"
fi
