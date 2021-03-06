touch result.txt
TMP_FILE=./tmp/tmp.xhd
TMP_FILE2=./tmp/tmp2.xhd
TMP_OUTPUT_FILE=./tmp/tmp_init_result.xhd
TMP_TN_FILE=./tmp/tmp_tn_list.txt # nom du fichier listant les TN g�n�r�s
ROOT_CMD_LOCATION=.
TEMPLATE_LOCATION=./template      # r�pertoire ou se trouvent les template
SYSTN_101=1000
SYSTN_106=1100
SYSTN_107=1200
SYSTN_109=1300
SYSTN_117=1400

################################################
# Parametres  AHD109
################################################
AHD109_NBR=0
AHD109_REC_RATE=1     # en sec
AHD109_REC_MIN=0      # nbre minute de la recurrence
AHD109_REC_SEC=1      # nbre seconde de la recurrence
AHD109_DELTA_TIME=2   # en sec 
		      # dur�e pendant laquelle sont �mis les AHD10x
                      # chaque message est �mis 2 fois
                      # delta_time = REC_RATE * 2
AHD109_DELTA_NBR=0  # nbre de r�ccurrence de chaque AHD10x
		      # DELTA_NBR*DELTA_TIME = CONSTANTE = 768
################################################
# Parametres  AHD107
################################################
AHD107_NBR=0
AHD107_REC_RATE=1     # en sec
AHD107_REC_MIN=0      # nbre minute de la recurrence
AHD107_REC_SEC=1      # nbre seconde de la recurrence
AHD107_DELTA_TIME=2   # en sec 
		      # dur�e pendant laquelle sont �mis les AHD10x
                      # chaque message est �mis 2 fois
                      # delta_time = REC_RATE * 2
AHD107_DELTA_NBR=0  # nbre de r�ccurrence de chaque AHD10x
		      # DELTA_NBR*DELTA_TIME = CONSTANTE = 768
################################################
# Parametres  AHD101
################################################
AHD101_NBR=5
AHD101_REC_RATE=1     # en sec
AHD101_REC_MIN=0      # nbre minute de la recurrence
AHD101_REC_SEC=1      # nbre seconde de la recurrence
AHD101_DELTA_TIME=2   # dur�e pendant laquelle sont �mis les AHD10x
                      # chaque message est �mis 2 fois
                      # delta_time = REC_RATE * 2
AHD101_DELTA_NBR=384  # nbre de r�ccurrence de chaque AHD10x
################################################
# Parametres  AHD106
################################################
AHD106_NBR=0
AHD106_REC_RATE=1     # en sec
AHD106_REC_MIN=0      # nbre minute de la recurrence
AHD106_REC_SEC=1      # nbre seconde de la recurrence
AHD106_DELTA_TIME=2   # dur�e pendant laquelle sont �mis les AHD10x
                      # chaque message est �mis 2 fois
                      # delta_time = REC_RATE * 2
AHD106_DELTA_NBR=0  # nbre de r�ccurrence de chaque AHD10x
################################################
# Nbre de AHD190 en reponse au J9.0
################################################
AHD190_NBR=0

/bin/rm -f $TMP_TN_FILE;touch $TMP_TN_FILE
/bin/rm -f $TMP_OUTPUT_FILE;touch $TMP_OUTPUT_FILE

function register_tn_created
######################################
# purpose : register link TN to drop at the end of
#    each 45 min period 
# parameters :
#  - $1 = Link Track Number
#######################################
{
 echo $1>>$TMP_TN_FILE
}

function list_of_tns_to_drop
{
  cat $TMP_TN_FILE
}



function clear_tmp_file
{
  /bin/rm $TMP_FILE
  touch $TMP_FILE
}

function extract_from_templates
######################################
# parameters :
#  - $1 = AHD number
#######################################
{
 for f in $TEMPLATE_LOCATION/template_load_test*.*hd 
 do
    awk '{for(i=2;i<=NF;i++){printf("%s",$i)};print("\n");}' $f | \
         awk -v numero=$1 '{if(index($0,numero)==13){for(i=1;i<=length($0);i+=2){printf("%s ",substr($0,i,2))}}}' 
 done

}

