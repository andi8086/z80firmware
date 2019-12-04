#!/bin/bash


var=254
printf "%b" "\x$(printf "%X" $var)" | hexdump -C
