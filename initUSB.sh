#!/bin/sh

stty -F /dev/ttyUSB0 raw -echo -echoe -echok
stty -F /dev/ttyUSB0 115200
