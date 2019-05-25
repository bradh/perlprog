#!/usr/xpg4/bin/awk -f


BEGIN {
trans_h=0;
trans_m=0;
trans_s=0;
trans_ms=0;
last_time="";
}

{
hour=substr($1,1,2);
minute=substr($1,4,2);
second=substr($1,7,2);
msec=substr($1,10,3);
   

if(last_time==$1)
  {
   trans_ms++;
   if(trans_ms>=1000){trans_s++;trans_ms=trans_ms-1000};
   if(trans_s>=60){trans_m++;trans_s=trans_s-60};
   if(trans_m>=60){trans_h++;trans_m=trans_m-60};

  }

   msec=msec+trans_ms;
   if(msec>=1000){second++;msec=msec-1000};
   second=second+trans_s;
   if(second>=60){minute++;second=second-60};
   minute=minute+trans_m;
   if(minute>=60){hour++;minute=minute-60};
   hour=hour+trans_h;

 printf("%.2d:%.2d:%.2d.%.3d %s\n",hour,minute,second,msec,substr($0,14));

 last_time=$1;

}
