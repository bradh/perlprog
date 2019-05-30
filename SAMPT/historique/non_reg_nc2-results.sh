#!/bin/ksh	

set -x

cd /h7_usr/sil2_usr/samptivq/tests/NON_C2/UMAT/SAMPT_V5

cd /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/T_C2_PIM_TX/ATR
checker -o /h7_usr/sil2_usr/samptivq/tests/sampt_mask.txt ./V11R2E4/t_c2_pim_tx.fim ./V11R2E6/t_c2_pim_tx.fim >> /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/non_reg_results.log
checker -o /h7_usr/sil2_usr/samptivq/tests/sampt_mask.txt ./V11R2E4/t_c2_pim_tx.xdh ./V11R2E6/t_c2_pim_tx.xdh >> /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/non_reg_results.log

cd /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/T_C2_PIM_RX/ATR
checker -o /h7_usr/sil2_usr/samptivq/tests/sampt_mask.txt ./V11R2E4/t_c2_pim_rx.fim ./V11R2E6/t_c2_pim_rx.fim >> /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/non_reg_results.log
checker -o /h7_usr/sil2_usr/samptivq/tests/sampt_mask.txt ./V11R2E4/t_c2_pim_rx.xdh ./V11R2E6/t_c2_pim_rx.xdh >> /h7_usr/sil2_usr/samptivq/tests/C2/UMAT/SAMPT_V5/non_reg_results.log

echo "the end"
