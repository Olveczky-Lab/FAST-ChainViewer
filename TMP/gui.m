function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      instance to run (singleton).
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 15-May-2015 17:42:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
               
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
chainsVec = {};
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%%%%%%%
% HELP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MINIMAP : Display all the data (bottom left). %%%%%%%%%%%
% SCREENER : Display selected data (Top and middle left). %
% THE MATRIX AND THE CLUSTERS NEED TO BE LOADED %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- PLOT CLUSTER (under clusters listbox).
function pushbutton25_Callback(hObject, eventdata, handles)
% Plotting of a selected cluster in the cluster listbox.
addpath([pwd '/plotFunctions/']);

% Loading the data.
value_selected = get(handles.listbox1, 'Value')
clusterVecAll = handles.clusterVecAll;

% Looking for the chains.
chainsMatTot = handles.chainsMatTot;
cluster = [];

for chain = 1 : length(clusterVecAll{1, value_selected})
    for chainL2 = 1 : length(chainsMatTot)
        if clusterVecAll{1, value_selected}(chain) == chainsMatTot(chainL2).num
            cluster = [cluster; chainsMatTot(chainL2)];
        end
    end
end


channel = handles.channel_screener;
channel_tetrode_screener = handles.channel_tetrode_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

% Plotting of the selection.
plotFunction(handles.plot_mode, cluster, channel, handles, channel_4_1, channel_4_2);
ylabel(['Ch ' num2str(channel)]);

% Loading of the waveforms.
L2cluster = [];
for chain = 1 : length(cluster)
    L2chain = cluster(chain);
    L2chain.wv = double(L2chain.wv);
    L2cluster = [L2cluster, L2chain];
end
    
% Plot of the waveforms;
cla(handles.axes3);
axes(handles.axes3);
plotSpikeWaveforms(L2cluster);

% Saving the variables.
handles.fromMap = 0;
handles.fromClust = 1;
handles.cluster = cluster;
guidata(hObject, handles)


% --- PLOT CHAINS (under Chains listbox).
function pushbutton27_Callback(hObject, eventdata, handles)
% Plot the selected chains in a selected cluster.
addpath([pwd '/plotFunctions/']);

% Determination of the channel.
channel = handles.channel_screener;

% Loading of the chain.
value_selected = get(handles.listbox1, 'Value');
value_selected_chains = get(handles.listbox2, 'Value');
chain = handles.clusterVecAll{1, value_selected}(value_selected_chains);

% Looking for the chains.
chainsMatTot = handles.chainsMatTot;

for chainL2 = 1 : length(chainsMatTot)
    if chain == chainsMatTot(chainL2).num
        chains = chainsMatTot(chainL2);
    end
end

% Plotting the chains.
axes(handles.axes2);
[color] = colorSelection;
plot(chains.times, double(chains.amps(:,channel)) * 1.95e-7, '.', 'color', color, 'markersize', 6);



% --- DISPLAY CHAINS (under Chains listbox).
function pushbutton26_Callback(hObject, eventdata, handles)
value_selected = get(handles.listbox1,'Value');
chainsNum = [handles.clusterVecAll{1, value_selected}];
chainsMatTot = handles.chainsMatTot;

chainsMatTotSelected = [];
for a = 1 : length(chainsMatTot)
    for b = 1 : length(chainsNum)
        if chainsMatTot(a).num == chainsNum(b);
            chainsMatTotSelected =  [chainsMatTotSelected, chainsMatTot(a)];
        end
    end
end
    
set(handles.listbox2, 'value', 1);
set(handles.listbox2, 'string', chainsNum);



% SHUFFLE.
function pushbutton63_Callback(hObject, eventdata, handles)
% Shuffle the chains.
addpath([pwd '/plotFunctions/']);

% Determination of the border.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;

% Determination of the channel.
channel = handles.channel_minimap;

% Croping the data.
chainsMatTot = handles.chainsMatTot;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot(1 : end-1), borderLeft, borderRight, 10, channel);

% Shuffle the data.
ix = randperm(length(chainsMatTot));
chainsMatTotShuffled = chainsMatTot(ix);

% Plotting the data.
cla(figure(1));
figure(1);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTotShuffled(1 : end - 1), channel);

xlim([borderLeft, borderRight]);
ylabel(['Ch ' num2str(channel)]);


% --- MINIMAP LEFT.
function pushbutton29_Callback(hObject, eventdata, handles)
% Shifting of the minimap to the left.
addpath([pwd '/plotFunctions/']);

% Determination of the border.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;

% Determination of the channel.
channel = handles.channel_minimap;

% Croping the data.
chainsMatTot = handles.chainsMatTot;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 2, channel);

% Plotting the data.
cla(figure(1));
figure(1);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel);

xlim([borderLeft, borderRight]);
ylabel(['Ch ' num2str(channel)]);

hFigure = gcf;
setappdata(0, 'hFigure', hFigure);

% Saving the variables.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;

guidata(hObject, handles)


% ---MINIMAP RIGHT.
function pushbutton30_Callback(hObject, eventdata, handles)
% Shifting of the minimap to the right.
addpath([pwd '/plotFunctions/']);

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;

% Determination of the channel.
channel = handles.channel_minimap;

% Cropping the data.
chainsMatTot = handles.chainsMatTot;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 3, channel);

% Plotting the data.
cla(figure(1));
figure(1);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel);
xlim([borderLeft, borderRight]);
ylabel(['Ch ' num2str(channel)]);

hFigure = gcf;
setappdata(0, 'hFigure', hFigure);

% Saving the variables.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
guidata(hObject, handles)


% ---MINIMAP ZOOM +.
function pushbutton31_Callback(hObject, eventdata, handles)
% Zoom in in the minimap.
addpath([pwd '/plotFunctions/']);

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;

% Determination of the channel.
channel = handles.channel_minimap;

% Cropping of the data.
chainsMatTot = handles.chainsMatTot;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 0, channel);

% Plotting the data.
cla(figure(1));
figure(1)

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel);
xlim([borderLeft, borderRight]);
ylabel(['Ch ' num2str(channel)]);

hFigure = gcf;
setappdata(0, 'hFigure', hFigure);

% Saving the variables.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
guidata(hObject, handles)


% --- MINIMAP ZOOM -.
function pushbutton32_Callback(hObject, eventdata, handles)
% Zoom out in the minimap.
addpath([pwd '/plotFunctions/']);

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;

% Determination of the channel.
channel = handles.channel_minimap;

% Cropping the data.
chainsMatTot = handles.chainsMatTot;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 1, channel);

% Plotting of the data.
cla(figure(1));
figure(1)

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel);
xlim([borderLeft, borderRight]);
ylabel(['Ch ' num2str(channel)]);

hFigure = gcf;
setappdata(0, 'hFigure', hFigure);

% Saving the data.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
guidata(hObject, handles)


% --- DISP NOISE.
function pushbutton60_Callback(hObject, eventdata, handles)
% Allow to disp the grey background.
noise = handles.noise;

if noise == 1
    handles.noise = 0;
end
if noise == 0
    handles.noise = 1;
end

guidata(hObject, handles)


% --- PLOT CHAINS (under All chains listbox)
function pushbutton33_Callback(hObject, eventdata, handles)
% Plot a selected after a manual selection in the minimap.
addpath([pwd '/plotFunctions/']);

% Loading of the variables.
value_selected_chains = get(handles.listbox3, 'Value');
axes(handles.axes2);

% Determination of the channel.
channel = handles.channel_screener;

% Plotting of the data.
axes(handles.axes2);
[color] = colorSelection;
plot(handles.chainsMatTotSelectedAxes1(value_selected_chains).times, double(handles.chainsMatTotSelectedAxes1(value_selected_chains).amps(:,channel)) * 1.95e-7, '.', 'color', color, 'markersize', 6);


% --- DISP ALL.
function pushbutton34_Callback(hObject, eventdata, handles)
% Disp all the chains in the minimap.
addpath([pwd '/plotFunctions/']);

% Determination of the channel.
channel = handles.channel_minimap;

% Plotting of the data.
cla(handles.axes1);
axes(handles.axes1);

if handles.noise == 1
    plotSpikeChains(handles.chainsMatTot(end), 1, channel, 3);
end

extractChains = handles.extractChains;
plotSpikeChains(extractChains, 1, channel, 3);
ylabel(['Ch ' num2str(channel)]);


% --- DELETE CLUSTER (under cluters listbox).
function pushbutton39_Callback(hObject, eventdata, handles)
% Delete the selectioned cluster. 
addpath([pwd '/plotFunctions/']);

% Loading of the variables.
cluster_selected = handles.cluster_selected;
clusterVecAll = handles.clusterVecAll;
counta = 0;
global manualModifications;
chainsMatTot = handles.chainsMatTot;

% Identification of the selected cluster and deletion. The links between
% the chains are stocked in a variable. If the user compute the clusters
% with a new combination of criteria, the manual changes would be applied
% to the linksMatrix. 
for a = 1 : size(clusterVecAll, 2)
    a = a - counta;
    clusterName = clusterVecAll{2, a};
    
    if strcmp(cluster_selected, clusterName) == 1
        chainsList = clusterVecAll{1, a};
        clusterVecAll(:, a) = [];
        counta = counta + 1;
        
        % Saving the modifications of the links in a cell.
        for chain1 = 1 : length(chainsList)
            
            for chain2 = 1 : length(chainsList)
                
                % Identification of the chain and of the time.
                if chain1 ~= chain2;
                    manualModifications{end + 1} = [chainsList(chain1), chainsList(chain2), 0];      
                    manualModifications{end + 1} = [chainsList(chain2), chainsList(chain1), 0];
                end
            end
        end
    end
end

[chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, clusterVecAll);

% Updating the list of clusters.
clusterVecAllName = clusterVecAll(2, :);

set(handles.listbox1, 'value', 1);
set(handles.listbox1, 'string', clusterVecAllName);

% Saving of the variables.
handles.chainsMatTot = chainsMatTot;
handles.clusterVecAll = clusterVecAll;
guidata(hObject, handles)


% --- DELETE CHAINS (under Chains listbox).
function pushbutton40_Callback(hObject, eventdata, handles)
% Delete the selected chains for the list chains.
addpath([pwd '/plotFunctions/']);

value_selected = get(handles.listbox1,'Value');
value_selected_chains = get(handles.listbox2, 'Value');
clusterVecAll = handles.clusterVecAll;
cluster = clusterVecAll{1, value_selected};
chains_selected = cluster(value_selected_chains);
chainsMatTot = handles.chainsMatTot;
counta = 0;

disp('Chains selected :')
disp(chains_selected)

for a = 1 : length(cluster)
    a = a - counta;
    num = cluster(a);
    if num == chains_selected
        cluster(a) = [];
        counta = counta + 1;
    end
end

clusterVecAll{1, value_selected} = cluster;
chainsNum = [cluster] 

[chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, clusterVecAll);

handles.clusterVecAll = clusterVecAll;
handles.chainsMatTot = chainsMatTot;

