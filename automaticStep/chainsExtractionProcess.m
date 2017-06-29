function [chainsMatTot, L2chainsMatTot] = chainsExtractionProcess(chainsVecTmp, chainsMatTot, L2chainsMatTotTmp)
% This function allow to extract only the chains with an high amplitudes
% (and the L2 chains) and to convert the files. 


%%%%%%%%%%%%%%%%%%
% INITIALISATION %
%%%%%%%%%%%%%%%%%%
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

chainsMatTot = [];
L2chainsMatTot = [];


%%%%%%%%%%%
% PROCESS %
%%%%%%%%%%%
for a = 1 : length(chainsVecTmp)
    fileCell = chainsVecTmp{a};
    fileCell = chainsExtractionAlgo(fileCell);
    for b = 1 : length(fileCell);
        color = colors(randi(size(colors, 1)), :);
        chainsCell = fileCell(b);
        chainsCell.color = color;
        chainsMat = [chainsCell];
        chainsMatTot = [chainsMatTot; chainsMat];
    end
end
for a = 1 : length(chainsMatTot)
    for b = 1 : length(L2chainsMatTotTmp)
        if chainsMatTot(a).num == L2chainsMatTotTmp(b).num
            L2chainsMatTotTmp(b).times = double(L2chainsMatTotTmp(b).times);
            L2chainsMatTotTmp(b).times = (((L2chainsMatTotTmp(b).times / 30000) / 60) / 60);
            L2chainsMatTotTmp(b).timeBegin = double(chainsMatTot(a).times(1));
            L2chainsMatTotTmp(b).names = chainsMatTot(a).names;
            L2chainsMatTotTmp(b).color = chainsMatTot(a).color;
            L2chainsMatTot = [L2chainsMatTot; L2chainsMatTotTmp(b)];
        end
    end
end

end