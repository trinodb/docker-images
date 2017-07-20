#!/bin/bash

# 
# Requires that the top layer is a LABEL layer. If it is, return the checksum
# of its parent layer and exit 0. If the top layer isn't a LABEL layer, exit 1.
#
docker history --no-trunc --format "{{.ID}}\t{{.CreatedBy}}" "$1" | awk '
	BEGIN {
		ec = 1;
	}
	$5 == "LABEL" && NR == 1 {
		getline;
		ec = 0;
		exit;
	}
	END {
		if (ec == 0) {
			print $1
		}
		exit ec
	}'
