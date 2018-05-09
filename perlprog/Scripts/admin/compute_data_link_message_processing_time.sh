if ([[ $# -ne 3 ]]) then
  echo "usage :"$0" file.fom file.xdh nb_samples_in_distrib"
  exit 1
fi
# Fichiers .fom et .xdh en argument
XDH_FILE=$2
DATA_LINK_FILE=$1


echo " extraction of TNs and times for adh10x (surveillance messages)..."
# awk '{if((substr($3,1,2)=="01")&&(substr($3,7,2)>="65")&&(substr($3,7,2)<="6D")){printf("%s %s%s\n",$1,$16,$17)}}' $XDH_FILE>xdh_arrival_times_and_tns.txt
# remplacement de la commande awk par le script perl suivant
extract_TN_date_from_xdh.pl -f $2

echo " extraction of TNs and times for J3.x/J2.x (surveillance messages) from "$DATA_LINK_FILE"..."
# a adapter au format .fom
# awk '{if((substr($42,3,2)=="8C")||(substr($42,3,2)=="0C")||(substr($42,3,2)=="0B")||(substr($42,3,2)=="8B")){TN=sprintf("%s%s",$44,$43);numb="123456789ABCDEF";TN_DEC=0;mult=1;for(i=8;i>=1;i--){TN_DEC+=mult*index(numb,substr(TN,i,1));mult*=16;};TN_DEC=int(TN_DEC/8)%(2**19);printf("%s %0.8X\n",$1,TN_DEC);}}' $DATA_LINK_FILE>ind_rep_apu_arrival_times_and_tns.txt
# remplacement de la commande awk par le script perl suivant
extract_TN_date_from_fom.pl -f $1

# à partir de ce point pas de changement ?!
echo "searching for each TN delta time between reception of DL message and forwarding of adh to host ..."
LIST_OF_TN_FROM_DATA_LINK=`awk '{print $2}' ./fom_arrival_times_and_tns.txt|sort -u`

#echo "list of TN to be processed is :      "$LIST_OF_TN_FROM_DATA_LINK

rm -f rx_lost_message.txt
touch rx_lost_message.txt
rm -f rx_list_of_TN_not_lost.txt
touch rx_list_of_TN_not_lost.txt

for TN in $LIST_OF_TN_FROM_DATA_LINK;do 
   echo "processing TN "$TN"..."
   ###########################################################
   # compute  messages times for track number TN in XDH/DATA LINK files
   ###########################################################
 #  grep $TN ./fom_arrival_times_and_tns.txt>./fom_arrival_times_for_tn_${TN}.txt
 #  grep $TN ./xdh_arrival_times_and_tns.txt>./xdh_arrival_times_for_tn_${TN}.txt
 extract_by_TN.pl -t $TN -f fom_arrival_times_and_tns.txt
 extract_by_TN.pl -t $TN -f xdh_arrival_times_and_tns.txt
   
   ###########################################################
   # verify the number of message received and transmitted to host
   ###########################################################
   NB_MSG_FOM=`cat fom_arrival_times_and_tns_${TN}.txt | wc -l`
   NB_MSG_XDH=`cat  xdh_arrival_times_and_tns_${TN}.txt | wc -l`
   NB_MSG_LOST=`expr $NB_MSG_FOM - $NB_MSG_XDH`;
   echo " $NB_MSG_XDH , $NB_MSG_FOM"
   if ([[ $NB_MSG_FOM -ne $NB_MSG_XDH ]]) then
   	echo " $TN : $NB_MSG_LOST msg lost !!! " 
  	echo " $TN : $NB_MSG_LOST msg lost !!! " >> rx_lost_message.txt
	
   else
	echo "$TN" >>  rx_list_of_TN_not_lost.txt
  	
   	###########################################################
   	# merge XDH/DATA LINK  times of messages of track number TN
   	###########################################################
   	cat ./fom_arrival_times_and_tns_${TN}.txt ./xdh_arrival_times_and_tns_${TN}.txt>./arrival_times_for_${TN}.txt
    	sort arrival_times_for_${TN}.txt>./sorted_arrival_times_for_${TN}.txt
   	   
   	#wc -l ./sorted_arrival_times_for_${TN}.txt|awk '{if($1%2!=0){print "some messages for TN "'$TN'" are lost!!!!"}}'
   	###########################################################
   	# compute data link messages processing time
   	###########################################################
   	awk 'function to_sec(x){hour=0.0+substr(x,1,2);min=0.0+substr(x,4,2);sec=0.0+substr(x,7,2);msec=substr(x,9,4);res=3600*hour+60*min+sec;return sprintf("%s%s",res,msec)};BEGIN{tn_processed=0;prev_time=0;prev_tn=$2}{if(($2==prev_tn)&&!tn_processed){printf("%s %f\n",prev_time, to_sec($1)-to_sec(prev_time));tn_processed=1}else{tn_processed=0};prev_time=$1;prev_tn=$2}' ./sorted_arrival_times_for_${TN}.txt>./rx_delta_times_and_j_reception_time_for_${TN}.txt
   	awk '{print $2}' ./rx_delta_times_and_j_reception_time_for_${TN}.txt > ./rx_delta_times_for_${TN}.txt
   fi
   # Remove tmporary files
   # rm -f ./fom_arrival_times_and_tns_${TN}.txt ./xdh_arrival_times_and_tns_${TN}.txt 
   rm -f ./arrival_times_for_${TN}.txt
   rm -f ./sorted_arrival_times_for_${TN}.txt
done

LIST_OF_TN_FROM_DATA_LINK_NOT_LOST=`cat rx_list_of_TN_not_lost.txt`

#rm list_of_TN_not_lost.txt
  rm ./rx_delta_time_for_dl_processing.txt
  touch ./rx_delta_time_for_dl_processing.txt
  rm ./rx_delta_time_and_j_reception_time_for_dl_processing.txt
  touch ./rx_delta_time_and_j_reception_time_for_dl_processing.txt
 
  echo "merging result of all TNs ..."

  for TN in $LIST_OF_TN_FROM_DATA_LINK_NOT_LOST;do 
   echo "processing TN not lost "$TN"..."

    cat ./rx_delta_times_for_${TN}.txt >> ./rx_delta_time_for_dl_processing.txt

    cat ./rx_delta_times_and_j_reception_time_for_${TN}.txt >> ./rx_delta_time_and_j_reception_time_for_dl_processing.txt
    rm -f ./rx_delta_times_and_j_reception_time_for_${TN}.txt
  done

echo "compute max and min delta_time ...(remove delta times >4)"
  awk 'BEGIN{max=-1000;min=1000}{if($1<4){if(max<$1){max=$1};if(min>$1){min=$1}}}END{printf("%s %s\n",min,max)}' ./rx_delta_time_for_dl_processing.txt>./rx_max_and_min_delta_time.txt

  MIN_DELTA_TIME=`awk '{print $1}' ./rx_max_and_min_delta_time.txt`
  MAX_DELTA_TIME=`awk '{print $2}' ./rx_max_and_min_delta_time.txt`

  echo "min delta_time="$MIN_DELTA_TIME
  echo "max delta_time="$MAX_DELTA_TIME
  
  echo "compute delta_time distribution...(remove delta times >4) (file : rx_distrib_delta_time.txt)"
  NB_SAMPLES_IN_DISTRIB=$3
  NB_OF_DELTA=`cat ./rx_delta_time_for_dl_processing.txt|wc -l|tr -d " "`

  echo "nb of delta_time value "$NB_OF_DELTA

  DIST_QUANT=`awk '{print ($2-$1)/'$NB_SAMPLES_IN_DISTRIB'}' ./rx_max_and_min_delta_time.txt`

   awk -v nb_delta=$NB_OF_DELTA  -v nb_samp=$NB_SAMPLES_IN_DISTRIB 'BEGIN{for(i=0;i<nb_samp;i++){v[i]=0}}{for(i=0;i<nb_samp;i++){if(($1>'$MIN_DELTA_TIME'+i*'$DIST_QUANT')&&($1<'$MIN_DELTA_TIME'+(i+1)*'$DIST_QUANT')){v[i]++}}}END{for(i=0;i<nb_samp;i++){printf("%f to %f     %f  %f pourc.\n",'$MIN_DELTA_TIME'+i*'$DIST_QUANT','$MIN_DELTA_TIME'+(i+1)*'$DIST_QUANT',v[i],v[i]/nb_delta)}}' ./rx_delta_time_for_dl_processing.txt|tee ./rx_distrib_delta_time.txt

   echo "computing mean value ..."

   awk -v nb_delta=$NB_OF_DELTA  'BEGIN{mean=0}{mean+=$1}END{print mean/nb_delta}' ./rx_delta_time_for_dl_processing.txt


   echo "compute time evolution of delta_time value (removing delta_time >4) (file rx_evol_delta_time.txt)"

   sort  ./rx_delta_time_and_j_reception_time_for_dl_processing.txt |awk '{if($2<=4){print}}' > ./rx_sorted_delta_time_and_j_reception_time_for_dl_processing.txt

   awk 'function to_sec(x){hour=0.0+substr(x,1,2);min=0.0+substr(x,4,2);sec=0.0+substr(x,7,2);msec=substr(x,9,4);res=3600*hour+60*min+sec;return sprintf("%s%s",res,msec)};{printf("%f %s\n",to_sec($1),$2)}'  ./rx_sorted_delta_time_and_j_reception_time_for_dl_processing.txt > rx_evol_delta_time.txt
