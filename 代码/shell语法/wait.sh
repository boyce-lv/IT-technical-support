#!/bin/bash
touch a.txt &
touch b.txt &
ping 192.168.0.1 &
wait
echo "aaaaaaaa" >> a.txt
echo "bbbbbbbb" >> b.txt
