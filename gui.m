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

% Last Modified by GUIDE v2.5 04-Jul-2015 10:54:38

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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);

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
addpath([pwd '/toolsFunctions/']);
addpath([pwd '/helperFunctions/']);

% Loading the data.
value_selected = get(handles.listbox1, 'Value');
clusterVecAll = handles.clusterVecAll;

% Looking for the chains.
chainsMatTot = handles.chainsMatTot;
cluster = [];

for a = 1 : length(value_selected)
    chains = clusterVecAll{1, value_selected(a)};
    chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
    cluster = [cluster, chainsL2];
end

channel = handles.channel_screener;
channel_tetrode_screener = handles.channel_tetrode_screener;
channel_4_1 = find(channel_tetrode_screener{1} == 1);
channel_4_2 = find(channel_tetrode_screener{2} == 1);

% Plotting of the selection.
plotFunction(handles.plot_mode, cluster, channel, handles, channel_4_1, channel_4_2);
ylabel(['Ch ' num2str(channel)]);
    
% Plot of the waveforms;
cla(handles.axes3);
axes(handles.axes3);
plotSpikeWaveforms(cluster);

% Saving the variables.
handles.fromMap = 0;
handles.fromClust = 1;
handles.cluster = cluster;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
set(handles.listbox2, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);



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
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 10);

% Shuffle the data.
ix = randperm(length(chainsMatTot));
chainsMatTotShuffled = chainsMatTot(ix);

% Plotting the data.
cla(figure(24));
figure(24);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTotShuffled(1 : end - 1), channel, handles.clusterVecAll, handles.dataTips, handles.pointSize);

xlim([borderLeft, borderRight]);
ylim([borderDown, borderUp]);
ylabel(['Ch ' num2str(channel)]);
axes(handles.axes4);


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
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 2);

% Plotting the data.
cla(figure(24));
figure(24);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel, handles.clusterVecAll, handles.dataTips, handles.pointSize);

xlim([borderLeft, borderRight]);
ylim([borderDown, borderUp]);
ylabel(['Ch ' num2str(channel)]);

% Saving the variables.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
guidata(hObject, handles); 
minimap = figure(24); 
guidata(minimap, handles);  
set(minimap, 'KeyPressFcn', @navigation, 'WindowScrollWheelFcn', @scrollNavigation);
axes(handles.axes4);


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
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 3);

% Plotting the data.
cla(figure(24));
figure(24);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel, handles.clusterVecAll, handles.dataTips, handles.pointSize);
xlim([borderLeft, borderRight]);
ylim([borderDown, borderUp]);
ylabel(['Ch ' num2str(channel)]);

hFigure = gcf;
setappdata(0, 'hFigure', hFigure);

% Saving the variables.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
guidata(hObject, handles);  
minimap = figure(24); 
guidata(minimap, handles);  
set(minimap, 'KeyPressFcn', @navigation, 'WindowScrollWheelFcn', @scrollNavigation);
axes(handles.axes4);


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
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 0);

% Plotting the data.
cla(figure(24));
figure(24)

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel, handles.clusterVecAll, handles.dataTips, handles.pointSize);
xlim([borderLeft, borderRight]);
ylim([borderDown, borderUp]);
ylabel(['Ch ' num2str(channel)]);

hFigure = gcf;
setappdata(0, 'hFigure', hFigure);

% Saving the variables.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;

guidata(hObject, handles);  
minimap = figure(24); 
guidata(minimap, handles);  
set(minimap, 'KeyPressFcn', @navigation, 'WindowScrollWheelFcn', @scrollNavigation);
axes(handles.axes4);


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
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 1);

% Plotting of the data.
cla(figure(24));
figure(24)

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel, 'from');
    plotSpikeChains(chainsMatTotSelected, 1, channel, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel, handles.clusterVecAll, handles.dataTips, handles.pointSize);
xlim([borderLeft, borderRight]);
ylim([borderDown, borderUp]);
ylabel(['Ch ' num2str(channel)]);

hFigure = gcf;
setappdata(0, 'hFigure', hFigure);

% Saving the data.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;

guidata(hObject, handles); 
minimap = figure(24); 
guidata(minimap, handles);  
set(minimap, 'KeyPressFcn', @navigation, 'WindowScrollWheelFcn', @scrollNavigation);
axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
addpath([pwd '/toolsFunctions/']);

% Loading of the variables.
cluster_selected = get(handles.listbox1, 'Value')

% cluster_selected = handles.cluster_selected;
clusterVecAll = handles.clusterVecAll;
counta = 0;
global manualModifications;
chainsMatTot = handles.chainsMatTot;

cluster_selected = clusterVecAll(2,cluster_selected);

% Identification of the selected cluster and deletion. The links between
% the chains are stocked in a variable. If the user compute the clusters
% with a new combination of criteria, the manual changes would be applied
% to the linksMatrix. 
for a = 1 : size(clusterVecAll, 2)
    a = a - counta;
    clusterName = clusterVecAll{2, a};
    
    if any(strcmp(cluster_selected, clusterName))
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
set(handles.listbox1, 'value', length(clusterVecAllName));

% Saving of the variables.
handles.chainsMatTot = chainsMatTot;
handles.clusterVecAll = clusterVecAll;

[clustersChecked] = clusterChecking(handles.clusterVecAll);
handles.clustersChecked = clustersChecked;
delete(handles.axes2.Children);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4); 


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
    if sum(num == chains_selected) ~= 0
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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
      
chainsNum = [newCluster]; 
disp('Remaining chains :')
disp(chainsNum)

handles.newCluster = newCluster;

set(handles.listbox6, 'value', 1);
set(handles.listbox6, 'string', chainsNum);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);
windowfunc = get(minimap, 'WindowButtonMotionFcn');
if isa(windowfunc, 'function_handle') && strcmp(func2str(windowfunc), 'highlightChain') 
    delete(minimap.Children.Children(1:end-3));
    plotCluster(handles.chainsMatTot(1:end-1), handles.newCluster, handles.channel_minimap, handles.pointSize * 4, [0.5 0.5 0.5]);
    plotCompareChain(handles.chainsMatTot(1:end-1), handles.compareToChain, handles.channel_minimap, handles.pointSize);
    % Plot newcluster spike waveforms in black
    axes(handles.axes2);
    cla(handles.axes2);
    plotClusterSpikeWaveforms(handles.chainsMatTot(1:end-1), handles.newCluster, [0.5 0.5 0.5]);
    axes(handles.axes4);
    cla(handles.axes4);
    plotClusterISIs(handles.chainsMatTot(1:end-1), handles.newCluster, [0.5 0.5 0.5]);  
end
axes(handles.axes4);


% --- PLOT CLUSTER (under Selected cluster listbox).
function pushbutton42_Callback(hObject, eventdata, handles)
% Plot the newCluster.
addpath([pwd '/plotFunctions/']);

newCluster = handles.newCluster;
channel = handles.channel_screener;

% Looking for the chains.
chainsMatTot = handles.chainsMatTot;
cluster = chainsMatTot(ismember([chainsMatTot.num], newCluster));

axes(handles.axes2);
cla(handles.axes2);
plotSpikeChains(cluster, 1 , channel, 6);

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
handles.chainsMatTotSelectedAxes1 = L2cluster;

% Plot of the waveforms;
cla(handles.axes3);
axes(handles.axes3);
plotSpikeWaveforms(L2cluster);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- SAVE CLUSTER (under Selected cluster listbox).
function pushbutton38_Callback(hObject, eventdata, handles)
% Save the cluster manually create.
addpath([pwd '/plotFunctions/']);
addpath([pwd '/clusteringFunctions/']);
addpath([pwd '/toolsFunctions/']);

global manualModifications;
minimap = figure(24); 

% Loading of the variable.
newCluster = handles.newCluster;

if ~isempty(newCluster)
    newCluster = {newCluster};
    clusterVecAll = handles.clusterVecAll;
    manualClusters = handles.manualClusters;
    chainsMatTot = handles.chainsMatTot;

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

    [clustersChecked] = clusterChecking(handles.clusterVecAll);
    handles.clustersChecked = clustersChecked;

    set(handles.listbox1, 'value', 1);
    set(handles.listbox1, 'string', [clusterVecAll(2, :)]);
    set(handles.listbox1, 'value', size(clusterVecAll,2));
    set(handles.listbox6, 'value', 1);
    set(handles.listbox6, 'string', newCluster);
    windowfunc = get(minimap, 'WindowButtonMotionFcn');
    if isa(windowfunc, 'function_handle') && strcmp(func2str(windowfunc), 'highlightChain') 
        delete(minimap.Children.Children(1:end-3));
        plotCluster(handles.chainsMatTot(1:end-1), handles.newCluster, handles.channel_minimap, handles.pointSize * 4, [0 0 0]);
        plotCompareChain(handles.chainsMatTot(1:end-1), handles.compareToChain, handles.channel_minimap, handles.pointSize);
        % Plot newcluster spike waveforms in black
        axes(handles.axes2);
        cla(handles.axes2);
        plotClusterSpikeWaveforms(chainsMatTot(1:end-1), handles.newCluster, [0.5 0.5 0.5]);
        axes(handles.axes4);
        cla(handles.axes4);
        plotClusterISIs(chainsMatTot(1:end-1), handles.newCluster, [0.5 0.5 0.5]);  
    end
end
% Save All clusters to disk (autosave)

cluster = [];
cluster.clusterVecAll = handles.clusterVecAll;
cluster.linksMatrix = handles.linksMatrix;
cluster.pairsMatrix = handles.pairsMatrix;
cluster.manualClusters = handles.manualClusters;
cluster.clustersChecked = handles.clustersChecked;
cluster.manualModifications = manualModifications;

if exist([handles.savepath, 'clusterVecAllTemp.mat'], 'file') ~= 2
    save([handles.savepath, 'clusterVecAllTemp.mat'], '-struct', 'cluster', '-v7.3');
else
    save([handles.savepath, 'clusterVecAllTemp.mat'], '-struct', 'cluster', 'clusterVecAll', 'manualClusters', 'clustersChecked', 'manualModifications');
end

% Also save new units to disk
L2chainsMatTotAll = handles.chainsMatTot;
L2chainsMatTotAll_new = L2chainsMatTotAll(cellfun(@(x) ~isempty(strfind(x, '_')), {L2chainsMatTotAll.trueNumber}));
save([handles.savepath, 'L2chainsMatTotAll_new.mat'], 'L2chainsMatTotAll_new', '-v7.3');