set(handles.listbox2, 'value', 1);
set(handles.listbox2, 'string', chainsNum);

guidata(hObject, handles)


% --- PLOT CHAINS (under In screener listbox).
function pushbutton41_Callback(hObject, eventdata, handles)
% Plot the selected chains in the inScreener list.
addpath([pwd '/plotFunctions/']);

% TODO : Change the channel of the plot. 
value_selected = handles.values_selected_inScreener;
chains_selected = handles.chains_selected_inScreener;

chains = handles.chainsMatTotSelectedAxes2(value_selected);

% Channel.
channel = handles.channel_screener;

axes(handles.axes2);
[color] = colorSelection;
plot(chains.times, double(chains.amps(:,channel)) * 1.95e-7, '.', 'color', color, 'markersize', 6);

axes(handles.axes3);
cla(handles.axes3);
plotSpikeWaveforms(chains);


% --- DELETE CHAINS (under Selected cluster listbox).
function pushbutton43_Callback(hObject, eventdata, handles)
% Delete the selected chains in the newCluster construction.
addpath([pwd '/plotFunctions/']);

value_selected = handles.values_selected_newCluster;
newCluster = handles.newCluster;
chains_selected = newCluster(value_selected);
counta = 0;
disp('Chains selected :')
disp(chains_selected)

for a = 1 : length(newCluster)
    a = a - counta;
    num = newCluster(a);
    if num == chains_selected
        newCluster(a) = [];
        counta = counta + 1;
    end
end

% Update of pairsMatrix.
pairsMatrix = handles.pairsMatrix;
for a = 1 : length(newCluster)
    num = newCluster(a);

    if (pairsMatrix(num + 1, chains_selected + 1) ==  1)
        pairsMatrix(num + 1, chains_selected + 1 ) = 0;
    end

    if (pairsMatrix(chains_selected + 1, num  + 1) == 1)
        pairsMatrix(chains_selected + 1, num + 1) = 0;
    end
end
    
      
chainsNum = [newCluster]; 
disp('Remaining chains :')
disp(chainsNum)

handles.newCluster = newCluster;

set(handles.listbox6, 'value', 1);
set(handles.listbox6, 'string', chainsNum);
guidata(hObject, handles)


% --- PLOT CLUSTER (under Selected cluster listbox).
function pushbutton42_Callback(hObject, eventdata, handles)
% Plot the newCluster.
addpath([pwd '/plotFunctions/']);

newCluster = handles.newCluster;
channel = handles.channel_screener;

% Looking for the chains.
chainsMatTot = handles.chainsMatTot;
cluster = [];

for chain = 1 : length(newCluster)
    for chainL2 = 1 : length(chainsMatTot)
        if newCluster(chain) == chainsMatTot(chainL2).num
            cluster = [cluster; chainsMatTot(chainL2)];
        end
    end
end

axes(handles.axes2);
cla(handles.axes2);
plotSpikeChains(cluster, 1 , channel, 6);

% Loading of the waveforms.
% Loading of the waveforms.
L2cluster = [];
for chain = 1 : length(cluster)
    L2chain = cluster(chain);
    L2chain.wv = double(L2chain.wv);
    L2cluster = [L2cluster, L2chain];
end
    
% Plot of the waveforms;
cla(handles.axes3);
axes(handles.axes3);
plotSpikeWaveforms(L2cluster);


% --- SAVE CLUSTER (under Selected cluster listbox).
function pushbutton38_Callback(hObject, eventdata, handles)
% Save the cluster manually create.
addpath([pwd '/plotFunctions/']);
addpath([pwd '/clusteringFunctions/']);

% Loading of the variable.
newCluster = handles.newCluster;
newCluster = {newCluster};
clusterVecAll = handles.clusterVecAll;
manualClusters = handles.manualClusters;
chainsMatTot = handles.chainsMatTot;
global manualModifications;

% ClusterNomination.
newCluster = clusterNomination(newCluster, 1);

% Adding the new cluster to the list of clusters.
manualClusters = [manualClusters, newCluster];

% Assignation of a color to the clusters. 
[color] = colorSelection;
newCluster = [newCluster; {color}];

clusterVecAll = [clusterVecAll, newCluster];


% Saving the modifications of the links in a cell. 
for chain1 = 1 : length(newCluster{1, 1})
    
    for chain2 = 1 : length(newCluster{1, 1})
        
        if chain1 ~= chain2;
            manualModifications{end + 1} = [newCluster{1, 1}(chain1), newCluster{1, 1}(chain2), 1];
            manualModifications{end + 1} = [newCluster{1, 1}(chain2), newCluster{1, 1}(chain1), 1];
        end
    end
end

[chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, clusterVecAll);

% Saving the data.
newCluster = [];
handles.newCluster = newCluster;
handles.clusterVecAll = clusterVecAll;
handles.manualClusters = manualClusters;
handles.manualModifications = manualModifications;
handles.chainsMatTot = chainsMatTot;

set(handles.listbox1, 'value', 1);
set(handles.listbox1, 'string', [clusterVecAll(2, :)])
set(handles.listbox6, 'value', 1);
set(handles.listbox6, 'string', newCluster);
guidata(hObject, handles);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
value_selected = get(hObject, 'Value');
item_selected = items{value_selected};
handles.cluster_selected = item_selected;
handles.value_selected = value_selected;
guidata(hObject, handles);


% --- SCALE MINIMAP.
function pushbutton61_Callback(hObject, eventdata, handles)
% Allow to scale the minimap to the position of the inscreener plot.
% Loading of the cluster displayed in the screener.
addpath([pwd '/plotFunctions/']);

cluster = handles.cluster;

% Extraction of the time of each chains of the cluster.
times = [];
for chains = 1 : length(cluster)    
    times = [times; cluster(chains).times];
end

% Determination of the borders for the minimap.
borderLeft = min(times);
borderRight = max(times);

% Detection of the channel.
channel = handles.channel_minimap;

% Croping the chains.
chainsMatTot = handles.chainsMatTot;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 10, channel);

% cla(handles.axes1);
figure(1);

% Determination if the noise has to be display.
if handles.noise == 1
    plotSpikeChains(chainsMatTot(end), 1, channel, 3);
end

% Displaying of the chains in the minimap.
plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel);
xlim([borderLeft, borderRight]);
ylabel(['Ch ' num2str(channel)]);

plotSpikeCluster(cluster, 1, channel);

% Saving the borders.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
guidata(hObject, handles)


% --- CLEAN LIST.
function pushbutton47_Callback(hObject, eventdata, handles)
% Clean the listbox with the selected chains for statistical analysis.
analysisVec = []

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', analysisVec);
handles.analysisVec = analysisVec;
guidata(hObject, handles);


% --- APPLY
function pushbutton48_Callback(hObject, eventdata, handles)
% Apply the statistical test selected.
addpath([pwd '/plotFunctions/']);
addpath([pwd '/automaticStep/']);
addpath([pwd '/toolsFunctions/']);
addpath([pwd '/toolsFunctions/crossCorrelation/'])
test_selected = handles.test_selected;
test_value_selected = handles.test_value_selected;
value_selected_inAnalysis = handles.values_selected_inAnalysis;

analysisVec = handles.analysisVec;

% TESTS AND ANALYSIS.
% HISI test.
if test_value_selected == 1;
    chainsSelected = analysisVec(value_selected_inAnalysis);
    chainsMatTot = handles.chainsMatTot;
    
    for chainL2 = 1 : length(chainsMatTot)
        if chainsSelected == chainsMatTot(chainL2).num
            chains = chainsMatTot(chainL2);
        end
    end
    
    pathway = [handles.pathBasic chains.names{1}];
    ChGroup = chains.channel;
    disp('Loading complete chains...')
    chainsSelectedTest = getSomeMergedChains(pathway, ChGroup, chains.trueNumber, 0);
    chainsSelectedTest.times = double(chainsSelectedTest.times);
    
    % Control if the chains is in the first file. 
    if length(chains.names{1} == '635400060049541397') > sum(chains.names{1} == '635400060049541397')
        chainsSelectedTest.times = (((chainsSelectedTest.times / 30000) / 60) / 60);
        chainsSelectedTest.times = chainsSelectedTest.times + chains.timeBegin;
    else
        chainsSelectedTest.times = (((chainsSelectedTest.times / 30000) / 60) / 60);
    end
    
    if length(chainsSelectedTest.times) > 100;
        isiTmp = ((chainsSelectedTest.times * 60) * 60) * 1000;
        spikeActivity = sgolayfilt(histc(diff(isiTmp), logspace(0, 6, 100)), 3, 9);
        spikeActivityNormalized = spikeActivity / length(chainsSelectedTest.times);
        figure(2);
        semilogx(logspace(0, 6, 100), spikeActivityNormalized);
        hold all;
        semilogx([2, 2], [min(spikeActivityNormalized), max(spikeActivityNormalized)], '-.', 'color', [0.75  0.75  0.75]);
        hold all;
        set(handles.textTools, 'string', 'hISI plotted !');
    else
        disp('Impossible to calcul the HISI. The chains is to short');
        set(handles.textTools, 'string', 'Impossible to calcul the Hisi. The chains is to short');
    end
end

% Correlation test.
if test_value_selected == 2;
    disp('Correlation test (spike waveforms)')
    chainsSelected = analysisVec(value_selected_inAnalysis);
    chainsMatTot = handles.chainsMatTot;
    handles.chainsForCorrelation = [];
    handles.correlation_ready = 0;
    
    chain1 = chainsSelected(1);
    chain2 = chainsSelected(2);
    
    for chainL2 = 1 : length(chainsMatTot)
        if chain1 == chainsMatTot(chainL2).num
            chains1 = chainsMatTot(chainL2);
        end
    end
    for chainL2 = 1 : length(chainsMatTot)
        if chain2 == chainsMatTot(chainL2).num
            chains2 = chainsMatTot(chainL2);
        end
    end
    
    disp('Loading complete chains...')
    pathway = [handles.pathBasic chains1.names{1}];
    chainSelectedTest1 = getSomeMergedChains(pathway, chains1.channel, chains1.trueNumber, 1, 1);
    pathway = [handles.pathBasic chains2.names{1}];
    chainSelectedTest2 = getSomeMergedChains(pathway, chains2.channel, chains2.trueNumber, 1, 1);
    
    if length(chains1.names{1} == '635400060049541397') > sum(chains1.names{1} == '635400060049541397')
        chainSelectedTest1.times = chainSelectedTest1.times / 30000 / 60 / 60;
        chainSelectedTest1.times = chainSelectedTest1.times + chains1.timeBegin;
    else
        chainSelectedTest1.times = chainSelectedTest1.times / 30000 / 60 / 60;
    end
    if length(chains2.names{1} == '635400060049541397') > sum(chains2.names{1} == '635400060049541397')
        chainSelectedTest2.times = chainSelectedTest2.times / 30000 / 60 / 60;
        chainSelectedTest2.times = chainSelectedTest2.times + chains1.timeBegin;
    else
        chainSelectedTest2.times = chainSelectedTest2.times / 30000 / 60 / 60;
    end
    
    select1 = round(0.1*length(chainSelectedTest1.times));
    select2 = round(0.1*length(chainSelectedTest2.times));
    
    if select1 > 100
        select1 = 100;
    end
    if select2 > 100
        select2 = 100;
    end
    
    wv1 = double(chainSelectedTest1.wv(1 : select1, :, :))*1.95e-7;
    wv2 = double(chainSelectedTest2.wv((end - select2 + 1) : end, :, :))*1.95e-7;
    wvSqueezeMean1 = squeeze(mean(wv1));
    wvSqueezeMeanTransp1 = wvSqueezeMean1';
    wvSqueezeMean2 = squeeze(mean(wv2));
    wvSqueezeMeanTransp2 = wvSqueezeMean2';
    
    criteria_corr = corr(wvSqueezeMeanTransp1(:), wvSqueezeMeanTransp2(:));
    
    set(handles.textTools, 'string', num2str(criteria_corr));
