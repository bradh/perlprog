# Script permettant de detecter la carte reseau active sur un OS Linux
# ---------------------------------------------------------------------

for i in  `ls /etc/sysconfig/network-scripts/ifcfg-eth*`;
do

# On 'reveille' toutes les carte reseaux
# ---------------------------------------------------------------------
ifconfig `echo  $i | cut -f3 -d-` up

# On recherche celle dont l'option Link detected est a yes
# ---------------------------------------------------------------------
ethtool `echo  $i | cut -f3 -d-`|grep "Link detected: yes" > ER

if test -s ER
then

# on affiche que celle qui est active
# ---------------------------------------------------------------------
        echo "======================================="
        echo "Carte reseau active \"`echo  $i | cut -f3 -d-`\""
        echo "======================================="
fi
done
rm -f ER
