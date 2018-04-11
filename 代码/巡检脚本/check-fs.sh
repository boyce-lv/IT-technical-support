#! /bin/bash
#check filesystem
touch cfs-`date +%F`.txt
cfs1=`df -h | sed 1d | awk '{print $5}' |cut -d "%" -f 1`
cfs2=`df -i | sed 1d | awk '{print $5}' |cut -d "%" -f 1`
cfs3_1=`df | sed 1d | awk '{print $6}' | wc -l`
cfs3_2=`cat /etc/fstab | grep -v \# | sed 1d | awk '{print $2}' | wc -l`
#check file system usage
if [ $cfs1 -gt 70 ];then
        echo "文件系统使用率不正常" > cfs-`date +%F`.txt
else
        echo "文件系统使用率正常" > cfs-`date +%F`.txt
fi
#check i usage
if [ $cfs2 -gt 70 ];then
        echo "文件系统i节点使用率不正常" >> cfs-`date +%F`.txt
else
        echo "文件系统i节点使用率正常" >> cfs-`date +%F`.txt
fi
#check file system mount
if [ $cfs3_1 -ge $cfs_2 ];then
        echo "文件系统挂载正常" >> cfs-`date +%F`.txt
else
        echo "文件系统挂载不正常" >> cfs-`date +%F`.txt
fi
