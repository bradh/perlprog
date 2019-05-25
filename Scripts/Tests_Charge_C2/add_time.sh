awk -v dhour=$2 -v dminute=$3 -v dsecond=$4 -v dmsec=$5 \
'{hour=substr($1,1,2);minute=substr($1,4,2);second=substr($1,7,2);msec=substr($1,10,3);msec=msec+dmsec;'\
'if(msec>=1000){second++;msec=msec-1000};'\
'if(msec<0){second--;msec=msec+1000};'\
'second=second+dsecond;'\
'if(second>=60){minute++;second=second-60};'\
'if(second<0){minute--;second=second+60};'\
'minute=minute+dminute;'\
'if(minute>=60){hour++;minute=minute-60};'\
'if(minute<0){hour--;minute=minute+60};'\
'hour=hour+dhour;printf("%.2d:%.2d:%.2d.%.3d%s\n",hour,minute,second,msec,substr($0,13));}' $1
