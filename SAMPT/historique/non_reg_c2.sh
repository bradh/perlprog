#!/bin/ksh	

set -x

cd /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5

#cd /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/T_C2_PIM_TX/ATR
#sampt_init.pl -r 1 -c 4 -t T_AUTOMATION_LOGICIEL
#sampt_start_test.pl -r 1 -c 4 -v SAMPT_V5 -t T_C2_PIM_TX -i -l
#sampt_retrieve_log.pl -r 1 -c 4 -t T_C2_PIM_TX
#compas
#mkdir V11R2E6
#cp *.log *.fim *.xdh *.report V11R2E6/

#cd /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/T_C2_PIM_RX/ATR
#sampt_init.pl -r 1 -c 4 -t T_AUTOMATION_LOGICIEL
#sampt_start_test.pl -r 1 -c 4 -v SAMPT_V5 -t T_C2_PIM_RX -i -l
#sampt_retrieve_log.pl -r 1 -c 4 -t T_C2_PIM_RX
#compas
#mkdir V11R2E6
#cp *.log *.fim *.xdh *.report V11R2E6/

#sampt_update_exe.pl

#sleep 1000


cd /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5

cd /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/T_C2_PIM_TX/ATR
sampt_init.pl -r 1 -c 4 -t T_AUTOMATION_LOGICIEL
sampt_start_test.pl -r 1 -c 4 -v SAMPT_V5 -t T_C2_PIM_TX -i -l
sampt_retrieve_log.pl -r 1 -c 4 -t T_C2_PIM_TX
compas
mkdir V11R2E4
cp *.log *.fim *.xdh *.report V11R2E4/

cd /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/T_C2_PIM_RX/ATR
sampt_init.pl -r 1 -c 4 -t T_AUTOMATION_LOGICIEL
sampt_start_test.pl -r 1 -c 4 -v SAMPT_V5 -t T_C2_PIM_RX -i -l
sampt_retrieve_log.pl -r 1 -c 4 -t T_C2_PIM_RX
compas
mkdir V11R2E4
cp *.log *.fim *.xdh *.report V11R2E4/


echo "the end"


