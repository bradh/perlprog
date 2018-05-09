#!/bin/ksh
AWK_CMD=/usr/xpg4/bin/awk
SCRIPT_DIR=`dirname $0`

if [[ ! -f $AWK_CMD ]] then
 echo "pour fonctionner le script a besoin de "$AWK_CMD
 exit
fi

if [[ ! -f $SCRIPT_DIR/to_hour_minute_second.awk ]] then
 echo "pour fonctionner le script a besoin que to_hour_minute_second.awk soit installe dans "$SCRIPT_DIR
 exit
fi

if [[ $# -ne 1 ]] then
 echo "usage "$0" fichier_log_genere_par_dlip_martha"
 exit
fi

$AWK_CMD \
'function hex_to_dec(hex_val){'\
'  numb="123456789ABCDEF";'\
'  result=0;'\
'  mult=1;'\
'  len_hex_val=length(hex_val);'\
'  for(i=len_hex_val;i>=1;i--){result+=mult*index(numb,substr(hex_val,i,1));mult*=16;};'\
'  return result;'\
'}'\
'function label_and_sublabel (first_byte,second_byte)'\
'{'\
'  msg_header=sprintf("%s%s",first_byte,second_byte);'\
'  dec_val=hex_to_dec(msg_header);'\
'  label=int(dec_val/4)%32;'\
'  sublabel=int(dec_val/128)%8;'\
'  return sprintf("%.2X%.2X00",label,sublabel);'\
'}'\
'BEGIN{previous1="";previous2="";sce_time="";msg_detected=0;nb_data=0;is_jo=0;data="";data_read=0;msg_id="";methode_trans="";PG=0;Needline=0}'\
'{if(index($0,"tx_task")&&(index($0,"Msg_Type = MESSAGE_J")))'\
'   {sce_time=$2;msg_detected=1;'\
'     is_jo=1;data_read=0;}'\
' else {'\
'    if(msg_detected&&index($0,"Stn_0"))'\
'        {originator=$9;'\
'         }'\
'    else {'\
'       if(msg_detected&&index($0,"Methode_Trans"))'\
'         {methode_trans=$9;}'\
'       else {'\
'        if(msg_detected&&index($0,"PG"))'\
'          {PG=$9;}'\
'        else {'\
'            if(msg_detected&&index($0,"NeedLine"))'\
'              {Needline=$9;}'\
'            else {'\
'                 if(msg_detected&&!data_read&&(index($0,"SUCCESSFUL"))&&(index($0,"Data")))'\
'                   {'\
'                     if($7 == "Data"){start=9};'\
'                     msg_id=label_and_sublabel ($start,$(start+1));'\
'                     printf("%d %s %s ",is_jo,msg_id,sce_time);'\
'                     data="";'\
'                     for(i=start;i<=NF;i++){data=sprintf("%s %s ",data,$i)};'\
'                     printf("%s %d %d %s\n",originator,PG,Needline,data);'\
'                     data_read=1;'\
'                     msg_detected=0;'\
'                   }'\
'                 }'\
'             }'\
'           }'\
'         }'\
'      }'\
' previous1=$1;}'\
' END {'\
'    if(msg_detected&&data_read)'\
'        {msg_detected=0;'\
'         fake_originator="0";'\
'         printf("%s %s\n",fake_originator,data);   '\
'         };'\
'    };'\
 $1 |\
$AWK_CMD '{if(NF!=0){print}}' |\
$AWK_CMD '{'\
'   if($1){msg_type="0F"}else{msg_type="0E"};'\
'   nb_byte=20+NF-6;'\
'   if(!$1){nb_byte += 2}'\
'   printf("%s %.8X %s%s 0000 0000 0000 0%.3X %.4X %.4X 0000 ",$3,nb_byte,msg_type,$2,$5,$6,$4);'\
'   if($1){printf("0000 ")}'\
'    for(i=7;i<=NF;i++){'\
'     printf("%s",$i);'\
'     if(i%2==0){printf(" ")}};'\
'   printf("\n")}' |\
$AWK_CMD -f $SCRIPT_DIR/to_hour_minute_second.awk
