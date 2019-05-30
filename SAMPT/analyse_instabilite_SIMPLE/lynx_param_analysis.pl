#!/bin/perl -w

use strict;

my $rack_lynx_ip = "200.1.18.2";
my $rack_lynx_user = "root";
my $rack_lynx_cmd = "rsh -l $rack_lynx_user $rack_lynx_ip";

open Fin, "ps -ax |";
while(<Fin>){
	print $_;
}