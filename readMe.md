Mountainlab-JS for JadhavLab
======

Repository for Jadhav Lab code for the use of MountainSort-JS
% Last Updated: 2022 - Jacob Olson

Install Instructions are in INSTALL_INSTRUCTIONS.txt


%%%%%%%%%%%% All Instructions Below Here Preceded Olson 2022 Edits %%%%%%%%%%%%

TODO: convert franklab script to convert mountainsort output to FF files (spikes & cellinfo)
TODO: launcher script to simplify qt-mountainview launch


Usage
------
* run exportmda on your raw trodes data
* Required Directory Structure (+ - required naming scheme)
```
    animal_container_folder
    --> raw_data_folder (eg. RZ9)
        --> day_directories +(day#_date eg. 01_180924)
            --> Raw data files, etracted binaries, etc. +(animID_day#_date_whatever eg. RZ9_01_180924_1Sleep)
    --> direct_folder +(animID_direct eg. RZ9_direct)
```
    * required naming scheme is because currently the scripts parse animID, day #, date and tetrode number from file names
* ml_process_animal(animID,rawDir) will mountainsort all days for that animal. Output will be saved to animID_direct/MountainSort in folders for each day, with subfolders for each tetrode
    * I recommend passing this function a tet_list to restrict the tetrodes you run it on to only those you want to cluster, since MountainSort will take ~3.5GB per tetrode for 1hr of recording
* This wrapper function will:
    * create the output directories
    * make prv links to the raw mda files and copy over the timestamps.mda (TODO: make it use a link to save space)
    * Bandpass filter (600-6000 Hz), mask artifacts and whiten  the raw data. Saved as filt.mda (filtered and masked), and pre.mda (whitened filt.mda).
    * Split into epochs and spike sort each epoch separately
    * Track drift and combine clusters across epochs (output: firings_raw.mda)
    * Calculate cluster and isolation metrics (output: metrics_raw.json)
    * Automatically tag clusters to aid with manual verification (output: metrics_tagged.json), threshold taken from frank lab
* You can manually run each step and customize parameters (i.e. filtering band, thresholds, etc) using ml_filt_mask_whiten and ml_sort_on_segs which take the tetrode results directory as the input (animID_direct/MountainSort/day_folder.mountain/tetrode_folder)
    * read the help for each function to figure out how to customize variables in the function call
* additionally, all parameters  can be overriden using the params.json file inside the tetrode results directory by including fields in json format.

qt-mountainview
------
* cd into the tetrode directory you want to view
* launch qt-mountainview
    `qt-mountainview --raw=raw.mda.prv --filt=filt.mda --pre=pre.mda --firings=firings_raw.mda --cluster_metrics=metrics_tagged.json --samplerate=30000`