end

% Distance test (normalized).
if test_value_selected == 3;
    disp('Distance test (spike waveforms)')
    chainsSelected = analysisVec(value_selected_inAnalysis);
    chainsMatTot = handles.chainsMatTot;
    
    chain1 = chainsSelected(1);
    chain2 = chainsSelected(2);
    
    for chainL2 = 1 : length(chainsMatTot)
        if chain1 == chainsMatTot(chainL2).num
            chains1 = chainsMatTot(chainL2);
        end
    end
    for chainL2 = 1 : length(chainsMatTot)
        if chain2 == chainsMatTot(chainL2).num
            chains2 = chainsMatTot(chainL2);
        end
    end
    
    disp('Loading complete chains...')
    pathway = [handles.pathBasic chains1.names{1}];
    chainSelectedTest1 = getSomeMergedChains(pathway, chains1.channel, chains1.trueNumber, 1, 1);
    pathway = [handles.pathBasic chains2.names{1}];
    chainSelectedTest2 = getSomeMergedChains(pathway, chains2.channel, chains2.trueNumber, 1, 1);
    
    if length(chains1.names{1} == '635400060049541397') > sum(chains1.names{1} == '635400060049541397')
        chainSelectedTest1.times = chainSelectedTest1.times / 30000 / 60 / 60;
        chainSelectedTest1.times = chainSelectedTest1.times + chains1.timeBegin;
    else
        chainSelectedTest1.times = chainSelectedTest1.times / 30000 / 60 / 60;
    end
    if length(chains2.names{1} == '635400060049541397') > sum(chains2.names{1} == '635400060049541397')
        chainSelectedTest2.times = chainSelectedTest2.times / 30000 / 60 / 60;
        chainSelectedTest2.times = chainSelectedTest2.times + chains1.timeBegin;
    else
        chainSelectedTest2.times = chainSelectedTest2.times / 30000 / 60 / 60;
    end
    
    select1 = round(0.1*length(chainSelectedTest1.times));
    select2 = round(0.1*length(chainSelectedTest2.times));
    
    if select1 > 100
        select1 = 100;
    end
    if select2 > 100
        select2 = 100;
    end
    
    wv1 = double(chainSelectedTest1.wv(1 : select1, :, :))*1.95e-7;
    wv2 = double(chainSelectedTest2.wv((end - select2 +1) : end, :, :))*1.95e-7;
    wvSqueezeMean1 = squeeze(mean(wv1));
    wvSqueezeMeanTransp1 = wvSqueezeMean1';
    wvSqueezeMean2 = squeeze(mean(wv2));
    wvSqueezeMeanTransp2 = wvSqueezeMean2';
    
    wvDist = (wvSqueezeMeanTransp1(:) - wvSqueezeMeanTransp2(:)).^2;
    wvDistSum = sqrt(sum(wvDist));
    wvSqueezeStd1 = squeeze(std(wv1));
    wvSqueezeStdTransp1 = wvSqueezeStd1';
    wvStdSum1 = sum(wvSqueezeStdTransp1(:));
    wvSqueezeStd2 = squeeze(std(wv2));
    wvSqueezeStdTransp2 = wvSqueezeStd2';
    wvStdSum2 = sum(wvSqueezeStdTransp2(:));
    
    criteria_dist = wvDistSum / ((wvStdSum2 + wvStdSum1) / 2);
    
    set(handles.textTools, 'string', num2str(criteria_dist));
end

% Test chains compatibility is a function allowing to find the compatibles
% chains, just in function of time, with the selected chains. It returns 
% the statistics analysis (hISI, waveforms distance and correlation) of the
% compatibility. In order to find the possible compatible chains with a
% cluster, select the last or the first chains of the cluster and apply the
% function. 
if test_value_selected == 4;
    compatibleChains = [];
    matrixSc = [];
    chainsSelected = analysisVec(value_selected_inAnalysis);
    linksMatrix = handles.linksMatrix;
    
    for row = 1 : length(linksMatrix)
        if (linksMatrix(row, 1) == chainsSelected)
            compatibleChains = [compatibleChains, linksMatrix(row, 2)];
            rowSc = [linksMatrix(row, 2), linksMatrix(row, 6), linksMatrix(row, 10), (linksMatrix(row, 3) / ((linksMatrix(row, 4) + linksMatrix(row, 5)) / 2)), linksMatrix(row, 12)]; %* log(linksMatrix(row, 7))];
            matrixSc = [matrixSc; rowSc];
        end
        if (linksMatrix(row, 2) == chainsSelected)
            compatibleChains = [compatibleChains, linksMatrix(row, 1)];
            rowSc = [linksMatrix(row, 1), linksMatrix(row, 6), linksMatrix(row, 10), (linksMatrix(row, 3) / ((linksMatrix(row, 4) + linksMatrix(row, 5)) / 2)), linksMatrix(row, 12)]; % * log(linksMatrix(row, 7))];
            matrixSc = [matrixSc; rowSc];
        end
    end
    
    for row = 1 : size(matrixSc, 1)
        if matrixSc(row, 3) == 0
            matrixSc(row, 3) = NaN;
        end
    end
    
    if size(matrixSc, 1) == 0
        set(handles.textTools, 'string', 'No compatibility.');
    else
        [~, ia] = unique(matrixSc(:, 1), 'rows');
        matrixSc = matrixSc(ia, :);   
        compatibleChains = unique(compatibleChains);
        set(handles.textTools, 'string', compatibleChains);
        format long
        disp(matrixSc)
        figure(5);
        imagesc(matrixSc(:, 2:end));
        set(gca, 'YTick', [1 : size(matrixSc, 1)])
        set(gca, 'yticklabel', cellstr(num2str(matrixSc(:, 1))));
        set(gca, 'Xtick', [1, 2, 3, 4])
        set(gca, 'xticklabel', {'Correlation', 'ISI correlation', 'Distance', 'Criteria'})
        [Row, ~] = find(matrixSc == max(matrixSc(:, 5)));
        disp('Best partner : ')
        disp(matrixSc(Row, 1))
    end
end

% Plot all of the possible partners. Identification of the putative
% partners by the same way used in the test 4.
if test_value_selected == 5;
    chainsMatTot = handles.chainsMatTot;
    chainsMatTotTmp = [];
    compatibleChains = [];
    matrixSc = [];
    chainsSelected = analysisVec(value_selected_inAnalysis);
    linksMatrix = handles.linksMatrix;
    
    for row = 1 : length(linksMatrix)
        if (linksMatrix(row, 1) == chainsSelected)
            compatibleChains = [compatibleChains, linksMatrix(row, 2)];
            rowSc = [linksMatrix(row, 2)];
            matrixSc = [matrixSc; rowSc];
        end
        if (linksMatrix(row, 2) == chainsSelected)
            compatibleChains = [compatibleChains, linksMatrix(row, 1)];
            rowSc = [linksMatrix(row, 1)];
            matrixSc = [matrixSc; rowSc];
        end
    end
    
    matrixSc = unique(matrixSc);
    
    for a = 1 : length(chainsMatTot)
        for b = 1 : length(matrixSc)
            if chainsMatTot(a).num == matrixSc(b)
                chainsMatTotTmp = [chainsMatTotTmp; chainsMatTot(a)];
            end
        end
    end
    
    figure()
    plotSpikeChains(chainsMatTotTmp, 1, handles.channel_screener, 6)
    hold all
    
    for a =  1 : length(chainsMatTot)
        if chainsMatTot(a).num == chainsSelected
            chains = chainsMatTot(a);
        end
    end
    
    plotSpikeCluster(chains, 1, handles.channel_screener);
    
    disp(matrixSc)
end

% Find cluster. This test return the cluster which contains the selected
% chain. 
if test_value_selected == 6
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    chainsSelected = analysisVec(value_selected_inAnalysis);
    chainsList = [];
    
    for a = 1 : size(clusterVecAll, 2)
        clusterTested = clusterVecAll{1, a};
        
        for b = 1 : length(clusterTested)
            if clusterTested(b) == chainsSelected
                clusterSelected = clusterVecAll{1, a};
                clusterSelectedName = clusterVecAll{2, a};
            end
        end
    end
    
    for a =  1 : length(chainsMatTot)
        for b = 1 : length(clusterSelected)
            if chainsMatTot(a).num == clusterSelected(b)
                chainsList = [chainsList; chainsMatTot(a)];
            end
        end
    end
    
    figure();
    plotSpikeChains(chainsList, 1, handles.channel_screener, 6)
    hold all
    
    for a =  1 : length(chainsMatTot)
        if chainsMatTot(a).num == chainsSelected
            chains = chainsMatTot(a);
        end
    end
    
    plotSpikeCluster(chains, 1, handles.channel_screener)
    
    set(handles.textTools, 'string', clusterSelectedName);
    
end

% Cross Correlation
if test_value_selected == 7
    disp('Cross correlation')
    set(handles.textTools, 'string', 'Cross correlation');

    chainsMatTot = handles.chainsMatTot;
    [chainsSelected] = chainsSearch(chainsMatTot, analysisVec(value_selected_inAnalysis));
    
    chain1 = chainsSelected(1);
    chain2 = chainsSelected(2);
    chain1.times = chain1.times * 3600;
    chain2.times = chain2.times * 3600;
    [C, B] = CrossCorr(chain1.times, chain2.times, 2, 500);
    figure()
    plot(B, C)
    xlabel('msec')
    ylabel('Count')
    title(['XCorr ' num2str(chain1.num) ' Vs ' num2str(chain2.num)]);
end

% Split a chain. 
if test_value_selected == 8
    chainsMatTot = handles.chainsMatTot;
    chainsSelected = analysisVec(value_selected_inAnalysis);
    [chains] = chainsSearch(chainsMatTot, chainsSelected);
    saveSpikesforSplit(chains, handles.pathBasic, handles.savepath);
end

