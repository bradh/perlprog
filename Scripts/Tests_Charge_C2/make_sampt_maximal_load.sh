#!/bin/ksh
#################################################
#default configuration parameters to be set     #
#################################################

export TEST_TOTAL_DURATION=720;  # in minute multiple de BASE_SCENARIO_DURATION
# export BASE_SCENARIO_DURATION=`expr 45 \* 60`; # in second
export BASE_SCENARIO_DURATION=3200; # in second
export NB_OF_MIN_RESERVED_TO_DROP_OBJECTS=3 ; # in minute
BASE_SEQUENCE_DURATION=768; # in second
#  BASE_SEQUENCE_DURATION = DELTA_NBR * DELTA_TIME cf make_ji_file_for_c2_martha_load_scenario.sh
export OPERATIONAL_MESSAGE_START_TIME="00:02:40.000" ;

export LIST_OF_GENERATION_DIRECTIVES="DROP_MSG DONT_REPEAT_IN_BASE_SCENARIO";
export DATA_LINK_FILE_EXT="ji fom"
export DATA_LINK_FILE_EXT_WITHOUT_JI="fom"
export HOST_FILE_EXT="xhd";

TEMPLATE_DIR="template"
TEMP_DIR="tmp"
OUTPUT_DIR="scenario"
TEST_NAME="t_c2_capa_max"
TEST_NAME_UMAT="t_c2_capa_max_umat"
TEST_NAME_SIMPLE="t_c2_capa_max_simple"

INPUT_JI_MSG_FILE="tmp_init_result.ji"
OUTPUT_JI_MSG_FILE="tmp_result.ji"
OUTPUT_FOM_MSG_FILE="tmp_result.fom"
OUTPUT_APU_MSG_FILE="tmp_result.ind_rep_apu"

INIT_XHD_MSG_FILE_UMAT="sampt_c2_init_umat.xhd"
INIT_XHD_MSG_FILE_SIMPLE="sampt_c2_init_simple.xhd"
INIT_XHD_FILTER_FILE="filters_sequence.xhd"
INIT_25_POLYGONES="25_polygones.xhd"
INIT_FOM12_FILE="fom12.fom"

INPUT_XHD_MSG_FILE="tmp_init_result.xhd"
OUTPUT_XHD_MSG_FILE="tmp_result.xhd"

###################################################################
#  load user parameters
###################################################################

# ./load_test_config_file.sh

###################################################################
#  computed parameters
###################################################################

# format is 'directive_1|directive_2|....|directive_n'
export LIST_OF_GENERATION_DIRECTIVES_IN_EGREP_FORMAT=\
`echo $LIST_OF_GENERATION_DIRECTIVES|awk '{for(i=1;i<=NF;i++){if(i!=1){printf("|%s",$i)}else{printf("%s",$i)}}}';`;

# data link file type list without ji type
export DATA_LINK_FILE_EXT_WITHOUT_JI=`echo $DATA_LINK_FILE_EXT|awk '{for(i=1;i<=NF;i++){if($i!="ji"){print $i}}}'`

echo "###############################################"
echo "#  COMPUTE JI BASE SEQUENCE of "$BASE_SEQUENCE_DURATION" second duration                  #"
echo "###############################################"
#pour rendre les differents scripts indépendents
# make_ji_file_for_c2_martha_load_scenario.sh
#make_ji_file_for_c2_martha_load_scenario.sh|tee tmp_init_result.ji
egrep -v $LIST_OF_GENERATION_DIRECTIVES_IN_EGREP_FORMAT $TEMP_DIR/$INPUT_JI_MSG_FILE > $TEMP_DIR/$OUTPUT_JI_MSG_FILE

########################################################
# Passage dans le rep temporaire
########################################################
cd $TEMP_DIR

echo "###############################################"
echo "#  CONVERT JI=> IND_REP_APU/FOM               #"
echo "###############################################"

# convert messages in base sequence without directive

#../convert_to_ind_rep_apu $OUTPUT_JI_MSG_FILE $OUTPUT_APU_MSG_FILE
../convert  $OUTPUT_JI_MSG_FILE $OUTPUT_FOM_MSG_FILE

# convert messages  in base sequence with directive 

#cat $OUTPUT_APU_MSG_FILE > tmp_init_result.ind_rep_apu
cat $OUTPUT_FOM_MSG_FILE > tmp_init_result.fom

for DIRECTIVE in $LIST_OF_GENERATION_DIRECTIVES;do

   grep  $DIRECTIVE $INPUT_JI_MSG_FILE|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n");}'>tmp_not_to_repeat_${DIRECTIVE}.ji

   ../convert_to_ind_rep_apu tmp_not_to_repeat_${DIRECTIVE}.ji  tmp_not_to_repeat_${DIRECTIVE}.ind_rep_apu
