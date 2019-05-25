{
 t=$1;
 if(!index(t,".")){t=sprintf("%s.000",t)}
 mspos=index(t,".");
 ms=substr(t,mspos+1);   
 length_ms=length(ms);
 if(length_ms<3) 
 {
  for(i=0;i<3-length_ms;i++)
   {ms=ms*10}
 }
else
 {
  if(length_ms>3)
   {ms=substr(ms,1,3)}
 }
 s=substr(t,1,mspos-1); 
 hour=int(s/3600);
 minute=int((s-hour*3600)/60);
 second=int(s-hour*3600-minute*60);
 printf("%.2d:%.2d:%.2d.%.3d ",hour,minute,second,ms);
 for(i=2;i<=NF;i++){printf("%s ",$i)};
 printf("\n")
}