% Load a split chain.
if test_value_selected == 9
    chainsMatTot = handles.chainsMatTot;
    pairsMatrix = handles.pairsMatrix;
    chainsSelected = analysisVec(value_selected_inAnalysis);
    [chains, chain_inds] = chainsSearch(chainsMatTot, chainsSelected);
    L1chainSplits = getChainSplits(chains, handles.pathBasic, handles.savepath);
    L2chainSplits = getL2Splits(chains, L1chainSplits, handles.pathBasic);
    [handles] = replaceChainWithSplits(handles, chains, L1chainSplits, L2chainSplits);
    handles.chainsMatTot = chainsMatTot;
    handles.pairsMatrix = pairsMatrix;
end

guidata(hObject, handles)


% --- DELETE CHAINS (under All chains listbox).
function pushbutton52_Callback(hObject, eventdata, handles)
% Delete chains for All chains list.
addpath([pwd '/plotFunctions/']);

value_selected = handles.value_selected_allChains;
chains_selected = handles.chains_selected_allChains;
counta = 0;

% From map security. 
if handles.fromMap == 1
    chainsMatTotSelectedAxes1 = handles.chainsMatTotSelectedAxes1;
end

chains = chainsMatTotSelectedAxes1(value_selected)
disp('Chains selected :')
disp(chains.num)
chainsMatTotSelectedAxes1(value_selected) = [];
disp('Remaining chains :');
disp([chainsMatTotSelectedAxes1.num])

set(handles.listbox3, 'value', 1);
set(handles.listbox3, 'string', [chainsMatTotSelectedAxes1.num]);
handles.chainsMatTotSelectedAxes1 = chainsMatTotSelectedAxes1;
guidata(hObject, handles)


% --- DELETE CHAINS (under In screener listbox).
function pushbutton53_Callback(hObject, eventdata, handles)
% Delete chains for In screener list.
value_selected = handles.values_selected_inScreener;
chains_selected = handles.chains_selected_inScreener;

if handles.fromMap == 1
    chainsMatTotSelectedAxes2 = handles.chainsMatTotSelectedAxes2;
end
if handles.fromClust == 1
    value_selected_TMP = get(handles.listbox1, 'Value');
    chainsMatTotSelectedAxes2 = handles.clusterVecAll{1, value_selected_TMP};
end

chainsMatTotSelectedAxes2(value_selected) = [];
chainsNum = [chainsMatTotSelectedAxes2.num];

handles.chainsMatTotSelectedAxes2 = chainsMatTotSelectedAxes2;
set(handles.listbox5, 'value', 1);
set(handles.listbox5, 'string', chainsNum);
guidata(hObject, handles)


% --- DELETE CHAINS (statistical tools).
function pushbutton56_Callback(hObject, eventdata, handles)
% Delete chains for Analysis list. 
value_selected = handles.values_selected_inAnalysis;
chains_selected = handles.chains_selected_inAnalysis;
counta = 0;
analysisVec = handles.analysisVec;
chains = analysisVec(value_selected);
disp('Chains selected :')
disp(chains)
analysisVec(value_selected) = [];
chainsNum = [analysisVec];

handles.analysisVec = analysisVec;

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor', 'white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
value_selected = get(hObject, 'Value');
item_selected = items(value_selected);
handles.chains_selected = item_selected;
handles.value_selected_chains = value_selected;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- ALL CHAINS LISTBOX.
function listbox3_Callback(hObject, eventdata, handles)
items = get(hObject,'String');
value_selected = get(hObject,'Value');
chains_selected = items(value_selected);
handles.chains_selected_allChains = chains_selected;
handles.value_selected_allChains = value_selected;
guidata(hObject,handles);


% --- ALL CHAINS LISTBOX.
function listbox3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
items = get(hObject,'String');
value_selected = get(hObject,'Value');
test_selected = items(value_selected);
display(test_selected);
handles.test_selected = test_selected;
handles.test_value_selected = value_selected;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox5.
function listbox5_Callback(hObject, eventdata, handles)
% List 'In screener'.
items = get(hObject,'String');
value_selected = get(hObject,'Value');
chains_selected_inScreener = items(value_selected);
handles.values_selected_inScreener = value_selected;
handles.chains_selected_inScreener = chains_selected_inScreener;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function listbox5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox6.
function listbox6_Callback(hObject, eventdata, handles)
% Chains selected to form a new cluster. 
items = get(hObject,'String');
value_selected = get(hObject,'Value');
chains_selected = items(value_selected);
handles.values_selected_newCluster = value_selected;
handles.chains_selected_newCluster = chains_selected;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function listbox6_CreateFcn(hObject, eventdata, handles)
% Chains selected to form a new cluster. 
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox7.
function listbox7_Callback(hObject, eventdata, handles)
% List of chains selected for statistical analysis.
items = get(hObject,'String');
value_selected = get(hObject,'Value');
chains_selected_inAnalysis = items(value_selected);
handles.values_selected_inAnalysis = value_selected;
handles.chains_selected_inAnalysis = chains_selected_inAnalysis;
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function listbox7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- CHAIN > ANALYSIS.
function edit1_Callback(hObject, eventdata, handles)
% Enter a chains
chainsEnter = str2double(get(hObject,'string'));

if isnan(chainsEnter)
    errordlg('You must enter a numeric value', 'Invalid Input', 'modal')
    uicontrol(hObject)
    return
else
    display(chainsEnter);
end

chainsMatTot = handles.chainsMatTot;

for a = 1 : length(chainsMatTot)
    chains = chainsMatTot(a);
    if chains.num == chainsEnter
        chainSelected = chains;
    end
end

analysisVec = handles.analysisVec;
analysisVec = [analysisVec, chainSelected.num];
chainsNum = [analysisVec];

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);
handles.analysisVec = analysisVec;
    
guidata(hObject, handles);


% --- CHAIN > ANALYSIS.
function edit1_CreateFcn(hObject, eventdata, handles)
% Enter a chains
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- CLUSTER > ANALYSIS.
function edit3_Callback(hObject, eventdata, handles)
% Enter a cluster.
clusterEnter = get(hObject,'string');
clusterVecAll = handles.clusterVecAll;

for a = 1 : length(clusterVecAll)
    if strcmp(clusterVecAll{2, a}, clusterEnter) == 1
        clusterSelected = clusterVecAll{1, a};
    end
end

analysisVec = clusterSelected;
chainsNum = [analysisVec];

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);
handles.analysisVec = analysisVec;

guidata(hObject, handles);


% --- CLUSTER > ANALYSIS.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- CHAIN > CLUSTER.
function edit4_Callback(hObject, eventdata, handles)
% Add a chains to the new cluster. 
chainsEnter = str2double(get(hObject,'string'));

if isnan(chainsEnter)
    errordlg('You must enter a numeric value', 'Invalid Input', 'modal')
    uicontrol(hObject)
    return
else
    display(chainsEnter);
end

chainsMatTot = handles.chainsMatTot;
newCluster = handles.newCluster;

for a = 1 : length(chainsMatTot)
    chains = chainsMatTot(a);
    
    if chains.num == chainsEnter
        newCluster = [newCluster, chains.num];
    end
end

handles.newCluster = newCluster;
chainsNum = [newCluster];

set(handles.listbox6, 'string', chainsNum);
set(handles.listbox6, 'string', chainsNum);
guidata(hObject, handles);


% --- CHAIN > CLUSTER.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- CLUSTER > CLUSTER.
function edit5_Callback(hObject, eventdata, handles)
% Enter a cluster.

% Identification of the cluster.
clusterEnter = get(hObject, 'string');
clusterVecAll = handles.clusterVecAll;
manualClusters = handles.manualClusters;

for a = 1 : size(clusterVecAll, 2)
    
    if (strcmp(clusterVecAll{2, a}, clusterEnter) == 1)
        clusterSelected = clusterVecAll{1, a};
    end
end


% Find if a cluster is already select.
newCluster = handles.newCluster;
newCluster = [newCluster, clusterSelected];

set(handles.listbox6, 'value', 1);
set(handles.listbox6, 'string', newCluster);

% Saving the variable.
handles.newCluster = newCluster;
guidata(hObject, handles);


% --- CLUSTER > CLUSTER.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- DIST THRESHOLD.
function edit6_Callback(hObject, eventdata, handles)
distThresholdEnter = get(hObject, 'string')
handles.distThreshold = str2num(distThresholdEnter);
guidata(hObject, handles);


% --- DIST THRESHOLD.
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- CORR THRESHOLD.
function edit7_Callback(hObject, eventdata, handles)
corrThresholdEnter = get(hObject, 'string')
handles.corrThreshold = str2num(corrThresholdEnter);
guidata(hObject, handles);


% --- CORR THRESHOLD.
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- ISI THRESHOLD.
function edit8_Callback(hObject, eventdata, handles)
isiThresholdEnter = get(hObject, 'string')
handles.isiThreshold = str2num(isiThresholdEnter);
guidata(hObject, handles);


% --- ISI THRESHOLD.
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- TEMPERATURE PARAMETER.
function edit9_Callback(hObject, eventdata, handles)
temperatureParameterEnter = get(hObject, 'string')
handles.temperatureParameter = str2num(temperatureParameterEnter);
guidata(hObject, handles);


% --- TEMPERATURE PARAMETER.
function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
end


% --- APPLY CLUSTERING.
function pushbutton58_Callback(hObject, eventdata, handles)
addpath([pwd '/plotFunctions/']);
addpath([pwd '/clusteringFunctions/']);
set(handles.textTools, 'string', 'Clustering...');

temperatureParameter = handles.temperatureParameter;
isiThreshold = handles.isiThreshold;
distThreshold = handles.distThreshold;
corrThreshold = handles.corrThreshold;
linksMatrix = handles.linksMatrix;
ampsParameter = handles.ampsParameter;
lengthParameter = handles.lengthParameter;
chainsMatTot = handles.chainsMatTot;
% singleCluster = handles.singleCluster;
wDist = handles.wDist;
xDist = handles.xDist;
wCorr = handles.wCorr;
xCorr = handles.xCorr;
wISI = handles.wISI;
xISI = handles.xISI;

[groupList, pairsMatrixOutput, linksMatrixOutput] = linksMatrixClustering(linksMatrix, chainsMatTot, wDist, wCorr, wISI, xDist, xCorr, xISI, distThreshold, corrThreshold, isiThreshold, temperatureParameter, ampsParameter, lengthParameter);

% Assignations of the cluster modes.
[chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, groupList);


handles.groupList = groupList;
handles.pairsMatrix = pairsMatrixOutput;
handles.linksMatrix = linksMatrixOutput;
handles.chainsMatTot = chainsMatTot;

set(handles.textTools, 'string', 'clustering DONE');

handles.clusterVecAll = groupList;
clusterVecAllName = handles.groupList(2, :);
handles.clusterVecAll = groupList;
set(handles.listbox1, 'value', 1);
set(handles.listbox1, 'string', clusterVecAllName);
guidata(hObject, handles);


