# Common utilities functions for the tools

# Locate the tests
# args : <tests root directory>
# result : $tests_list contains the list of test directories
function locate_tests
{
   local tests_root=$1
   local test_folders=$(find $tests_root -type d)

   tests_list=
   for d in $test_folders
   do
      local test_name=${d##*/}
    
      if [ -f ${tests_root}/excluded_tests.txt ]
      then
         # Exclusion list exists
         if [ -z "$(grep -w ${test_name} ${tests_root}/excluded_tests.txt)" ]
         then
         
# Not used in TDM1 (to be checked if someone changes his mind)         
#            if [ -f $d/${test_name}.sh -o -f $d/${test_name}_host.cfg -o -f $d/${test_name}_l16.cfg  ]

           # XML is the good one : XML file exists and has the same name than its directory
           if [ -f $d/${test_name}.xml ]
           then
               # This is a (not excluded) test folder
               tests_list="$tests_list $d"
           fi
         fi
      else
         # No exclusion list
         
# Not used in TDM1 (to be checked if someone changes his mind)         
#         if [ -f $d/${test_name}.sh -o -f $d/${test_name}_host.cfg -o -f $d/${test_name}_l16.cfg  ]

        # XML is the good one : XML file exists and has the same name than its directory	   
        if [ -f $d/${test_name}.xml ]
        then
            # This is a (not excluded) test folder
            tests_list="$tests_list $d"
        fi
      fi      
   done
}
