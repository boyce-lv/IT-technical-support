#!/bin/bash
echo "plesse inout number"
read var
while [ $var -gt 998 ]
do
#var=$(($var-1))
#let var--
var=`expr $var - 1`
echo $var
done
