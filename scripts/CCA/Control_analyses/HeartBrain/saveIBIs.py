import os
import glob
import pandas as pd
import seaborn as sns
import numpy as np
from systole.detection import ppg_peaks, interpolate_clipping

from pathlib import Path
import json
sns.set_context('talk')

##########################################################################
# get subject numbers from BIDS folder & find physio data file (EXG)
##########################################################################
bids = "/mnt/raid0/scratch/BIDS/"
save_filepath = '/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/IBIs_RestScanAligned/'

subList = os.listdir(bids)
subList = [sub for sub in subList if sub.startswith("sub")]
subList = list(set(subList))
subList.sort()

# bad physio recordings (includes subjects with 'bad_segments' of poor quality, short data, less triggers)
participants_to_exclude = ["sub-0168", "sub-0516", "sub-0048", "sub-0335", "sub-0636", "sub-0037", "sub-0411", "sub-0187", "sub-0237", "sub-0273", "sub-0287", "sub-0518", "sub-0279","sub-0301","sub-0311","sub-0317","sub-0353","sub-0369","sub-0381","sub-0393","sub-0397","sub-0410","sub-0437","sub-0448","sub-0457","sub-0460","sub-0488","sub-0512","sub-0514","sub-0524","sub-0533","sub-0537","sub-0542","sub-0544","sub-0548","sub-0564","sub-0602","sub-0613","sub-0622","sub-0170","sub-0198","sub-0226"]

# these vmp1 subjects use scanner cardiac rather than exg:
vmp1_scanner = ["sub-0021", "sub-0156", "sub-0166", "sub-0169", "sub-0170", "sub-0198", "sub-0200", "sub-0221", "sub-0236", "sub-0246"]

for sub in subList:
    if not sub.startswith("sub"):
        continue

    # Exit here if we know the recording is faulty for this participant
    if sub in participants_to_exclude:
        continue

    print(sub)
    sub_nb = sub[4:]

    # List files
    file_list = glob.glob(bids + f"sub-{sub_nb}/" + "**/*.*", recursive=True)

    # find the EXG recording path (can contain EGG, RESP and cheek PPG - VMP1, finger PPG - VMP2)
    # VMP1:
    if int(sub_nb) <= 262:
        if sub in vmp1_scanner:
            exg_files = [f for f in file_list if f.endswith(
                "rest_run-001_physio.tsv.gz")]
            json_files = [f for f in file_list if f.endswith(
                "rest_run-001_physio.json")]
            ppg_name = "cardiac"
            pattern = "physio"
            sfreq = 200
        else:    
            exg_files = [f for f in file_list if f.endswith(
                "rest_run-001_recording-exg_physio.tsv.gz")]
            json_files = [f for f in file_list if f.endswith(
                "rest_run-001_recording-exg_physio.json")]
            ppg_name = "PLETH"
            pattern = "exg"
            sfreq = 1000
    # VMP2
    elif int(sub_nb) >= 263: 
        exg_files = [f for f in file_list if f.endswith(
            "rest_run-001_recording-cardiac_physio.tsv.gz")]
        json_files = [f for f in file_list if f.endswith(
            "rest_run-001_recording-cardiac_physio.json")]
        sfreq = 200
        ppg_name = "cardiac"
        pattern = "cardiac"

    if len(exg_files) == 1 and len(json_files) == 1:
        exg_file = exg_files[0]
        json_file = json_files[0]
    else:
        print(
            f"Subject {sub} - Cannot load data / too many data (number of tsv files ={len(exg_files)}, json = {len(json_files)})")
        continue
    

