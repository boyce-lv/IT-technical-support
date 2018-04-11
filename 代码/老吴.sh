#! /bin/bash
while true
do
echo "如何证明你是老吴"
echo "please input a number in 1-2
      1为证明 2为不证明"
read nu
case $nu in
1)  
echo ”老吴的梦中情人是谁“
select LL in "韩红" "贾玲"
do
echo "$LL"
sleep 3
echo "你一定是老吴"
break
done
;;
2)
echo "你不是老吴你是谁"
echo "你一定是老吴"
;;
esac
sleep 3
done
