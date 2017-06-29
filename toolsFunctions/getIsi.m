function hISI = getIsi(chain, pathBasic)

pathway = [pathBasic chain.names{1}];
ChGroup = chain.channel;

L1chain = getSomeMergedChains(pathway, ChGroup, mat2cell(chain.trueNumber, 1), 0);
if numel(L1chain.times) > 100
    L1chain.times = double(L1chain.times)/30000;
    hISI = sgolayfilt(histc(diff(L1chain.times), logspace(-3, 3, 100)), 3, 9) / length(L1chain.times);        
else
    hISI = zeros(100,1) * NaN;
end