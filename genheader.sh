#!/bin/bash

declare -a bytes
bytes=(`xxd -p -c 1 $1 | tr '\n' ' '`)
size=`stat -c %s $1`
if [ $size -gt 65043 ]; then
    echo "Error, program is too large. Maximum size is 65035 bytes". >&2
    exit -1
fi
targetaddr=$2
if [ -z $2 ]; then
	echo "Error, specify target address: 0x01ED..0xFFF0" >&2
	exit -2
fi

if [ $(($targetaddr + $size)) -gt $((0xfff8)) ]; then
	echo "Error, program does not fit below 0xFFF8." >&2
	exit -3
fi

total=0;
for(( i=0; i<${#bytes[@]}; i++));
do
    total=$(($total + 0x${bytes[i]}))
    total=$(($total & 65535))
done
printf "Size: %04x\n" $size >&2
printf "Checksum: %04x\n" $total >&2
printf "Target: %04x\n" $targetaddr >&2

sizeMSB=$((($size-1)/256))
sizeLSB=$((($size-1) & 0xFF))
cksumMSB=$(( $total / 256))
cksumLSB=$(( $total & 0xFF ))
targetMSB=$(( $targetaddr / 256 ))
targetLSB=$(( $targetaddr & 0xFF ))

printf "%b" "\x$(printf "%X" $targetLSB)"
printf "%b" "\x$(printf "%X" $targetMSB)"
printf "%b" "\x$(printf "%X" $sizeLSB)"
printf "%b" "\x$(printf "%X" $sizeMSB)"
printf "%b" "\x$(printf "%X" $cksumLSB)"
printf "%b" "\x$(printf "%X" $cksumMSB)"