guidata(hObject, handles); guidata(minimap, handles);  axes(handles.axes4);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
value_selected = get(hObject, 'Value');
item_selected = items{value_selected};
handles.cluster_selected = item_selected;
handles.value_selected = value_selected;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- SCALE MINIMAP.
function pushbutton61_Callback(hObject, eventdata, handles)
% Allow to scale the minimap to the position of the inscreener plot.
% Loading of the cluster displayed in the screener.
addpath([pwd '/plotFunctions/']);

value_selected = get(handles.listbox1, 'Value');
clusterVecAll = handles.clusterVecAll;

% Looking for the chains.
chainsMatTot = handles.chainsMatTot;
cluster = [];

for a = 1 : length(value_selected)
    chains = clusterVecAll{1, value_selected(a)};
    [chainsL2] = chainsSearch(chainsMatTot, chains);
    cluster = [cluster, chainsL2];
end

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
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 10);

figure(24);
% clf;

% % Determination if the noise has to be display.
% if handles.noise == 1
%     plotSpikeChains(chainsMatTot(end), 1, channel, 3);
% end
% 
% % Displaying of the chains in the minimap.
% plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel, handles.clusterVecAll, handles.dataTips, handles.pointSize);
xlim([borderLeft, borderRight]);
ylim([borderDown, borderUp]);
ylabel(['Ch ' num2str(channel)]);

plotSpikeCluster(cluster, 1, channel);

% Saving the borders.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- CLEAN LIST.
function pushbutton47_Callback(hObject, eventdata, handles)
% Clean the listbox with the selected chains for statistical analysis.
analysisVec = [];

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', analysisVec);
handles.analysisVec = analysisVec;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
    isiPlot(handles, chainsSelected);
end

% Correlation test.
if test_value_selected == 2;
    disp('Correlation test (spike waveforms)')
    chainsSelected = analysisVec(value_selected_inAnalysis);
    corrComput(handles, chainsSelected);
end

% Distance test (normalized).
if test_value_selected == 3;
    disp('Distance test (spike waveforms)')
    chainsSelected = analysisVec(value_selected_inAnalysis);
    distComput(handles, chainsSelected);
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
    
    for row = 1 : size(linksMatrix, 1)
        if (linksMatrix(row, 1) == chainsSelected)
            compatibleChains = [compatibleChains, linksMatrix(row, 2)];
            rowSc = [linksMatrix(row, 2), linksMatrix(row, 6), linksMatrix(row, 10), linksMatrix(row, 11), linksMatrix(row, 12)]; %* log(linksMatrix(row, 7))];
            matrixSc = [matrixSc; rowSc];
        end
        if (linksMatrix(row, 2) == chainsSelected)
            compatibleChains = [compatibleChains, linksMatrix(row, 1)];
            rowSc = [linksMatrix(row, 1), linksMatrix(row, 6), linksMatrix(row, 10), linksMatrix(row, 11), linksMatrix(row, 12)]; % * log(linksMatrix(row, 7))];
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
        format long
        disp(matrixSc)
        figure(5);
        imagesc(matrixSc(:, 2:end));
        set(gca, 'YTick', [1 : size(matrixSc, 1)])
        set(gca, 'yticklabel', cellstr(num2str(matrixSc(:, 1))));
        set(gca, 'Xtick', [1, 2, 3, 4])
        set(gca, 'xticklabel', {'Correlation', 'ISI correlation', 'Distance', 'Criteria'})
        
        rowIndice = [];
        matrixScTmp = matrixSc;

        scoreTmp = sort(matrixSc(:, 5), 'Descend');
        scoreValues = scoreTmp(1 : 5);
        scoreIndices = [];
        for a = 1 : length(scoreValues)
            [scoreIndice, ~] = find(matrixSc(:, 5) == scoreValues(a));
            scoreIndices = [scoreIndices, scoreIndice];
        end    
        disp('Best partners : ')
        disp(matrixSc(scoreIndices, 1))
        set(handles.textTools, 'string', matrixSc(scoreIndices, 1));
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
    chainsSelected = analysisVec(value_selected_inAnalysis);
    [clusterSelectedName, chainsList] = findCluster(handles, chainsSelected);
    
    figure();
    if isempty(chainsList) == 0
        plotSpikeChains(chainsList, 1, handles.channel_screener, 6)
        set(handles.textTools, 'String', clusterSelectedName)
    else
        set(handles.textTools, 'String', 'No cluster for this chain :(')
    end
    hold all
end

% Cross Correlation
if test_value_selected == 7 
    disp('Cross correlation')
    set(handles.textTools, 'string', 'Cross correlation');
    chainsSelected = analysisVec(value_selected_inAnalysis);
    chainsMatTot = handles.chainsMatTot;
    
    chain1 = chainsSearch(chainsMatTot, chainsSelected(1));
    chain2 = chainsSearch(chainsMatTot, chainsSelected(2));
    
    pathway = [handles.pathBasic chain1.names{1}];
    chainSelectedTest1 = getSomeMergedChains(pathway, chain1.channel, mat2cell(chain1.trueNumber, 1), 0)
    pathway = [handles.pathBasic chain2.names{1}];
    chainSelectedTest2 = getSomeMergedChains(pathway, chain2.channel, mat2cell(chain2.trueNumber, 1), 0)
        
    [C, B] = CrossCorr(chainSelectedTest1.times / 3000 / 60 / 60, chainSelectedTest2.times / 3000 / 60 / 60, 2, 500);
    figure()
    plot(B, C)
    xlabel('msec')
    ylabel('Count')
    title(['XCorr ' num2str(chain1.num) ' Vs ' num2str(chain2.num)]);
    
    if strcmp(chain1.names{1}, chain2.names{1}) == 0
        set(handles.textTools, 'String', 'The chains are not overlapping');
    end
end

% Split a chain. 
if test_value_selected == 8
    chainsMatTot = handles.chainsMatTot;
    chainsSelected = analysisVec(value_selected_inAnalysis);
    [chains] = chainsSearch(chainsMatTot, chainsSelected);
    saved = saveSpikesforSplit(chains, handles.pathBasic, handles.savepath);
    if saved
        set(handles.textTools, 'string', ['SAVED for ' num2str(chainsSelected)]);
    else
        set(handles.textTools, 'string', ['NOT SAVED for ' num2str(chainsSelected)]);
    end
end

% Replace chain with splits
if test_value_selected == 9
    chainsSelected = analysisVec(value_selected_inAnalysis);
    [chains] = chainsSearch(handles.chainsMatTot, chainsSelected);
    [handles.chainsMatTot, handles.pairsMatrix] = removeOldSplits(handles.chainsMatTot, handles.pairsMatrix, chainsSelected);    
    L1chainSplits = getChainSplits(chains, handles.pathBasic, handles.savepath);
    L2chainSplits = getL2Splits(chains, L1chainSplits, handles.pathBasic);
    [handles] = replaceChainWithSplits(handles, chains, L1chainSplits, L2chainSplits);
    dispString = ['Chain ' num2str(chainsSelected) ' replaced by '];
    for c = double(max(L2chainSplits.splits)) : -1 : 1
        dispString = [dispString num2str(handles.chainsMatTot(end-c).num) ' '];
    end
    set(handles.textTools, 'string', dispString)
end


% Cluster quality test for selected chains
if test_value_selected == 10
    disp('Cluster quality check');
    chainsMatTot = handles.chainsMatTot;
    chainsSelected = analysisVec(value_selected_inAnalysis);
    [chains] = chainsSearch(chainsMatTot, chainsSelected);
    
    set(handles.textTools, 'string', ['DONE for ' num2str(chainsSelected)])
end


guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
    
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- DIST THRESHOLD.
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- CORR THRESHOLD.
function edit7_Callback(hObject, eventdata, handles)
corrThresholdEnter = get(hObject, 'string')
handles.corrThreshold = str2num(corrThresholdEnter);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- CORR THRESHOLD.
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- ISI THRESHOLD.
function edit8_Callback(hObject, eventdata, handles)
isiThresholdEnter = get(hObject, 'string')
handles.isiThreshold = str2num(isiThresholdEnter);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- ISI THRESHOLD.
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- TEMPERATURE PARAMETER.
function edit9_Callback(hObject, eventdata, handles)
temperatureParameterEnter = get(hObject, 'string')
handles.temperatureParameter = str2num(temperatureParameterEnter);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
lengthParameter = handles.lengthParameter;
chainsMatTot = handles.chainsMatTot;
% singleCluster = handles.singleCluster;
wDist = handles.wDist;
xDist = handles.xDist;
wCorr = handles.wCorr;
xCorr = handles.xCorr;
wISI = handles.wISI;
xISI = handles.xISI;

[groupList, pairsMatrixOutput, linksMatrixOutput] = linksMatrixClustering(linksMatrix, chainsMatTot, wDist, wCorr, wISI, xDist, xCorr, xISI, distThreshold, corrThreshold, isiThreshold, temperatureParameter, lengthParameter);

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
set(handles.listbox1, 'string', clusterVecAllName, 'max', length(clusterVecAllName), 'min', 0);

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- RE-APPLY CLUSTERING ONLY TO CHAINS WITHIN MINIMAP WINDOW.
function pushbutton62_Callback(hObject, eventdata, handles)

addpath([pwd '/plotFunctions/']);
addpath([pwd '/clusteringFunctions/']);
set(handles.textTools, 'string', 'Re-Clustering...');

temperatureParameter = handles.temperatureParameter;
isiThreshold = handles.isiThreshold;
distThreshold = handles.distThreshold;
corrThreshold = handles.corrThreshold;
linksMatrix = handles.linksMatrix;
lengthParameter = handles.lengthParameter;
chainsMatTot = handles.chainsMatTot;
pairsMatrix = handles.pairsMatrix;
clusterVecAll = handles.clusterVecAll;

% Retain manual clusters
manClust = clusterVecAll(:, cellfun(@(x) ~isempty(strfind(x, 'm')), clusterVecAll(2,:)));

% singleCluster = handles.singleCluster;
wDist = handles.wDist;
xDist = handles.xDist;
wCorr = handles.wCorr;
xCorr = handles.xCorr;
wISI = handles.wISI;
xISI = handles.xISI;

