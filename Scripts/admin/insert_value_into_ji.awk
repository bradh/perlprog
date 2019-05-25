

 
function hex_to_bin (hex_value) 
{
  bin_value="";
  for(i=1;i<=length(hex_value);i++)
   {
    bin_value=sprintf("%s%s",bin_value,bin[substr(hex_value,i,1)]);
   }
  return bin_value;
}

function dec_to_bin (dec_value)
{
  bin_value="";
  while(dec_value>0)
  {
    bin_value=sprintf("%d%s",dec_value%2,bin_value);
    dec_value=int(dec_value/2); 
  }
 return bin_value;
}

function bin_to_hex (bin_value)
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


function to_ji_data_format (hex_value)
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


BEGIN
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
}
{
#######################################
# Parametres du programme awk :
#  base  : base dans laquelle on donne la valeur a inserer (hex/dec)
#  nb_bit : nombre de bit de la valeur a inserer
#  pos_value : position ou inserer la valeur
#  value : valeur a inserer
#  data_type : ahd/ji/raw => utile pour reformater les donnees en sortie
#######################################


#conversion de la valeur a inserer

if(base=="hex")
{	
  bin_value=hex_to_bin (value);
}
else
{
 if(base=="dec")
   {	
  bin_value=dec_to_bin (value);
    
   }
}

#resize value to insert to nb_bit size (remove digit or add Zeros)

if(length(bin_value)>nb_bit) {
  bin_value_to_insert=substr(bin_value,length(bin_value)-nb_bit+1,nb_bit);
   }
else
{
  if(length(bin_value)<nb_bit)
  {
   
   nb_zero_to_add=nb_bit-length(bin_value);
   bin_value_to_insert=bin_value;
    for(n=0;n<nb_zero_to_add;n++)
    {
      bin_value_to_insert=sprintf("0%s",bin_value_to_insert);
    }
  }
  else
  {
   bin_value_to_insert=bin_value;
  }
}


#conversion du message en binaire
# et insertion de la valeur

#printf("value=%s\n",bin_value_to_insert);

message_in_binary=hex_to_bin ($0);


message_in_binary_with_ins_val=sprintf("%s%s%s",
			substr(message_in_binary,1,length(message_in_binary)-pos_value-nb_bit),
        		bin_value_to_insert,
        		substr(message_in_binary,length(message_in_binary)-pos_value+1,pos_value));

message_in_hexa_with_ins_val= bin_to_hex (message_in_binary_with_ins_val);

message_in_ji_format_with_ins_val=to_ji_data_format (message_in_hexa_with_ins_val);


#printf("message: \n%s\n%s\n%s\n%s\n%s\n",
#        $0,
#        message_in_binary,
#	message_in_binary_with_ins_val,
#	message_in_hexa_with_ins_val,
#       message_in_ji_format_with_ins_val);

#printf("%s",to_ji_data_format ($0));
if(data_type=="ji") {printf("%s",message_in_ji_format_with_ins_val);}
if(data_type=="ahd") {printf("%s",message_in_ji_format_with_ins_val);}
}