function duplicate_and_translate_in_time_xhd_file
######################################
# parameters :
#  - $1 = file to translate/duplicate
#  - $2 = translation value (second)
#  - $3 = repetition value
#######################################
{
 #/bin/rm -f ./tmp/tmp_file_to_translate.ji 
 #touch      ./tmp/tmp_file_to_translate.ji 
 local_compt=0;
 while [[ $local_compt -lt  $3 ]] ;do 
   delta_time=`echo|awk '{print '$local_compt'*'$2'}'`
   time_to_add_in_hour_min_sec=`echo $delta_time|awk -f ./to_hour_minute_second.awk`
#echo $time_to_add_in_hour_min_sec
   hour=`echo $time_to_add_in_hour_min_sec |cut -f1 -d':'`
   minute=`echo $time_to_add_in_hour_min_sec |cut -f2 -d':'`
   second=`echo $time_to_add_in_hour_min_sec |cut -f3 -d':'|cut -f1 -d'.'`
   milisecond=`echo $time_to_add_in_hour_min_sec |cut -f2 -d'.'|cut -f1`
   add_time.sh $1 $hour $minute $second $milisecond >> $TMP_OUTPUT_FILE
   local_compt=`expr $local_compt + 1`;
    #echo "$local_compt"
 done
}

####################################################################################
# this test use MARTHA DLIP and L16 nato data link
# warning : in  MARTHA program  J2.3/J3.6 are not implemented they will be replaced 
# resp by J2.2/J3.2 : to be replaced when doing test with SAMP/T exe
##############################################################################

AHD101=`extract_from_templates 0065`
AHD106=`extract_from_templates 006A`
AHD107=`extract_from_templates 006B`
AHD109=`extract_from_templates 006D`
AHD110=`extract_from_templates 006E`
AHD190=`extract_from_templates 00BE`
AHD121=`extract_from_templates 0079`


################################################
echo " Make periodic sequence for AHD107 :4 in 96 sec"
#
#  to force reschedule at each AHD107 reception 
#  we create first 4 AHD107 with speed=1.5 DM/hour
#  and then 4 with speed=25.5 DM/hour
################################################

clear_tmp_file
sys_tn=$SYSTN_107
sce_time=0 
compt=0
other_speed=0 # 0 to not modify speed : no retransmission is required



# TIME_FUNCTION 'll be useful to link AHD107 received by DLIP with corresp. J3.0 emitted
# important to be able to compute AHD10x processing time
time_function=0; 

#Pour chaque AHD107 �criture de 2 msg avec des speed et time func diff�rente
# 
while [[ $compt -lt  $AHD107_NBR ]] ;do 
  AHD_WITH_TN=`insert_value_into_ahd.sh dec 16 128 $sys_tn $sce_time" $AHD107" |awk -f ./to_hour_minute_second.awk` 
  AHD_WITH_TIME_FUNC=`insert_value_into_ahd.sh dec 8 184 $time_function  "$AHD_WITH_TN"` 
  echo "$AHD_WITH_TIME_FUNC" >> $TMP_FILE
  # make message with same TN and speed changed to force reschedule
  # (original message extracted from template file had a speed of 1.5 DM/hour)
  AHD_WITH_TIME_FUNC_AND_SPEED_CHANGED=`insert_value_into_ahd.sh dec 16 296 $other_speed  "$AHD_WITH_TIME_FUNC"`
  # translate this message from 96 second (1 min 36 sec)
  echo "$AHD_WITH_TIME_FUNC_AND_SPEED_CHANGED"|add_time.sh "" 0 $AHD107_REC_MIN $AHD107_REC_SEC 0 >> $TMP_FILE
  register_tn_created $sys_tn
  sys_tn=`expr $sys_tn + 1`;
  compt=`expr $compt + 1`;
  time_function=`expr $time_function + 1`;
  sce_time=`echo |awk '{print '$compt'*'$AHD107_REC_RATE'/'$AHD107_NBR'}'`;
