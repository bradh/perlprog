#!/bin/ksh	

set -x

checker -o /h7_usr/sil2_usr/samptivq/tests/sampt_mask.txt ./V11R2E3-20131120/t_c2_pim_rx.fim ./V11R2E7/t_c2_pim_rx.fim 

checker -o /h7_usr/sil2_usr/samptivq/tests/sampt_mask.txt ./V11R2E3-20131120/t_c2_pim_rx.xdh ./V11R2E7/t_c2_pim_rx.xdh 

echo "the end"