% Get chainNums whose centroids are within the minimap window borders
chainsWind = findChainsWind(chainsMatTot, handles.channel_minimap, handles.borderLeft, handles.borderRight, handles.borderUp, handles.borderDown);

[groupList, pairsMatrixOutput, linksMatrixOutput] = linksMatrixReClustering(linksMatrix, pairsMatrix, chainsMatTot, chainsWind, wDist, wCorr, wISI, xDist, xCorr, xISI, distThreshold, corrThreshold, isiThreshold, temperatureParameter, lengthParameter);

% Assignations of the cluster modes.
[chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, groupList);

% clusterColor = [];
% for a = 1 : length(manualClusters)
%     [color] = colorSelection;
%     clusterColor = [clusterColor, {color}];
% end
% manualClusters = [manualClusters; clusterColor];

clusterVecAll = [groupList, manClust];
handles.clusterVecAll = clusterVecAll;

handles.groupList = groupList;
handles.pairsMatrix = pairsMatrixOutput;
handles.linksMatrix = linksMatrixOutput;

clusterVecAllName = clusterVecAll(2, :);
handles.clusterVecAll = clusterVecAll;
handles.chainsMatTot = chainsMatTot;

set(handles.listbox1, 'value', 1);
set(handles.listbox1, 'string', clusterVecAllName, 'max', length(clusterVecAllName), 'min', 0);
set(handles.textTools, 'string', 'Re-Clustering DONE');

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);

