export all_stream=`echo $5 |/usr/xpg4/bin/awk '{printf("%s ",$1);for(i=2;i<=NF;i++){printf("%s",$i)}}'`
export test_driver_header=`echo $all_stream|/usr/xpg4/bin/awk '{printf("%s ",$1);for(i=1;i<=16;i++){printf("%s",substr($2,i,1));if(i%2==0){printf(" ")};}}'`
export test_driver_data=`echo $all_stream|/usr/xpg4/bin/awk '{for(i=length($2)-1;i>=17;i-=2){printf("%s",substr($2,i,2))}}'`

#echo $all_stream
#echo $test_driver_header
#echo $test_driver_data


echo `echo "$test_driver_header" ;echo  "$test_driver_data"|/usr/xpg4/bin/awk -v base=$1 -v nb_bit=$2 -v pos_value=$3 -v value=$4 -v data_type=ahd -f ./insert_value_into_data.awk`
#echo  $5|awk '{for(i=NF;i>=11;i--){printf("%s",$i)}printf("\n")}'|/usr/xpg4/bin/awk -v base=$1 -v nb_bit=$2 -v pos_value=$3 -v value=$4 -v data_type=$5 -f ./insert_value_into_data.awk
