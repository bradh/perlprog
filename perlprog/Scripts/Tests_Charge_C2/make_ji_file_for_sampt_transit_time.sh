# S. MOUCHOT le 4/12/2006
# ajout des messages J10.2 en complement FQR C2

#!/bin/ksh
#touch result.txt
TMP_FILE=./tmp/tmp.ji
TMP_TN_FILE=./tmp/tmp_tn_list.txt
TMP_OUTPUT_FILE=./tmp/tmp_init_result.ji
ROOT_CMD_LOCATION=.
TEMPLATE_LOCATION=./template
OWN_PLATFORM_LTN=7
DIST_SOURCE_TN=8
LTN_J2_2=1200
LTN_J2_3=1300
LTN_J2_5=1400
LTN_J3_0=1500
LTN_J3_2=1700
LTN_J3_5=2200
LTN_J3_6=2300
LTN_J3_7=2400

########################################
# Nombre de J9.0
########################################
J9_0_NBR=6
################################################
# Parametres  J2.2
################################################
J2_2_NBR=20	    # au lieu de 10
J2_2_REC_RATE=12    # en sec
J2_2_REC_MIN=0      # nbre minute de la recurrence
J2_2_REC_SEC=12     # nbre seconde de la recurrence
J2_2_DELTA_TIME=12  # durée pendant laquelle sont émis les J
                    # chaque message est émis 1 fois
                    # delta_time = REC_RATE 
J2_2_DELTA_NBR=64   # nbre de réccurrence de chaque J
		    # DELTA_NBR * DELTA_TIME = CONSTANTE = 768

################################################
# Parametres  J2.3
################################################
J2_3_NBR=30         # au lieu de 10  
J2_3_REC_RATE=12    # en sec
J2_3_REC_MIN=0      # nbre minute de la recurrence
J2_3_REC_SEC=12     # nbre seconde de la recurrence
J2_3_DELTA_TIME=12  # durée pendant laquelle sont émis les J
                     # chaque message est émis 1 fois
                     # delta_time = REC_RATE 
J2_3_DELTA_NBR=64    # nbre de réccurrence de chaque J
################################################
# Parametres  J2.5
################################################
J2_5_NBR=30          # au lieu de 10
J2_5_REC_RATE=12    # en sec
J2_5_REC_MIN=0      # nbre minute de la recurrence
J2_5_REC_SEC=12     # nbre seconde de la recurrence
J2_5_DELTA_TIME=12  # durée pendant laquelle sont émis les J
                      # chaque message est émis 1 fois
                      # delta_time = REC_RATE 
J2_5_DELTA_NBR=64    # nbre de réccurrence de chaque J
################################################
# Parametres  J3.0
################################################
J3_0_NBR=60          # 10
J3_0_REC_RATE=768   # en sec
J3_0_REC_MIN=12     # nbre minute de la recurrence
J3_0_REC_SEC=48     # nbre seconde de la recurrence
J3_0_DELTA_TIME=768 # durée pendant laquelle sont émis les J
                    # chaque message est émis 1 fois
                    # delta_time = REC_RATE 
J3_0_DELTA_NBR=1   # nbre de réccurrence de chaque J
################################################
# Parametres  J3.2
################################################
J3_2_NBR=240        #
J3_2_REC_RATE=12    # en sec
J3_2_REC_MIN=0      # nbre minute de la recurrence
J3_2_REC_SEC=12     # nbre seconde de la recurrence
J3_2_DELTA_TIME=12  # durée pendant laquelle sont émis les J
                      # chaque message est émis 1 fois
                      # delta_time = REC_RATE 
J3_2_DELTA_NBR=64    # nbre de réccurrence de chaque J
################################################
# Parametres  J3.6
################################################
J3_6_NBR=3          #
J3_6_REC_RATE=12    # en sec
J3_6_REC_MIN=0      # nbre minute de la recurrence
J3_6_REC_SEC=12     # nbre seconde de la recurrence
J3_6_DELTA_TIME=12  # durée pendant laquelle sont émis les J
                     # chaque message est émis 1 fois
                     # delta_time = REC_RATE 
J3_6_DELTA_NBR=64    # nbre de réccurrence de chaque J
################################################
# Parametres  J3.5
################################################
J3_5_NBR=20         #
J3_5_REC_RATE=96    # en sec
J3_5_REC_MIN=1      # nbre minute de la recurrence
J3_5_REC_SEC=36     # nbre seconde de la recurrence
J3_5_DELTA_TIME=96  # durée pendant laquelle sont émis les J
                    # chaque message est émis 1 fois
                    # delta_time = REC_RATE 
J3_5_DELTA_NBR=8    # nbre de réccurrence de chaque J

