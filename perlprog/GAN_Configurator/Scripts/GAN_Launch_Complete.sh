#!/bin/bash
DIR_SCRIPTS=/h7_usr/sil2_usr/ganivq/Scripts
PROG_CONFIGURATOR=/h7_usr/sil2_usr/ganivq/Scripts/Configurator
ESPACE_REFERENCE=/h7_usr/sil2_usr/ganivq/Espace_de_reference
cd ~
ERROR=0
clear
echo "==================================================================================================="
echo "PREPARATION DES MIS A JOURS AUTOMATIQUES DES CONFIGURATIONS DES APPLI GAN"
echo "==================================================================================================="
		
$DIR_SCRIPTS/GAN_Launch_Configurator.sh		
if [ $? -ne 0 ]; then
	echo "===================================================================="
	echo "L'Application GAN_configurator_lc a rencontre un Probleme"
	echo "===================================================================="
	ERROR=1
	exit $ERROR
fi
echo
echo
echo
echo

echo "==================================================================================================="
echo "DEPLOIEMENT AUTOMATIQUES DES FICHIERS DE CONFIGURATIONS DES APPLI GAN DANS L'ESPACE DE REFERENCE"
echo "==================================================================================================="
		
$DIR_SCRIPTS/GAN_Deploy_Configuation.sh		
if [ $? -ne 0 ]; then
	echo "===================================================================="
	echo "L'Application GAN_Deploy_Configuation a rencontre un Probleme"
	echo "===================================================================="
	ERROR=1
	exit $ERROR
fi
echo
echo
echo
echo

echo "==================================================================================================="
echo "DEPLOIEMENT AUTOMATIQUES DES BINAIRES DES APPLI GAN DANS L'ESPACE DE REFERENCE "
echo "==================================================================================================="
		
$DIR_SCRIPTS/GAN_Position_version.sh	
if [ $? -ne 0 ]; then
	echo "===================================================================="
	echo "L'Application GAN_Position_version.sh a rencontre un Probleme"
	echo "===================================================================="
	ERROR=1
	exit $ERROR
fi		

echo
echo
echo
echo
echo "==================================================================================================="
echo "VERSION GAN A DEPLOYER "
echo "----------------------"
cat $DIR_SCRIPTS/../GAN_Version.txt
echo "==================================================================================================="
cp $DIR_SCRIPTS/../GAN_Version.txt $ESPACE_REFERENCE
echo
echo
echo
echo
#sleep 10
echo "=================================================================================="
echo "DEPLOIEMENT AUTOMATIQUES DES APPLICATIONS GAN SUR MACHINES CIBLES "
echo "=================================================================================="
		
$DIR_SCRIPTS/GAN_install_toplink_lcall.sh		
if [ $? -ne 0 ]; then
	echo "===================================================================="
	echo "L'Application GAN_install_toplink_lcall.sh a rencontre un Probleme"
	echo "===================================================================="
	ERROR=1
	exit $ERROR
fi		
