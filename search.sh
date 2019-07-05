#!/bin/bash

set -x

hashtag=$1

function run() {
	url=$1
	hashtag=$2
	echo $url >&2
	curl -s https://$url/explore/$hashtag \
	| egrep -o $url'/@[^"]+' \
	| tee -a $hashtag.out.txt
}
export -f run


trap "sort $hashtag.out.txt | uniq | sort > $hashtag.tmp.txt; mv $hashtag.tmp.txt $hashtag.out.txt" EXIT SIGINT SIGQUIT SIGABRT SIGTERM


if [ ! -f hosts.lst ]; then
	(
		echo qoto.org
		echo ifwo.eu
		curl -s https://fediverse.network/mastodon \
			| awk -F'<|>' '/href/ && /<\/td>/ {print $3}'
	) > hosts.lst
fi

#--timeout 5 --jobs 400% 
cat hosts.lst | parallel run {} "$hashtag"