################################################
# Parametres  J3.7
################################################
J3_7_NBR=12
J3_7_REC_RATE=48    # en sec
J3_7_REC_MIN=0      # nbre minute de la recurrence
J3_7_REC_SEC=48     # nbre seconde de la recurrence
J3_7_DELTA_TIME=48  # durée pendant laquelle sont émis les J
                    # chaque message est émis 1 fois
                    # delta_time = REC_RATE 
J3_7_DELTA_NBR=16   # nbre de réccurrence de chaque J

/bin/rm -f $TMP_TN_FILE;touch $TMP_TN_FILE
/bin/rm -f $TMP_OUTPUT_FILE;touch $TMP_OUTPUT_FILE

################################################
# Parametres  J10.2
################################################
J10_2_NBR=1
J10_2_REC_RATE=24    # en sec
J10_2_REC_MIN=0      # nbre minute de la recurrence
J10_2_REC_SEC=24     # nbre seconde de la recurrence
J10_2_DELTA_TIME=48  # durée pendant laquelle sont émis les J
                    # chaque message est émis 1 fois
                    # delta_time = REC_RATE 
J10_2_DELTA_NBR=16   # nbre de réccurrence de chaque J

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
#######################################
# parameters :
#  - $1 = J label
#  - $2 = J sublabel
#  - $3 = index (used with  J3.0 )
#######################################
{
 if ([[ `grep 0E0${1}0${2}00 $TEMPLATE_LOCATION/template_load_test_l16_nato.ji|wc -l` -eq 0 ]]) then
   echo "J"$1"."$2" has not been found in th e following template files !!!:"
   ls $TEMPLATE_LOCATION/template_load_test_*.ji
   exit 1
 fi

 #if ([[ $1 -ne 3 ]]||[[ $2 -ne 0 ]]) then
    # message to extract is not multiside line/area (J3.0)
    grep 0E0${1}0${2}00 $TEMPLATE_LOCATION/template_load_test_l16_nato.ji|cut -f2- -d" "|xargs -i{} echo " "{}
 #elif ([[ $1 -eq 3 ]]&&[[ $2 -eq 0 ]]) then
    # message to extract is  multiside line/area (J3.0):
    # user can choose which J3.0 he want to extract with param $3
 #   grep 0E0${1}0${2}00 $TEMPLATE_LOCATION/template_load_test_*.ji|cut -f2- -d":"|head -$3|tail -1|cut -f2- -d" "|xargs -i{} echo " "{}
 #fi
}

function duplicate_and_translate_in_time_ji_file
######################################
# parameters :
#  - $1 = file to translate/duplicate
#  - $2 = translation value (second)
#  - $3 = repetition value
#######################################
{
#/bin/rm -f $TMP_OUTPUT_FILE
#touch      $TMP_OUTPUT_FILE 
 local_compt=0;
 while [[ $local_compt -ne  $3 ]] ;do 
   export delta_time=`echo|awk '{print '$local_compt'*'$2'}'`
   export time_to_add_in_hour_min_sec=`echo $delta_time|awk -f ./to_hour_minute_second.awk`
   export hour=`echo $time_to_add_in_hour_min_sec |cut -f1 -d':'`
   export minute=`echo $time_to_add_in_hour_min_sec |cut -f2 -d':'`
   export second=`echo $time_to_add_in_hour_min_sec |cut -f3 -d':'|cut -f1 -d'.'`
   export milisecond=`echo $time_to_add_in_hour_min_sec |cut -f2 -d'.'|cut -f1`
   add_time.sh $1 $hour $minute $second $milisecond >> $TMP_OUTPUT_FILE
   export local_compt=`expr $local_compt + 1`;
 done
}

####################################################################################
# this test use MARTHA DLIP and L16 nato data link
# warning : in  MARTHA program  J2.3/J3.6 are not implemented they will be replaced 
# resp by J2.2/J3.2 : to be replaced when doing test with SAMP/T exe
##############################################################################

export J2_2=`extract_from_templates 2 2`
export J2_3=`extract_from_templates 2 3`
export J2_5=`extract_from_templates 2 5`
export J3_0=`extract_from_templates 3 0`
export J3_2=`extract_from_templates 3 2`
export J3_5=`extract_from_templates 3 5`
export J3_6=`extract_from_templates 3 6`
export J3_7=`extract_from_templates 3 7`
export J9_0=`extract_from_templates 9 0`
export J7_0=`extract_from_templates 7 0`
export J10_2=`extract_from_templates A 2`
echo "$J10_2"

################################################
echo "Make periodic sequence for J10.2"
# 
################################################

clear_tmp_file