% --- RE-APPLY.
function pushbutton62_Callback(hObject, eventdata, handles)
% Allow to re-apply with new parameters from the matrix manaully changed.
addpath([pwd '/plotFunctions/']);
addpath([pwd '/clusteringFunctions/']);

temperatureParameter = handles.temperatureParameter;
isiThreshold = handles.isiThreshold;
distThreshold = handles.distThreshold;
corrThreshold = handles.corrThreshold;
linksMatrix = handles.linksMatrix;
ampsParameter = handles.ampsParameter;
lengthParameter = handles.lengthParameter;
chainsMatTot = handles.chainsMatTot;
pairsMatrix = handles.pairsMatrix;
manualClusters = handles.manualClusters;
wDist = handles.wDist;
xDist = handles.xDist;
wCorr = handles.wCorr;
xCorr = handles.xCorr;
wISI = handles.wISI;
xISI = handles.xISI;

set(handles.textTools, 'string', 'Clustering.');

% [~, pairsMatrixOutput, linksMatrixOutput] = linksMatrixClustering(linksMatrix, chainsMatTot, wDist, wCorr, wISI, xDist, xCorr, xISI, distThreshold, corrThreshold, isiThreshold, temperatureParameter, ampsParameter, lengthParameter);

pairsMatrixOutput = handles.pairsMatrix;
linksMatrixOutput = handles.linksMatrix;

% Application of the manual modifications.
global manualModifications;
for element = 1 : length(manualModifications)
    
    % Deletion.
    if manualModifications{element}(end) == 0
        pairsMatrixOutput(manualModifications{element}(1) + 1, manualModifications{element}(2) + 1) = 0;
    end
    
    % Addition.
    if manualModifications{element}(end) == 1;
        pairsMatrixOutput(manualModifications{element}(1) + 1, manualModifications{element}(2) + 1) = 1;
    end
end

% If the single chains have less than 5000 spikes, it is not conserved. 
singleList = find(all(~pairsMatrixOutput, 1) & all(~pairsMatrixOutput, 2)');
singleList = singleList - 1;

singleFinalChain = {};
for chain = 1 : length(singleList)
    [indiceRow, indiceColumn] = find(linksMatrix(:, 1:2) == singleList(chain));
    
    if (length(indiceColumn) > 1) || (length(indiceRow) > 1)
        if indiceColumn(1) == 1
            chainLength = linksMatrix(indiceRow(1), 8);
        end
        if indiceColumn(1) == 2
            chainLength = linksMatrix(indiceRow(1), 9);
        end
        if chainLength > 5000
            singleFinalChain{end + 1} = singleList(chain);
        end
    end
end

[singleFinalChain] = clusterNomination(singleFinalChain, 2);

% Chains joining.
[groupList] = clusterCreation(pairsMatrixOutput);

% Grouping step.
[groupList] = clusterConstruction(groupList);

% Cleaning of the small groups.
[groupList] = clustersSelection(linksMatrix, groupList, lengthParameter);
[groupList] = clusterNomination(groupList, 0);

% Adding the single chains
groupList = [groupList, singleFinalChain];

% Assignation of a color to the clusters. 
clusterColor = [];
for a = 1 : length(groupList)
    [color] = colorSelection;
    clusterColor = [clusterColor, {color}];
end

groupList = [groupList; clusterColor];

clusterVecAll = groupList;

[chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, clusterVecAll);

manualClusters = [manualClusters; clusterColor];
clusterVecAll = [clusterVecAll, manualClusters];
handles.clusterVecAll = clusterVecAll;
handles.chainsMatTot = chainsMatTot;
clusterVecAllName = clusterVecAll(2, :);
handles.pairsMatrix = pairsMatrixOutput;

set(handles.listbox1, 'value', 1);
set(handles.listbox1, 'string', clusterVecAllName);
set(handles.textTools, 'string', 'Clustering DONE.');

guidata(hObject, handles);


% --- LENGTH THRESHOLD.
function Length_Callback(hObject, eventdata, handles)
lengthParameterEnter = get(hObject, 'string')
handles.lengthParameter = str2num(lengthParameterEnter);
guidata(hObject, handles);


% --- LENGTH THRESHOLD.
function Length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- AMPS THRESHOLD.
function edit11_Callback(hObject, eventdata, handles)
ampsParameterEnter = get(hObject, 'string')
handles.ampsParameter = str2num(ampsParameterEnter);
guidata(hObject, handles);


% --- AMPS THRESHOLD.
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- wDist.
function edit14_Callback(hObject, eventdata, handles)
wDist = get(hObject, 'string')
handles.wDist = str2num(wDist);
guidata(hObject, handles);


% --- wDist.
function edit14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- xDist.
function edit15_Callback(hObject, eventdata, handles)
xDist = get(hObject, 'string')
handles.xDist = str2num(xDist);
guidata(hObject, handles);


% --- xDist.
function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- wCorr.
function edit16_Callback(hObject, eventdata, handles)
wCorr = get(hObject, 'string')
handles.wCorr = str2num(wCorr);
guidata(hObject, handles);


% --- wCorr.
function edit16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- xCorr.
function edit17_Callback(hObject, eventdata, handles)
xCorr = get(hObject, 'string')
handles.xCorr = str2num(xCorr);
guidata(hObject, handles);


% --- xCorr.
function edit17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- wISI.
function edit18_Callback(hObject, eventdata, handles)
wISI = get(hObject, 'string')
handles.wISI= str2num(wISI);
guidata(hObject, handles);


% --- wISI.
function edit18_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- xISI.
function edit19_Callback(hObject, eventdata, handles)
xISI = get(hObject, 'string')
handles.xISI = str2num(xISI);
guidata(hObject, handles);


% --- xISI.
function edit19_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- SELECT EXTRACTION.
function edit20_Callback(hObject, eventdata, handles)
selectExtraction = get(hObject, 'string')
handles.selectExtraction = str2num(selectExtraction);
guidata(hObject, handles);


% --- SELECT EXTRACTION.
function edit20_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- PLOT ENTIRE CHAIN.
function pushbutton64_Callback(hObject, eventdata, handles)
% Plot the entire chain selected in the minimap.
addpath([pwd '/plotFunctions/']);

% Loading of the variables.
value_selected_chains = get(handles.listbox3, 'Value');

% Loading data.
chainsMatTot = handles.chainsMatTot;

% Determination of the channel.
channel = handles.channel_screener;
num = handles.chainsMatTotSelectedAxes1(value_selected_chains).num;

for a = 1 : length(chainsMatTot)
    if chainsMatTot(a).num == num
        chains = chainsMatTot(a);
    end
end

% Plotting of the data.
axes(handles.axes2);
cla(handles.axes2);
plotSpikeChains(chains, 1, channel, 6);


% --- PLOT ENTIRE CHAIN (in screener).
function pushbutton65_Callback(hObject, eventdata, handles)
% Plot whole chain in screener.
addpath([pwd '/plotFunctions/']);

% Plot the entire chain selected in the minimap.
% Loading of the variables.
value_selected_chains = get(handles.listbox5, 'Value');

% Loading data.
chainsMatTot = handles.chainsMatTot;

% Determination of the channel.
channel = handles.channel_screener;
num = handles.chainsMatTotSelectedAxes2(value_selected_chains).num;

for a = 1 : length(chainsMatTot)
    if chainsMatTot(a).num == num
        chains = chainsMatTot(a);
    end
end

% Plotting of the data.
axes(handles.axes2);
cla(handles.axes2);
plotSpikeChains(chains, 1, channel, 6);


% --- SHORTCUTS --- %
% --------------------------------------------------------------------
function load_chains_Callback(hObject, eventdata, handles)
% Allow to load the chainsMatTot file.
set(handles.textTools, 'string', 'Loading.');
addpath([pwd '/plotFunctions/']);

% Determination of the pathway.
[filename, pathname] = uigetfile({'L2chainsMatTotAll.mat'}, 'File Selector');
pathnameFull = strcat(pathname, filename);
chainsMatTot = load(pathnameFull);
handles.savepath = pathname;

% Determination of the pathway were the original data are saved.
pathBasic = 'U:/Data/Dhanashri/';

% Creation of the variable which contains all of the L2 chains.
chainsMatTot = chainsMatTot.L2chainsMatTotAll;
disp('L2 loaded')

% Save the matrix in the handles.
handles.chainsMatTot = chainsMatTot;

% Displaying in the minimap.
borderLeft = 1;
borderRight = 10;
borderUp = 5e-4;
borderDown = -5e-4;

[borderLeft, borderRight] = chainsSelectionMinimap(chainsMatTot, borderLeft, borderRight, 10, 1);

% axes(handles.axes1);
figure(1);

plotSpikeChains(chainsMatTot(end), 1, 1, 3);
hold all
plotSpikeChains(chainsMatTot(1 : end - 1), 1, 1, 3);
ylim([borderDown, borderUp]);
xlim([borderLeft, borderRight]);
hFigure = gcf;

% Initialisation of the different variables.
handles.chainsMatTot = chainsMatTot;
handles.newCluster = [];
handles.analysisVec = [];
handles.chainsSelectedTest = [];
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
handles.borderUp = borderUp;
handles.borderDown = borderDown;
handles.noise = 1 ; 
handles.manualModifications = {};
handles.manualClusters = [];
handles.newCluster = [];
handles.channel_minimap = 1;
handles.channel_screener = 1;
handles.pathBasic = pathBasic;
handles.cluster_mode = [0, 0];
handles.plot_mode = [1, 0, 0, 0, 0, 0, 0];
handles.channel_tetrode_screener = {[1, 0, 0, 0], [0, 1, 0, 0]};
handles.temperatureParameter = 1e-3;
handles.isiThreshold = 0.9;
handles.distThreshold = 0.2;
handles.corrThreshold = 0.9;
handles.ampsParameter = 1;
handles.lengthParameter = 10000;
handles.wDist = 1;
handles.xDist = 1;
handles.wCorr = 1;
handles.xCorr = 1;
handles.wISI = 1;
handles.xISI = 1;
handles.color_chains = 0;
global manualModifications;
manualModifications = {};
     

% Loading the linksMatrix which contains the relations between the chains.
set(handles.textTools, 'string', 'Loading.');

%Loading the file.    
% [filename, pathname] = uigetfile({'linksMatrix.mat'}, 'File Selector');
pathnameFull = strcat(pathname, 'linksMatrix.mat');
linksMatrix = load(pathnameFull);
% singleCluster = load([pathname 'singleCluster']);

set(handles.textTools, 'string', 'Loading Complete');

% Saving the variables.
handles.linksMatrix = linksMatrix.linksMatrix;
% handles.singleCluster = singleCluster;

setappdata(0, 'hFigure', hFigure);
guidata(hObject, handles);


% --------------------------------------------------------------------
function load_clusters_Callback(hObject, eventdata, handles)
% Allow to load previous clusters (from a previous session, for example).
set(handles.textTools, 'string', 'Loading.');

% Determination of the pathway.
[filename, pathname] = uigetfile({'*.mat'}, 'File Selector');
pathnameFull = strcat(pathname, filename);
clusterVecAll = load(pathnameFull);
chainsMatTot = handles.chainsMatTot;

set(handles.textTools, 'string', 'Loading DONE');

% Saving the variables in the handles.
clusterVecAllTmp = [clusterVecAll.cluster.clusterVecAll];
handles.clusterVecAll = clusterVecAllTmp;
handles.linksMatrix = clusterVecAll.cluster.linksMatrix;
handles.pairsMatrix = clusterVecAll.cluster.pairsMatrix;
handles.manualClusters = clusterVecAll.cluster.manualClusters;
global manualModifications;
manualModifications = clusterVecAll.cluster.manualModifications; 
clusterVecAllName = clusterVecAllTmp(2, :);

% Assignations of the cluster modes.
[chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, clusterVecAllTmp);

set(handles.listbox1, 'value', 1);
set(handles.listbox1, 'string', clusterVecAllName); 

handles.chainsMatTot = chainsMatTot;
guidata(hObject, handles);


% --------------------------------------------------------------------
function save_clusters_Callback(hObject, eventdata, handles)
% Allow to save the cluster manually changed during the session.

% Loading the data.
clusterVecAll = handles.clusterVecAll;
pairsMatrix = handles.pairsMatrix;
linksMatrix = handles.linksMatrix;
global manualModifications;
manualClusters = handles.manualClusters;

cluster = [];
cluster.clusterVecAll= clusterVecAll;
cluster.linksMatrix = linksMatrix;
cluster.pairsMatrix = pairsMatrix;
cluster.manualModifications = manualModifications;
cluster.manualClusters = manualClusters;

disp(cluster)
[file, path] = uiputfile('clusterVecAll.mat', 'Save clusters configuration');
save(strcat(path, file), 'cluster', '-v7.3');
disp(['File saved to ' strcat(path, file)]);
set(handles.textTools, 'string', 'File saved.');


% --------------------------------------------------------------------
function files_Callback(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function minimap_Callback(hObject, eventdata, handles)
% hObject    handle to minimap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function chain_analysis_Callback(hObject, eventdata, handles)
% Select chains for analysis from in screener.
value_selected = get(handles.listbox5, 'Value');

if handles.fromMap == 1
    chainsMatTotSelectedAxes2 = handles.chainsMatTotSelectedAxes2;
    chains = chainsMatTotSelectedAxes2(value_selected).num;
end
if handles.fromClust == 1
    chainsMatTotSelectedAxes2 = handles.chainsMatTotSelectedAxes2;
    chains = chainsMatTotSelectedAxes2(value_selected).num;
end

analysisVec = handles.analysisVec;
analysisVec = [analysisVec, chains];
chainsNum = [analysisVec];

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);
handles.analysisVec = analysisVec;
guidata(hObject, handles);


% --------------------------------------------------------------------
function chain_cluster_Callback(hObject, eventdata, handles)
% Add a chains to the new cluster. 
value_selected = get(handles.listbox5, 'Value');

chainsMatTot = handles.chainsMatTot;
newCluster = handles.newCluster;

if handles.fromMap == 1
    chainsMatTotSelectedAxes2 = handles.chainsMatTotSelectedAxes2;
    chains = chainsMatTotSelectedAxes2(value_selected).num;
end
if handles.fromClust == 1
    chainsMatTotSelectedAxes2 = handles.chainsMatTotSelectedAxes2;
    chains = chainsMatTotSelectedAxes2(value_selected).num;
end

newCluster = [newCluster, chains];

handles.newCluster = newCluster;
chainsNum = [newCluster];

set(handles.listbox6, 'value', 1);
set(handles.listbox6, 'string', chainsNum);
guidata(hObject, handles);


% --------------------------------------------------------------------
function cluster_to_analysis_Callback(hObject, eventdata, handles)
% Add a chains to the new cluster.
value_selected = get(handles.listbox1, 'Value')
clusterVecAll = handles.clusterVecAll;

cluster = clusterVecAll{1, value_selected};

chainsMatTot = handles.chainsMatTot;
analysisVec = handles.analysisVec;

analysisVec = [analysisVec, cluster];
chainsNum = analysisVec;

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);
handles.analysisVec = analysisVec;
guidata(hObject, handles);


