#!/usr/bin/perl -w

use Tkx;
use File::Basename;
use File::Next;
use File_tools;
use strict;

my $mw;

my $source_dir;
my $target_dir;
my $config_file_name = ;

# Main window Tak$e top and the bottom - now implicit top is in the middle
$mw = Tkx::widget->new(".");
$mw->g_wm_title("Configuration Backup" );
$source_dir = File_tools::chooseDir("z:\\t0028369");


Tkx::MainLoop();




