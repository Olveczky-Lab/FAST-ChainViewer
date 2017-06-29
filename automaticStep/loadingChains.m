function [chainsVec, L2chainsVec, nameFileVec, fileSize] = loadingChains(indice, ChGroup, pathway, filesTrue, lastChainsFile, lastL2ChainsFile, lastChainsName)
% This function allows the loading of the chains by two (or more if the
% size is smaller than 500000000 bytes), and the L2 chains. 
% chainsVec : cell with the loaded chains.
% L2chainsVec : cell with the loaded L2chains.
% nameFilesVec : cell with the name of the files. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALISATION OF VARIABLES %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nameFileVec = {};
chainsVec = {};
L2chainsVec = {};
fileSize = 0;
    
if indice == 1
    addNumber = 0;
else
    addNumber = 1;
    L2chainsVec{1} = lastL2ChainsFile;
    chainsVec{1} = lastChainsFile;
    nameFileVec{1} = lastChainsName;
end



%%%%%%%%%%%%%%%%
% LOADING STEP %
%%%%%%%%%%%%%%%%
while ((fileSize < 200000000) || (length(nameFileVec) < 2)) && ((indice + addNumber) <= length(filesTrue))
        
    % Identification and loading of the file 'chains.mat'.
    chainsNumTmp = filesTrue(indice + addNumber).name;
    chains = getAllMergedChains([pathway chainsNumTmp], ChGroup, 1);
    
    if length(chains) >= 1
                
        % Loading of the L2 file.
        L2Pathway = [pathway chainsNumTmp];
        [L2chains] = getLevel2Spikes(L2Pathway, ChGroup, 1);
        
        % Determination of the properties of the files 'chains.mat'.
        chainsPropertiesTMP = whos('chains');
        fileSize = fileSize + chainsPropertiesTMP.bytes;
        
        % The file loaded is put into a vector, output of the function.
        chainsVec{end+1} = chains;
        
        % Assignation of a new class to the chains : the channel group.
        for a = 1 : length(L2chains)
            L2chains(a).channel = ChGroup;
        end
        
        % The L2 chains is put into a vector, output of the function.
        L2chainsVec{end+1} = L2chains;
        
        % The following vector contains the names of the loaded files,
        % ouput of the function.
        nameFileVec{end+1} = chainsNumTmp;
    end
    
    clear chains;
    addNumber = addNumber + 1;
end

% Conversion of the str to number for the L2 variables. The first file was
% converted in the previous run. 
for a = 1 : length(L2chainsVec)
    for b = 1 : length(L2chainsVec{a}) - 1
        L2chainsVec{a}(b).num = str2num(L2chainsVec{a}(b).num);
    end
end
    
end