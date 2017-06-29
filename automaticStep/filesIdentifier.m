function [filesTrue, filesBackground] = filesIdentifier(pathway, ChGroup)
% This function allows to determine the files chains.mat in a rat folder.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTOMATIC LOADING FILES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identification and pre-loading of the files.
disp('Initialisation of the Data.')

files = dir([pathway '6*']);
files = files([files.isdir] == 1);

vecFiles = zeros(size(files));

for a = 1 : length(files)
    vecFiles(a) = exist([pathway files(a).name '/ChGroup_' num2str(ChGroup) '/MergedChains/0.wv']);
end
vecIndices = vecFiles == 2;
filesTrue = files(vecIndices);

bgthere = zeros(size(files));
for a = 1 : length(files)
    bgthere(a) = exist([pathway files(a).name '/ChGroup_' num2str(ChGroup) '/Level2/SpikeTimesRaw'], 'file');
end
bgIndices = bgthere == 2;
filesBackground = files(bgIndices);