% --------------------------------------------------------------------
function cluster_to_cluster_Callback(hObject, eventdata, handles)
% Add a chains to the new cluster. 
value_selected = get(handles.listbox1, 'Value')
clusterVecAll = handles.clusterVecAll;

cluster = clusterVecAll{1, value_selected};

chainsMatTot = handles.chainsMatTot;
newCluster = handles.newCluster;

newCluster = [newCluster, cluster];

handles.newCluster = newCluster;
chainsNum = [newCluster];

set(handles.listbox6, 'string', chainsNum);
set(handles.listbox6, 'string', chainsNum);
guidata(hObject, handles);


% --------------------------------------------------------------------
function select_zone_screener_Callback(hObject, eventdata, handles)
% Selection by hand of a region in the screener. The numbers of the
% selected chains are displayed in a listbox.
addpath([pwd '/plotFunctions/']);
addpath([pwd '/selectTools/']);

% Coordinates of the selection.
axes(handles.axes2);
[x, y] = DrawConvexHull;
selectTimeMin = min(x);
selectTimeMax = max(x);
selectAmpsMin = min(y);
selectAmpsMax = max(y);

% Determination of the channel.
channel = handles.channel_screener;

% Croping of the data. The data could come from a manual selection in the
% minimap, a plotted cluster or from the plot of a cluster in construction.
if handles.fromMap == 1
    [chainsMatTotSelectedAxes2] = chainsSelection(handles.chainsMatTotSelectedAxes1, selectTimeMin, selectTimeMax, selectAmpsMin, selectAmpsMax, handles.channel_screener, 'fromMap');
end

if handles.fromClust == 1
    value_selected = get(handles.listbox1, 'Value');
    chainsMatTot = handles.chainsMatTot;
    clusterVecAll = handles.clusterVecAll;
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelectedAxes1 = cluster;
    [chainsMatTotSelectedAxes2] = chainsSelection(chainsMatTotSelectedAxes1, selectTimeMin, selectTimeMax, selectAmpsMin, selectAmpsMax, handles.channel_screener, 'fromClust');
end

chainsNum = [chainsMatTotSelectedAxes2.num];

set(handles.listbox5, 'value', 1);
set(handles.listbox5, 'string', chainsNum);

axes(handles.axes3);
cla(handles.axes3);
plotSpikeWaveforms(chainsMatTotSelectedAxes2);

% Saving the variables.
handles.chainsMatTotSelectedAxes2 = chainsMatTotSelectedAxes2;
guidata(hObject, handles)


% --------------------------------------------------------------------
function channel_screener_1_Callback(hObject, eventdata, handles)
% Refresh the channel for the screener.
addpath([pwd '/plotFunctions/']);

channel_screener = 1;

if handles.fromMap == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1(end), 1, channel_screener, 6)
    plotSpikeChains(handles.chainsMatTotSelectedAxes1(1 : end - 1), 1, channel_screener, 6)

    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(handles.chainsMatTotSelectedAxes1)
end

if handles.fromClust == 1
    cla(handles.axes2);
    axes(handles.axes2);
    value_selected = get(handles.listbox1, 'Value');
    chainsMatTot = handles.chainsMatTot;
    clusterVecAll = handles.clusterVecAll;
    cluster = [];
    
    for chain = 1 : length(clusterVecAll{1, value_selected})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    
    % Loading of the waveforms.
    L2cluster = [];
    for chain = 1 : length(cluster)
        L2chain = cluster(chain);
        L2chain.wv = double(L2chain.wv);
        L2cluster = [L2cluster, L2chain];
    end

    plotSpikeChains(cluster, 1, channel_screener, 6)
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(L2cluster)
    
    handles.channel_screener = channel_screener;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function channel_screener_2_Callback(hObject, eventdata, handles)
% Refresh the channel for the screener.
addpath([pwd '/plotFunctions/']);

channel_screener = 2;

if handles.fromMap == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1(end), 1, channel_screener, 6)
    plotSpikeChains(handles.chainsMatTotSelectedAxes1(1 : end - 1), 1, channel_screener, 6)

    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(handles.chainsMatTotSelectedAxes1)
end

if handles.fromClust == 1
    cla(handles.axes2);
    axes(handles.axes2);
    value_selected = get(handles.listbox1, 'Value');
    chainsMatTot = handles.chainsMatTot;
    clusterVecAll = handles.clusterVecAll;
    cluster = [];
    
    for chain = 1 : length(clusterVecAll{1, value_selected})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    
    % Loading of the waveforms.
    L2cluster = [];
    for chain = 1 : length(cluster)
        L2chain = cluster(chain);
        L2chain.wv = double(L2chain.wv);
        L2cluster = [L2cluster, L2chain];
    end

    plotSpikeChains(cluster, 1, channel_screener, 6)
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(L2cluster)
    
    handles.channel_screener = channel_screener;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function channel_screener_3_Callback(hObject, eventdata, handles)
% Refresh the channel for the screener.
addpath([pwd '/plotFunctions/']);

channel_screener = 3;

if handles.fromMap == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1(end), 1, channel_screener, 6)
    plotSpikeChains(handles.chainsMatTotSelectedAxes1(1 : end - 1), 1, channel_screener, 6)
    
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(handles.chainsMatTotSelectedAxes1)
end

if handles.fromClust == 1
    cla(handles.axes2);
    axes(handles.axes2);
    value_selected = get(handles.listbox1, 'Value');
    chainsMatTot = handles.chainsMatTot;
    clusterVecAll = handles.clusterVecAll;
    cluster = [];
    
    for chain = 1 : length(clusterVecAll{1, value_selected})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    
    % Loading of the waveforms.
    L2cluster = [];
    for chain = 1 : length(cluster)
        L2chain = cluster(chain);
        L2chain.wv = double(L2chain.wv);
        L2cluster = [L2cluster, L2chain];
    end

    plotSpikeChains(cluster, 1, channel_screener, 6)
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(L2cluster)
    
    handles.channel_screener = channel_screener;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function channel_screener_4_Callback(hObject, eventdata, handles)
% Refresh the channel for the screener.
addpath([pwd '/plotFunctions/']);

channel_screener = 4;

if handles.fromMap == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1(end), 1, channel_screener, 6)
    plotSpikeChains(handles.chainsMatTotSelectedAxes1(1 : end - 1), 1, channel_screener, 6)
    
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(handles.chainsMatTotSelectedAxes1)
end

