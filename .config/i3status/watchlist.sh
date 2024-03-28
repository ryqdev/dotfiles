#!/bin/bash

i3status | while :
do
        read line
	
	response=$(curl -s "https://finnhub.io/api/v1/quote?symbol=AAPL&token=cg9cnopr01qk68o82q1gcg9cnopr01qk68o82q20")

	value=$(echo $response | jq '.c')

        echo "AAPL $value | $line" || exit 1
done
