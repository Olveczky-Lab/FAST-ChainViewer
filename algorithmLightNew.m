function algorithmLightNew(pathwaySave, ChGroupList, pathwayData)
% Main function of the program. This function allows to load the data and
% to identify the partners for each chains.
% Two outputs are saved in hard drive : the matrix of links and properties, and a vector with all
% of the L2 chains. 

if nargin < 3
    pathwayData = getDataPath(pathwaySave);
end

% pathwaySave = ['H:\Clustering\Kamod\'];

addpath([pwd '/automaticStep/']);
addpath([pwd '/toolsFunctions/']);
addpath([pwd '/helperFunctions/']);

colors = [
    0.00  0.00  1.00
    0.00  0.50  0.00
    1.00  0.00  0.00
    0.00  0.75  0.75
    0.75  0.00  0.75
    0.75  0.75  0.00
    0.25  0.25  0.25
    0.75  0.25  0.25
    0.95  0.95  0.00
    0.25  0.25  0.75
    0.00  1.00  0.00
    0.76  0.57  0.17
    0.54  0.63  0.22
    0.34  0.57  0.92
    1.00  0.10  0.60
    0.88  0.75  0.73
    0.10  0.49  0.47
    0.66  0.34  0.65
    0.99  0.41  0.23
    ];

samprate = 3e4;
maxNumPC = 10000;

for ChGroup = ChGroupList
    
    % pathwayLS is the pathway where the program will save and load the data. 
    if exist([pathwaySave 'ChGroup_' num2str(ChGroup)], 'dir') ~= 7
        mkdir([pathwaySave 'ChGroup_' num2str(ChGroup)]);
    end
    pathwayLS = [pathwaySave 'ChGroup_' num2str(ChGroup) '\'];
    disp(pathwayLS);
    
    % Creation of a vector with the names of the folders for this ChGroup
    [filesList, filesBackground] = filesIdentifier(pathwayData, ChGroup);    
    firstFile = filesBackground(1).name;
    
    % Get file sizes
    nChains = zeros(size(filesList));
    for f = 1 : length(filesList)
         [~, temp] = getAllMergedChainsSize([pathwayData filesList(f).name], ChGroup, 1);
         nChains(f) = numel(temp);
    end    
    
    disp([num2str(sum(nChains)) ' chains in total.']);

    % Load link metrics for all merged chains, file by file
    L2chainsMatTotAll = [];
    metrix = [];
    L2background = [];
    L2background.num = -1;
    
    for f = 1 : length(filesList)
                
        disp(['File ' num2str(f) ' of ' num2str(length(filesList)) ' : ' filesList(f).name]);
        
       % Load all chains at one go...
        chains = getAllMergedChains([pathwayData filesList(f).name], ChGroup, 0, 0)';

        L2chains = getLevel2Spikes([pathwayData filesList(f).name], ChGroup, 1)';              
        L2chains = L2chains(1:end-1);
        
        % Extract chain metrix
        metrix = [metrix; getChainMetrix(chains, L2chains, ChGroup, pathwayData, filesList(f).name, firstFile)'];
        
        if f == 1
            lastNum = 0;
        else
            lastNum = L2chainsMatTotAll(end).num;
        end
        
        fileBegin = double(str2num(['uint64(' filesList(f).name ')']) - str2num(['uint64(' firstFile ')'])) / (1e7 * 3600);
        
        % Add other features to L2chains
        for c = 1 : length(L2chains)
            L2chains(c).times = double(L2chains(c).times)/(samprate*3600) + fileBegin;
            L2chains(c).channel = ChGroup;
            L2chains(c).trueNumber = num2str(L2chains(c).num);
            L2chains(c).num = lastNum + c;
            L2chains(c).timeBegin = L2chains(c).times(1);
            L2chains(c).isi = metrix(c).isi;
            L2chains(c).names = {filesList(f).name};
            L2chains(c).firstFile = str2num(['uint64(' firstFile ')']);  
            L2chains(c).color = colors(randi(size(colors,1)),:);
            L2chains(c).numSpikes = length(chains(c).times);
        end
        
        L2chainsMatTotAll = [L2chainsMatTotAll; L2chains];
        
        clear chains L2chains;
        disp([num2str(100*sum(nChains(1:f))/sum(nChains)) ' % done']);
    end
    
    
    save([pathwayLS 'ChainsTemp.mat'], 'L2chainsMatTotAll', 'metrix', '-v7.3');
    
    % Generate linksMatrix
    disp('Calculating linksMatrix');
    
    [linksMatrix, singleCluster] = generateLinksMatrix(metrix, L2chainsMatTotAll);
    
    % Save variables
    disp('Saving linksMatrix.mat');
    save([pathwayLS 'linksMatrix.mat'], 'linksMatrix', '-v7.3');
    save([pathwayLS 'singleCluster.mat'], 'singleCluster', '-v7.3');
        
    clear linksMatrix singleCluster metrix;
    
    % Add features to L2chainsMatTotAll
    disp('Calculating extra L2 features');
    allL2wv = double(cat(1, L2chainsMatTotAll.wv))*1.95e-7; 
    
    % Limit number of chains for PC calculation.
    if size(allL2wv,1) > maxNumPC
        allL2wv = allL2wv(randperm(size(allL2wv,1), maxNumPC), :, :);
    end
    
    PCs = zeros(size(allL2wv,2), size(allL2wv,3), size(allL2wv,3));
    for ch = 1 : size(allL2wv,2)
        PCs(ch,:,:) = princomp(squeeze(allL2wv(:,ch,:)));
    end
    
    clear allL2wv;

    for x = 1 : length(L2chainsMatTotAll)
        tempwv = L2chainsMatTotAll(x).wv;
        L2chainsMatTotAll(x).features.energy = getEnergy(tempwv);
        L2chainsMatTotAll(x).features.valley = getValley(tempwv, 32);
        L2chainsMatTotAll(x).features.width = getSpikeWidth(tempwv, 32);
        [L2chainsMatTotAll(x).features.pc1, L2chainsMatTotAll(x).features.pc2] = getPCs(double(tempwv)*1.95e-7, PCs); 
        L2chainsMatTotAll(x).isi = getIsi(L2chainsMatTotAll(x), pathwayData); 
    end

    % L2 Background
    disp('Generating Background features');
    L2background = [];
    L2background.num = -1;
    L2background.names = 'BACKGROUND';
    L2background.color = [0.75  0.75  0.75];
    L2background.isi = [];
    L2background.wv = zeros(10, 10, 64);
    L2background.trueNumber = '-1';
    L2background.timeBegin = 'NA';
    L2background.channel = ChGroup;
    L2background.firstFile = str2num(['uint64(' firstFile ')']);
    L2background.numSpikes = -1;
    
    allTimes = [];
    allEnergy = [];
    allValley = [];
    allWidth = [];
    allPC1 = [];
    allPC2 = [];
    allAmps = [];

    count = 1;
    for f = 1 : length(filesBackground)
        L2backgroundChain = getLevel2BackgroundSpikes([pathwayData filesBackground(f).name], ChGroup, 1);
        L2backgroundwv = L2backgroundChain(1).wv;
        allEnergy(count:(count+size(L2backgroundwv,1)-1),:) = getEnergy(L2backgroundwv);
        allValley(count:(count+size(L2backgroundwv,1)-1),:) = getValley(L2backgroundwv, 32);
        allWidth(count:(count+size(L2backgroundwv,1)-1),:) = getSpikeWidth(L2backgroundwv, 32);
        [allPC1(count:(count+size(L2backgroundwv,1)-1),:), allPC2(count:(count+size(L2backgroundwv,1)-1),:)] = getPCs(double(L2backgroundwv)*1.95e-7, PCs);   

        L2backgroundTimes = double(L2backgroundChain(1).times);
        tOffset = double(str2num(['uint64(' filesBackground(f).name ')'])) - double(str2num(['uint64(' firstFile ')']));
        tOffset = (tOffset * 1e-7) * 30000;
        L2backgroundTimes = L2backgroundTimes + tOffset;
        allTimes(count:(count+size(L2backgroundwv,1)-1)) = L2backgroundTimes/(30000 * 3600);

        allAmps(count:(count+size(L2backgroundwv,1)-1),:) = L2backgroundChain(1).amps;

        count = count + size(L2backgroundwv,1);
    end

    L2background.features.energy = allEnergy;
    L2background.features.valley = allValley;
    L2background.features.width = allWidth;
    L2background.features.pc1 = allPC1;
    L2background.features.pc2 = allPC2;
    L2background.times = allTimes;
    L2background.amps = allAmps;

    L2chainsMatTotAll = [L2chainsMatTotAll; L2background];
    
    clear L2background L2backgroundwv L2backgroundChain allEnergy allPC1 allPC2 allValley allWidth;
    
    % Save variables
    disp('Saving L2chainsMatTotAll.mat');
    save([pathwayLS 'L2chainsMatTotAll.mat'], 'L2chainsMatTotAll', '-v7.3');
    
    delete([pathwayLS 'ChainsTemp.mat']);
    
    clear L2chainsMatTotAll;
end