#   awk '{printf("'$DIRECTIVE' %s\n",$0)}' tmp_not_to_repeat_${DIRECTIVE}.ind_rep_apu>tmp_not_to_repeat_2_${DIRECTIVE}.ind_rep_apu

   ../convert tmp_not_to_repeat_${DIRECTIVE}.ji tmp_not_to_repeat_${DIRECTIVE}.fom
   awk '{printf("'$DIRECTIVE' %s\n",$0)}' tmp_not_to_repeat_${DIRECTIVE}.fom>tmp_not_to_repeat_2_${DIRECTIVE}.fom

done

# merge them with base sequence messages without directive

for ext in $DATA_LINK_FILE_EXT_WITHOUT_JI ;do 
  cat tmp_result.$ext `echo $LIST_OF_GENERATION_DIRECTIVES|awk '{for(i=1;i<=NF;i++){printf("tmp_not_to_repeat_2_%s.'$ext' ",$i)}}'`>tmp_init_result.$ext
done

echo "###############################################"
echo "#  COMPUTE XHD BASE SEQUENCE   of "$BASE_SEQUENCE_DURATION" second duration               #"
echo "###############################################"

#make_xhd_file_for_c2_martha_load_scenario.sh|tee tmp_init_result.xhd
# suppression des lignes avec directive
egrep -v $LIST_OF_GENERATION_DIRECTIVES_IN_EGREP_FORMAT $INPUT_XHD_MSG_FILE > $OUTPUT_XHD_MSG_FILE

echo "###############################################"
echo "#  SORTING JI/XHD FILE                        #"
echo "###############################################"

for ext in $DATA_LINK_FILE_EXT ;do 
   sort tmp_result.$ext>tmp1_result.$ext
done
sort -u tmp_result.xhd>tmp1_result.xhd

#parameters computed
export BASE_SCENARIO_DURATION_IN_MINUTE=`echo|awk '{print '$BASE_SCENARIO_DURATION'/60}'`;

echo "#######################################################"
echo "#  REPEAT SEQUENCE UP TO OBTAIN "$BASE_SCENARIO_DURATION_IN_MINUTE" min SCENARIO       #"
echo "#######################################################"

for ext in $DATA_LINK_FILE_EXT ;do 
  /bin/rm -f tmp21_result.$ext;touch tmp21_result.$ext
done
/bin/rm -f tmp21_result.xhd;touch tmp21_result.xhd

export NB_OF_REPEATITION=`echo|awk '{print 1+int(('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS')*60/'$BASE_SEQUENCE_DURATION') }'`

echo "will copy/paste "$NB_OF_REPEATITION" the initial sequence..."
export COUNT=0
while [[ $COUNT -ne $NB_OF_REPEATITION ]] ;do
 export TRANSLATION_VALUE=`expr $COUNT \* $BASE_SEQUENCE_DURATION`
 export TRANSLATION_HMS=`echo $TRANSLATION_VALUE|awk -f ../to_hour_minute_second.awk `
 export TRANSLATION_HOUR=`echo $TRANSLATION_HMS|cut -f1 -d":" `;
 export TRANSLATION_MINUTE=`echo $TRANSLATION_HMS|cut -f2 -d":" `;
 export TRANSLATION_SECOND=`echo $TRANSLATION_HMS|cut -f3 -d":"|cut -f1 -d"."`;
 export TRANSLATION_MSECOND=`echo $TRANSLATION_HMS|cut -f3 -d":"|cut -f2 -d"."`;
 for ext in $DATA_LINK_FILE_EXT ;do 
   ../add_time.sh tmp1_result.$ext $TRANSLATION_HOUR $TRANSLATION_MINUTE $TRANSLATION_SECOND $TRANSLATION_MSECOND >>tmp21_result.$ext  
done
 ../add_time.sh tmp1_result.xhd $TRANSLATION_HOUR $TRANSLATION_MINUTE $TRANSLATION_SECOND $TRANSLATION_MSECOND >>tmp21_result.xhd
export COUNT=`expr $COUNT + 1`;
 echo $COUNT"th copy/paste proceeded"
done

##########################################################
# Suppression des fichiers temporaire
##########################################################
for ext in $DATA_LINK_FILE_EXT ;do
   rm -f  tmp1_result.$ext
done
rm -f  tmp1_result.xhd

