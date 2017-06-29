function [groupList, pairsMatrixOutput, linksMatrix] = linksMatrixClustering(linksMatrix, chainsMatTot, distWeight, corrWeight, isiWeight, distExp, corrExp, isiExp, distThreshold, corrThreshold, isiThreshold, tempParameter, lengthParameter)

% This function allows to check the different compatibility between chains
% and to regroup the best clusters.
%
% First, the function search each compatibility for a particular chain.
% Then, the function search the best partner and a link is created.
% Second, the same things is repeted for each chains. 
% Third, the groups are compared. If two chains are found in commun, the
% chains are linked togethers. 
%
% INPUTS
% "linksMatrix" : the matrix of links between the chains, two by two,
% returned by the algorithm.
% "distWeight" : weight of the waveforms distance in the criteria.
% "corrWeight" : weight of the waveforms correlation in the criteria.
% "isiWeight" : weight of the isi distribution in the criteria. /!\ The isi
% distribution is not available for all pairs of chains, only if the two
% chains have more than 1000 spikes.
% "distExp" : exponent of the distance, change the weight of the distance.
% "corrExp" : exponent of the correlation.
% "isiExp" : exponent of the isi distribution.
% criteriaThreshold : the pairs with a criteria under this value will not
% be selectionned. 
%
% OUTPUT
% "groupList" : a cell array with the group of chains (cluster of chains). 

% Example of parameters.
% distWeight = 1;
% corrWeight = 1e5;
% isiWeight = 1e5;
% distExp = 1;
% corrExp = 1;
% isiExp = 1;
% distThreshold = 1e-5;
% corrThreshold = 0.9;
% isiThreshold = 0.8;
% tempParameter = 1e-5;
% lengthParameter = 5000;
% ampsParameter = 1e-4;

if ~isempty(linksMatrix)
    %%%%%%%%%%
    % STEP 1 %
    %%%%%%%%%%
    % Creation of the variable "groupList", a cell array, which contains for
    % each chain with at least one partner, the previous partner or the
    % followin partner, or the two. 
    %
    % The links matrix is a square matrix. In this matrix, the row and the
    % column correspond to the chains number + 1. The row correspond to the
    % chains which have a column correspond to the chains wter. By the way, if
    % there is not a NaN for a particular column and chains, the chains coresponding to row-1 and
    % column-1 are linked, and the chains column-1 is the first chains in time. 

    % Cleaning of the linksMatrix.
    [~, ia] = unique(linksMatrix(:, 1 : 2), 'rows');
    linksMatrix = linksMatrix(ia, :);

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Criteria determination %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    linksMatrix(:, 11) = distCriteria(linksMatrix(:, :));
    linksMatrix(:, 12) = criteriaValue(linksMatrix(:, :), distWeight, corrWeight, isiWeight, distExp, corrExp, isiExp); 


    % Creation of two matrix.
    % pairsMatrix, dim(chains * chains), with 1 is there is a pairs, else zero.
    % scoreMatrix, dim(chains * chains), with the scores values for the pairs,
    % else zero.
    max1 = max(linksMatrix(:, 1)) + 1;
    max2 = max(linksMatrix(:, 2)) + 1;
    maxMax = max([max1, max2]);
    scoresMatrix = zeros(maxMax, maxMax);
    pairsMatrix = false(maxMax, maxMax);

    % Filling of the scoresMatrix.
    scoresMatrix(sub2ind(size(scoresMatrix), linksMatrix(:, 1) + 1, linksMatrix(:, 2) + 1)) = linksMatrix(:, 12);

    % Filling of the pairsMatrix.
    [pairsMatrix] = thresholdApplication(linksMatrix, pairsMatrix, distThreshold, corrThreshold, isiThreshold);

    % Selection in function of the temp parameters.
    if any(pairsMatrix(:))
        [pairsMatrix] = tempSelection(pairsMatrix, tempParameter, scoresMatrix);
        pairsMatrixOutput = pairsMatrix;

        % Chains joining.
        [groupList] = clusterCreation(pairsMatrix);

        % Grouping step.
        [groupList] = clusterConstruction(groupList);

        % Cleaning of the small groups.
        [groupList] = clustersSelection(chainsMatTot, groupList, lengthParameter);

        % Cluster nominaion.
        [groupList] = clusterNomination(groupList, 0);


        % Identification of the single chain.
        pairsMatrix = sparse(pairsMatrix);
        singleList = find(not(any(pairsMatrix, 1) | any(pairsMatrix, 2)'));
        singleList = singleList - 1;

        % If the single chains have less than 5000 spikes, it is not conserved. 
        chains = chainsMatTot(ismember([chainsMatTot.num], singleList));
    else
        chains = chainsMatTot;
        groupList = [];
        pairsMatrixOutput = [];
        
    end
else
    chains = chainsMatTot;
    groupList = [];
    pairsMatrixOutput = [];
end

chains = chains([chains.numSpikes] > 5000);
singleFinalChain = num2cell([chains.num]);

% 
% for c = 1 : length(singleList)
%     [indiceRow, indiceColumn] = find(linksMatrix(:, 1:2) == singleList(c));
%     
%     if (length(indiceColumn) > 1) || (length(indiceRow) > 1)
%         if indiceColumn(1) == 1
%             chainLength = linksMatrix(indiceRow(1), 8);
%         end
%         if indiceColumn(1) == 2
%             chainLength = linksMatrix(indiceRow(1), 9);
%         end
%         if chainLength > 5000
%             singleFinalChain{end + 1} = singleList(c);
%         end
%     end
% end

[singleFinalChain] = clusterNomination(singleFinalChain, 2);

% Adding the single chains
groupList = [groupList, singleFinalChain];

% Assignation of a color to the clusters. 
clusterColor = [];
for a = 1 : size(groupList,2)
    [color] = colorSelection;
    clusterColor = [clusterColor, {color}];
end

groupList = [groupList; clusterColor];

end