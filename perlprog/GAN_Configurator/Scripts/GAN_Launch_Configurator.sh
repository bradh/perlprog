#!/bin/bash
DIR_CONFIGURATION=/h7_usr/sil2_usr/ganivq/Configuration
PROG_CONFIGURATOR=/h7_usr/sil2_usr/ganivq/Scripts/Configurator
ERROR=0
cd $PROG_CONFIGURATOR
./GAN_configurator_lc.pl -f GAN_configurator.csv
if [ $? -ne 0 ]; then
		echo "===================================================================="
		echo "L'application GAN_configurator_lc rencontre un Probleme"
		echo "===================================================================="
		ERROR=1
fi
exit $ERROR
