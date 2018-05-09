#!/bin/ksh

export MY_ROOT_DIR=`dirname \`echo $0 |awk '{print $1}'\``/
/bin/rm *expected
to_expected ./
# sed  "s/xhd/ahd/g" $1.conf  > $1.conf.new;mv $1.conf.new $1.conf
# sed  "s/xdh/adh/g" $1.conf  > $1.conf.new;mv $1.conf.new $1.conf

# mv $1.xhd $1.ahd
# mv $1.xdh $1.adh
# mv $1.xdh.expected $1.adh.expected

if [[ `find . -name "*.xdh.expected" -print|wc -l` -ne 0 ]] then
for f in *.xdh.expected ;do
 $MY_ROOT_DIR/force_default_checks_in_adh_expected.sh $f > $f.new;
 mv $f.new $f
done
fi
if [[ `find . -name "*.fim.expected" -print|wc -l` -ne 0 ]] then
for f in *.fim.expected ;do
 $MY_ROOT_DIR/force_default_checks_in_fim_expected.sh $f > $f.new;
 mv $f.new $f
done
fi
