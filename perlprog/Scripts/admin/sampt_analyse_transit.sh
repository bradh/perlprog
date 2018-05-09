clear.sh
cp ../recorder.log .
cp ../sampt_main.log .
log2fxm_simple.pl
log2xdh.pl
compute_data_link_message_processing_time.sh recorder.fom sampt_main.xdh 12
compute_host_message_processing_time.sh sampt_main.xhd recorder.fim  12