% % Allow to re-apply with new parameters from the matrix manually changed.
% (OLD REAPPLY - no longer using manual modifications)
% addpath([pwd '/plotFunctions/']);
% addpath([pwd '/clusteringFunctions/']);
% 
% temperatureParameter = handles.temperatureParameter;
% isiThreshold = handles.isiThreshold;
% distThreshold = handles.distThreshold;
% corrThreshold = handles.corrThreshold;
% linksMatrix = handles.linksMatrix;
% ampsParameter = handles.ampsParameter;
% lengthParameter = handles.lengthParameter;
% chainsMatTot = handles.chainsMatTot;
% pairsMatrix = handles.pairsMatrix;
% manualClusters = handles.manualClusters;
% clustersChecked = handles.clustersChecked;
% wDist = handles.wDist;
% xDist = handles.xDist;
% wCorr = handles.wCorr;
% xCorr = handles.xCorr;
% wISI = handles.wISI;
% xISI = handles.xISI;
% 
% set(handles.textTools, 'string', 'Clustering.');
% 
% % [~, pairsMatrixOutput, linksMatrixOutput] = linksMatrixClustering(linksMatrix, chainsMatTot, wDist, wCorr, wISI, xDist, xCorr, xISI, distThreshold, corrThreshold, isiThreshold, temperatureParameter, ampsParameter, lengthParameter);
% 
% pairsMatrixOutput = handles.pairsMatrix;
% linksMatrixOutput = handles.linksMatrix;
% 
% % Application of the manual modifications.
% global manualModifications;
% for element = 1 : length(manualModifications)
%     
%     % Deletion.
%     if manualModifications{element}(end) == 0
%         pairsMatrixOutput(manualModifications{element}(1) + 1, manualModifications{element}(2) + 1) = 0;
%     end
%     
%     % Addition.
%     if manualModifications{element}(end) == 1;
%         pairsMatrixOutput(manualModifications{element}(1) + 1, manualModifications{element}(2) + 1) = 1;
%     end
%     
%     % Row deletion
%     if manualModifications{element}(end) == 2;
%         if manualModifications{elements}(1) == -1
%             pairsMatrixOutput(:, manualModifications{element}(2) + 1) = 0;
%         end
%         if manualModifications{elements}(2) == -1
%             pairsMatrixOutput(manualModifications{element}(1) + 1, :) = 0;
%         end
%     end
% end
% 
% % If the single chains have less than 5000 spikes, it is not conserved. 
% singleList = find(all(~pairsMatrixOutput, 1) & all(~pairsMatrixOutput, 2)');
% singleList = singleList - 1;
% 
% singleFinalChain = {};
% for chain = 1 : length(singleList)
%     [indiceRow, indiceColumn] = find(linksMatrix(:, 1:2) == singleList(chain));
%     
%     if (length(indiceColumn) > 1) || (length(indiceRow) > 1)
%         if indiceColumn(1) == 1
%             chainLength = linksMatrix(indiceRow(1), 8);
%         end
%         if indiceColumn(1) == 2
%             chainLength = linksMatrix(indiceRow(1), 9);
%         end
%         if chainLength > 5000
%             singleFinalChain{end + 1} = singleList(chain);
%         end
%     end
% end
% 
% [singleFinalChain] = clusterNomination(singleFinalChain, 2);
% 
% % Chains joining.
% [groupList] = clusterCreation(pairsMatrixOutput);
% 
% % Grouping step.
% [groupList] = clusterConstruction(groupList);
% 
% % Cleaning of the small groups.
% % [groupList] = clustersSelection(linksMatrix, groupList, lengthParameter);
% [groupList] = clusterNomination(groupList, 0);
% 
% % Adding the single chains
% groupList = [groupList, singleFinalChain];
% 
% % Assignation of a color to the clusters. 
% clusterColor = [];
% for a = 1 : length(groupList)
%     [color] = colorSelection;
%     clusterColor = [clusterColor, {color}];
% end
% groupList = [groupList; clusterColor];
% 
% clusterColor = [];
% for a = 1 : length(manualClusters)
%     [color] = colorSelection;
%     clusterColor = [clusterColor, {color}];
% end
% manualClusters = [manualClusters; clusterColor];
% 
% % clusterColor = [];
% % for a = 1 : length(clustersChecked)
% %     [color] = colorSelection;
% %     clusterColor = [clusterColor, {color}];
% % end
% % clustersChecked = [clustersChecked; clusterColor];
% 
% clusterVecAll = groupList;
% 
% [chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, clusterVecAll);
% 
% clusterVecAll = [clusterVecAll, manualClusters, clustersChecked];
% handles.clusterVecAll = clusterVecAll;
% handles.chainsMatTot = chainsMatTot;
% clusterVecAllName = clusterVecAll(2, :);
% handles.pairsMatrix = pairsMatrixOutput;
% 
% set(handles.listbox1, 'value', 1);
% set(handles.listbox1, 'string', clusterVecAllName);
% set(handles.textTools, 'string', 'Clustering DONE.');



% --- LENGTH THRESHOLD.
function Length_Callback(hObject, eventdata, handles)
lengthParameterEnter = get(hObject, 'string')
handles.lengthParameter = str2num(lengthParameterEnter);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- LENGTH THRESHOLD.
function Length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- AMPS THRESHOLD.
function edit11_Callback(hObject, eventdata, handles)
ampsParameterEnter = get(hObject, 'string')
handles.ampsParameter = str2num(ampsParameterEnter);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- AMPS THRESHOLD.
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- wDist.
function edit14_Callback(hObject, eventdata, handles)
wDist = get(hObject, 'string')
handles.wDist = str2num(wDist);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- wDist.
function edit14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- xDist.
function edit15_Callback(hObject, eventdata, handles)
xDist = get(hObject, 'string')
handles.xDist = str2num(xDist);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- xDist.
function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- wCorr.
function edit16_Callback(hObject, eventdata, handles)
wCorr = get(hObject, 'string')
handles.wCorr = str2num(wCorr);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- wCorr.
function edit16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- xCorr.
function edit17_Callback(hObject, eventdata, handles)
xCorr = get(hObject, 'string')
handles.xCorr = str2num(xCorr);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- xCorr.
function edit17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- wISI.
function edit18_Callback(hObject, eventdata, handles)
wISI = get(hObject, 'string')
handles.wISI= str2num(wISI);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- wISI.
function edit18_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- xISI.
function edit19_Callback(hObject, eventdata, handles)
xISI = get(hObject, 'string')
handles.xISI = str2num(xISI);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- xISI.
function edit19_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- SELECT EXTRACTION.
function edit20_Callback(hObject, eventdata, handles)
selectExtraction = get(hObject, 'string')
handles.selectExtraction = str2num(selectExtraction);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- SELECT EXTRACTION.
function edit20_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- PLOT ENTIRE CHAIN.
function pushbutton64_Callback(hObject, eventdata, handles)
% Plot the entire chain selected in the minimap.
addpath([pwd '/plotFunctions/']);
addpath([pwd '/toolsFunctions/']);
% Loading of the variables.
value_selected_chains = get(handles.listbox3, 'Value');

% Loading data.
chainsMatTot = handles.chainsMatTot;

% Determination of the channel.
channel = handles.channel_screener;
num = [handles.chainsMatTotSelectedAxes1(value_selected_chains).num];

[chainsL2] = chainsSearch(chainsMatTot, num);

% Plotting of the data.
axes(handles.axes2);
cla(handles.axes2);
plotSpikeChains(chainsL2, 1, channel, 6);


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
addpath([pwd '/clusteringFunctions/']);

% Determination of the pathway.
[filename, pathname] = uigetfile({'L2chainsMatTotAll.mat'}, 'File Selector');
pathnameFull = strcat(pathname, filename);
chainsMatTot = load(pathnameFull);
handles.savepath = pathname;

set(handles.path_text, 'String', pathname);

% Determination of the pathway were the original data are saved.
pathBasic = getDataPath(handles.savepath);

% Creation of the variable which contains all of the L2 chains.
chainsMatTot = chainsMatTot.L2chainsMatTotAll;
% string_selected = get(handles.edit20, 'String');
% extractThreshold = str2num(string_selected);
% chainsMatTot = chainsExtractionGUI(chainsMatTot, extractThreshold);
handles.clusterVecAll = [];

% Calculate chain centroids
chainsMatTot = getChainCentroids(chainsMatTot);

% Calculate ISIs if they are missing
if ~isfield(chainsMatTot, 'isi')
    for c = 1 : length(chainsMatTot)-1
%         if c/500 == floor(c/500); disp(c); end
        chainsMatTot(c).isi = getIsi(chainsMatTot(c), pathBasic); 
    end
    disp('ISIs computed');
end

% Loading the linksMatrix which contains the relations between the chains.
set(handles.textTools, 'string', 'Loading.');

% Loading the file.    
pathnameFull = strcat(pathname, 'linksMatrix.mat');
linksMatrix = load(pathnameFull);
linksMatrix = linksMatrix.linksMatrix;

% Get num of spikes for each chain
if ~isfield(chainsMatTot, 'numSpikes')
    for c = 1 : length(chainsMatTot)-1
        chainsMatTot(c).numSpikes = getChainLength(linksMatrix, chainsMatTot(c).num);
    end
end

% Calculate first file
if ~isfield(chainsMatTot, 'firstFile')
    allFiles = unique(cellfun(@(x) str2num(['uint64(' x(1:18) ')']), [chainsMatTot(1:end-1).names]));
    firstFile = min(allFiles);
    handles.firstFile = firstFile;
else
    handles.firstFile = chainsMatTot(1).firstFile;
end

% Extraction.
disp('L2 loaded');

% Save the matrix in the handles.
handles.chainsMatTot = chainsMatTot;

% Displaying in the minimap.
borderLeft = 1;
borderRight = 10;
borderUp = 5e-4;
borderDown = -5e-4;

[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 10);

minimap = figure(24); 

plotSpikeChains(chainsMatTot(end), 1, 1, 3);
hold all
plotSpikeChains(chainsMatTot(1 : end - 1), 1, 1, 3);
ylim([borderDown, borderUp]);
xlim([borderLeft, borderRight]);

% Initialisation of the different variables.
handles.chainsMatTot = chainsMatTot;
handles.chainsMatTotPlot = chainsMatTot;
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
handles.cluster_mode = [0, 0, 0];
handles.plot_mode = [1, 0, 0, 0, 0, 0, 0];
handles.channel_tetrode_screener = {[1, 0, 0, 0], [0, 1, 0, 0]};
handles.temperatureParameter = 1e-3;
handles.isiThreshold = 0.9;
handles.distThreshold = 0.2;
handles.corrThreshold = 0.9;
handles.compareToChain = [];
handles.ampsParameter = 1;
handles.lengthParameter = 10000;
handles.wDist = 1;
handles.xDist = 1;
handles.wCorr = 1;
handles.xCorr = 1;
handles.wISI = 1;
handles.xISI = 1;
handles.color_chains = 0;
handles.clustersChecked = [];
handles.dataTips = 'OFF';
handles.plotCentroids = false;

% handles.extractThreshold = extractThreshold;
global manualModifications;
manualModifications = {};

% singleCluster = load([pathname 'singleCluster']);
set(handles.textTools, 'string', 'Loading Complete');

% Saving the variables.
handles.linksMatrix = linksMatrix;
% handles.singleCluster = singleCluster;

guidata(hObject, handles);  
minimap = figure(24); 
guidata(minimap, handles);  
set(minimap, 'KeyPressFcn', @navigation, 'WindowScrollWheelFcn', @scrollNavigation);
axes(handles.axes4);

function scrollNavigation(hObject, eventdata)
minimap = figure(24);
handles = guidata(minimap);

% Determination of the border.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
borderUp = handles.borderUp;
borderDown = handles.borderDown;

% Get scroll movement
scroll = eventdata.VerticalScrollCount;

% Get mouse position
mouse = get(get(minimap, 'CurrentAxes'), 'CurrentPoint');
mouse = mouse(1,1:2);

[borderLeft, borderRight, borderUp, borderDown] = borderScrollMinimap(borderLeft, borderRight, borderUp, borderDown, scroll, mouse);

xlim([borderLeft, borderRight]);
ylim([borderDown, borderUp]);

% Saving the variables.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
handles.borderUp = borderUp;
handles.borderDown = borderDown;

guidata(handles.figure1, handles);
guidata(minimap, handles); 



% LEFT, RIGHT, UP, DOWN, ZOOM and CHANNEL changes with keyboard shortcuts
function navigation(hObject, eventdata)
minimap = figure(24);
handles = guidata(minimap);
addpath([pwd '/plotFunctions/']);
addpath([pwd '/automaticStep/']);

% Determination of the border.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
borderUp = handles.borderUp;
borderDown = handles.borderDown;

% Determination of the channel.
ChOn = handles.channel_minimap;
move = 10;
dataTips = 'OFF';

plotCentroidsNow = [];

chainsMatTot = handles.chainsMatTot;
chainsMatTotPlot = handles.chainsMatTotPlot;

switch eventdata.Key
    case 'rightarrow' % minimap right
        move = 3;        
    case 'leftarrow' % minimap left
        move = 2;        
    case 'uparrow' % minimap up
        move = 4;
    case 'downarrow' % minimap down
        move = 5;
    case 'hyphen' % minimap X axis zoom out
        move = 1;        
    case 'equal' % minimap X axis zoom in
        move = 0;
    case 'add' % minimap Y axis zoom in
        move = 6;
    case 'subtract' % minimap Y axis zoom out
        move = 7;
    case {'1', 'numpad1'}
        ChOn = 1;        
    case {'2', 'numpad2'}
        ChOn = 2;            
    case {'3', 'numpad3'}
        ChOn = 3;                
    case {'4', 'numpad4'}
        ChOn = 4; 
    case 'r'
        dataTips = 'ON';
    case 'c'
        handles.plotCentroids = ~handles.plotCentroids;
        plotCentroidsNow = handles.plotCentroids;
    case 'p'
        cluster_mode = handles.cluster_mode;
        if all((cluster_mode == [0, 0, 0]) | (cluster_mode == [0, 1, 0]) | (cluster_mode == [0, 0, 1]) | (cluster_mode == [0, 1, 1]))
            handles.cluster_mode = [1, 0, 0];
        end
        if cluster_mode == [1, 0, 0]
            handles.cluster_mode = [0, 0, 0];
        end
        if cluster_mode == [1, 0, 1]
            handles.cluster_mode = [0, 0, 1];
        end

        if all((handles.cluster_mode == [1, 0, 0]) | (handles.cluster_mode == [1, 0, 1]))
            set(handles.text_mode, 'string', 'Black clusters ON; Colors clusters OFF')
        end
        if all((handles.cluster_mode == [0, 0, 0]) | (handles.cluster_mode == [0, 0, 1]))
            set(handles.text_mode, 'string', 'Black clusters OFF; Color clusters OFF')
        end
    case 'n'
        % Plot with Clusters Color Callback
        cluster_mode = handles.cluster_mode;
        if all((cluster_mode == [0, 0, 0]) | (cluster_mode == [1, 0, 0]) | (cluster_mode == [0, 0, 1]) | (cluster_mode == [1, 0, 1]))
            handles.cluster_mode = [0, 1, 0];
        end
        if cluster_mode == [0, 1, 0]
            handles.cluster_mode = [0, 0, 0];
        end
        if cluster_mode == [0, 1, 1]
            handles.cluster_mode = [0, 0, 1];
        end

        if all((handles.cluster_mode == [0, 1, 0]) | (handles.cluster_mode == [0, 1, 1]))
            set(handles.text_mode, 'string', 'Black clusters OFF; Colors clusters ON')
        end
        if all((handles.cluster_mode == [0, 0, 0]) | (handles.cluster_mode == [0, 0, 1]))
            set(handles.text_mode, 'string', 'Black clusters OFF; Color clusters OFF')
        end
        
    case {'multiply', '8'}
        % Plot only starred clusters
        cluster_mode = handles.cluster_mode;
        if cluster_mode(end) == 0
            cluster_mode = [0 1 1];
            set(handles.checkbox2, 'Value', 1);
            set(handles.text_mode, 'string', 'Black clusters OFF; Colors clusters ON')
        else
            cluster_mode(end) = 0;
            set(handles.checkbox2, 'Value', 0);
        end
        handles.cluster_mode = cluster_mode;
        
    case 'a' % Set compare to chain
        windowfunc = get(minimap, 'WindowButtonDownFcn');
        if isa(windowfunc, 'function_handle') && strcmp(func2str(windowfunc), 'selectChain')  
            if ~isfield(handles, 'compareToChain') || isempty(handles.compareToChain) || handles.compareToChain ~= handles.highlightedChains(1)
                handles.compareToChain = handles.highlightedChains(1);
            else
                handles.compareToChain = [];
            end
        end
        delete(minimap.Children.Children(1:end-4));
        plotCompareChain(chainsMatTot(1:end-1), handles.compareToChain, ChOn, handles.pointSize);
        
    case 'l' % Load Level 1 chain data
        windowfunc = get(minimap, 'WindowButtonDownFcn');
        if isa(windowfunc, 'function_handle') && strcmp(func2str(windowfunc), 'selectChain') 
            hInd = find([chainsMatTot(1:end-1).num] == handles.highlightedChains(1), 1, 'first');
            if ~isempty(hInd)
                L1Path = [handles.pathBasic chainsMatTot(hInd).names{1}];
                L1Chains = getSomeMergedChains(L1Path, chainsMatTot(hInd).channel, mat2cell(chainsMatTot(hInd).trueNumber,1), 1, 1); 
                plotL1Chains(L1Chains,[chainsMatTot(hInd).num],vertcat(chainsMatTot(hInd).color));
            end
        end
        
    case 'x' % Cross-corr between highlighted chain and compareToChain
        windowfunc = get(minimap, 'WindowButtonDownFcn');
        if isa(windowfunc, 'function_handle') && strcmp(func2str(windowfunc), 'selectChain') && ~isempty(handles.compareToChain)
            hInd = find([chainsMatTot(1:end-1).num] == handles.highlightedChains(1), 1, 'first');
            cInd = find([chainsMatTot(1:end-1).num] == handles.compareToChain, 1, 'first');
            
            % If chains overlap in time
            if any(chainsMatTot(hInd).times > chainsMatTot(cInd).times(1) & chainsMatTot(hInd).times < chainsMatTot(cInd).times(end))
                % Get L1 times
                hL1Chain = getSomeMergedChains([handles.pathBasic chainsMatTot(hInd).names{1}], chainsMatTot(hInd).channel, ...
                    mat2cell(chainsMatTot(hInd).trueNumber,1), 0);
                cL1Chain = getSomeMergedChains([handles.pathBasic chainsMatTot(cInd).names{1}], chainsMatTot(cInd).channel, ...
                    mat2cell(chainsMatTot(cInd).trueNumber,1), 0);
                
                figure(4);
                clf;
                % Cross-corr
                addpath('./toolsFunctions/crossCorrelation/');
                subplot(2,1,1);
                [cross_corr, t_axis] = CrossCorr(double(hL1Chain.times)/3, double(cL1Chain.times)/3, 0.25, 400);
                plot(t_axis, cross_corr)
                xlabel('msec')
                ylabel('Count')
                title(['XCorr ' num2str(chainsMatTot(hInd).num) ' Vs ' num2str(chainsMatTot(cInd).num)]);
                
                % Combined ISI plot
                subplot(2,1,2);
                combTimes = double([hL1Chain.times; cL1Chain.times])/30000;
                combTimes = sort(combTimes);
                combISI = sgolayfilt(histc(diff(combTimes), logspace(-3, 3, 100)), 3, 9) / length(combTimes);
                semilogx([2e-3, 2e-3], [0, max(combISI(:))*1.2], '--', 'color', [0  0  0]);
                hold all;
                semilogx(logspace(-3, 3, 100), combISI, 'color', [0 0 1], 'LineWidth', 2);
                xlim([1e-3 1e3])
                ylim([0 inf]);
                xlabel('ISI (s)');
                set(gca, 'XScale', 'log');
                title(['Combined ISI histogram. ' num2str(100*sum(diff(combTimes) < 2e-3)/length(diff(combTimes)), 3) '% ISIs < 2 ms']);
            else
                disp('Selected chains do not overlap in time');
            end
        end
        
    case {'0', 'numpad0'}
        % Don't show chains in starred clusters
        clusStarInd = cellfun(@(x) ~isempty(strfind(x, '*')), handles.clusterVecAll(2,:));
        chainsChecked = unique([handles.clusterVecAll{1,clusStarInd}]);
        chainParents = findSplitChainParents(chainsChecked, chainsMatTot(1:end-1));
        chainsMatTotNoStar = chainsMatTot(~ismember([chainsMatTot.num], [chainsChecked chainParents(~isnan(chainParents))]));
        chainsMatTotStar = [chainsMatTot(ismember([chainsMatTot.num], chainsChecked));...
            chainsMatTot(end)];
        % Cycle through not showing starred clusters to showing only
        % starred clusters to showing everything
        switch length(handles.chainsMatTotPlot)
            case length(chainsMatTotNoStar)
                chainsMatTotPlot = chainsMatTotStar;
            case length(chainsMatTotStar)
                chainsMatTotPlot = chainsMatTot;
            otherwise
                chainsMatTotPlot = chainsMatTotNoStar;
        end
        
    case 'm'
        % Don't show chains in manual clusters
%         clusManInd = cellfun(@(x) ~isempty(strfind(x, 'm')) && isempty(strfind(x, '*')), handles.clusterVecAll(2,:));
        clusManInd = cellfun(@(x) ~isempty(strfind(x, 'm')), handles.clusterVecAll(2,:));
        chainsMan = unique([handles.clusterVecAll{1,clusManInd}]);
        chainParents = findSplitChainParents(chainsMan, chainsMatTot(1:end-1));
        chainsMatTotNoMan = chainsMatTot(~ismember([chainsMatTot.num], [chainsMan chainParents(~isnan(chainParents))]));
        chainsMatTotMan = [chainsMatTot(ismember([chainsMatTot.num], chainsMan));...
            chainsMatTot(end)];
        % Cycle through not showing manual clusters to showing only manual
        % clusters to showing everything
        switch length(handles.chainsMatTotPlot)
            case length(chainsMatTotNoMan)
                chainsMatTotPlot = chainsMatTotMan;
            case length(chainsMatTotMan)
                chainsMatTotPlot = chainsMatTot;
            otherwise
                chainsMatTotPlot = chainsMatTotNoMan;
        end
        
    case 'v'
        % Toggle visibility of new cluster chains 
        
    case 't'
        % Toggle time display on x-axis
        ticklabelformat(gca,'x',{@axisTimeLabels,gca,handles.firstFile});        
end

figure(minimap);

[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, move);

switch eventdata.Key
    case {'r','n','p','multiply','8'}
        chainsMatTotPlot = handles.chainsMatTot;
end

switch eventdata.Key
    case {'r','1','numpad1','2','numpad2','3','numpad3','4','numpad4','n','p','multiply','8','0','numpad0','m'}
        % Replotting the data
        cla(figure(24));
        figure(24);

        if handles.noise == 1
            plotBackGround(chainsMatTotPlot, 10, ChOn, 3); % skip factor for background (faster plotting)
        end

        plotFunctionCluster(handles.cluster_mode, chainsMatTotPlot(1:end-1), ChOn, handles.clusterVecAll, dataTips, handles.pointSize);
        plotCentroidsNow = handles.plotCentroids;
        
        ticklabelformat(gca,'x',[]);
end

if plotCentroidsNow
    plotChainCentroids(chainsMatTotPlot(1:end-1), ChOn, 10);
    plotCluster(chainsMatTotPlot(1:end-1), handles.newCluster, ChOn, handles.pointSize * 4, [0.5 0.5 0.5]);
    plotCompareChain(chainsMatTotPlot(1:end-1), handles.compareToChain, ChOn, handles.pointSize);
    % Plot newcluster spike waveforms in black
    axes(handles.axes2);
    cla(handles.axes2);
    plotClusterSpikeWaveforms(chainsMatTotPlot(1:end-1), handles.newCluster, [0.5 0.5 0.5]);    
    axes(handles.axes4);
    cla(handles.axes4);
    plotClusterISIs(chainsMatTotPlot(1:end-1), handles.newCluster, [0.5 0.5 0.5]);    
    set(minimap, 'WindowButtonMotionFcn', @highlightChain);
elseif length(minimap.Children.Children) > 2 && ~isempty(plotCentroidsNow)
    delete(minimap.Children.Children(1:end-2));
    set(minimap, 'WindowButtonMotionFcn','');
    axes(handles.axes2);
    cla(handles.axes2);
    axes(handles.axes4);
    cla(handles.axes4);
    set(handles.axes4, 'XScale', 'linear');
end
figure(minimap);
xlim([borderLeft, borderRight]);
ylim([borderDown, borderUp]);
ylabel(['Ch ' num2str(ChOn)]);

% Saving the variables.
handles.borderLeft = borderLeft;
handles.borderRight = borderRight;
handles.borderUp = borderUp;
handles.borderDown = borderDown;
handles.channel_minimap = ChOn;
handles.chainsMatTotPlot = chainsMatTotPlot;

guidata(handles.figure1, handles);
guidata(minimap, handles); 
figure(minimap);

% Highlight chains as the mouse hovers over the centroids
function highlightChain(hObject, eventdata)

minimap = figure(24);
handles = guidata(minimap);
chainsMatTotPlot = handles.chainsMatTotPlot(1:end-1);
chainsMatTot = handles.chainsMatTot(1:end-1);
channel = handles.channel_minimap;

hlthresh = 0.01; % as a fraction of axes span

% Get axes width and height span
tSpan = handles.borderRight - handles.borderLeft;
aSpan = handles.borderUp - handles.borderDown;

% Get mouse position
mouse = get(get(minimap, 'CurrentAxes'), 'CurrentPoint');
mouse = mouse(1,1:2);

% % Get all centroids
% allCentroids = vertcat(chainsMatTot.centroid);
% allCentroids = allCentroids(:,[1,1+channel]);
% allCentroids(:,2) = double(allCentroids(:,2)) * 1.95e-7;
% 
% % Find closest centroid
% [minDist, minInd] = min(sqrt(((allCentroids(:,1) - mouse(1))/tSpan).^2 + ((allCentroids(:,2) - mouse(2))/aSpan).^2));

% Get closest point and chain
alltimes = vertcat(chainsMatTotPlot.times);
allamps = vertcat(chainsMatTotPlot.amps);
allamps = double(allamps(:,channel)) * 1.95e-7;
cumnums = cumsum(cellfun(@numel, {chainsMatTotPlot.times}));

alltimes = alltimes(end:-1:1); % Reverse vectors in order to detect split chains first
allamps = allamps(end:-1:1);

[minDist, spikeInd] = min(sqrt(((alltimes - mouse(1))/tSpan).^2 + ((allamps - mouse(2))/aSpan).^2));
spikeInd = length(alltimes) - spikeInd + 1;
minInd = find(cumnums >= spikeInd, 1,'first');
if minInd > 1
    spikeInd = spikeInd - cumnums(minInd-1);
end

% If clusters are plotted check if closest chain is part of a cluster
if sum(handles.cluster_mode(1:2)) > 0
    [~, clusterInd] = getClusterName([chainsMatTotPlot(minInd).num], handles.clusterVecAll);
    pickInd = find(~isnan(clusterInd));
    if ~isempty(pickInd)
        minInd = minInd(pickInd(1));
        clusterInd = clusterInd(pickInd(1));
        clusInd = find(ismember([chainsMatTotPlot.num], handles.clusterVecAll{1,clusterInd}));      
        clusInd = clusInd(clusInd ~= minInd);
        minInd = [minInd, clusInd]; % move selected chain to the first position of the cluster   end
    else
        minInd = minInd(1);
    end
else
    minInd = minInd(1);
end

% Clear any scatter plots if they exist
if isa(handles.axes2.Children, 'matlab.graphics.chart.primitive.Scatter')
    delete(handles.axes2.Children);
end

if isa(handles.axes4.Children, 'matlab.graphics.chart.primitive.Scatter')
    delete(handles.axes4.Children);
end

% If closest centroid distance is less than hlthresh, highlight chain
if minDist <= hlthresh
    
%     disp(minInd(1));
    % Plot highlighted chain single waveform
    axes(handles.axes3);
    cla(handles.axes3);
    [wv1, wv2] = plotOneSpikeWaveform(chainsMatTot, chainsMatTotPlot(minInd(1)).num, handles.compareToChain, spikeInd, 2);

    % First check if this chain is already highlighted
    if ~isfield(handles, 'highlightedChains') || ~isequal(handles.highlightedChains, [chainsMatTotPlot(minInd).num]) || length(minimap.Children.Children) < 6
        handles.highlightedChains = [chainsMatTotPlot(minInd).num];

        % Check if there is a compareToChain
        if ~isempty(handles.compareToChain)
            cInd = find([chainsMatTot.num] == handles.compareToChain, 1, 'first');
        else
            cInd = [];
        end        
        
        % Delete old highlighted chains plot, if necessary
        if length(minimap.Children.Children) > 5 
            delete(minimap.Children.Children(1:end-5));
            set(minimap, 'WindowButtonDownFcn', '');
        end
        
        % Plot new highlighted chains
        figure(minimap);
        plotSpikeChains(chainsMatTotPlot(minInd), 1, channel, handles.pointSize*4);
        set(minimap, 'WindowButtonDownFcn', @selectChain);

        % Plot highlighted chain mean waveform
        axes(handles.axes2);
        while ~isempty(handles.axes2.Children) && any(handles.axes2.Children(1).Color ~= [0.5 0.5 0.5])
            delete(handles.axes2.Children(1:4));
        end
        if ~isempty(cInd); plotSpikeWaveforms(chainsMatTot(cInd), 0.5); end
        plotSpikeWaveforms(chainsMatTotPlot(minInd), 2);
        
        % Plot highlighted chain ISI
        axes(handles.axes4);
        while ~isempty(handles.axes4.Children) && any(handles.axes4.Children(1).Color ~= [0.5 0.5 0.5])
            delete(handles.axes4.Children(1));
        end
        if ~isempty(cInd); plotISIs(chainsMatTot(cInd), 0.5); end
        plotISIs(chainsMatTotPlot(minInd), 2);
        
        % Print analysis stats
        if (exist('clusterInd', 'var') == 1) && ~isnan(clusterInd)
            analStr = ['Cluster ' handles.clusterVecAll{2,clusterInd} '\n'];
        else
            analStr = '';
        end
        analStr = [analStr 'Chain ' num2str(handles.highlightedChains(1)) ' [trueName ' chainsMatTotPlot(minInd(1)).trueNumber ']'];
        
%         keyboard;
        
        % Check if chain is the result of a split
        if ~isempty(strfind(chainsMatTotPlot(minInd(1)).trueNumber, '_'))
            parentNum = strsplit(chainsMatTotPlot(minInd(1)).trueNumber, '_');
            parentFile = chainsMatTotPlot(minInd(1)).names{1};
            parentInd = find(cellfun(@(x,y) strcmp(x, parentNum{1}) & strcmp(y, parentFile), {chainsMatTot.trueNumber}, {chainsMatTot.names}), 1,'first');
            if ~isempty(parentInd)
                analStr = [analStr ' (split of ' num2str(chainsMatTot(parentInd).num) ')'];
            end
        end
        
        if ~isempty(handles.compareToChain)
            hInd = find([chainsMatTotPlot.num] == handles.highlightedChains(1), 1, 'first');
            cInd = find([chainsMatTot.num] == handles.compareToChain, 1, 'first');
            
            if hInd ~= cInd
                analStr = [analStr ' vs Chain ' num2str(handles.compareToChain) '\n']; 

                % wv comparison. Use L2 wv in this case
                hwv = squeeze(mean(double(chainsMatTotPlot(hInd).wv)*1.95e-7, 1));
                cwv = squeeze(mean(double(chainsMatTot(cInd).wv)*1.95e-7, 1));
                hwv = hwv(:); cwv = cwv(:);

                % WV dist
                analStr = [analStr '<WV> dist: ' num2str(sqrt(sum((hwv - cwv).^2)),3) '\n'];
                % WV corr
                analStr = [analStr '<WV> corr: ' num2str(corr(hwv, cwv),3) '\n'];

                % ISI comparison
                analStr = [analStr 'ISI corr: ' num2str(corr(chainsMatTotPlot(hInd).isi(:), chainsMatTot(cInd).isi(:)),3)];

                % Single waveform stats
                wv1 = wv1(:); wv2 = wv2(:);            
                % single wv corr
                wv1StatStr =  ['Corr: ' num2str(corr(wv1, wv2),3)];            
                % single wv dist
                wv1StatStr = [wv1StatStr '; Dist: ' num2str(sqrt(sum((wv1 - wv2).^2)),3)];
            else
                wv1StatStr = '';
            end
        else
            wv1StatStr = '';
        end
        
        analStr = sprintf(analStr);
        
        set(handles.textTools, 'String', analStr);
        set(handles.textWV, 'String', wv1StatStr);
    end
else
    delete(minimap.Children.Children(1:end-5));
    set(minimap, 'WindowButtonDownFcn', '');
    while ~isempty(handles.axes2.Children) && any(handles.axes2.Children(1).Color ~= [0.5 0.5 0.5])
        delete(handles.axes2.Children(1:4));
    end
    while ~isempty(handles.axes4.Children) && any(handles.axes4.Children(1).Color ~= [0.5 0.5 0.5])
        delete(handles.axes4.Children(1));
    end
    cla(handles.axes3);
    set(handles.textTools, 'String', '');
    set(handles.textWV, 'String', '');
end
guidata(handles.figure1, handles);
guidata(minimap, handles);
figure(minimap);

function selectChain(hObject, ~)
% Send highlighted chain to new cluster or analysis depending on left or
% right mouse click respectively

minimap = figure(24);
handles = guidata(minimap);

newCluster = handles.newCluster;

switch get(hObject, 'selectionType');
    
    case 'extend' % shift click => this deletes the highlighted chain (not the entire selected cluster) from new cluster
        chainInd = find(newCluster == handles.highlightedChains(1), 1, 'first');
        if ~isempty(chainInd)
            newCluster = newCluster(1:length(newCluster) ~= chainInd);
        end
        handles.newCluster = newCluster;

        delete(minimap.Children.Children(1:end-3));
        plotCluster(handles.chainsMatTot(1:end-1), handles.newCluster, handles.channel_minimap, handles.pointSize*4, [0.5 0.5 0.5]);
        plotCompareChain(handles.chainsMatTot(1:end-1), handles.compareToChain, handles.channel_minimap, handles.pointSize);
        axes(handles.axes2);
        cla(handles.axes2);
        plotClusterSpikeWaveforms(handles.chainsMatTot(1:end-1), handles.newCluster, [0.5 0.5 0.5]); 
        axes(handles.axes4);
        cla(handles.axes4);
        plotClusterISIs(handles.chainsMatTot(1:end-1), handles.newCluster, [0.5 0.5 0.5]);  
        set(handles.listbox6, 'value', 1);
        set(handles.listbox6, 'string', [newCluster]);
    
    case 'normal' % Left Click => add chain(s) to new cluster
        for h = 1 : length(handles.highlightedChains)
            newChainInd = find(newCluster == handles.highlightedChains(h), 1, 'first');

            if isempty(newChainInd)
                newCluster = [newCluster handles.highlightedChains(h)]; % Add chain to new clister if it is not there
            end
        end

        handles.newCluster = newCluster;

        delete(minimap.Children.Children(1:end-3));
        plotCluster(handles.chainsMatTot(1:end-1), handles.newCluster, handles.channel_minimap, handles.pointSize*4, [0.5 0.5 0.5]);
        plotCompareChain(handles.chainsMatTot(1:end-1), handles.compareToChain, handles.channel_minimap, handles.pointSize);
        axes(handles.axes2);
        cla(handles.axes2);
        plotClusterSpikeWaveforms(handles.chainsMatTot(1:end-1), handles.newCluster, [0.5 0.5 0.5]); 
        axes(handles.axes4);
        cla(handles.axes4);
        plotClusterISIs(handles.chainsMatTot(1:end-1), handles.newCluster, [0.5 0.5 0.5]);  
        set(handles.listbox6, 'value', 1);
        set(handles.listbox6, 'string', [newCluster]);
    
    case 'alt' % Right click
        analysisVec = handles.analysisVec;
        
        newChainInd = find(analysisVec == handles.highlightedChains(1), 1, 'first');

        if isempty(newChainInd)
            analysisVec = [analysisVec handles.highlightedChains(1)]; % Add chain to new clister if it is not there
        else
            analysisVec = analysisVec(1:length(analysisVec) ~= newChainInd); % Delete chain from new cluster if it is already there
        end
        
        set(handles.listbox7, 'value', 1);
        set(handles.listbox7, 'string', [analysisVec], 'max', length(analysisVec), 'min', 0);
        handles.analysisVec = analysisVec;
end

guidata(handles.figure1, handles);
guidata(minimap, handles);
figure(minimap);

function axisTimeLabels(varargin)
% Set x-axis tick labels

hAxes = varargin{end-1};
firstFile = varargin{end};

formatOut = 'mm/dd hh am'; 
firstFile = double(convertMSDNtime(firstFile));
% try
%     hAxes = eventData.AffectedObject;
% catch
%     hAxes = ancestor(eventData.Source,'Axes');
% end
tickValues = get(hAxes,'XTick');
tickLabels = arrayfun(@(x) datestr(x/24 + firstFile, formatOut), tickValues,'UniformOutput',false);
set(hAxes,'XTickLabel',tickLabels);
    

% --------------------------------------------------------------------
function load_clusters_Callback(hObject, eventdata, handles)
% Allow to load previous clusters (from a previous session, for example).
set(handles.textTools, 'string', 'Loading.');

% Determination of the pathway.
[filename, pathname] = uigetfile({[handles.savepath '*.mat']}, 'File Selector');
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
handles.clustersChecked = clusterVecAll.cluster.clustersChecked;
global manualModifications;
manualModifications = clusterVecAll.cluster.manualModifications; 
clusterVecAllName = clusterVecAllTmp(2, :);

% Assignations of the cluster modes.
[chainsMatTot] = plotFunctionClusterAssignation(chainsMatTot, clusterVecAllTmp);

set(handles.listbox1, 'value', 1);
set(handles.listbox1, 'string', clusterVecAllName); 

handles.chainsMatTot = chainsMatTot;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4); 