###############################################################################
# Extract ppg signal & R-peaks
###############################################################################

    # first check if manual correction file exists (& if so import corrected_peaks & preprocessed cardiac signal)
    correction_file = Path(f"/mnt/raid0/scratch/BIDS/derivatives/systole/corrected/{sub}/ses-session1/func/{sub}_ses-session1_task-rest_run-001_recording-{pattern}_peakscorrected.tsv.gz")
    if correction_file.is_file():
        cardiac_df = pd.read_csv(correction_file, compression='gzip', sep='\t')
        # convert to boolean peak array
        peaks = np.zeros(len(cardiac_df["cardiac"]), dtype=bool)
        peaks[pd.to_numeric(cardiac_df["peaks_corrected"].dropna(), downcast="integer")] = True
        signal = cardiac_df["cardiac"]
        sfreq = 1000
        
        # load orig cardiac file to cut data at start and end of rest scan triggers (TR trigs) (for scanner recordings)
        if sub in vmp1_scanner or int(sub_nb) >= 263:
            # import EXG files with cheek photoplethysmography 
            exg_df = pd.read_csv(f'{exg_file}', compression='gzip', sep='\t', header=None)
            f = open(f'{json_file}')
            json_dict = json.load(f)
            exg_df.columns = json_dict['Columns']
            # resample so same as correction file (1000 Hz)
            if np.sum(exg_df.iloc[:,1]) != 600: # check if sum triggers 600
                print(
                f"Subject {sub} - not 600 TR triggers")
                continue
            first_trig = np.argmax(exg_df.iloc[:, 1].values == 1) * 5 # * 5 as sampling rate of correction file in 1000Hz (this file in 200Hz  - so *5 more)
            last_trig = exg_df.iloc[:, 1][exg_df.iloc[:, 1] == 1].index[-1] * 5 # * 5 as sampling rate of correction file in 1000Hz (this file in 200Hz  - so *5 more)
            peaks = peaks[first_trig:last_trig+1]
                        
                                        
    # if no manual correction load raw cardiac data & compute peaks 
    else:
        
        # import EXG files with cheek photoplethysmography 
        exg_df = pd.read_csv(f'{exg_file}', compression='gzip', sep='\t', header=None)
        f = open(f'{json_file}')
        json_dict = json.load(f)
        exg_df.columns = json_dict['Columns']
        
        # cut data at start and end of rest scan triggers (TR trigs) (for scanner recordings)
        if sub in vmp1_scanner or int(sub_nb) >= 263:
            if np.sum(exg_df.iloc[:,1]) != 600: # check if sum triggers 600
                print(
                f"Subject {sub} - not 600 TR triggers")
                continue
            first_trig = np.argmax(exg_df.iloc[:, 1].values == 1)
            last_trig = exg_df.iloc[:, 1][exg_df.iloc[:, 1] == 1].index[-1]
            exg_df = exg_df.iloc[first_trig:last_trig+1,:] # align with first TR trigger


        # select photoplethysmography (ppg) as dataframe
        if not ppg_name in json_dict['Columns']:
            print(
                f"Subject {sub} - no ppg in exg file")
            continue

        ppg_idx = json_dict['Columns'].index(ppg_name)
        ppg_df = exg_df.iloc[:,ppg_idx]
        ppg_df = pd.Series.to_frame(ppg_df).rename(columns={ppg_name: 'ppg'})
        
        # correct for clipping artefacts for VMP1 (threshold=1e+6 i.e., 1'000'000 - set to just below this) 
        ppg_np = ppg_df.ppg.to_numpy() # ppg to numpy array (for peak detection)
        # VMP1:
        if int(sub_nb) <= 262 and sub not in vmp1_scanner:
            clean_ppg = interpolate_clipping(ppg_np, max_threshold=950000) 
        else:
            clean_ppg = ppg_np # no clipping correction for VMP2 

        # ppg peak detection
        # signal is resampled ppg signal (only if sfreq is diff from 1000 - systole default) & vector of peaks (0 & 1's))
        signal, peaks = ppg_peaks(clean_ppg, sfreq=sfreq, clean_nan=True)  # ensures when NaNs to interpolate 
        sfreq = 1000
        print(f'{sum(peaks)} peaks detected.')  

    ##################### compute & save IBIs ################################
    # Create a time vector (seconds)
    time = np.arange(0, len(peaks))/sfreq 
    # IBIs in seconds
    IBIs = pd.DataFrame()
    IBIs['first_rpeak_time'] = time[peaks] # time of first R-peak (secs)
    IBIs['second_rpeak_time']= [time[next_idx] if next_idx < len(time) else None for next_idx in np.where(peaks)[0][1:]] + [None] # second R-peak time (secs)
    IBIs = IBIs[:-1] # remove time of last IBI (as only has first r-peak - no second)
    IBIs['ibi'] = np.diff(time[peaks]) # IBI in seconds
    # Save IBIs as .txt file (for instantaneous HRV estimation)
    np.savetxt(rf'/mnt/raid0/scratch/BIDS/derivatives/InstantaneousHRV/IBIs_RestScanAligned/{sub}_IBIs_restscan.txt', IBIs.values, fmt='%f')
   