# FAST-ChainViewer

Use this graphical utility to visualize the unsupervised output of our Fast Automated Spike Tracker ([FAST](https://github.com/Olveczky-Lab/FAST)) spike-sorting algorithm. 

Using a combination of automatic and manual procedures, you can interactively *merge* spike 'chains' or clusters that should belong to the same single unit, and *split* chains that are incorrect mergers of two or more single units.


## Installation

- You will need a computer running Matlab 2016a or later. 

- Depending on the size of your datasets, you may require a decent amount of memory and a desktop graphics card. For loading 3 month long tetrode recordings, we require at least 32 GB RAM. An SSD is also helpful to speed up loading/saving from disk.

- In order to split clusters that have been incorrectly merged by the automatic steps of FAST, we suggest downloading the spike-sorting software, [MClust](http://redishlab.neuroscience.umn.edu/MClust/MClust.html) (A. D. Redish et al). We have provided a loading engine **ChainSplitter_LE.m** that should be placed in the MClust Loading Engines folder - this will let you load the '*\*.s*' files generated by the Chain Viewer GUI (see Instructions below for more details). Make sure that MClust saves time-stamps of the final clusters with 64 bit precision.


## Data processing

- First run the function **saveMergedChainsWV.m** to generate spike waveform files for each FAST-identified 'merged chain' for the dataset.

- Now run **processAllChains.m** on the dataset. For each channel grouping, this will generate a consolidated list of FAST-identified chains across all recording files. This function will also identify putative links between neighbouring chains in the same file or across recording files, based on their beginning-to-end similarity; the chains can then be automatically merged in the GUI based on these similarity measures.


## GUI