% --------------------------------------------------------------------
function save_clusters_Callback(hObject, eventdata, handles)
% Allow to save the cluster manually changed during the session.

% Loading the data.
clusterVecAll = handles.clusterVecAll;
pairsMatrix = handles.pairsMatrix;
linksMatrix = handles.linksMatrix;
global manualModifications;
manualClusters = handles.manualClusters;
L2chainsMatTotAll = handles.chainsMatTot;

cluster = [];
cluster.clusterVecAll= clusterVecAll;
cluster.linksMatrix = linksMatrix;
cluster.pairsMatrix = pairsMatrix;
cluster.manualModifications = manualModifications;
cluster.manualClusters = manualClusters;
cluster.clustersChecked = handles.clustersChecked;

disp(cluster)
[file, path] = uiputfile({[handles.savepath 'clusterVecAll.mat']}, 'Save clusters');
if file ~= 0
    save(strcat(path, file), 'cluster', '-v7.3');
    save(strcat(path, 'L2chainsMatTotAllBis.mat'), 'L2chainsMatTotAll', '-v7.3');
    disp('File saved !')
    set(handles.textTools, 'string', 'File saved.');
end


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function cluster_to_analysis_Callback(hObject, eventdata, handles)
% Add a chains to the new cluster.
value_selected = get(handles.listbox1, 'Value');
clusterVecAll = handles.clusterVecAll;