# sce_time=`echo |awk '{print '$compt'*96/4}'`;
done

duplicate_and_translate_in_time_xhd_file $TMP_FILE $AHD107_DELTA_TIME $AHD107_DELTA_NBR

################################################
echo " Make periodic sequence for AHD109 :4 in 96 sec"
#
#  to force reschedule at each AHD109 reception 
#  we create first 4 AHD107 with speed=1.5 DM/hour
#  and then 4 with speed=25.5 DM/hour
################################################

clear_tmp_file
sys_tn=$SYSTN_109
sce_time=0 
compt=0
xvelocity=0 # 0 to not modify speed : no retransmission is required

# TIME_FUNCTION 'll be useful to link AHD109 received by DLIP with corresp. J3.0 emitted
# important to be able to compute AHD10x processing time
minute=0; 

#Pour chaque AHD109 �criture de 2 msg avec des speed et time func diff�rente
# 
while [[ $compt -lt  $AHD109_NBR ]] ;do 
  AHD_WITH_TN=`insert_value_into_ahd.sh dec 16 128 $sys_tn $sce_time" $AHD109" |awk -f ./to_hour_minute_second.awk` 
  AHD_WITH_MINUTE=`insert_value_into_ahd.sh dec 8 192 $minute  "$AHD_WITH_TN"` 
  echo "$AHD_WITH_MINUTE" >> $TMP_FILE
  # make message with same TN and speed changed to force reschedule
  # (original message extracted from template file had a speed of 1.5 DM/hour)
  AHD_WITH_MINUTE_AND_SPEED_CHANGED=`insert_value_into_ahd.sh dec 16 360 $xvelocity  "$AHD_WITH_MINUTE"`
  # translate this message from 96 second (1 min 36 sec)
  echo "$AHD_WITH_MINUTE_AND_SPEED_CHANGED"|add_time.sh "" 0 $AHD109_REC_MIN $AHD109_REC_SEC 0 >> $TMP_FILE
  register_tn_created $sys_tn
  sys_tn=`expr $sys_tn + 1`;
  compt=`expr $compt + 1`;
  minute=`expr $minute + 1`;
  sce_time=`echo |awk '{print '$compt'*'$AHD109_REC_RATE'/'$AHD109_NBR'}'`;
# sce_time=`echo |awk '{print '$compt'*96/4}'`;
done

duplicate_and_translate_in_time_xhd_file $TMP_FILE $AHD109_DELTA_TIME $AHD109_DELTA_NBR


################################################
echo " Make periodic sequence for AHD101 :54 in 12 sec"
#  (warning 4 of these AHD101 will be AHD space track  when using SAMPT exe)
#
#  to force reschedule at each AHD101 reception 
#  we create first 54 AHD101 with IFF mode II between 1 and 54
#  and then 54 AHD101 with IFF mode II between 1000 and 1054
################################################

clear_tmp_file
sys_tn=$SYSTN_101
sce_time=0 
compt=0

# IFF 'll be useful to link AHD101 received by DLIP with corresp. J3.2 emitted
# important to be able to compute AHD10x processing time
iff=0; 
other_iff=0; 

while [[ $compt -lt $AHD101_NBR ]] ;do 
  AHD_WITH_TN=`insert_value_into_ahd.sh dec 16 128 $sys_tn $sce_time" $AHD101" |awk -f ./to_hour_minute_second.awk `
  AHD_WITH_TN_AND_IFF=`insert_value_into_ahd.sh dec 16 472 $iff  "$AHD_WITH_TN" `
  echo "$AHD_WITH_TN_AND_IFF" >>$TMP_FILE
  # make message with same TN and mode II IFF changed to force reschedule
  AHD_WITH_TN_AND_OTHER_IFF=`insert_value_into_ahd.sh dec 16 472 $other_iff  "$AHD_WITH_TN" `
  echo "$AHD_WITH_TN_AND_OTHER_IFF"|add_time.sh "" 0 $AHD101_REC_MIN $AHD101_REC_SEC 0 >> $TMP_FILE
  register_tn_created $sys_tn
  sys_tn=`expr $sys_tn + 1`;
  compt=`expr $compt + 1`;
  iff=`expr $iff + 1`;
  other_iff=`expr $other_iff + 1`;
  sce_time=`echo |awk '{print '$compt'*'$AHD101_REC_RATE'/'$AHD101_NBR'}'`;
