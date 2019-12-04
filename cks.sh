#!/bin/bash


declare -a bytes
bytes=(`xxd -p -c 1 $1 | tr '\n' ' '`)

total=0;
for(( i=0; i<${#bytes[@]}; i++));
do
    total=$(($total + 0x${bytes[i]}))
    if [ $total > 4294967295 ]; then
            total=$(($total & 4294967295))
    fi
done

printf "Checksum: %04x" $total
