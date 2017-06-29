function isiPlot(handles, chainsSelected)
    chainsMatTot = handles.chainsMatTot;
    chains = chainsSearch(chainsMatTot, chainsSelected);
    pathway = [handles.pathBasic chains.names{1}];
    ChGroup = chains.channel;
    disp('Loading complete chains...')
    chainsSelectedTest = getSomeMergedChains(pathway, ChGroup, mat2cell(chains.trueNumber, 1), 0);
    chainsSelectedTest.times = double(chainsSelectedTest.times);
    chainsSelectedTest.times = (((chainsSelectedTest.times / 30000) / 60) / 60);
    
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