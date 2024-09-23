# Overview
Functional library and filesystem for mri processing. 

# What is not included in the repository
See the gitignore: public libraries need to be installed from the appropriate places available online
- bm3d 4.0.2
- wavelet-coherence-master

And the data also does not exist. Available by request from me as a zip of size 750MB. 

# Experiment Setup

Designed to be simple to use and grow. 

Set the proper path in config.m
Call init_paths('experiment_name_string').... this will place everything properly into paths and set global variables for the experiment you will like to work in (results will be saved there), and the calling directory will be placed here. 

Open the folder for the experiment - by experiment we mean some data analysis tasks that make some coherent idea in your mind, to group your scripting. The goal of this is just to keep the scripts organized. Clone an existing folder if you want something similar to what already exists. 

Then script away, and utilize the wide library of functions in the Common directory. 

# Adding Data

When you acquire data, simply paste it in the Data/Raw folder. 
Should be a 1 liner to convert it to the format. 

The format was chosen such that the 6th dimension will always be there, keeping a constant format without disappearing end dimensions form auto-squeezing .
Unfortunately, we have made it the detectors, so if doing non-EMI experiments, this will give you some bugs. But if you have multiple detectors, you can assume your data will be recorded as 6D

The spec dimensions
1 = Readout
2 = Phase encodes (misleadingly labeled fe rn)
3 = Echoes (automatically bumped to 2 for 3d imaging procedures, just repeated)
4 = repeats, these are repeats of the whole experiment after completion
5 = calibrations or averages, these are repeats of same echo train before moving to next
6 = Nc, number of coils 
(and the primary is going to be in position one)

# Filesystem Overview

## Data
Raw data from a single session can be placed in a folder inside of the Raw folder. One can use the appropriate file processing helper from Common/FileProcessing to get the corresponding data in the the Data/Processed directory, in a consistent format. The scripts in Experiments/validating_FileProcessing/Scripts give examples of how to process the different file types dependent on the acquisition parameters. Lastly, you may wish to create your own organization linkages between various scans, which are best put in the CustomDatasets folder. 

## Common
The common folder is the core of this library. Everything in here will be added to the path, so make sure not to have name collisions. 

General - this mostly consists of the different algorithms. Calibration, editer (old/standard implementation and the new/dev implementation). With the dev methods one can do just inference or training (named accordingly), but also the autotuned methods. We also have the smoothing implementations and some of the SNR/MSE metric calculations here. 

Helpers - This is mostly for functions that won't be called in an experiment script directly, but are used frequently and useful to have. Clarissa gave me a chunk of functions, and I added many of mine own. You should create your own folder for new ones. 

FileProcessing - The functions related to processing that data. 

Plotting - specific plot functions. the holy grail plot_with_scale function is actually in the helpers since it is called by so many other ones. 

Libraries - contains big external libraries, will be added to path. Early examples are the bm4d library and the wavelet-coherence-master library. 

python - contains starter code for CNN use on the exported matlab data. Python was also used occasionally for data analysis. 

Misc - ideally empty, just as a place for filees without a home

Legacy - similar to Misc, isn't really used. For old code that isn't quite ready to be deleted. In this case it was with old data formats. 

## Experiments

Here you can segment your work towards different ends. Scripts from only your selected one of these will be active (see caveat #1 in Random NOTES). If you choose to save plots, they will go in the localized results subfolder. Existing as of Sep 23, 2024 are different sections corresponding to different sections in the Master's thesis that went along with this work. 


# Random NOTES:
1. if you switch too many times, and have named files the same things in diff experiments,
    maybe you will have path problems, so just log out and back in. 
2. Much code and the comments is directly copied from chatGPT
3. I chose to leave all the files rather than just the very best, which may be confusing. My recommended top files to get started with are: 
* plot_with_scale.m = can work inside subplots, gives you control over the scaling to visualize small values. 
* the scripts inside Experiments/ValidateFileProcessing/Scripts = calling these will turn your raw data into processed. 
* scripts inside General/postprocessing along with plotDenoisingMosaic function = you can apply the smoothing algorithms and see how they affect the image for a variety of parameters
* devediter _full or _full_autotuned_simplified = for regular editer (w. or wo. the grid search window grouping method), _training and _inference = to do calibration (although this is also accomplished by calibration2d_EDITER)
* calculate_snr_saving2d = gets the snr, and allows you to save and store coordinates to get the same box for multiple reconstruction algorithms
* repeat_evaluation_quiet = use lambda functions to get the MSE metric automatically
* Helpers/shiftyifft = gets the primary back 