cluster = clusterVecAll{1, value_selected};

chainsMatTot = handles.chainsMatTot;
analysisVec = handles.analysisVec;

analysisVec = [analysisVec, cluster];
chainsNum = analysisVec;

set(handles.listbox7, 'value', 1);
set(handles.listbox7, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);
handles.analysisVec = analysisVec;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function cluster_to_cluster_Callback(hObject, eventdata, handles)
% Add a chains to the new cluster. 
value_selected = get(handles.listbox1, 'Value');
clusterVecAll = handles.clusterVecAll;

cluster = clusterVecAll{1, value_selected};

chainsMatTot = handles.chainsMatTot;
newCluster = handles.newCluster;

newCluster = [newCluster, cluster];

[~, ind]=unique(newCluster,'first');
newCluster = newCluster(sort(ind));

handles.newCluster = newCluster;
chainsNum = [newCluster];

set(handles.listbox6, 'string', chainsNum);
% set(handles.listbox6, 'string', chainsNum);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function select_zone_screener_Callback(hObject, eventdata, handles)
% empty
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
    
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    
    % Loading of the waveforms.
    L2cluster = [];
    for chain = 1 : length(cluster)
        L2chain = cluster(chain);
        L2chain.wv = double(L2chain.wv);
        L2cluster = [L2cluster, L2chain];
    end

    channel = channel_screener;
    channel_tetrode_screener = handles.channel_tetrode_screener;
    channel_4_1 = find(channel_tetrode_screener{1} == 1);
    channel_4_2 = find(channel_tetrode_screener{2} == 1);
    
    % Plotting of the selection.
    plotFunction(handles.plot_mode, cluster, channel, handles, channel_4_1, channel_4_2);