#remove part of RASP refresh to put drop
export LAST_TIME_BEFORE_DROP_IN_HMS=`echo |awk '{print 60*('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS'-1)}'|awk -f ../to_hour_minute_second.awk|awk '{print substr($0,1,12)}'`
for ext in $DATA_LINK_FILE_EXT ;do 
  awk '{if($1<"'$LAST_TIME_BEFORE_DROP_IN_HMS'"){print}}' tmp21_result.$ext>tmp22_result.$ext
  rm -f tmp21_result.$ext
done
awk '{if($1<"'$LAST_TIME_BEFORE_DROP_IN_HMS'"){print}}' tmp21_result.xhd>tmp22_result.xhd
rm -f tmp21_result.xhd

# get DROPs messages

for ext in $DATA_LINK_FILE_EXT ;do 
  grep DROP_MSG tmp_init_result.$ext|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n")}'>tmp23_result.$ext
done
grep DROP_MSG tmp_init_result.xhd|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n")}'>tmp23_result.xhd

export START_HOUR_DROP=`echo |awk '{print int(('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS')/60)}'`
export START_MIN_DROP=`echo |awk '{print int(('$BASE_SCENARIO_DURATION_IN_MINUTE'-'$NB_OF_MIN_RESERVED_TO_DROP_OBJECTS')%60)}'`

for ext in $DATA_LINK_FILE_EXT ;do 
  ../add_time.sh tmp23_result.$ext $START_HOUR_DROP $START_MIN_DROP 0 0 >tmp24_result.$ext
  rm -f tmp23_result.$ext
done
../add_time.sh tmp23_result.xhd $START_HOUR_DROP $START_MIN_DROP 0 0 >tmp24_result.xhd
rm -f tmp23_result.xhd

#get messages of base sequence that shall not been repeated in base scenario

for ext in $DATA_LINK_FILE_EXT ;do 
  grep DONT_REPEAT_IN_BASE_SCENARIO tmp_init_result.$ext|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n")}'>tmp25_result.$ext
done
grep DONT_REPEAT_IN_BASE_SCENARIO tmp_init_result.xhd|awk '{for(i=2;i<=NF;i++){printf("%s ",$i)};printf("\n")}'>tmp25_result.xhd


# merge all type of messages

for ext in $DATA_LINK_FILE_EXT ;do 
  cat tmp22_result.$ext tmp24_result.$ext tmp25_result.$ext |sort -u >tmp2_result.$ext
  rm -f tmp22_result.$ext tmp24_result.$ext tmp25_result.$ext
done
cat tmp22_result.xhd tmp24_result.xhd tmp25_result.xhd |sort -u >tmp2_result.xhd
rm -f tmp22_result.xhd tmp24_result.xhd tmp25_result.xhd

echo "###############################################"
echo "#  translate JI/XHD FILE from "$OPERATIONAL_MESSAGE_START_TIME"            #"
echo "###############################################"

export OPERATIONAL_MESSAGE_START_TIME_HOUR=`echo $OPERATIONAL_MESSAGE_START_TIME|cut -f1 -d":" `;
export OPERATIONAL_MESSAGE_START_TIME_MINUTE=`echo $OPERATIONAL_MESSAGE_START_TIME|cut -f2 -d":" `;
export OPERATIONAL_MESSAGE_START_TIME_SECOND=`echo $OPERATIONAL_MESSAGE_START_TIME|cut -f3 -d":"|cut -f1 -d"."`;
export OPERATIONAL_MESSAGE_START_TIME_MSEC=`echo $OPERATIONAL_MESSAGE_START_TIME|cut -f3 -d":"|cut -f2 -d"."`;

for ext in $DATA_LINK_FILE_EXT ;do 
  ../add_time.sh tmp2_result.$ext $OPERATIONAL_MESSAGE_START_TIME_HOUR \
                               $OPERATIONAL_MESSAGE_START_TIME_MINUTE \
                               $OPERATIONAL_MESSAGE_START_TIME_SECOND \
                               $OPERATIONAL_MESSAGE_START_TIME_MSEC >tmp3_result.$ext
  rm -f  tmp2_result.$ext
done

# Decalage des pistes locales de 10
# permet d'amortir le pic de charge à la creation des objets

OPERATIONAL_MESSAGE_START_TIME_SECOND_XHD=`expr $OPERATIONAL_MESSAGE_START_TIME_SECOND + 10`
../add_time.sh tmp2_result.xhd $OPERATIONAL_MESSAGE_START_TIME_HOUR \
                               $OPERATIONAL_MESSAGE_START_TIME_MINUTE \
                               $OPERATIONAL_MESSAGE_START_TIME_SECOND_XHD \
                               $OPERATIONAL_MESSAGE_START_TIME_MSEC >tmp3_result.xhd
rm -f tmp2_result.xhd

