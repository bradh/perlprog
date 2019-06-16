#!/usr/bin/perl

use File::Copy;
my $old_dir = "/media/stephane/Photos1/Images/Images/2003/bac_ a_sable";
my $new_dir = "/media/stephane/Photos1/Images/Images/2003/bac__a_sable";
print $ENV{'PWD'};
#system("mkdir toto");
#print `ls $old_dir`;
File::Copy::move($old_dir, $new_dir);
print `ls $new_dir`;
exit 0;