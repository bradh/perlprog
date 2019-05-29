#! /bin/bash
cd /PROJECTS/Applicatifs/proxy_MIDS
rm /PROJECTS/Applicatifs/proxy_MIDS/proxy.log
/PROJECTS/Applicatifs/proxy_MIDS/proxy_MIDS_V6.pl GANTEST1 1025 1024 >> proxy.log

exit 0
