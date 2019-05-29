#!/usr/bin/perl
my $REMOTE_ENV =
  " export PATH=\$PATH:/h7_usr/sil2_usr/marthivq/MARTHA_CGC3/Scripts:.";
my $runDir = "/h7_usr/sil2_usr/marthivq/MARTHA_CGC3/Scripts";
my $puttySession = "martha_cgc3_c2_non_reg";
#my $echo_command = "echo \'/usr/bin/perl $runDir/test.pl\' > $runDir/test.sh ;chmod +x $runDir/test.sh";
my $echo_command = "echo toto \> $runDir/test.sh ";
print $echo_command . "\n";
# system("plink martha_cgc3_c2_non_reg $REMOTE_ENV;cd $runDir;  ./check.pl 2>&1 > /dev/null ");
system("plink martha_cgc3_c2_non_reg $REMOTE_ENV; cd $runDir ;  $echo_command ;  at  -f $runDir/test.sh now "); 
exit 0; 