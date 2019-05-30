#!/bin/bash

#set -x

# Avoid strange effects due to misplaced libraries and/or path
# These two environment variables arer automatically resetted 
# to their previous values when script ends
export LD_LIBRARY_PATH=
export PATH=/bin:/usr/bin

if [ $# -lt 1 ]
then
   echo
   echo "-----------------------------------------------------------------------------------------------------------------------"
   echo "Usage $0 <path_result_file> | <result_folder> [<tests_folder>]"
   echo "   <path_result_file> must be a .rtf filename (with full path)"
   echo "   <path_result_file> and <result_folder> are exclusive"
   echo
   echo "   If <path_result_file> is specified, only one file is created which contains all the tests."
   echo "   If <result_folder> is specified, each test generates a specific file. All .rtf files are created in <result_folder>."
   echo
   echo "   Examples :"
   echo "      - With <path_result_file>   : $0 ../En_Cours/resultat.rtf"
   echo "      - With <result_folder> : $0 ../En_Cours"
   echo "-----------------------------------------------------------------------------------------------------------------------"
   echo
   exit 1
fi

# Path for stylesheet retreiving
base=${0%/*}

generation_type=N
# 1 output file ?
Nbcar=`echo $1 | wc -m`
Nbcar=`expr $Nbcar + 0`    # Get rid of spurious spaces
PosDeb=`expr $Nbcar - 4`
extension=`echo $1 | cut -b $PosDeb-$Nbcar` # Extension ".rtf" : 4-characters long

# Is it an rtf file ?
if [ "$extension" = ".rtf" ]
then
   generation_type=F
fi

# or a directory ?
if [ -d $1 ]
then
   generation_type=D
fi

# Test if at least one valid filename or directory has been found
if [ $generation_type = N ]
then
   echo "Error : Invalid filename or non existant directory !"
   exit 1
fi

if [ $generation_type = F ]
then
   outfile=$1
else
   outdir=$1
fi
shift

# Search for tests folder (./ by default)
TESTS_FOLDER=$PWD
if [ $# = 1  ]
then
   HERE=$PWD
   cd $1
   TESTS_FOLDER=$PWD
   cd $HERE
   shift
fi

# At least oOne extra parameter => signal error
if [ $# != 0 ]
then
   echo "Usage $0 <path_result_file> | <result_folder> [<tests folder>]"
   exit 1
fi

# Source locating tests subprogram
. ${base}/common_utilities.sh

# Stylesheet parameters
title_style='\s15\ql \fi-576\li933\ri0\sb510\sa340\widctlpar \jclisttab\tx933\aspalpha\aspnum\faauto\ls1\ilvl1\outlinelevel1\adjustright\rin0\lin933\itap0 \b\caps\f1\fs24\lang1033\langfe3082\langnp1033\langfenp3082'
title_ident='\sbasedon2 \snext0 >1:annexe2;'
host_name='Host'
link_name='MIDS'

echo

# Clean up old files
if [ $generation_type = F ]
then
   if [ -f $1 ]
   then
      echo "   Previous rtf file deletion."
      rm -f $outfile
   fi
else
      echo "   Previous rtf files deletion."
   rm -f $outdir/*.rtf
fi

# Locate the tests
locate_tests $TESTS_FOLDER

#####let nb_tests=$(echo $tests_list | wc -w)
Nb_Tests=`echo $tests_list | wc -w`
Nb_Tests=`expr $Nb_Tests + 0`
echo "   Tests number = $Nb_Tests"

# Order the tests
tests_list=$(for t in $tests_list ; do echo $t ; done | sort)

if [ $generation_type = F ]
then
   # Generate unique file
      echo "   Unique file generation..."
else
   # Generate all files (one for each test)
   echo "   Generate all files (one for each test)..."
fi
echo

# Parse every tests
let i=1
for t in $tests_list
do
   test_name=${t##*/}
   echo "   Test name : $test_name"

   if [ $generation_type = F ]
   then
      # Output RTF start on first doc only
      if [ $i -eq 1 ]
      then
         start="rtf-open 1"
      else
         start="rtf-open 0"
      fi

      # Output RTF end on last doc only
      if [ $i -eq $Nb_Tests ]
      then
         end="rtf-close 1"
      else
         end="rtf-close 0"
      fi
   else
      # Output RTF start on all docs
      start="rtf-open 1"
      end="rtf-close 1"
   fi

   if [ $generation_type = F ]
   then
      # Generate unique file
      xsltproc --param $start --param $end --stringparam title-style "$title_style" --stringparam title-ident "$title_ident" --stringparam host-name "$host_name" --stringparam link-name "$link_name" ${base}/STD_NONC2_AERO_RTF.xsl ${t}/${test_name}.xml >> $outfile
   else
      # Generate all files (one for each test)
      xsltproc --param $start --param $end --stringparam title-style "$title_style" --stringparam title-ident "$title_ident" --stringparam host-name "$host_name" --stringparam link-name "$link_name" ${base}/STD_NONC2_AERO_RTF.xsl ${t}/${test_name}.xml >> $outdir/${test_name}.rtf
   fi

  let i=i+1
done
echo


