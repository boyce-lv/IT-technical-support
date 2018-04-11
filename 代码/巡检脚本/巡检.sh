#!/bin/bash
while (true)
  do
    clear
    select num in "error log" "filesystem" "course" "Swap_usage-rate" "卷组状态" "system-safety" "resource"
      do
        case $num in

          "error log")

                    kan=`cat /var/log/messages-20171001 | grep -E "error|fail|critical|fatal" >a.txt | less  /var/ftp/pub/az/a.txt |wc -l`
                     if [ $kan -ne 0 ]
                       then
                       cat /var/ftp/pub/az/a.txt
                       echo "故障记录总共有$kan行"
                     else
                       echo "无故障记录"
                     fi
                     ;;

          "filesystem")
                    clear
                    select num1 in "systemused" "i-nodeused" "filesystemmount"
                      do 
                        case $num1 in
                          "systemused")
                            clear
                            df -h |awk '{print $1,$3,$5}' OFS='\t\t\t'
                            continue
                            ;; 
                          "i-nodeused")
                            clear
                            df -i | awk '{print $1,$3,$5}' OFS='\t\t\t'
                            continue
                            ;;
                          "filesystemmount")
                            clear
                            df | awk '{print $1,$6}' OFS='\t\t\t\t\t'
                            echo
                            shu=`df | wc -l`   #统计行数
                            shu0=`expr $shu - 1` #换算属于磁盘文件的实际行数
                            shu1=$shu0            #行数分工
                            for (( y=1;y<=$shu0;y++ ))                   
                              do
                                point=`df | sed '1d' |sed -n ''$shu1'p' |awk '{print $6}'` 
                                name=`df | sed '1d' |sed -n ''$shu1'p' |awk '{print $1}'`
                                grep "$point" /etc/fstab >/dev/null
                                  if [ $? -eq 0 ]
                                    then
                                      echo "$name 已制作挂载配置"
                                  fi 
                            shu1=`expr $shu1 - 1`
                              done               
                            continue
                            ;; 
                 
                            *)
                             break
                            ;;                
                       esac
                
                   done
                   ;;
          "course")
                  select num2 in "rigid" "patrolagent" "ntp-course" "NTP授时状态" "PPIDuser"
                    do
                      case $num2 in
                        "rigid")   
                          clear
                          ps -ef | grep defunc >/dev/null
                          if [ $? -eq 0 ] 
                            then
                              echo "有呆板进程请确认"
                   ps -ef | grep defunc | egrep -v "V_LIN_HEA_DEFNUM"   #此处有漏洞，确为 -v后面的所属进程将终端将显示为空 
                          elif [ $? -eq 1 ]   #学用下elif
                            then
                              echo "没有呆板进程" 
                          fi 
                          ;;
                        "patrolagent")
                          clear
                          wcnum=`ps -ef |grep patrolagent | wc -l`   
                          if [ $wcnum -eq 0 ]
                            then
                              echo "系统没有警报进程，情况不算好"
                          else
                            echo "正常" 
                          fi   
                          ;;
                        "ntp-course")
                          clear
                          ntpdnum=`ps -ef | grep ntpd | wc -l`
                          if [ $ntpdnum -eq 0 ]
                            then
                              echo "系统没有网络时间协议进程，不正常"   

                          else
                            echo "正常"
                          fi 
                          ;;
                        "NTP授时状态")
                          clear
                          echo "NTP：连接拒绝 ,5.10机子命令不存在" 
                          ;;
                          "PPIDuser")
                          clear
                          ps -ef | sed '1d' | awk '{print $1,$3}'|grep '\<1\>' >./ppid1user.txt
                          cat ./ppid1user.txt | awk '{print $1}'| egrep -v '(root|oracle|informix|patrol)' >./fatal.txt
                          fatalnumber=`cat ./fatal.txt | wc -l`
                          if [ $fatalnumber -gt 0 ]
                            then
                              echo "有特权用户存在，请确认"
                              cat ./fatal.txt
                          else
                            echo "PPID分配正常"
                          fi             
                          rm -f ppid1user.txt fatal.txt
                          ;;
                        *)
                          break
                          ;; 
                      esac 
                    done
                    ;;
          "Swap_usage-rate")
                    clear
                    baifenbi=`free |sed -n 3p |awk '{printf "%.1f %\n",$3/$2*100}'`                #算法待研究
                    echo "SWAP虚拟内存已使用空间  $baifenbi"
                    ;;
          
          "卷组状态")
                    clear
                    select num3 in "root剩余空间" "lv状态" "vg状态" "pv状态"
                      do
                        case $num3 in 
                          "root剩余空间") 
                            clear 
                           Toatlnum=`vgdisplay | grep -A 2 "Total PE" | awk 'NR==1 {print $3}'`
                           Free=`vgdisplay | grep -A 2 "Total PE" | awk 'NR==3 {print $5}'`
                          PEnum=`echo "scale=2;$Free/$Toatlnum*100"|bc` 
                         
                         PEfreenum=`printf "%.f\n" $PEnum`  
                           if [ $PEfreenum -lt 10 ]
                             then
                               echo "root VG 没多少了，已经用了 $PEfreenum% "
                           else
                             echo "root VG 闲余空间还够的,只用了 $PEfreenum% "
                           fi

                           ;;
                          "lv状态")
                            clear
                            state0=`lvdisplay | grep "LV Status" | head -1 | awk '{print $3}'`
                            if [ $state0 = available ]
                              then
                                echo "LV 状态为可用 $state0"
                            else
                              echo "LV 状态为不可用 $state0"
                            fi
                           ;;
                          "vg状态")
                            clear
                            state1=`vgdisplay -v | grep "VG Status" | awk '{print $3}'`
                            if [ $state1 = resizable ]
                              then
                                echo "VG状态为可调整 $state1"
                            else
                              echo "VG状态为不可调整 $state1"
                            fi
                           ;;
                          "pv状态")
                            clear
	       		    state2=`pvdisplay | grep "PV Status" | awk '{print $3}'`
	                    if [ $state2 = allocatable ]
			      then
				echo "VG状态为可调整 $state2"                                #需要做LVM空间后 可行
         		    else
	       		      echo "VG状态为不可调整 $state2"
	        	    fi
			   ;; 
                         esac
                       done
                     ;;
          "system-safety")
                    clear
                    select num4 in "usernum" "priviuser" "mail-size" 
                      do
                        case $num4 in 
                          "usernum")
                            clear
                            usernumber=`who | awk '{print $1}'| wc -l`
                            if [ $usernumber -lt 10 ]
                              then
                              echo "用户数量在范围内"
                            else
                              echo "用户数量超范啦！"  
                            fi
                            ;;
                          "priviuser")
                            clear
                            privinum=`awk -F: '$3==0 {print $1}' /etc/passwd |wc -l`  
                            if [ $privinum -gt 1 ]
                              then
                                echo "有高级别权限会有杀伤力的用户存在" 
                                awk -F : '$3==0 {print $1}' /etc/passwd | grep -v "root"
                            else
                              echo "没有其他特权用户"
                            fi
                            ;;
               
                          "mail-size")
                            clear
                            ls /var/spool/mail >./mailfile
                            for mailnum in `cat ./mailfile`
                              do
                                sizenum=`ls -l /var/spool/mail |grep "$mailnum" |awk '{print $5}'`
                       
                                let "sizenum= ($sizenum / 1024) / 1024"
                                #   sizenum=$(($sizenum / 1024))
                                if [ $sizenum -gt 64 ]
                                  then 
                                    echo "用户$mailnum 日志爆啦"
                                else
                                  echo "用户$mailnum 一平如水" 
                                fi
                              done
                              ;;                     

                           *)
                           break
                           ;;
                     esac
                     done
                     ;;
          "resource")
                   clear
                   select num5 in "IDused" "busy_cource-with_cpu" "sysmem_used" "busy_cource-with_mem"                
                     do
                       case $num5 in
                         "IDused")
                               clear
                               sar 2 2 | grep -ivE "CPU" |awk '{print int($9)}' | awk '{if($1<30)print $0}'>./IDused.txt
                               for IDusednum in `cat ./IDused.txt`                 
                                 do
                                   if [ $IDusednum -lt 30 ]
                                     then
                                       echo "正常正常"
                                   else
                                     echo "OH shit!"
                                   fi
                                 done
                               ;;
                         "busy_cource-with_cpu")
                               clear
                               ps auxwww | sed '1d' | awk '($1>10){print $0}' >./cource-with_cpu.txt
                               for cource_busynum in ` cat ./cource-with_cpu.txt | awk '{print int($3)}' | sort -n`
                                 do
                                   if [ $cource_busynum -lt 30 ]
                                     then
                                       echo "情况良好"
                                   else
                                     echo "OH shit!"
                                   fi
                                 done 
                               ;;
                           
                         "sysmem_used")
                               clear
                               free | sed '1d' | awk '{printf "%.f\n",$3/$2*100}' >sysmem_used.txt   #"%.1f" % 后面的数字决定小数点位
                               for num501 in `cat sysmem_used.txt`   
                                 do
                                   if [ $num501 -lt 70 ] 
                                     then
                                       echo "只用到$num501%空间    情况良好!"
                                     
                                   else 
                                     echo "OH shit!"

                                   fi 
                                 done
                               ;;
 
                                           
                         "busy_cource-with_mem")
                               clear
                               ps auxwww | sed '1d'| awk '($4>20){print $0}' >./busymemfile
                               if [ ! -s ./busymemfile ]       #目前只针对有无超过20%进程作简单的过标报警,未指明是谁         
                                 then
                                   echo  "还好哦,没有耗内存的进程喔"
                               fi
                               ;;
                       esac 
                     done


        esac
      done
  done

#kan=`cat /var/log/iiimessages-20171001 | grep -E "fail|error|critical|fatal"\