done

duplicate_and_translate_in_time_xhd_file $TMP_FILE $AHD101_DELTA_TIME $AHD101_DELTA_NBR

################################################
echo " Make periodic sequence for AHD106 :10 in 48 sec"
#
#  to force reschedule at each AHD106 reception 
#  we create first 10 AHD106 with platform between 1 and 10
#  and then 10 AHD106 with platform between 20 and 30
################################################

clear_tmp_file
sys_tn=$SYSTN_106
sce_time=0 
compt=0

# Platform 'll be useful to link AHD106 received by DLIP with corresp. J3.7 emitted
# important to be able to compute AHD10x processing time
identity=0; 
bearing=1;

while [[ $compt -lt  $AHD106_NBR ]] ;do 
  AHD_WITH_TN=`insert_value_into_ahd.sh dec 16 128 $sys_tn $sce_time" $AHD106" |awk -f ./to_hour_minute_second.awk` 
  AHD_WITH_TN_AND_BEAR=`insert_value_into_ahd.sh dec  8 400 $bearing "$AHD_WITH_TN" ` 
  echo "$AHD_WITH_TN_AND_BEAR" >>$TMP_FILE
  AHD_WITH_TN_BEAR_AND_OTHER_ID=`insert_value_into_ahd.sh dec 8 488 $identity  "$AHD_WITH_TN_AND_BEAR" ` 
  echo "$AHD_WITH_TN_BEAR_AND_OTHER_ID" |add_time.sh "" 0 $AHD106_REC_MIN $AHD106_REC_SEC 0 >>$TMP_FILE

 register_tn_created $sys_tn
  sys_tn=`expr $sys_tn + 1`;
  compt=`expr $compt + 1`;
  bearing=`expr $bearing + 1`;
  sce_time=`echo |awk '{print '$compt'*'$AHD106_REC_RATE'/'$AHD106_NBR'}'`;
done

duplicate_and_translate_in_time_xhd_file $TMP_FILE $AHD106_DELTA_TIME $AHD106_DELTA_NBR

##############################################################
# Make response to J9.0 messages : 6  AHD190 in 45 minutes
##############################################################

#clear_tmp_file
#sce_init_time=6; #wait all air tracks are defined in xhd file
#sce_time=$sce_init_time 
#export compt=0
#while [[ $compt -lt  $AHD190_NBR ]] ;do 
#  printf "DONT_REPEAT_IN_BASE_SCENARIO ">> $TMP_OUTPUT_FILE;echo $sce_time" $AHD190" |awk -f ./to_hour_minute_second.awk >> $TMP_OUTPUT_FILE
#  compt=`expr $compt + 1`;
#  sce_time=`echo |awk '{print '$sce_init_time'+'$compt'*2}'`;
#done

################################################
echo " Make AHD10x/110 for originator (J2.2(TN=1)) of J9.0 messages"
################################################

printf "DONT_REPEAT_IN_BASE_SCENARIO ">> $TMP_OUTPUT_FILE; echo "00:00:02.001"" $AHD110" >> $TMP_OUTPUT_FILE

################################################
echo " Make final AHD121 messages drop"
################################################

clear_tmp_file
sce_time=0 
compt=0
for stn in `list_of_tns_to_drop` ;do 
  printf "DROP_MSG ">> $TMP_OUTPUT_FILE;insert_value_into_ahd.sh dec 16 128 $stn $sce_time" $AHD121" |awk -f ./to_hour_minute_second.awk >> $TMP_OUTPUT_FILE
  compt=`expr $compt + 1`;
  sce_time=`echo |awk '{print '$compt'/10}'`;
done

