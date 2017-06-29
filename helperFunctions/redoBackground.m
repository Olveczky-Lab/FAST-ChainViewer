function redoBackground(pathwayBs, ChGroupList)

pathwayData = getDataPath(pathwayBs);

for ChGroup = ChGroupList
    L2chainsMatTotAll = [];
    L2background = [];
    addpath([pwd '/automaticStep/']);
    addpath([pwd '/toolsFunctions/']);

    pathwayLS = [pathwayBs 'ChGroup_' num2str(ChGroup) '/'];
    disp(pathwayLS);

    load([pathwayBs 'ChGroup_' num2str(ChGroup) '/L2chainsMatTotAll.mat']);
    L2chainsMatTotAll = L2chainsMatTotAll(1:end-1);

    [filesTrue, filesBackground] = filesIdentifier(pathwayData, ChGroup);
    firstFile = filesTrue(1).name; 

    % Get principal components, energy, peak-valley diff etc for L2 chains
    allL2wv = double(cat(1, L2chainsMatTotAll.wv))*1.95e-7; 
    PCs = zeros(size(allL2wv,2), size(allL2wv,3), size(allL2wv,3));
    for ch = 1 : size(allL2wv,2)
        PCs(ch,:,:) = princomp(squeeze(allL2wv(:,ch,:)));
    end

    for x = 1 : length(L2chainsMatTotAll)
        tempwv = L2chainsMatTotAll(x).wv;
        L2chainsMatTotAll(x).features.energy = getEnergy(tempwv);
        L2chainsMatTotAll(x).features.valley = getValley(tempwv, 32);
        L2chainsMatTotAll(x).features.width = getSpikeWidth(tempwv, 32);
        [L2chainsMatTotAll(x).features.pc1, L2chainsMatTotAll(x).features.pc2] = getPCs(double(tempwv)*1.95e-7, PCs);   
    end

    % Background time correction and properties completion.
    L2background.num = -1;
    L2background.names = 'BACKGROUND';
    L2background.color = [0.75  0.75  0.75];

    L2background.wv = zeros(10, 10, 64);
    L2background.trueNumber = '-1';
    L2background.timeBegin = 'NA';
    L2background.channel = ChGroup;

    % Get waveform features for background spikes

    % Load background spikes file by file
%     nbackSpikes = numel(L2background.times);
    allTimes = [];
    allEnergy = [];
    allValley = [];
    allWidth = [];
    allPC1 = [];
    allPC2 = [];
    allAmps = [];

    count = 1;
    for f = 1 : length(filesBackground)
        if f/5 == fix(f/5)
            disp(f/length(filesBackground)); 
        end
        L2backgroundChain = getLevel2BackgroundSpikes([pathwayData filesBackground(f).name], ChGroup, 1);
        L2backgroundwv = L2backgroundChain(1).wv;
        allEnergy(count:(count+size(L2backgroundwv,1)-1),:) = getEnergy(L2backgroundwv);
        allValley(count:(count+size(L2backgroundwv,1)-1),:) = getValley(L2backgroundwv, 32);
        allWidth(count:(count+size(L2backgroundwv,1)-1),:) = getSpikeWidth(L2backgroundwv, 32);
        [allPC1(count:(count+size(L2backgroundwv,1)-1),:), allPC2(count:(count+size(L2backgroundwv,1)-1),:)] = getPCs(double(L2backgroundwv)*1.95e-7, PCs);   

        L2backgroundTimes = L2backgroundChain(1).times;
        tOffset = double(str2num(['uint64(' filesBackground(f).name ')'])) - double(str2num(['uint64(' firstFile ')']));
        tOffset = (tOffset * 1e-7) * 30000;
        L2backgroundTimes = double(L2backgroundTimes) + tOffset;
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
    
    if isfield(L2chainsMatTotAll, 'isi')
        L2background.isi = [];
    end

    L2chainsMatTotAll = [L2chainsMatTotAll; L2background];
    save([pathwayLS 'L2chainsMatTotAll.mat'], 'L2chainsMatTotAll', '-v7.3');
    clear L2background L2backgroundwv L2backgroundChain allEnergy allPC1 allPC2 allValley allWidth;
    clear L2chainsMatTotAll;
end