if handles.fromClust == 1
    cla(handles.axes2);
    axes(handles.axes2);
    value_selected = get(handles.listbox1, 'Value');
    chainsMatTot = handles.chainsMatTot;
    clusterVecAll = handles.clusterVecAll;
    cluster = [];
    
    for chain = 1 : length(clusterVecAll{1, value_selected})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    
    % Loading of the waveforms.
    L2cluster = [];
    for chain = 1 : length(cluster)
        L2chain = cluster(chain);
        L2chain.wv = double(L2chain.wv);
        L2cluster = [L2cluster, L2chain];
    end

    plotSpikeChains(cluster, 1, channel_screener, 6)
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(L2cluster)
    
    handles.channel_screener = channel_screener;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function plot_with_clusters_Callback(hObject, eventdata, handles)
% Plot the cluster with only one color in the minimap.
% Loading data.
cluster_mode = handles.cluster_mode;

if (cluster_mode == [0, 0]) | (cluster_mode == [0, 1])
    handles.cluster_mode = [1, 0];
end
if cluster_mode == [1, 0]
    handles.cluster_mode = [0, 0];
end

if handles.cluster_mode == [1, 0];
    set(handles.text_mode, 'string', 'Black clusters ON; Colors clusters OFF')
end
if handles.cluster_mode == [0, 0];
    set(handles.text_mode, 'string', 'Black clusters OFF; Color clusters OFF')
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function plot_with_cluster_color_Callback(hObject, eventdata, handles)
% Plot the cluster with only one color for the non-clustered chains. Each
% cluster is plot in a specific cluster. 
cluster_mode = handles.cluster_mode;

if (cluster_mode == [0, 0]) | (cluster_mode == [1, 0])
    handles.cluster_mode = [0, 1];
end
if cluster_mode == [0, 1]
    handles.cluster_mode = [0, 0];
end

if handles.cluster_mode == [0, 1];
    set(handles.text_mode, 'string', 'Black clusters OFF; Colors clusters ON')
end
if handles.cluster_mode == [0, 0];
    set(handles.text_mode, 'string', 'Black clusters OFF; Color clusters OFF')
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function select_zone_minimap_Callback(hObject, eventdata, handles)
% Selection by hand of a region in the minimap. The selected region is
% plotted in the screener and the number of the selected chains are
% displayed.
addpath([pwd '/plotFunctions/']);
addpath('./selectTools/')

% Coordinates of the selection.
figure(1);
[x, y] = DrawConvexHull;
selectTimeMin = min(x);
selectTimeMax = max(x);
selectAmpsMin = min(y);
selectAmpsMax = max(y);


% Determination of the channel.
channel = handles.channel_minimap;

% Loading data.
chainsMatTot = handles.chainsMatTot;

% Croping of the data.
[chainsMatTotSelectedAxes1] = chainsSelection(chainsMatTot, selectTimeMin, selectTimeMax, selectAmpsMin, selectAmpsMax, channel, 'fromMap');

% Plotting in the tetrode screener.
channel_tetrode_screener = handles.channel_tetrode_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

% Plotting of the selection.
plotFunction(handles.plot_mode, chainsMatTotSelectedAxes1, handles.channel_minimap, handles, channel_4_1, channel_4_2);
    
% Loading of the waveforms.
L2chainsList = [];
if length(chainsMatTotSelectedAxes1(1 : end - 1)) > 1
    for chain = 1 : length(chainsMatTotSelectedAxes1(1 : end - 1))
        chains = chainsMatTotSelectedAxes1(chain);
        L2chainsList = [L2chainsList, chains];
    end
else
    chains = chainsMatTotSelectedAxes1(1);
    L2chainsList = [L2chainsList, chains];
end

value_selected = get(handles.listbox3, 'Value');
chainsNum = [chainsMatTotSelectedAxes1.num];

set(handles.listbox3, 'value', 1);
set(handles.listbox3, 'string', chainsNum);

% Plotting the waveforms.
cla(handles.axes3);
axes(handles.axes3);
plotSpikeWaveforms(L2chainsList);

% Saving the variables.
handles.chainsMatTotSelectedAxes1 = chainsMatTotSelectedAxes1;
handles.fromMap = 1;
handles.fromClust = 0;
guidata(hObject, handles);


% --------------------------------------------------------------------
function channel_minimap_1_Callback(hObject, eventdata, handles)
% Refresh the minimap after a channel selection.
addpath([pwd '/plotFunctions/']);

channel_minimap = 1;
chainsMatTot = handles.chainsMatTot;

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 10, channel_minimap);

% Plotting of the chains.
cla(figure(1));
figure(1);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel_minimap, 'fromMap');
    plotSpikeChains(chainsMatTotSelected, 1, channel_minimap, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel_minimap);

ylabel(['Ch ' num2str(channel_minimap)]);

checkVariable = exist('handles.chainsMatTotSelectedAxes1', 'var');

if checkVariable == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1, 1, channel_minimap, 3);
end

handles.channel_minimap = channel_minimap;
guidata(hObject, handles);


% --------------------------------------------------------------------
function channel_minimap_2_Callback(hObject, eventdata, handles)
% Refresh the minimap after a channel selection.
addpath([pwd '/plotFunctions/']);

channel_minimap = 2;
chainsMatTot = handles.chainsMatTot;

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 10, channel_minimap);

% Plotting of the chains.
cla(figure(1));
figure(1);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel_minimap, 'fromMap');
    plotSpikeChains(chainsMatTotSelected, 1, channel_minimap, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel_minimap);
ylabel(['Ch ' num2str(channel_minimap)]);

checkVariable = exist('handles.chainsMatTotSelectedAxes1', 'var');

if checkVariable == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1, 1, channel_minimap, 3);
end

handles.channel_minimap = channel_minimap;
guidata(hObject, handles);


% --------------------------------------------------------------------
function channel_minimap_3_Callback(hObject, eventdata, handles)
% Refresh the minimap after a channel selection.
addpath([pwd '/plotFunctions/']);

channel_minimap = 3;
chainsMatTot = handles.chainsMatTot;

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 10, channel_minimap);

% Plotting of the chains.
cla(figure(1));
figure(1);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel_minimap, 'fromMap');
    plotSpikeChains(chainsMatTotSelected, 1, channel_minimap, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel_minimap);
ylabel(['Ch ' num2str(channel_minimap)]);

checkVariable = exist('handles.chainsMatTotSelectedAxes1', 'var');

if checkVariable == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1, 1, channel_minimap, 3);
end

handles.channel_minimap = channel_minimap;
guidata(hObject, handles);


% --------------------------------------------------------------------
function channel_minimap_4_Callback(hObject, eventdata, handles)
% Refresh the minimap after a channel selection.
addpath([pwd '/plotFunctions/']);

channel_minimap = 4;
chainsMatTot = handles.chainsMatTot;

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
[borderLeft, borderRight] = chainsSelectionMinimap(handles.chainsMatTot, borderLeft, borderRight, 10, channel_minimap);

% Plotting of the chains.
cla(figure(1));
figure(1);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel_minimap, 'fromMap');
    plotSpikeChains(chainsMatTotSelected, 1, channel_minimap, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel_minimap);
ylabel(['Ch ' num2str(channel_minimap)]);

checkVariable = exist('handles.chainsMatTotSelectedAxes1', 'var');

if checkVariable == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1, 1, channel_minimap, 3);
end

handles.channel_minimap = channel_minimap;
guidata(hObject, handles);


% --------------------------------------------------------------------
function screener_Callback(hObject, eventdata, handles)
% hObject    handle to screener (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function tools_Callback(hObject, eventdata, handles)
% hObject    handle to tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function clear_all_Callback(hObject, eventdata, handles)
set(handles.listbox1, 'value', 1);
set(handles.listbox2, 'value', 1);
set(handles.listbox3, 'value', 1);
set(handles.listbox5, 'value', 1);
set(handles.listbox6, 'value', 1);
set(handles.listbox7, 'value', 1);

clear handles;


% ---  ¡.
function pushbutton67_Callback(hObject, eventdata, handles)
borderUp = handles.borderUp;
borderDown = handles.borderDown;

borderUp = borderUp + 1e-4;
borderDown = borderDown + 1e-4

figure(1);
ylim([borderDown, borderUp]);

handles.borderUp = borderUp;
handles.borderDown = borderDown;
guidata(hObject, handles);


% --- !.
function pushbutton68_Callback(hObject, eventdata, handles)
borderUp = handles.borderUp;
borderDown = handles.borderDown;

borderUp = borderUp - 1e-4;
borderDown = borderDown - 1e-4;

figure(1);
ylim([borderDown, borderUp]);

handles.borderUp = borderUp;
handles.borderDown = borderDown;
guidata(hObject, handles);


% --- ZOOM + Y.
function pushbutton69_Callback(hObject, eventdata, handles)
borderUp = handles.borderUp;
borderDown = handles.borderDown;

borderUp = borderUp - 1e-4;
borderDown = borderDown + 1e-4

figure(1);
ylim([borderDown, borderUp]);

handles.borderUp = borderUp;
handles.borderDown = borderDown;
guidata(hObject, handles);

% --- ZOOM - Y.
function pushbutton70_Callback(hObject, eventdata, handles)
borderUp = handles.borderUp;
borderDown = handles.borderDown;

borderUp = borderUp + 1e-4;
borderDown = borderDown - 1e-4

figure(1);
ylim([borderDown, borderUp]);

handles.borderUp = borderUp;
handles.borderDown = borderDown;
guidata(hObject, handles);


% --------------------------------------------------------------------
function load_parameters_Callback(hObject, eventdata, handles)
% [filename, pathname] = uigetfile({'parameters.csv'}, 'File Selector');
[filename, pathname] = uigetfile({'parameters.xlsx'}, 'File Selector');
pathnameFull = strcat(pathname, filename);

% parameters = csvread(pathnameFull);
parameters = xlsread(pathnameFull);

temperatureParameter = parameters(4);
isiThreshold = parameters(3);
distThreshold = parameters(1);
corrThreshold = parameters(2);
ampsParameter = parameters(6);
lengthParameter = parameters(5);
wDist = parameters(7);
xDist = parameters(8);
wCorr = parameters(9);
xCorr = parameters(10);
wISI = parameters(11);
xISI = parameters(12);

% set(handles.edit6, 'value', distThreshold);
% set(handles.edit7, 'value', corrThreshold);
% set(handles.edit8, 'value', isiThreshold);
% set(handles.edit9, 'value', distThreshold);
% set(handles.Length, 'value', distThreshold);
% set(handles.edit11, 'value', distThreshold);
% set(handles.edit14, 'value', distThreshold);
% set(handles.edit15, 'value', distThreshold);
% set(handles.edit16, 'value', distThreshold);
% set(handles.edit17, 'value', distThreshold);
% set(handles.edit18, 'value', distThreshold);
% set(handles.edit19, 'value', distThreshold);

handles.temperatureParameter = temperatureParameter;
handles.isiThreshold = isiThreshold;
handles.distThreshold = distThreshold;
handles.corrThreshold = corrThreshold;
handles.ampsParameter = ampsParameter;
handles.lengthParameter = lengthParameter;
handles.wDist = xDist;
handles.xDist = xDist;
handles.wCorr = wCorr;
handles.xCorr = wCorr;
handles.wISI = wISI;
handles.xISI = xISI;

guidata(hObject, handles);


% --------------------------------------------------------------------
function chain_analysis_minimap_Callback(hObject, eventdata, handles)
value_selected = get(handles.listbox3, 'Value');

chainsMatTotSelectedAxes1 = handles.chainsMatTotSelectedAxes1;

analysisVec = handles.analysisVec;
chains = chainsMatTotSelectedAxes1(value_selected).num;
analysisVec = [analysisVec, chains];
chainsNum = [analysisVec];

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);
handles.analysisVec = analysisVec;
guidata(hObject, handles);

