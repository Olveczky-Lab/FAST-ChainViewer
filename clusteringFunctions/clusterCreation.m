function [groupList] = clusterCreation(pairsMatrix)
 % This function allows to create the cluster (with a name) and to return them.
  
pairsMatrix = logical(pairsMatrix);
[i,j] = ind2sub(size(pairsMatrix), find(pairsMatrix));
groupList = [i-1 j-1];



% groupList = cell(size(pairsMatrix,1),1);
% count = 1;
% for row = 1 : size(pairsMatrix,1)
%     % Find partners for each chain in rows of pair matrix
%     cols = pairsMatrix(row,:);
%     
%     if any(cols)
%         groupList{count} = [row-1, find(cols)-1];
%         count = count + 1;
%     end
% end
% 
% groupList = groupList(1:count-1);

