#!/bin/ksh
# The folowing awk program is a new version of the script 
# "extract_ji_msg_from_martha_log.sh, written by N. Durant.
# This script needed to be updated because DLIP traces
# have changed and variables from awk program could not be find.
# To help you reading the script the last awk command, note the variables matching :
# $1 : is_ji
# $2 : msg_id
# $3 : sce_time
# $4 : originator
# $5 : methode_rec
# $6 : PG
# $7 : needline
# $8 : first byte of data
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

awk '
function hex_to_dec(hex_val)
    {
	numb="123456789ABCDEF";
	result=0;
	mult=1;
	len_hex_val=length(hex_val);
	for(i=len_hex_val;i>=1;i--){result+=mult*index(numb,substr(hex_val,i,1));mult*=16;};
	return result;
    }
function label_and_sublabel (first_byte,second_byte)
    {
    msg_header=sprintf("%s%s",first_byte,second_byte);
    dec_val=hex_to_dec(msg_header);
    label=int(dec_val/4)%32;
    sublabel=int(dec_val/128)%8;
    return sprintf("%.2X%.2X00",label,sublabel);
    }
BEGIN{previous1="";previous2="";sce_time="";msg_detected=0;nb_data=0;is_ji=0;data="";data_read=0;msg_id="";methode_rec=3;PG=7;Needline=1}
    {
    if(index($0,"MESSAGE_J")&&(!index($0,"tx_task")))
	{sce_time=$2;msg_detected=1;
	is_ji=1;data_read=0;
	}
    else 
	{
	if(msg_detected&&index($0,"Stn_0"))
	    {originator=$9;
	    }
	else 
	    {
	    if(msg_detected&&index($0,"Methode_Rec"))
		{if ($9=="PG") {methode_rec=0;}
		else {if ($9=="NEEDLINE") {methode_rec=1}}
		}
	    else 
		{
		if(msg_detected&&index($0,"PG_Needline"))
		    {PG=$9;
		    if (methode_rec==1) {Needline=PG;PG=0;}
		    else {Needline=0};
		    }
		else 
		    {
		    if(msg_detected&&!data_read&&(index($0,"IND_REC_JFT_RECEIVED")))
			{
			if($7 == "Data="){start=8};
			msg_id=label_and_sublabel ($start,$(start+1));
			printf("%d %s %s ",is_ji,msg_id,sce_time);
			data="";
			for(i=start;i<=NF;i++){data=sprintf("%s %s ",data,$i)};
			methode_rec=methode_rec*64;
			printf("%s %d %d %d %s\n",originator,methode_rec,PG,Needline,data);
			data_read=1;
			msg_detected=0;
			}
		    }
		}
	    }
	}
 previous1=$1;}
END {
    if(msg_detected&&data_read)
        {msg_detected=0;
         fake_originator="0";
         printf("%s %s\n",fake_originator,data);   
         };
    }; ' $1 |\
awk '{if(NF!=0){print}}' |\
awk '{
   if($1){msg_type="0E"}else{msg_type="0F"};
   nb_byte=18+NF-7;
   if(!$1){nb_byte += 2}
   printf("%s %.8X %s%s 0000 00%.2X %.4X 00%.2X 0%.3X 0000 0000",$3,nb_byte,msg_type,$2,$5,$4,$6,$7);
   if(!$1){printf("0000 ")}
    for(i=8;i<=NF;i++){
     if(i%2==0){printf(" ")}
     printf("%s",$i);
               };
   printf("\n")}' |\
awk -f $SCRIPT_DIR/to_hour_minute_second.awk