% --------------------------------------------------------------------
function chain_cluster_minimap_Callback(hObject, eventdata, handles)
value_selected = get(handles.listbox3, 'Value');

chainsMatTot = handles.chainsMatTot;
newCluster = handles.newCluster;

chainsMatTotSelectedAxes1 = handles.chainsMatTotSelectedAxes1;

chains = chainsMatTotSelectedAxes1(value_selected).num;

newCluster = [newCluster, chains];

handles.newCluster = newCluster;
chainsNum = [newCluster];

set(handles.listbox6, 'value', 1);
set(handles.listbox6, 'string', chainsNum);
guidata(hObject, handles);


% --------------------------------------------------------------------
function waveforms_screener_Callback(hObject, eventdata, handles)
% Plot the waveforms in the screener.
waveforms_mode = handles.plot_mode(3);

if waveforms_mode == 0
    handles.plot_mode = [0, 0, 1, 0, 0, 0, 0];
end

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function chains_screener_Callback(hObject, eventdata, handles)
% Plot the chains amplitudes in the screener.
chains_mode = handles.plot_mode(1);

if chains_mode == 0
    handles.plot_mode = [1, 0, 0, 0, 0, 0, 0];
end

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function energy_screener_Callback(hObject, eventdata, handles)
% Plot the energy in the screener.
energy_mode = handles.plot_mode(2);

if energy_mode == 0
    handles.plot_mode = [0, 1, 0, 0, 0, 0, 0];
end

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function pca_screener_1_Callback(hObject, eventdata, handles)
% Plot the PCA in the screener. 
pca_mode = handles.plot_mode(4);

if pca_mode == 0
    handles.plot_mode = [0, 0, 0, 1, 0, 0, 0];
end


channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function pca_screener_2_Callback(hObject, eventdata, handles)
pca_mode = handles.plot_mode(7);

if pca_mode == 0
    handles.plot_mode = [0, 0, 0, 0, 0, 0, 1];
end

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);

% --------------------------------------------------------------------
function valley_screener_Callback(hObject, eventdata, handles)
valley_mode = handles.plot_mode(5);

if valley_mode == 0
    handles.plot_mode = [0, 0, 0, 0, 1, 0, 0];
end

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);

% --------------------------------------------------------------------
function width_screener_Callback(hObject, eventdata, handles)
width_mode = handles.plot_mode(6);

if width_mode == 0
    handles.plot_mode = [0, 0, 0, 0, 0, 1, 0];
end

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);



% --------------------------------------------------------------------
function tetrode_screener_Callback(hObject, eventdata, handles)
% hObject    handle to tetrode_screener (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function tetrode_channel_1_Callback(hObject, eventdata, handles)
% Set a new channel for the tetrode screener.
addpath([pwd '/plotFunctions/']);

channel_tetrode_screener = handles.channel_tetrode_screener;
channel_tetrode_screener{1} = [1, 0, 0, 0];
channely = find(channel_tetrode_screener{2} == 1);
handles.channel_tetrode_screener = channel_tetrode_screener;

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function tetrode_channel_2_Callback(hObject, eventdata, handles)
% Set a new channel for the tetrode screener.
addpath([pwd '/plotFunctions/']);

channel_tetrode_screener = handles.channel_tetrode_screener;
channel_tetrode_screener{1} = [0, 1, 0, 0];
channely = find(channel_tetrode_screener{2} == 1);
handles.channel_tetrode_screener = channel_tetrode_screener;

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function tetrode_channel_3_Callback(hObject, eventdata, handles)
% Set a new channel for the tetrode screener.
addpath([pwd '/plotFunctions/']);

channel_tetrode_screener = handles.channel_tetrode_screener;
channel_tetrode_screener{1} = [0, 0, 1, 0];
channely = find(channel_tetrode_screener{2} == 1);
handles.channel_tetrode_screener = channel_tetrode_screener;

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function tetrode_channel_4_Callback(hObject, eventdata, handles)
% Set a new channel for the tetrode screener.
addpath([pwd '/plotFunctions/']);

channel_tetrode_screener = handles.channel_tetrode_screener;
channel_tetrode_screener{1} = [0, 0, 0, 1];
channely = find(channel_tetrode_screener{2} == 1);
handles.channel_tetrode_screener = channel_tetrode_screener;

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function tetrode_channel_1_y_Callback(hObject, eventdata, handles)
% Set a new channel for the tetrode screener.
addpath([pwd '/plotFunctions/']);

channel_tetrode_screener = handles.channel_tetrode_screener;
channel_tetrode_screener{2} = [1, 0, 0, 0];
channelx = find(channel_tetrode_screener{1} == 1);
handles.channel_tetrode_screener = channel_tetrode_screener;

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function tetrode_channel_2_y_Callback(hObject, eventdata, handles)
% Set a new channel for the tetrode screener.
addpath([pwd '/plotFunctions/']);

channel_tetrode_screener = handles.channel_tetrode_screener;
channel_tetrode_screener{2} = [0, 1, 0, 0];
channelx = find(channel_tetrode_screener{1} == 1);
handles.channel_tetrode_screener = channel_tetrode_screener;

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function tetrode_channel_3_y_Callback(hObject, eventdata, handles)
% Set a new channel for the tetrode screener.
addpath([pwd '/plotFunctions/']);

channel_tetrode_screener = handles.channel_tetrode_screener;
channel_tetrode_screener{2} = [0, 0, 1, 0];
channelx = find(channel_tetrode_screener{1} == 1);
handles.channel_tetrode_screener = channel_tetrode_screener;

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function tetrode_channel_4_y_Callback(hObject, eventdata, handles)
% Set a new channel for the tetrode screener.
addpath([pwd '/plotFunctions/']);

channel_tetrode_screener = handles.channel_tetrode_screener;
channel_tetrode_screener{2} = [0, 0, 0, 1];
channelx = find(channel_tetrode_screener{1} == 1);
handles.channel_tetrode_screener = channel_tetrode_screener;

channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    clusterVecAll = handles.clusterVecAll;
    chainsMatTot = handles.chainsMatTot;
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);


% --------------------------------------------------------------------
function plot_links_Callback(hObject, eventdata, handles)
% Allow to plot the links between the chains.
chainsMatTot = handles.chainsMatTot;
clusterVecAll = handles.clusterVecAll;
channel = handles.channel_screener;
pairsMatrix = handles.pairsMatrix;

if handles.fromMap == 1
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
end
if handles.fromClust == 1
    value_selected_TMP = get(handles.listbox1, 'Value');
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected_TMP})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected_TMP}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelected = cluster;
end

cla(handles.axes2);
axes(handles.axes2);
plotLinks(chainsMatTotSelected, pairsMatrix, channel)


% --------------------------------------------------------------------
function link_gui_Callback(hObject, eventdata, handles)
% Run the linkControl GUI..
run linkControl.m


% --------------------------------------------------------------------
function set_color_lists_Callback(hObject, eventdata, handles)
addpath([pwd '/toolsFunctions/']);

value_selected = get(handles.listbox1,'Value');
chainsNum = [handles.clusterVecAll{1, value_selected}];
chainsMatTot = handles.chainsMatTot;
chainsMatTotSelected = [];
for a = 1 : length(chainsMatTot)
    for b = 1 : length(chainsNum)
        if chainsMatTot(a).num == chainsNum(b);
            chainsMatTotSelected =  [chainsMatTotSelected, chainsMatTot(a)];
        end
    end
end

% Display chains in colors.
setColorList(handles.listbox1, handles.listbox2, chainsMatTotSelected, 'all', handles.clusterVecAll);

% Display chains selected in the map in colors.
if isfield(handles, 'chainsMatTotSelectedAxes1') == 1
    disp('hihihihihihihi')
    chainsMatTotSelected = handles.chainsMatTotSelectedAxes1;
    setColorList(handles.listbox3, handles.listbox3, chainsMatTotSelected, 'selectMap', handles.clusterVecAll);
end

% Display clusters in colors.
setColorList(handles.listbox1, handles.listbox1, handles.clusterVecAll, 'cluster', handles.clusterVecAll);


guidata(hObject, handles)


% --------------------------------------------------------------------
function select_zone_tetrode_screener_Callback(hObject, eventdata, handles)
% Selection by hand of a region in the screener. The numbers of the
% selected chains are displayed in a listbox.
addpath([pwd '/plotFunctions/']);
addpath('/home/noduran/Documents/ENS/Stage_M1/Works/algorithmLight/selectTools/')

% Coordinates of the selection.
axes(handles.axes4);
[x, y] = DrawConvexHull;
selectXMin = min(x);
selectXMax = max(x);
selectYMin = min(y);
selectYMax = max(y);

% Determination of the channel.
channel_tetrode_screener = handles.channel_tetrode_screener;
channel = handles.channel_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

% Croping of the data. The data could come from a manual selection in the
% minimap, a plotted cluster or from the plot of a cluster in construction.
if handles.fromMap == 1
    [chainsMatTotSelectedAxes2] = chainsSelectionTetrode(handles.chainsMatTotSelectedAxes1, selectXMin, selectXMax, selectYMin, selectYMax, channel_4_1, channel_4_2, 'fromMap', handles.plot_mode);
end

if handles.fromClust == 1
    value_selected = get(handles.listbox1, 'Value');
    chainsMatTot = handles.chainsMatTot;
    clusterVecAll = handles.clusterVecAll;
    cluster = [];
    for chain = 1 : length(clusterVecAll{1, value_selected})
        for chainL2 = 1 : length(chainsMatTot)
            if clusterVecAll{1, value_selected}(chain) == chainsMatTot(chainL2).num
                cluster = [cluster; chainsMatTot(chainL2)];
            end
        end
    end
    chainsMatTotSelectedAxes1 = cluster;
    [chainsMatTotSelectedAxes2] = chainsSelectionTetrode(chainsMatTotSelectedAxes1, selectXMin, selectXMax, selectYMin, selectYMax, channel_4_1, channel_4_2, 'fromClust', handles.plot_mode);
end

chainsNum = [chainsMatTotSelectedAxes2.num];

set(handles.listbox5, 'value', 1);
set(handles.listbox5, 'string', chainsNum);

axes(handles.axes3);
cla(handles.axes3);
plotSpikeWaveforms(chainsMatTotSelectedAxes2);

% Saving the variables.
handles.chainsMatTotSelectedAxes2 = chainsMatTotSelectedAxes2;
guidata(hObject, handles)

