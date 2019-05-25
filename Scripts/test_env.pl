#!/usr/bin/perl -w
print "Hello world\n";
$ENV{PWD}="/data/users/loc1int";
#chdir("/data/users/loc1int");
$DIR=`toto.pl`;
#$DIR=$ENV{PWD};
print "$DIR\n";
$DISP=$ENV{DISPLAY};
print "$DISP\n";
exit 0;

