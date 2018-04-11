
#!/bin/bash
echo "plesse inout number"
read var
until [ $var -lt 998 ]
do
var=$(($var-1))
done
echo $var
