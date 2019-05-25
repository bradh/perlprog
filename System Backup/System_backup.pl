#!/usr/bin/perl -w

use Tkx;
use File::Basename;
use File::Next;
use File_tools;
use strict;

my $mw;

my $source_dir;
my $target_dir;

# Main window Tak$e top and the bottom - now implicit top is in the middle
$mw = Tkx::widget->new(".");
$mw->g_wm_title("System Backup" );
$source_dir = File_tools::chooseDir("z:\\t0028369");
$target_dir = File_tools::chooseDir("z:");


my $everything = File::Next::everything($source_dir);
while(defined (my $file_dir = $everything->())){
	if (-f $file_dir){ print "file: $file_dir\n"}
	if (-d $file_dir){ print "dir : $file_dir\n"}
	#print "$file_dir\n";
}


Tkx::MainLoop();




