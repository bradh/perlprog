

 
function hex_to_bin(hex_value) 
{
  bin_value="";
  for(i=1;i<=length(hex_value);i++)
   {
   #print bin[5];
    bin_value=sprintf("%s%s",bin_value,bin[substr(hex_value,i,1)]);
   }
    #print bin_value;
  return bin_value;
}

function dec_to_bin(dec_value)
{
  bin_value="";
  while(dec_value>0)
  {
    bin_value=sprintf("%d%s",dec_value%2,bin_value);
    dec_value=int(dec_value/2); 
  }
 return bin_value;
}

function bin_to_hex(bin_value)
{
 hex_value="";  


 # add zero binary digits to be able to use hex conversion array
 # defined in BEGIN statement

 if(length(bin_value)%4==0)
  {nb_zero_to_add=0}
 else
  {nb_zero_to_add=4-length(bin_value)%4};

 #printf("nb zero to add in bin_to_hex= %s\n",nb_zero_to_add);
 #for(n=1;n<=length(bin_value);n+=4){printf("%s|",substr(bin_value,n,4))};printf("\n");

 for(n=0;n<nb_zero_to_add;n++)
  {
   bin_value=sprintf("0%s",bin_value);
  }

 # make conversion to hexadecimal stream with  hex conversion array
 # defined in BEGIN statement

 for(n=1;n<=length(bin_value);n+=4)
  {
    hex_value=sprintf("%s%s",hex_value,hex[substr(bin_value,n,4)]);
  }
 return hex_value;
}


function to_ji_data_format(hex_value)
{
 ji_data="";
 if(length(hex_value)%4==0)
  {nb_zero_to_add=0}
 else
  {nb_zero_to_add=4-length(hex_value)%4;}

 for(n=0;n<nb_zero_to_add;n++)
  {
   hex_value=sprintf("0%s",hex_value);
  }
 for(n=length(hex_value);n>0;n-=4)
 { ji_data=sprintf("%s %s",ji_data,substr(hex_value,n-3,4));}
 return ji_data;
}

function to_ahd_data_format(hex_value)
{
  ahd_data=""  
  for(n=1;n<=length(hex_value);n+=2){
    ahd_data=sprintf(" %s %s",substr(hex_value,n,2),ahd_data)
    }
  return ahd_data;
}

function revert_bytes_of_bin_value(local_bin_value)
{
 length_bin_value=length(local_bin_value);
 reverted_bin_value=local_bin_value;
 nb_byte_to_revert=int(length_bin_value/8);
 if(nb_byte_to_revert>0)
 {
 reverted_bin_value="";
  for(i=length_bin_value-7;i>0;i-=8)
   {
    for(j=0;j<8;j++)
     {
       reverted_bin_value=sprintf("%s%s",reverted_bin_value,substr(local_bin_value,i+j,1));
     }
   }
 }
 return reverted_bin_value;
}



{
 bin["0"]="0000";
 bin["1"]="0001";
 bin["2"]="0010";
 bin["3"]="0011"; 
 bin["4"]="0100";
 bin["5"]="0101";
 bin["6"]="0110";
 bin["7"]="0111";
 bin["8"]="1000";
 bin["9"]="1001";
 bin["A"]="1010";
 bin["B"]="1011";
 bin["C"]="1100";
 bin["D"]="1101";
 bin["E"]="1110";
 bin["F"]="1111";

 hex["0000"]="0";
 hex["0001"]="1";
 hex["0010"]="2";
 hex["0011"]="3";
 hex["0100"]="4";
 hex["0101"]="5";
 hex["0110"]="6";
 hex["0111"]="7";
 hex["1000"]="8";
 hex["1001"]="9";
 hex["1010"]="A";
 hex["1011"]="B";
 hex["1100"]="C";
 hex["1101"]="D";
 hex["1110"]="E";
 hex["1111"]="F";

#######################################
# Parametres du programme awk :
#  nb_bit : nombre de bit de la valeur a extraire
#  pos_value : position de la valeur  a extraire
#  data_type : ahd/ji/jo/raw 
#######################################

#on teste si les parametres defini ci-dessus  sont passes
# avec les donnees du programme AWK

operational_data="";
header_data="";


# extraction donnees operationnelles et donnees header

if(data_type=="ji"){end_header_pos=11};
if(data_type=="jo"){end_header_pos=12};
if(data_type=="ahd"){end_header_pos=4};
if(sata_type=="fim"){end_header_pos=19};

for(i=1;i<end_header_pos;i++){header_data=sprintf("%s %s",header_data,$i)}
for(i=NF;i>=end_header_pos;i--){operational_data=sprintf("%s %s",operational_data,$i)}

print header_data;
print operational_data;
	exit;

#conversion du message en binaire
# et extraction de la valeur


operational_data_in_binary=hex_to_bin(operational_data);
#print message brut;
#print operational_data_in_binary;

extracted_val_in_bin=sprintf("%s",substr(operational_data_in_binary,length(operational_data_in_binary)-pos_value-nb_bit+1,nb_bit));
#print extracted_val_in_bin;

if(data_type=="ahd"){
 tmp_extracted_val_in_bin=revert_bytes_of_bin_value(extracted_val_in_bin);
 extracted_val_in_bin=tmp_extracted_val_in_bin;
}
#print extracted_val_in_bin;

extracted_val_in_hexa=bin_to_hex(extracted_val_in_bin);

#print extracted_val_in_hexa;


#printf("message: \n%s\n%s\n%s\n%s\n%s\n",
#        $0,
#        operational_data_in_binary,
#	operational_data_in_binary_with_ins_val,
#	message_in_hexa_with_ins_val,
#       message_in_ji_format_with_ins_val);

#printf("%s",to_ji_data_format ($0));


printf("%s %s\n",$1,extracted_val_in_hexa);

}