sce_time=20
WES=4
other_WES=8
 
./insert_value_into_ji.sh dec 4 57 $WES $sce_time"$J10_2" |awk -f ./to_hour_minute_second.awk >> $TMP_FILE
J10_2_2=`insert_value_into_ji.sh dec 4 57 $other_WES $sce_time" $J10_2"|awk -f ./to_hour_minute_second.awk`
echo "$J10_2_2" |add_time.sh "" 0 $J10_2_REC_MIN $J10_2_REC_SEC 000 >>$TMP_FILE

duplicate_and_translate_in_time_ji_file $TMP_FILE $J10_2_DELTA_TIME $J10_2_DELTA_NBR

################################################
echo "Make originator (J2.2(TN=1)) of J9.0 messages"
################################################

source_tn_1=$DIST_SOURCE_TN
./insert_value_into_ji_header.sh dec 15 32 $source_tn_1 "00:00:00.000""$J2_2" >> $TMP_OUTPUT_FILE

################################################
echo "Make periodic sequence for J9.0"
################################################

clear_tmp_file
export sce_init_time=15; #wait all air tracks are defined in xhd file
export sce_time=15  
export compt=0
export tn_objective=10010
export tn_friend_weapon=10020
own_unit_tn=$OWN_PLATFORM_LTN
while [[ $compt -ne $J9_0_NBR ]] ;do 
  ./insert_value_into_ji.sh dec 15 13 $own_unit_tn $sce_time"$J9_0" |awk -f ./to_hour_minute_second.awk > $TMP_FILE
  export J9_0_with_adresse=`cat $TMP_FILE`
  ./insert_value_into_ji.sh dec 19 37 $tn_objective "$J9_0_with_adresse" > $TMP_FILE
  export J9_0_with_adresse_and_tn_obj=`cat $TMP_FILE`
  printf "DONT_REPEAT_IN_BASE_SCENARIO " >> $TMP_OUTPUT_FILE ;./insert_value_into_ji.sh dec 19 131 $tn_friend_weapon "$J9_0_with_adresse_and_tn_obj" >> $TMP_OUTPUT_FILE
  export tn_objective=`expr $tn_objective + 1`;
  export tn_friend_weapon=`expr $tn_friend_weapon + 1`;
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$sce_init_time'+'$compt'*2}'`;
done

################################################
echo "Make periodic sequence for J2.2"
#  (warning 30 of these J2.2 will be J2.3 when using SAMPT exe)
################################################

clear_tmp_file
export source_tn=$LTN_J2_2
export sce_time=0 
export compt=0
while ([[ $compt -ne $J2_2_NBR ]]) ;do 
  ./insert_value_into_ji_header.sh dec 15 32 $source_tn $sce_time"$J2_2" |awk -f ./to_hour_minute_second.awk >> $TMP_FILE
  source_tn=`expr $source_tn + 1`;
  compt=`expr $compt + 1`;
  sce_time=`echo |awk '{print '$compt'*'$J2_2_REC_RATE'/'$J2_2_NBR'}'`;
done

duplicate_and_translate_in_time_ji_file $TMP_FILE $J2_2_DELTA_TIME $J2_2_DELTA_NBR

################################################
echo "Make periodic sequence for J2.3"
#  (warning 30 of these J2.2 will be J2.3 when using SAMPT exe)
################################################

clear_tmp_file
source_tn=$LTN_J2_3
export sce_time=0 
export compt=0
while ([[ $compt -ne $J2_3_NBR ]]) ;do 
  ./insert_value_into_ji_header.sh dec 15 32 $source_tn $sce_time"$J2_3" |awk -f ./to_hour_minute_second.awk >> $TMP_FILE
  export source_tn=`expr $source_tn + 1`;
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$compt'*'$J2_3_REC_RATE'/'$J2_3_NBR'}'`;
done

duplicate_and_translate_in_time_ji_file $TMP_FILE $J2_3_DELTA_TIME $J2_3_DELTA_NBR

################################################
echo "Make periodic sequence for J2.5"
################################################

