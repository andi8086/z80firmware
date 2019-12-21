#!/bin/bash

file=$1
target=$2

./genheader2.sh $1 $2 > ${1%.*}.header

cat ${1%.*}.header $1 > ${1%.*}.bin
