#!/bin/bash

# Define the bounding box coordinates and other parameters
MIN_LON=-96
MIN_LAT=29
MAX_LON=-94.8
MAX_LAT=30.1
# Period
START_DATE="2021-01-01"
END_DATE="2021-08-30"
TRACK='ASCENDING'
UserName=''
Password=''
# Stacksentinel.py  parameters
NUM_PROC=3
FILTER=.4
#
DOWNLOAD_DIR="/media/jasir/Elements/Jasir/HoustonSLC/slc/"
DEM_DIR="./dem"
ORBIT_DIR="./orbit"
log_file='tops_stack.log' 

################ Download dem ########################
#
# Create the dem directory if it doesn't exist
mkdir -p "$DEM_DIR"
# Get the integer part of MIN values for dem
MIN_LON_D=$(printf "%.0f" "$MIN_LON")
MIN_LAT_D=$(printf "%.0f" "$MIN_LAT")
# Get the rounded integer part of MAX_LAT and lon
MAX_LON_D=$(printf "%.0f" "$(echo "$MAX_LON + 0.5" | bc)")
MAX_LAT_D=$(printf "%.0f" "$(echo "$MAX_LAT + 0.5" | bc)")

echo $MIN_LAT_D $MAX_LAT_D $MIN_LON_D $MAX_LON_D
dem.py -a stitch -b $MIN_LAT_D $MAX_LAT_D $MIN_LON_D $MAX_LON_D -r -s 1


################ Download SLC #######################
#
# Create the download directory if it doesn't exist
mkdir -p "$DOWNLOAD_DIR"

# Run the Python script with these arguments
python3 asf4.py -b $MIN_LON $MIN_LAT $MAX_LON $MAX_LAT \
    --start_date $START_DATE \
    --end_date $END_DATE \
    --flight_direction $TRACK \
    --download_path $DOWNLOAD_DIR \
    --user $UserName \
    --pass $Password 
#
################ Download orbit files #######################
# Create the orbit directory if it doesn't exist
mkdir -p "$ORBIT_DIR"
eof --search-path $DOWNLOAD_DIR --save-dir $ORBIT_DIR
#
################ creating run files  #######################
#
bbox=`echo "$MIN_LAT $MAX_LAT $MIN_LON $MAX_LON"`
echo $bbox
stackSentinel.py -s $DOWNLOAD_DIR -d $DEM_DIR/demLat_N*.dem.wgs84 -a ./AUX -o  $ORBIT_DIR -b "$bbox"  -W interferogram -c 3 -f $FILTER -p vv --num_proc $NUM_PROC 
#
################  run files  #######################
#
echo run_01_unpack_topo_reference >> $log_file
echo run_01_unpack_topo_reference
sh ./run_files/run_01_unpack_topo_reference

echo run_02_unpack_secondary_slc>> $log_file
echo run_02_unpack_secondary_slc
sh ./run_files/run_02_unpack_secondary_slc

echo run_03_average_baseline >> $log_file
echo run_03_average_baseline 
sh ./run_files/run_03_average_baseline

echo run_04_extract_burst_overlaps  >> $log_file
echo run_04_extract_burst_overlaps 
sh ./run_files/run_04_extract_burst_overlaps

echo run_05_overlap_geo2rdr >> $log_file
echo run_05_overlap_geo2rdr 
sh ./run_files/run_05_overlap_geo2rdr

echo run_06_overlap_resample >> $log_file
echo run_06_overlap_resample
sh ./run_files/run_06_overlap_resample

echo run_07_pairs_misreg >> $log_file
echo run_07_pairs_misreg
sh ./run_files/run_07_pairs_misreg

echo run_08_timeseries_misreg >> $log_file
echo run_08_timeseries_misreg
sh ./run_files/run_08_timeseries_misreg

echo run_09_fullBurst_geo2rdr >> $log_file
echo run_09_fullBurst_geo2rdr
sh ./run_files/run_09_fullBurst_geo2rdr

echo run_10_fullBurst_resample >> $log_file
echo run_10_fullBurst_resample
sh ./run_files/run_10_fullBurst_resample

echo run_11_extract_stack_valid_region >> $log_file
echo run_11_extract_stack_valid_region
sh ./run_files/run_11_extract_stack_valid_region

echo run_12_merge_reference_secondary_slc >> $log_file
echo run_12_merge_reference_secondary_slc
sh ./run_files/run_12_merge_reference_secondary_slc

echo run_13_generate_burst_igram >> $log_file
echo run_13_generate_burst_igram 
sh ./run_files/run_13_generate_burst_igram

echo run_14_merge_burst_igram >> $log_file
echo run_14_merge_burst_igram
sh ./run_files/run_14_merge_burst_igram

echo run_15_filter_coherence >> $log_file
echo run_15_filter_coherence
sh ./run_files/run_15_filter_coherence

echo run_16_unwrap >> $log_file
echo run_16_unwrap
sh ./run_files/run_16_unwrap
