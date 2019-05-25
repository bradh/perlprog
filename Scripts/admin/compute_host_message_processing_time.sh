if ([[ $# -ne 3 ]]) then
  echo "usage :"$0" sampt_main.xhd recorder.fim nb_samples_in_distrib"
  exit 1
fi

XHD_FILE=$1
DATA_LINK_FILE=$2
RESULT_DIR=rx_result

echo " extraction of MSG_IDs and times for ahd10x (surveillance messages)..."
extract_TN_date_from_xhd.pl -f $XHD_FILE

# awk '{if(($6=="00")&&($9=="65")){print}}' $XHD_FILE|\
#awk  -f ./get_value_from_data.awk -v nb_bit=16 -v pos_value=472 -v data_type=ahd |\
#awk '{printf("%s IFF_%s\n",$1,$2)}' \
#>xhd_arrival_times_and_msg_ids_for_ahd101.txt

#awk '{if(($6=="00")&&($9=="6B")){print}}' $XHD_FILE|\
#awk  -f ./get_value_from_data.awk -v nb_bit=8 -v pos_value=184 -v data_type=ahd |\
#awk '{printf("%s TIME_FUNC_%s\n",$1,$2)}' \
#>xhd_arrival_times_and_msg_ids_for_ahd107.txt

#awk '{if(($6=="00")&&($9=="6A")){print}}' $XHD_FILE|\
#awk  -f ./get_value_from_data.awk -v nb_bit=8 -v pos_value=504 -v data_type=ahd |\
#awk '{printf("%s PLAT_%s\n",$1,$2)}' \
#>xhd_arrival_times_and_msg_ids_for_ahd106.txt

#cat xhd_arrival_times_and_msg_ids_for_ahd10*.txt|sort -u |grep ":">xhd_arrival_times_and_msg_ids.txt


#~/tmp/xhd_arrival_times_and_msg_ids.txt

echo " extraction of MSG_IDs and times for J3.x/J2.x (surveillance messages) from "$DATA_LINK_FILE"..."
extract_TN_date_from_fim.pl -f $DATA_LINK_FILE

#some identical J3.x are sent several times , at a short interval => remove them
#(by awk program with last_id variable)

# Remplacement cmd awk suivante par extract_TN_date_from_fim.pl
#awk '{if($3=="0F030200"){print}}' $DATA_LINK_FILE|\
#awk  -f ./get_value_from_data.awk -v nb_bit=12 -v pos_value=173 -v data_type=jo |\
#awk '{printf("%s IFF_0%s\n",$1,$2)}' |\
#awk 'BEGIN{last_id=""}{if($2!=last_id){print};last_id=$2}'>fom_arrival_times_and_msg_ids_for_j3_2.txt

#awk '{if($3=="0F030000"){print}}' $DATA_LINK_FILE|\
#awk  -f ./get_value_from_data.awk -v nb_bit=3 -v pos_value=42 -v data_type=jo |\
#awk '{printf("%s TIME_FUNC_0%s\n",$1,$2)}' |\
#awk 'BEGIN{last_id=""}{if($2!=last_id){print};last_id=$2}'>fom_arrival_times_and_msg_ids_for_j3_0.txt

#we look only at J3.7 with platform , i.e with C4 word
# to find platform position in hexa easily , we assume we are receiving each of the codewords  I/C1/C4
# and no other one

#awk '{if(($3=="0F030700")&&((substr($22,3))=="11")||(substr($22,3)=="91")){print}}' $DATA_LINK_FILE|\
#awk  -f ./get_value_from_data.awk -v nb_bit=6 -v pos_value=167 -v data_type=jo |\
#awk '{printf("%s PLAT_%s\n",$1,$2)}' |\
#awk 'BEGIN{last_id=""}{if($2!=last_id){print};last_id=$2}'>fom_arrival_times_and_msg_ids_for_j3_7.txt

#cat fom_arrival_times_and_msg_ids_for_j*.txt|sort -u |grep ":">fom_arrival_times_and_msg_ids.txt


#fom_arrival_times_and_msg_ids.txt

echo "searching for each MSG_ID delta time between reception of DL message and forwarding of adh to host ..."

LIST_OF_MSG_ID_FROM_DATA_LINK=`awk '{print $2}' fim_arrival_times_and_msg_ids.txt|sort -u`
#echo "list of MSG_ID to be processed is :      "$LIST_OF_MSG_ID_FROM_DATA_LINK

for MSG_ID in $LIST_OF_MSG_ID_FROM_DATA_LINK;do 
   echo "processing MSG_ID "$MSG_ID"..."
   ###########################################################
   # compute  messages times for id MSG_ID in XHD/DATA LINK files
   ###########################################################
   grep $MSG_ID fim_arrival_times_and_msg_ids.txt>fim_arrival_times_for_msg_id_${MSG_ID}.txt
   grep $MSG_ID xhd_arrival_times_and_msg_ids.txt>xhd_arrival_times_for_msg_id_${MSG_ID}.txt

  ###########################################################
   # verify the number of message received and transmitted to host
   ###########################################################
   NB_MSG_FIM=`cat fim_arrival_times_for_msg_id_${MSG_ID}.txt| wc -l`
   NB_MSG_XHD=`cat xhd_arrival_times_for_msg_id_${MSG_ID}.txt| wc -l`
   NB_MSG_LOST=`expr $NB_MSG_XHD - $NB_MSG_FIM`;
   echo " $NB_MSG_XHD , $NB_MSG_FIM"
   if ([[ $NB_MSG_FIM -ne $NB_MSG_XHD ]]) then
   	echo " $MSG_ID : $NB_MSG_LOST msg lost !!! " 
  	echo " $MSG_ID : $NB_MSG_LOST msg lost !!! " >> tx_lost_message.txt
   else
	echo "$MSG_ID" >>  tx_list_of_MSG_ID_not_lost.txt
   
   	###########################################################
   	# merge XHD/DATA LINK  times of messages of id MSG_ID
   	###########################################################
   	cat fim_arrival_times_for_msg_id_${MSG_ID}.txt xhd_arrival_times_for_msg_id_${MSG_ID}.txt>arrival_times_for_${MSG_ID}.txt
   	sort  arrival_times_for_${MSG_ID}.txt>sorted_arrival_times_for_${MSG_ID}.txt

   	###########################################################
   	# compute data link messages processing time
   	###########################################################
   	awk 'function to_sec(x){hour=0.0+substr(x,1,2);min=0.0+substr(x,4,2);sec=0.0+substr(x,7,2);msec=substr(x,9,4);res=3600*hour+60*min+sec;return sprintf("%s%s",res,msec)};BEGIN{msg_id_processed=0;prev_time=0;prev_msg_id=$2}{if(($2==prev_msg_id)&&!msg_id_processed){printf("%s %f\n",prev_time, to_sec($1)-to_sec(prev_time));msg_id_processed=1}else{msg_id_processed=0};prev_time=$1;prev_msg_id=$2}' sorted_arrival_times_for_${MSG_ID}.txt>tx_delta_times_and_j_reception_time_for_${MSG_ID}.txt
   	awk '{print $2}' tx_delta_times_and_j_reception_time_for_${MSG_ID}.txt >tx_delta_times_for_${MSG_ID}.txt
  fi
  rm -f arrival_times_for_${MSG_ID}.txt 
  rm -f sorted_arrival_times_for_${MSG_ID}.txt
done

LIST_OF_MSG_ID_NOT_LOST=`cat tx_list_of_MSG_ID_not_lost.txt`

#  /bin/rm tx_delta_time_for_dl_processing.txt
  touch tx_delta_time_for_dl_processing.txt
#  /bin/rm tmp_delta_time_for_dl_processing.txt
  touch tmp_delta_time_for_dl_processing.txt

#  /bin/rm tx_delta_time_and_j_reception_time_for_dl_processing.txt
  touch tx_delta_time_and_j_reception_time_for_dl_processing.txt
#  /bin/rm tmp_delta_time_and_j_reception_time_for_dl_processing.txt
  touch tmp_delta_time_and_j_reception_time_for_dl_processing.txt

  echo "merging result of all MSG_IDs ..."

  for MSG_ID in $LIST_OF_MSG_ID_NOT_LOST;do 
   echo "processing MSG_ID "$MSG_ID"..."

    cat tx_delta_times_for_${MSG_ID}.txt tx_delta_time_for_dl_processing.txt>tmp_delta_time_for_dl_processing.txt
    mv tmp_delta_time_for_dl_processing.txt tx_delta_time_for_dl_processing.txt

    cat tx_delta_times_and_j_reception_time_for_${MSG_ID}.txt \
          tx_delta_time_and_j_reception_time_for_dl_processing.txt>tmp_delta_time_and_j_reception_time_for_dl_processing.txt
    mv tmp_delta_time_and_j_reception_time_for_dl_processing.txt  tx_delta_time_and_j_reception_time_for_dl_processing.txt

  done
  rm -f tx_delta_times_and_j_reception_time_for_${MSG_ID}.txt 

echo "compute max and min delta_time ...(remove delta times >4)"
  awk 'BEGIN{max=-1000;min=1000}{if($1<4){if(max<$1){max=$1};if(min>$1){min=$1}}}END{printf("%s %s\n",min,max)}' tx_delta_time_for_dl_processing.txt>tx_max_and_min_delta_time.txt

  MIN_DELTA_TIME=`awk '{print $1}' ./tx_max_and_min_delta_time.txt`
  MAX_DELTA_TIME=`awk '{print $2}' ./tx_max_and_min_delta_time.txt`

  echo "min delta_time="$MIN_DELTA_TIME
  echo "max delta_time="$MAX_DELTA_TIME
  
  echo "compute delta_time distribution...(remove delta times >4) (file : tx_distrib_delta_time.txt)"
  NB_SAMPLES_IN_DISTRIB=$3
  NB_OF_DELTA=`cat tx_delta_time_for_dl_processing.txt|wc -l|tr -d " "`

  echo "nb of delta_time value "$NB_OF_DELTA

  DIST_QUANT=`awk '{print ($2-$1)/'$NB_SAMPLES_IN_DISTRIB'}' tx_max_and_min_delta_time.txt`

   awk -v nb_delta=$NB_OF_DELTA  -v nb_samp=$NB_SAMPLES_IN_DISTRIB 'BEGIN{for(i=0;i<nb_samp;i++){v[i]=0}}{for(i=0;i<nb_samp;i++){if(($1>'$MIN_DELTA_TIME'+i*'$DIST_QUANT')&&($1<'$MIN_DELTA_TIME'+(i+1)*'$DIST_QUANT')){v[i]++}}}END{for(i=0;i<nb_samp;i++){printf("%f to %f     %f  %f pourc.\n",'$MIN_DELTA_TIME'+i*'$DIST_QUANT','$MIN_DELTA_TIME'+(i+1)*'$DIST_QUANT',v[i],v[i]/nb_delta)}}' tx_delta_time_for_dl_processing.txt|tee tx_distrib_delta_time.txt


   echo "computing mean value ..."

   awk -v nb_delta=$NB_OF_DELTA  'BEGIN{mean=0}{mean+=$1}END{print mean/nb_delta}' tx_delta_time_for_dl_processing.txt


   echo "compute time evolution of delta_time value (removing delta_time >4) (file tx_evol_delta_time.txt)"

   sort  tx_delta_time_and_j_reception_time_for_dl_processing.txt |awk '{if($2<=4){print}}'> tx_sorted_delta_time_and_j_reception_time_for_dl_processing.txt

   awk 'function to_sec(x){hour=0.0+substr(x,1,2);min=0.0+substr(x,4,2);sec=0.0+substr(x,7,2);msec=substr(x,9,4);res=3600*hour+60*min+sec;return sprintf("%s%s",res,msec)};{printf("%f %s\n",to_sec($1),$2)}'  tx_sorted_delta_time_and_j_reception_time_for_dl_processing.txt > tx_evol_delta_time.txt
