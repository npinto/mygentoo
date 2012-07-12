#!/bin/bash

set -e
set -x

test ! -z ${N_SEC} || N_SEC=3600

echo "N_SEC=${N_SEC}"

while true; do
    NO_ASK=1 make clean me update;
    sleep ${N_SEC}
done;