%     plotSpikeChains(cluster, 1, channel_screener, 6)
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(cluster)
end

handles.channel_screener = channel_screener;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);



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
    
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    
    % Loading of the waveforms.
    L2cluster = [];
    for chain = 1 : length(cluster)
        L2chain = cluster(chain);
        L2chain.wv = double(L2chain.wv);
        L2cluster = [L2cluster, L2chain];
    end

    channel = channel_screener;
    channel_tetrode_screener = handles.channel_tetrode_screener;
    channel_4_1 = find(channel_tetrode_screener{1} == 1);
    channel_4_2 = find(channel_tetrode_screener{2} == 1);
    
    % Plotting of the selection.
    plotFunction(handles.plot_mode, cluster, channel, handles, channel_4_1, channel_4_2);
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(cluster)
end
handles.channel_screener = channel_screener;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
    
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    
    % Loading of the waveforms.
    L2cluster = [];
    for chain = 1 : length(cluster)
        L2chain = cluster(chain);
        L2chain.wv = double(L2chain.wv);
        L2cluster = [L2cluster, L2chain];
    end

    channel = channel_screener;
    channel_tetrode_screener = handles.channel_tetrode_screener;
    channel_4_1 = find(channel_tetrode_screener{1} == 1);
    channel_4_2 = find(channel_tetrode_screener{2} == 1);
    
    % Plotting of the selection.
    plotFunction(handles.plot_mode, cluster, channel, handles, channel_4_1, channel_4_2);
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(cluster)
end
handles.channel_screener = channel_screener;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);

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
    
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    
    % Loading of the waveforms.
    L2cluster = [];
    for chain = 1 : length(cluster)
        L2chain = cluster(chain);
        L2chain.wv = double(L2chain.wv);
        L2cluster = [L2cluster, L2chain];
    end

    channel = channel_screener;
    channel_tetrode_screener = handles.channel_tetrode_screener;
    channel_4_1 = find(channel_tetrode_screener{1} == 1);
    channel_4_2 = find(channel_tetrode_screener{2} == 1);
    
    % Plotting of the selection.
    plotFunction(handles.plot_mode, cluster, channel, handles, channel_4_1, channel_4_2);
    cla(handles.axes3);
    axes(handles.axes3);
    plotSpikeWaveforms(cluster)
end

handles.channel_screener = channel_screener;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);
    


% --------------------------------------------------------------------
function plot_with_clusters_Callback(hObject, ~, handles)
% Plot the cluster with only one color in the minimap.
% Loading data.
cluster_mode = handles.cluster_mode;

if (cluster_mode == [0, 0, 0]) | (cluster_mode == [0, 1, 0]) | (cluster_mode == [0, 0, 1]) | (cluster_mode == [0, 1, 1])
    handles.cluster_mode = [1, 0, 0];
end
if cluster_mode == [1, 0, 0]
    handles.cluster_mode = [0, 0, 0];
end
if cluster_mode == [1, 0, 1]
    handles.cluster_mode = [0, 0, 1];
end

if (handles.cluster_mode == [1, 0, 0]) | (handles.cluster_mode == [1, 0, 1]);
    set(handles.text_mode, 'string', 'Black clusters ON; Colors clusters OFF')
end
if (handles.cluster_mode == [0, 0, 0]) | (handles.cluster_mode == [0, 0, 1]);
    set(handles.text_mode, 'string', 'Black clusters OFF; Color clusters OFF')
end

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function plot_with_cluster_color_Callback(hObject, ~, handles)
% Plot the cluster with only one color for the non-clustered chains. Each
% cluster is plot in a specific cluster. 
cluster_mode = handles.cluster_mode;

if (cluster_mode == [0, 0, 0]) | (cluster_mode == [1, 0, 0]) | (cluster_mode == [0, 0, 1]) | (cluster_mode == [1, 0, 1])
    handles.cluster_mode = [0, 1, 0];
end
if cluster_mode == [0, 1, 0]
    handles.cluster_mode = [0, 0, 0];
end
if cluster_mode == [0, 1, 1]
    handles.cluster_mode = [0, 0, 1];
end

if (handles.cluster_mode == [0, 1, 0]) | (handles.cluster_mode == [0, 1, 1]);
    set(handles.text_mode, 'string', 'Black clusters OFF; Colors clusters ON')
end
if (handles.cluster_mode == [0, 0, 0]) | (handles.cluster_mode == [0, 0, 1]);
    set(handles.text_mode, 'string', 'Black clusters OFF; Color clusters OFF')
end

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function select_zone_minimap_Callback(hObject, eventdata, handles)
% Selection by hand of a region in the minimap. The selected region is
% plotted in the screener and the number of the selected chains are
% displayed.
addpath([pwd '/plotFunctions/']);
addpath([pwd '/selectTools/']);
addpath([pwd '/toolsFunctions/']);

% Coordinates of the selection.
figure(24);
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

value_selected = get(handles.listbox3, 'Value');
chainsNum = [chainsMatTotSelectedAxes1.num];

set(handles.listbox3, 'value', 1);
set(handles.listbox3, 'string', chainsNum, 'max', length(chainsNum), 'min', 0);

% Plotting the waveforms.
cla(handles.axes3);
axes(handles.axes3);
plotSpikeWaveforms(chainsMatTotSelectedAxes1);

% Displaying the clusters.
clusterNamesVec = {};
for a = 1 : length(chainsMatTotSelectedAxes1(1 : end-1))
    [clusterNames] = findCluster(handles, chainsMatTotSelectedAxes1(a).num);
    if isempty(clusterNames) == 0
        clusterNamesVec{end + 1} = clusterNames;
    end
end
set(handles.textTools, 'String', unique(clusterNamesVec))

% Saving the variables.
handles.chainsMatTotSelectedAxes1 = chainsMatTotSelectedAxes1;
handles.fromMap = 1;
handles.fromClust = 0;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function channel_minimap_1_Callback(hObject, eventdata, handles)
% Refresh the minimap after a channel selection.
addpath([pwd '/plotFunctions/']);

channel_minimap = 1;
chainsMatTot = handles.chainsMatTot;

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 10);

% Plotting of the chains.
cla(figure(24));
figure(24);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel_minimap, 'fromMap');
    plotSpikeChains(chainsMatTotSelected, 1, channel_minimap, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel_minimap, handles.clusterVecAll, handles.dataTips, handles.pointSize);

ylabel(['Ch ' num2str(channel_minimap)]);

checkVariable = exist('handles.chainsMatTotSelectedAxes1', 'var');

if checkVariable == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1, 1, channel_minimap, 3);
end

handles.channel_minimap = channel_minimap;
axes(handles.axes2);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function channel_minimap_2_Callback(hObject, eventdata, handles)
% Refresh the minimap after a channel selection.
addpath([pwd '/plotFunctions/']);

channel_minimap = 2;
chainsMatTot = handles.chainsMatTot;

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 10);

% Plotting of the chains.
cla(figure(24));
figure(24);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel_minimap, 'fromMap');
    plotSpikeChains(chainsMatTotSelected, 1, channel_minimap, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel_minimap, handles.clusterVecAll, handles.dataTips, handles.pointSize);
ylabel(['Ch ' num2str(channel_minimap)]);

checkVariable = exist('handles.chainsMatTotSelectedAxes1', 'var');

if checkVariable == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1, 1, channel_minimap, 3);
end

handles.channel_minimap = channel_minimap;
axes(handles.axes2);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function channel_minimap_3_Callback(hObject, eventdata, handles)
% Refresh the minimap after a channel selection.
addpath([pwd '/plotFunctions/']);

channel_minimap = 3;
chainsMatTot = handles.chainsMatTot;

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 10);

% Plotting of the chains.
cla(figure(24));
figure(24);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel_minimap, 'fromMap');
    plotSpikeChains(chainsMatTotSelected, 1, channel_minimap, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel_minimap, handles.clusterVecAll, handles.dataTips, handles.pointSize);
ylabel(['Ch ' num2str(channel_minimap)]);

checkVariable = exist('handles.chainsMatTotSelectedAxes1', 'var');

if checkVariable == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1, 1, channel_minimap, 3);
end

handles.channel_minimap = channel_minimap;
axes(handles.axes2);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function channel_minimap_4_Callback(hObject, eventdata, handles)
% Refresh the minimap after a channel selection.
addpath([pwd '/plotFunctions/']);

