Designed to be simple. 

Set the proper path in config. 
Call init_paths().... this will place everything properly into paths, 
and set global variables for the experiment you will like to work in (results will be saved there), and the calling directory will be placed here. 

Open the folder for the experiment, some data analysis tasks that make some coherent idea in your mind. 
The goal of this is just to keep the scripts organized. Clone an existing folder if you want something similar to before. 

Then script away, and utilize the wide library of functions in the Common directory. 

When you acquire data, simply paste it in the Data/Raw folder. 
Should be a 1 liner to convert it to the format. 

The format was chosen such that the 6th dimension will always be there, keeping a constant format without disappearing end dimensions form auto-squeeze .
Unfortunately, we have made it the detectors, so if doing non-EMI experiments, this will give you some bugs. 
Perhaps i will make it the readout direction if i feel so inclined, but i doubt it as this reverses things a bit. 

The spec dimensions
1 = Readout
2 = Phase encodes (misleadingly labeled fe rn)
3 = Echoes (automatically bumped to 2 for 3d imaging procedures, just repeated)
4 = calibrations or averages, these are repeats of same echo train before moving to next
5 = repeats, these are repeats of the whole experiment after completion
6 = Nc, number of coils 
(and the primary is going to be in position one)

NOTES:
1. if you switch too many times, and have named files the same things in diff experiments,
    maybe you will have path problems, so just log out and back in. 