#!/bin/bash

hashtag=$1
if [ ! -f hosts.lst ]; then
	(echo qoto.org;echo ifwo.eu;curl -s https://fediverse.network/mastodon | awk -F'<|>' '/href/ && /<\/td>/ {print $3}') > hosts.lst
fi

imax=$(wc -l hosts.lst);i=0

(cat hosts.lst | while read url; do i=$(( i + 1 ));echo $i/$imax $url>&2; curl -s https://$url/explore/$hashtag | egrep -o ''$url'/@[^"]+'; done) | tee -a $hashtag.out.txt
sort $hashtag.out.txt | uniq | sort $hashtag.tmp.txt
mv $hashtag.tmp.txt $hashtag.out.txt
