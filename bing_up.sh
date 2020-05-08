page_min=1
page_max=126
if [ $# = 0 ];then
	echo "default args[1 126]..."
elif [ $# -eq 1 -o $# -gt 2  ];then
	echo "Usage: $0 : [num1 num2]/[rand1 num1]"
	exit 1
elif [ $# = 2 -a $1 = "rand" ];then
if [ ! -e small/*.jpg ];then	# 如果没有图片就自己添加文件内容
	echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" > jpg.md5
else
	md5sum small/*.jpg > jpg.md5 # 首先计算已有文件的md5
fi
for i in `seq 1 $2`
do
	flag=0
	date1="123"
	name1="ps"
	wget -O html/rand_$i.html "https://bing.ioliu.cn/v1/rand?type=json" -q
	if test $? != 0;then
		echo "wget html failed."
		exit 1
	fi
	cat html/rand_$i.html | sed -e 's/"url":/\n\0 /' -e 's/"copyright":/\n\0 /' -e 's/(.*)/\n\0/g' -e 's/（.*）/\n\0/' -e 's/"/ /g' |awk -f rand.awk |sed -e 's/^ *//g' > tmp.txt
	while read date
	do
		read url
		read name
		name1="$name"
		date1="$date"
		wget -O small/"$date $name.jpg.tmp" "$url" -nc -q
	done < tmp.txt

	str=`md5sum small/"$date1 $name1.jpg.tmp"`
	md5_new=(${str:0:32})	# 获取临时文件的md5sum

	while read line
	do
		md5_old=(${line:0:32})	# 比较每个文件的md5sum
		if [ $md5_old == $md5_new ];then
			flag=1
			break
		fi 	
	done < jpg.md5

	if [ $flag = 1 ];then	# 图片已经存在
		echo "relative photo already exists."
		rm small/"$date1 $name1.jpg.tmp"
	else	# 图片不存在
		echo "$date1 $name1.jpg"
		mv small/"$date1 $name1.jpg.tmp" small/"$date1 $name1.jpg"
		md5sum small/"$date1 $name1.jpg" >> jpg.md5	# append新图片的md5sum
	fi
done
	rm jpg.md5 tmp.txt
	exit 0
else
	expr $1 + 6 &> /dev/null        # 判断$1是否为整数
    if [ $? -ne 0 ];then
        echo "Usage: $0 : [num1 num2]"
        exit 1
    fi
	page_min=$1
	page_max=$2
fi
	
for i in `seq $page_min $page_max`
do
	wget -O html/${i}.html https://bing.ioliu.cn/?p=$i -q
	
	cat html/$i.html -n| sed -e 's/<[^<>]*>/\n\0/g' -e 's/>/ /g' -e 's/"/ /g' -e 's/([^()]*)//g'| grep -E 'download  href|<h3|[^0][0-9]{4}-[0-9]{2}-[0-9]{2}'|awk -f up.awk |sed -e 's/^ *//g' > up.txt
	
	while true
	do
	{
		read date
		if [ $? != 0 ];then
			break
		fi
		read name
		read url
		wget -O small/"${date} ${name}.jpg.tmp" $url -q -nc
		ret=`echo $?`
		if [ $ret -eq 0 ];then
			mv small/"${date} ${name}.jpg.tmp" small/"${date} ${name}.jpg"		
			echo "$date ${name}.jpg"	
		else
			echo "$date ${name}.jpg...failed, $ret"	
			rm small/"${date} ${name}.jpg.tmp"
		fi	
	}
	done < up.txt
#	wait
done
rm up.txt

