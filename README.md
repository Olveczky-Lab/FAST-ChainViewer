# FAST-ChainViewer

Use this graphical utility to visualize the unsupervised output of our [Fast Automated Spike Tracker (FAST)](https://github.com/Olveczky-Lab/FAST) spike-sorting algorithm. 

Using a combination of automatic and manual procedures, you can interactively *merge* spike 'chains' or clusters that belong to the same single unit, and *split* chains that are incorrect mergers of two or more single units.


## Installation

- You will need a computer running at least Matlab 2015b (we haven't tested earlier versions). Copy the entire code folder to your computer and add it to your Matlab path. The folder includes some File Exchange functions such as [xml2struct.m](https://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct) and [rgb2hex](https://www.mathworks.com/matlabcentral/fileexchange/46289-rgb2hex-and-hex2rgb).

- Depending on the size of your datasets, you may require a decent amount of memory and a desktop graphics card. For working with a tetrode dataset spanning ~3 months, we require at least 32 GB RAM. An SSD is also helpful for speeding up loading/saving variables from disk.

- In order to split clusters that have been incorrectly merged by the automatic steps of FAST, we suggest downloading the spike-sorting software, [MClust](http://redishlab.neuroscience.umn.edu/MClust/MClust.html) (A. D. Redish et al). We have provided a loading engine **ChainSplitter_LE.m** which should be placed in the MClust Loading Engines folder - this will let you load the '*\*.s*' files generated by the Chain Viewer GUI (see Instructions below for more details). Make sure that MClust saves time-stamps of the final clusters with 64 bit precision.
We also include the CrossCorr function from MClust. You may need to compile a mex file for your OS.


## Pre-processing

- First run the function **saveMergedChainsWV.m** to create spike waveform files for each FAST-identified 'merged chain' for the dataset.

- Now run **processAllChains.m** on the dataset. For each channel grouping, this will generate a consolidated list of FAST-identified chains across all recording files. This function will also identify putative links between neighbouring chains in the same file or across recording files, based on their beginning-to-end similarity; the chains can then be automatically merged in the GUI based on these similarity measures.


## GUI functions

- Ensure that you have updated the path to your dataset folder in **getDataPath.m** and then run **gui.m** to open the Chain Viewer GUI. The GUI consists of two windows... 
	- An interactive Figure window which displays the spike amplitudes of the Level 2 spikes (spike centroids generated by Step 1 of FAST) for the entire data-set, color-coded by their chain membership. 
	To toggle interaction with the Figure window, press the hotkey *c*. In interactive mode, moving the mouse over the data-points will highlight a chain or cluster, whose mean spike waveform(s) and ISI histogram(s) will be displayed in the GUI window.
	- A GUI window where various functions can be accessed in the form of buttons or through the menu structure. This window also maintains a list of putative single-unit clusters and displays spike waveform and ISI histogram data for any chain or cluster selected in the Figure window.
	
- Select *Files > Load chains* to load the chains for a channel group from your dataset. Select the **L2chainsMatTotAll.mat** file if this is the first time you are loading this dataset or **L2chainsMatTotAllBis.mat** if you would like to resume from the last save-point.

- You can load any previously saved clusters by selecting *Files > Load_clusters*.
	
- You can first try our automated method of merging chains into single-unit clusters. In the lower-right corner of the GUI window, set appropriate thresholds and weights for similarity of spike-waveforms and ISI histograms between neighboring chains, as well as the minimum number of spikes in a chain, and then click *Apply*. This will generate putative automatic clusters denoted by the prefix 'c' in the 'Clusters' list box. Any large unclustered chains will be denoted by the prefix 's'. 
If you are not satisfied with the outcome of the automatic chain linking, you can change the parameters and click *Re-apply*. 
	**Note: These steps will clear your previously defined clusters, so use with caution.**

- Manual clusters can be created by left-clicking on the desired chains/clusters in the Figure window to add them to the 'Selected' list in the GUI window, and then clicking on *Save Cluster*. A new cluster with the prefix 'm' will now appear in the *Clusters* list box. 

- To modify an existing cluster from the *Clusters* list, highlight it and select *Tools > Cluster to manual cluster* or press *Ctrl+D* to move its constituent chains to the *Selected* list box. Now you can add or delete chains and then save the modified cluster under a different name. To avoid redundancy, you should delete the old cluster.

- If you want to split a chain that contains spikes from a mixture of single units, hover over the chain in the Figure window and right-click on it to send it to the *Analysis* list box on the center right of the GUI window. Now select the chain(s) you want to split in the Analysis list-box, then select 'Split Chain' in the neighboring list box and finally click on the Apply button on the right. This will generate *\*.s* file(s) in a new *Split Chains* folder on your hard drive containing the spike times and waveforms for the selected chain(s). After splitting the chains in MClust, you can then select a chain and apply the *Replace Chains* option. This will read in the *\*.t* generated by MClust and replace the parent chain by its split children. 

- You can designate certain clusters as distinct by inserting an asterisk symbol '\*' before their name in the cluster list. We use these to identify clusters that we think of as 'finalized' as opposed to 'in-progress' clusters. Clusters with a '\*' before their name will automatically be saved to a variable *clustersChecked* in the saved cluster file. To mark a cluster with an asterisk, you can select cluster in the *Clusters* list box and click *Tools > Mark cluster* or use the hot-key button *m*. To un-mark a cluster, select the cluster in the list box and then click *Tools > Unmark cluster*, or use the hot-key button *u*.

- To save your progress, click *Files > Save clusters*. This will save your clusters to a file named **clusterVecAll.mat**, and the modified chains structure to a variable **L2chainsMatTotAllBis.mat**.

- Everytime you click the *Save Cluster* button below the *Selected* list box, the Chain Viewer GUI autosaves your progress. If Matlab crashes at some point or you accidentally lose your clusters, you can resume from the last autosave point by clicking *Files > Load autosaved clusters*.

## GUI shortcuts
There are a number of keyboard + mouse shortcuts you can use to speed up interacting with the Figure Window.

### Navigation
Shortcut  			|  Function
:---: 				| :---
Arrow keys 			| Translate plot.
Mouse wheel 		| Zoom plot.
*=* or *-* 			| X-axis zoom.
Keypad *+* or *-* 	| Y-axis zoom.
*t*					| Changes X-axis ticklabels to show absolute time (date and hour) instead of hours from the beginning of the recording.


### Changing Views
Shortcut  			|  Function
:---: 				| :---
*1*, *2*, *3*, *4*	| Change view to selected electrode channel.
*c* 				| Toggle interactive mode.
*r*					| Refresh view.
*n*					| Toggle view: clusters in color, non-clusters in black.
*p*					| Toggle view: clusters in black, non-clusters in color.
*8*					| Only show marked ('\*') clusters in color.
*0*					| Marked ('\*') cluster views: Press once to remove from plot. Press again to only show them in plot.
*m*					| Manual ('m') cluster views: Press once to remove from plot. Press again to only show them in plot.

### Interacting with chains
First move the cursor over a chain in Interactive mode to highlight it.

Shortcut  			|  Function
:---: 				| :---
Left-click			| Add chain (or cluster) to *Selected* list box.
Shift + Left-click	| Remove chain from *Selected* list box.
Right-click			| Add chain (or cluster) to *Analysis* list box.
*l*					| Show plots of raw spike waveform amplitudes v/s time for chain.
*a*					| Toggles highlighted chain for comparison. Move cursor over another chain to compare their spike waveforms and ISI histograms.
*x*					| Plot cross-correlogram between highlighted chain and comparison chain.

## Notes

- At present, the GUI is designed to work with 4-channel tetrode data. ChGroups with fewer channels can also be sorted but their waveforms will be automatically padded with zeros up to 4 channels. In the future we will add support for channel groups with > 4 channels.

- This program also assumes that the individual recording files of your dataset are named by the [MSDN timestamps](https://msdn.microsoft.com/en-us/library/system.datetime.ticks(v=vs.110).aspx), i.e. the time at which each continuous recording began. These time-stamps measure the number of 100 nanosecond intervals that have elapsed since 12:00:00 midnight on Jan 1, 0001. This naming convention is helpful to place all recorded events in the dataset on a common time-base. If your recording files/folders are named following a different convention, you will have to rename them in the form of 64 bit timestamps running at a clock rate of 10<sup>7</sup> Hz.

- You may need to change '\' to '/' for paths on UNIX based filesystems. 