clear_tmp_file
source_tn=$LTN_J2_5
export sce_time=0 
export compt=0
while ([[ $compt -ne $J2_5_NBR ]]) ;do 
  ./insert_value_into_ji_header.sh dec 15 32 $source_tn $sce_time"$J2_5" |awk -f ./to_hour_minute_second.awk >>$TMP_FILE
  export source_tn=`expr $source_tn + 1`;
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$compt'*'$J2_5_REC_RATE'/'$J2_5_NBR'}'`;
done

duplicate_and_translate_in_time_ji_file $TMP_FILE $J2_5_DELTA_TIME $J2_5_DELTA_NBR

################################################
echo "Make periodic sequence for J3.0"
################################################

clear_tmp_file
tn_reference=$LTN_J3_0
export sce_time=0 
export compt=0
export first_tn_reference_of_j3_0=$tn_reference
while ([[ $compt -ne $J3_0_NBR ]]) ;do 
  ./insert_value_into_ji.sh dec 19 19 $tn_reference $sce_time"$J3_0" |awk -f ./to_hour_minute_second.awk >> $TMP_FILE
  register_tn_created $tn_reference
  export tn_reference=`expr $tn_reference + 1`;
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$compt'*'$J3_0_REC_RATE'/'$J3_0_NBR'}'`;
done

duplicate_and_translate_in_time_ji_file $TMP_FILE $J3_0_DELTA_TIME $J3_0_DELTA_NBR

################################################
echo "Make periodic sequence for J3.2"
#  (warning 2 of these 3.2 will be J3.6 when using SAMPT exe)
################################################

clear_tmp_file
tn_reference=$LTN_J3_2
export sce_time=0 
export compt=0
export first_tn_reference_of_j3_2=$tn_reference
while ([[ $compt -ne $J3_2_NBR ]]) ;do 
  ./insert_value_into_ji.sh dec 19 19 $tn_reference $sce_time"$J3_2" |awk -f ./to_hour_minute_second.awk >>$TMP_FILE
  register_tn_created $tn_reference
  export tn_reference=`expr $tn_reference + 1`;
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$compt'*'$J3_2_REC_RATE'/'$J3_2_NBR'}'`;
done

duplicate_and_translate_in_time_ji_file $TMP_FILE $J3_2_DELTA_TIME $J3_2_DELTA_NBR

################################################
echo "Make periodic sequence for J3.6"
#  (warning 2 of these 3.2 will be J3.6 when using SAMPT exe)
################################################

clear_tmp_file
tn_reference=$LTN_J3_6
export sce_time=0 
export compt=0
export first_tn_reference_of_j3_2=$tn_reference
while ([[ $compt -ne $J3_6_NBR ]]) ;do 
  ./insert_value_into_ji.sh dec 19 18 $tn_reference $sce_time"$J3_6" |awk -f ./to_hour_minute_second.awk >>$TMP_FILE
  register_tn_created $tn_reference
  export tn_reference=`expr $tn_reference + 1`;
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$compt'*'$J3_6_REC_RATE'/'$J3_6_NBR'}'`;
done

duplicate_and_translate_in_time_ji_file $TMP_FILE $J3_6_DELTA_TIME $J3_6_DELTA_NBR

################################################
echo "Make periodic sequence for J3.5"
################################################

clear_tmp_file
tn_reference=$LTN_J3_5
export sce_time=0 
export compt=0
while ([[ $compt -ne $J3_5_NBR ]]) ;do 
  ./insert_value_into_ji.sh dec 19 19 $tn_reference $sce_time"$J3_5" |awk -f ./to_hour_minute_second.awk >>$TMP_FILE
  register_tn_created $tn_reference
  export tn_reference=`expr $tn_reference + 1`;
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$compt'*'$J3_5_REC_RATE'/'$J3_5_NBR'}'`;
done

duplicate_and_translate_in_time_ji_file $TMP_FILE $J3_5_DELTA_TIME $J3_5_DELTA_NBR


################################################
echo "Make periodic sequence for J3.7"
################################################

clear_tmp_file
tn_reference=$LTN_J3_7
export sce_time=0 
export compt=0
while ([[ $compt -ne $J3_7_NBR ]]) ;do 
  ./insert_value_into_ji.sh dec 19 18 $tn_reference $sce_time"$J3_7" |awk -f ./to_hour_minute_second.awk >>$TMP_FILE
  register_tn_created $tn_reference
  export tn_reference=`expr $tn_reference + 1`;
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$compt'*'$J3_7_REC_RATE'/'$J3_7_NBR'}'`;
done

duplicate_and_translate_in_time_ji_file $TMP_FILE $J3_7_DELTA_TIME $J3_7_DELTA_NBR

################################################
echo "Make final J7.0 messages drop"
################################################

clear_tmp_file
export sce_time=0 
export compt=0
for tn_reference in `list_of_tns_to_drop` ;do 
  printf "DROP_MSG ">> $TMP_OUTPUT_FILE;./insert_value_into_ji.sh dec 19 19 $tn_reference $sce_time"$J7_0" |awk -f ./to_hour_minute_second.awk >> $TMP_OUTPUT_FILE
  export compt=`expr $compt + 1`;
  export sce_time=`echo |awk '{print '$compt'/10}'`;
done