channel_minimap = 4;
chainsMatTot = handles.chainsMatTot;

% Determination of the borders.
borderLeft = handles.borderLeft;
borderRight = handles.borderRight;
borderUp = handles.borderUp;
borderDown = handles.borderDown;
[borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, 10);

% Plotting of the chains.
cla(figure(24));
figure(24);

if handles.noise == 1
    [chainsMatTotSelected] = chainsSelection(chainsMatTot(end), borderLeft, borderRight, -1000, 1000, channel_minimap, 'fromMap');
    plotSpikeChains(chainsMatTotSelected, 1, channel_minimap, 3);
end

plotFunctionCluster(handles.cluster_mode, chainsMatTot(1 : end - 1), channel_minimap, handles.clusterVecAll, handles.dataTips, handles.pointSize);
ylabel(['Ch ' num2str(channel_minimap)]);

checkVariable = exist('handles.chainsMatTotSelectedAxes1', 'var');

if checkVariable == 1
    cla(handles.axes2);
    axes(handles.axes2);
    plotSpikeChains(handles.chainsMatTotSelectedAxes1, 1, channel_minimap, 3);
end

handles.channel_minimap = channel_minimap;
axes(handles.axes2);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
borderDown = borderDown + 1e-4;

figure(24);
ylim([borderDown, borderUp]);

handles.borderUp = borderUp;
handles.borderDown = borderDown;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- !.
function pushbutton68_Callback(hObject, eventdata, handles)
borderUp = handles.borderUp;
borderDown = handles.borderDown;

borderUp = borderUp - 1e-4;
borderDown = borderDown - 1e-4;

figure(24);
ylim([borderDown, borderUp]);

handles.borderUp = borderUp;
handles.borderDown = borderDown;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- ZOOM + Y.
function pushbutton69_Callback(hObject, eventdata, handles)
borderUp = handles.borderUp;
borderDown = handles.borderDown;

borderUp = borderUp - 1e-4;
borderDown = borderDown + 1e-4

figure(24);
ylim([borderDown, borderUp]);

handles.borderUp = borderUp;
handles.borderDown = borderDown;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);

% --- ZOOM - Y.
function pushbutton70_Callback(hObject, eventdata, handles)
borderUp = handles.borderUp;
borderDown = handles.borderDown;

borderUp = borderUp + 1e-4;
borderDown = borderDown - 1e-4

figure(24);
ylim([borderDown, borderUp]);

handles.borderUp = borderUp;
handles.borderDown = borderDown;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);

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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
    value_selected = get(handles.listbox1, 'Value');
    cluster = [];
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
    value_selected = get(handles.listbox1, 'Value');
    cluster = [];
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
    value_selected = get(handles.listbox1, 'Value');
    cluster = [];
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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
    value_selected = get(handles.listbox1, 'Value');
    cluster = [];
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);

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
    value_selected = get(handles.listbox1, 'Value');
    cluster = [];
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);

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
    value_selected = get(handles.listbox1, 'Value');
    cluster = [];
    for a = 1 : length(value_selected)
        chains = clusterVecAll{1, value_selected(a)};
        chainsL2 = chainsMatTot(ismember([chainsMatTot.num], chains));
        cluster = [cluster, chainsL2];
    end
    chainsMatTotSelected = cluster;
end
plotFunction(handles.plot_mode, chainsMatTotSelected, channel, handles, channel_4_1, channel_4_2);

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);



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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


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


guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function select_zone_tetrode_screener_Callback(hObject, eventdata, handles)
% Selection by hand of a region in the screener. The numbers of the
% selected chains are displayed in a listbox.
addpath([pwd '/plotFunctions/']);
addpath([pwd '/selectTools/'])

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

% Cropping of the data. The data could come from a manual selection in the
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
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function mark_cluster_Callback(hObject, eventdata, handles)
% Allow to mark a cluster by a star.
addpath([pwd '/toolsFunctions/'])
value_selected = get(handles.listbox1, 'Value');
clusterVecAll = handles.clusterVecAll;
clusterVecAll{2, value_selected} = ['*' clusterVecAll{2, value_selected}];
clusterVecAllName = clusterVecAll(2, :);
set(handles.listbox1, 'string', clusterVecAllName);
[clustersChecked] = clusterChecking(handles.clusterVecAll);
handles.clustersChecked = clustersChecked;
handles.clusterVecAll = clusterVecAll;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function unmark_cluster_Callback(hObject, eventdata, handles)
% Allow to unmark a cluster by a star.
addpath([pwd '/toolsFunctions/'])
value_selected = get(handles.listbox1, 'Value');
clusterVecAll = handles.clusterVecAll;
if ~isempty(strfind(clusterVecAll{2, value_selected}, '*'));
    clusterVecAll{2, value_selected} = clusterVecAll{2, value_selected}(2 : end);
    clusterVecAllName = clusterVecAll(2, :);
    set(handles.listbox1, 'string', clusterVecAllName);
    [clustersChecked] = clusterChecking(handles.clusterVecAll);
    handles.clustersChecked = clustersChecked;
    handles.clusterVecAll = clusterVecAll;
end
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
addpath([pwd '/toolsFunctions/']);
cluster_mode = handles.cluster_mode;
if (get(hObject, 'Value') == get(hObject, 'Max'))
  cluster_mode(end) = 1;
end
if (get(hObject, 'Value') == get(hObject, 'Min'))
  cluster_mode(end) = 0;
end
handles.cluster_mode = cluster_mode;
[clustersChecked] = clusterChecking(handles.clusterVecAll);
handles.clustersChecked = clustersChecked;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
if (get(hObject, 'Value') == get(hObject, 'Max'))
    dataTips = 'ON';
end
if (get(hObject, 'Value') == get(hObject, 'Min'))
    dataTips = 'OFF';
end
handles.dataTips = dataTips;
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);


% --------------------------------------------------------------------
function others_Callback(hObject, eventdata, handles)
% hObject    handle to others (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function credits_Callback(hObject, eventdata, handles)
msgbox(sprintf('Valentin Normand & Ashesh Dhawale \n valentin.normand@ens.fr'));


% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
msgbox('Help Yourself')


function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double
pointSize = get(hObject, 'string');
handles.pointSize = str2num(pointSize);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);  axes(handles.axes4);

% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

pointSize = get(hObject, 'string');
handles.pointSize = str2num(pointSize);
guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles); 

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton75. CLEAN LIST for new cluster
function pushbutton75_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.newCluster = [];
set(handles.listbox6, 'value', 1);
set(handles.listbox6, 'string', handles.newCluster);
guidata(hObject, handles);  minimap = figure(24); 
windowfunc = get(minimap, 'WindowButtonMotionFcn');
if isa(windowfunc, 'function_handle') && strcmp(func2str(windowfunc), 'highlightChain') 
    delete(minimap.Children.Children(1:end-3));
    plotCluster(handles.chainsMatTot(1:end-1), handles.newCluster, handles.channel_minimap, handles.pointSize * 4, [0 0 0]);
    plotCompareChain(handles.chainsMatTot(1:end-1), handles.compareToChain, handles.channel_minimap, handles.pointSize);
    % Plot newcluster spike waveforms in black
    axes(handles.axes2);
    cla(handles.axes2);
    axes(handles.axes4);
    cla(handles.axes4);
end
guidata(minimap, handles); 

% --- Executes on button press in pushbutton76.
function pushbutton76_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_autosaved_Callback(hObject, eventdata, handles)
% hObject    handle to load_autosaved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
minimap = figure(24);
global manualModifications;

load([handles.savepath, 'clusterVecAllTemp.mat']);
load([handles.savepath, 'L2chainsMatTotAll_new.mat']);

% Update clusters
% handles.clusterVecAll = cluster.clusterVecAll;
% handles.linksMatrix = cluster.linksMatrix;
% handles.pairsMatrix = cluster.pairsMatrix;
% handles.manualClusters = cluster.manualClusters;
% handles.clustersChecked = cluster.clustersChecked;
% handles.manualModifications = cluster.manualModifications;
% manualModifications = cluster.manualModifications;

handles.clusterVecAll = clusterVecAll;
% handles.linksMatrix = linksMatrix;
% handles.pairsMatrix = pairsMatrix;
handles.manualClusters = manualClusters;
handles.clustersChecked = clustersChecked;
handles.manualModifications = manualModifications;
% manualModifications = manualModifications;


% Updating list of clusters
clusterVecAllName = handles.clusterVecAll(2, :);

set(handles.listbox1, 'value', 1);
set(handles.listbox1, 'string', clusterVecAllName);
set(handles.listbox1, 'value', length(clusterVecAllName));

% Update chainsMatTot;
chainsMatTot = handles.chainsMatTot;
chainsMatTot = chainsMatTot(cellfun(@(x) isempty(strfind(x, '_')), {chainsMatTot.trueNumber}));
chainsMatTot = [chainsMatTot(1:end-1); L2chainsMatTotAll_new; chainsMatTot(end)];
chainsMatTot = plotFunctionClusterAssignation(chainsMatTot, handles.clusterVecAll);
handles.chainsMatTot = chainsMatTot;
guidata(hObject, handles); guidata(minimap, handles);

% Keyboard shortcut for marking cluster
% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

addpath([pwd '/toolsFunctions/'])
value_selected = get(handles.listbox1, 'Value');
clusterVecAll = handles.clusterVecAll;
        
switch eventdata.Key
    case 'm' % Mark cluster
        clusterVecAll{2, value_selected} = ['*' clusterVecAll{2, value_selected}];
        clusterVecAllName = clusterVecAll(2, :);
        set(handles.listbox1, 'string', clusterVecAllName);
        [clustersChecked] = clusterChecking(handles.clusterVecAll);
        handles.clustersChecked = clustersChecked;
        handles.clusterVecAll = clusterVecAll;
    case 'u' % Unmark cluster
        if ~isempty(strfind(clusterVecAll{2, value_selected}, '*'));
            clusterVecAll{2, value_selected} = clusterVecAll{2, value_selected}(2 : end);
            clusterVecAllName = clusterVecAll(2, :);
            set(handles.listbox1, 'string', clusterVecAllName);
            [clustersChecked] = clusterChecking(handles.clusterVecAll);
            handles.clustersChecked = clustersChecked;
            handles.clusterVecAll = clusterVecAll;
        end
end

guidata(hObject, handles);  minimap = figure(24); guidata(minimap, handles);
