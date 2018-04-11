#! /bin/bash
a=0;b=0;c=0;d=0;e=0;R=0
echo "请输入姓名"
read a
touch $a的体检单.txt
echo "姓名：$a" > $a.txt
echo "请选择性别"
while [ $b!=男 -a $b!=女 ]
do
	select b in 男 女
	do
	case $b in
	男)
		echo "性别：$b" >> $a.txt;;
	女)	
		echo "性别：$b" >> $a.txt;;
	*)
		echo "请正视自己的性别！！"
	continue
	;;
	esac
	break
	done
break
done
echo "请输入年龄"
read c
if [ $c -ge 8 -a -le 65 ]
then
echo "年龄：$c" >> $a.txt
else
echo "你年龄不在我们测试范围！！"
fi
echo "请输入身高cm"
read d
if [ $d -le 30 ]
then 
echo "你是聪明的侏儒吗？"
read d
elif [ $d -ge 200 ]
then
echo "本测试不对2米身高以上的人开放！"
read d
else
echo "身高：$d" >> $a.txt
fi
echo "请输入体重kg"
read e
if [ $e -le 0 ]
echo "你是中微子吗？？"
read e
elif [ $e -ge 200 ]
echo "我要大声念出你的体重 $e 斤！！"
read e
else
echo "体重：$e" >> $a.txt
fi
R=`expr $d-$e`
if [ $b=男 ]
then
	if [ $R -ge 30 -a -le 50 ]
	then
		echo "合格" >> $a.txt
	else
		echo "不合格" >> $a.txt
	fi
else
	if [ $R -ge 20 -a -le 40 ]
	then
                echo "合格" >> $a.txt
        else
                echo "不合格" >> $a.txt
	fi
fi
cat $a.txt