echo "#####################################################################"
echo "#  translate identical times in JI/XHD FILE                         #"
echo "#   (because test_driver discards messages with identical time tags)#"
echo "#####################################################################"

for ext in $DATA_LINK_FILE_EXT ;do 
   ../translate_identical_time_in_test_driver_sce.awk tmp3_result.$ext>tmp4_result.$ext
done
../translate_identical_time_in_test_driver_sce.awk tmp3_result.xhd>tmp4_result.xhd


#parameters computed
export TEST_TOTAL_DURATION_IN_HOUR=`echo|awk '{print '$TEST_TOTAL_DURATION'/60'}`;

echo "#######################################################"
echo "#  REPEAT "$BASE_SCENARIO_DURATION_IN_MINUTE" min SCENARIO TO OBTAIN "$TEST_TOTAL_DURATION_IN_HOUR" HOUR LOAD TEST #"
echo "#######################################################"

for ext in $DATA_LINK_FILE_EXT ;do 
  /bin/rm -f tmp21_result.$ext;touch tmp41_result.$ext
done
/bin/rm -f tmp21_result.xhd;touch tmp41_result.xhd

export NB_OF_REPEATITION=`echo|awk '{print 1+int('$TEST_TOTAL_DURATION'*60/'$BASE_SCENARIO_DURATION') }'`
echo "will copy/paste "$NB_OF_REPEATITION" the base sequence......"
export COUNT=0
while [[ $COUNT -ne $NB_OF_REPEATITION ]] ;do
 export TRANSLATION_VALUE=`expr $COUNT \* $BASE_SCENARIO_DURATION`
echo $TRANSLATION_VALUE 
 export TRANSLATION_HMS=`echo $TRANSLATION_VALUE|awk -f ../to_hour_minute_second.awk `
 export TRANSLATION_HOUR=`echo $TRANSLATION_HMS|cut -f1 -d":" `;
 export TRANSLATION_MINUTE=`echo $TRANSLATION_HMS|cut -f2 -d":" `;
 export TRANSLATION_SECOND=`echo $TRANSLATION_HMS|cut -f3 -d":"|cut -f1 -d"."`;
 export TRANSLATION_MSECOND=`echo $TRANSLATION_HMS|cut -f3 -d":"|cut -f2 -d"."`;
 for ext in $DATA_LINK_FILE_EXT ;do 
   ../add_time.sh tmp4_result.$ext $TRANSLATION_HOUR $TRANSLATION_MINUTE $TRANSLATION_SECOND $TRANSLATION_MSECOND >>tmp41_result.$ext
done
 ../add_time.sh tmp4_result.xhd $TRANSLATION_HOUR $TRANSLATION_MINUTE $TRANSLATION_SECOND $TRANSLATION_MSECOND >>tmp41_result.xhd
export COUNT=`expr $COUNT + 1`;
 echo $COUNT"th copy/paste proceeded"
done

##########################################################
# Suppression des fichiers temporaire
##########################################################
for ext in $DATA_LINK_FILE_EXT ;do
   rm -f  tmp4_result.$ext
done
rm -f  tmp4_result.xhd

###################################
# Retour dans le reprtoire de base
###################################
cd ..

echo "###############################################################"
echo "#  make SAMPT load test files  (load_test.xhd/ind_rep_apu)   #"
echo "#   1/add of init MARTHA DLIP init sequence (registration ...)#"
echo "###############################################################"

cat $TEMPLATE_DIR/$INIT_XHD_MSG_FILE_UMAT $TEMPLATE_DIR/$INIT_25_POLYGONES $TEMP_DIR/tmp41_result.xhd | sort -u > $OUTPUT_DIR/$TEST_NAME_UMAT.xhd
cat $TEMPLATE_DIR/$INIT_XHD_MSG_FILE_SIMPLE $TEMPLATE_DIR/$INIT_25_POLYGONES $TEMP_DIR/tmp41_result.xhd | sort -u > $OUTPUT_DIR/$TEST_NAME_SIMPLE.xhd
rm -f $TEMP_DIR/tmp41_result.xhd

echo "#############################################################"
echo "# creation du fichier .fim pour le test SIMPLE"
echo "#############################################################"

./fom2fim.pl -f $TEMP_DIR/tmp41_result.fom
mv  $TEMP_DIR/tmp41_result.fim $OUTPUT_DIR/$TEST_NAME.fim

cat $TEMPLATE_DIR/$INIT_FOM12_FILE $TEMP_DIR/tmp41_result.fom > $OUTPUT_DIR/$TEST_NAME.fom
rm -f $TEMP_DIR/tmp41_result.fom

exit
