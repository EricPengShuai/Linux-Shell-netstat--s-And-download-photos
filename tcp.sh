date=`date +%Y-%m-%d`
hour=0
minute=0
rec_send_last=0
label=" "
flag=0
while true
do
	label=" "
	minute=`expr $minute + 1`
	if [ $minute -eq 60 ]
	then
		hour=`expr $hour + 1`
		minute=0
	fi
	str1=`netstat -s|awk "NR==35"`
	str2=`netstat -s|awk "NR==36"`
	rec_before=`echo $str1|grep -o '[0-9]*'`
	send_before=`echo $str2|grep -o '[0-9]*'`
	# rec_before=`netstat -s|awk "NR==35"|grep -o '[0-9]*'`
	sleep 60
	str1=`netstat -s|awk "NR==35"`
	str2=`netstat -s|awk "NR==36"`
	rec_after=`echo $str1|grep -o '[0-9]*'`
	send_after=`echo $str2|grep -o '[0-9]*'`
	rec=`expr $rec_after - $rec_before`
	send=`expr $send_after - $send_before`
	rec_send=`expr $rec + $send`
	if [ $flag -ne 0 ];then
		if [ $rec_send -ge $rec_send_last ];then
			d=`expr $rec_send - $rec_send_last`
			if [ $d -gt 10 ];then
				label="+"
			fi
		elif [ $rec_send -le $rec_send_last ];then
			d=`expr $rec_send_last - $rec_send`
			if [ $d -gt 10 ];then
				label="-"
			fi
		fi
	fi
	flag=1
	rec_send_last=`expr $rec_send`	# 记下上一分钟的收发总数

	printf "%s %02d:%02d %8d %8d %8d %s\n" $date $hour $minute $rec $send $rec_send $label
done
