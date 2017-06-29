function [pairsMatrix] = tempSelection(pairsMatrix, tempParameter, scoresMatrix_in)
% This function allows to change pairsMatrix by the temp parameter. 

scoresMatrix = zeros(size(scoresMatrix_in));
scoresMatrix(pairsMatrix) = scoresMatrix_in(pairsMatrix);
scoresMatrix = sparse(scoresMatrix); % For speed purposes
[i,j] = find(scoresMatrix);
SelRows = unique(i);
SelCols = unique(j);

scoresMatrix = scoresMatrix(SelRows,SelCols);
scoresMatrix = scoresMatrix / max(scoresMatrix(:));
scoresMatrix = full(scoresMatrix);

%% Temp selection along rows
pairsMatrixRow = exp(scoresMatrix/tempParameter)./repmat(nansum(exp(scoresMatrix/tempParameter),2),1,size(scoresMatrix,2));

% Find rows that have any NaN values where they should not
NaNrows = find(any(isnan(pairsMatrixRow) & ~isnan(scoresMatrix), 2));
if ~isempty(NaNrows)
    [~, maxCols] = max(scoresMatrix(NaNrows,:),[],2);
    pairsMatrixRow(NaNrows,:) = NaN;
    pairsMatrixRow(sub2ind(size(pairsMatrixRow),NaNrows, maxCols)) = 1;
end
pairsMatrixRow = pairsMatrixRow >= repmat(1./sum(~isnan(pairsMatrixRow),2), 1, size(pairsMatrixRow,2));

%% Temp selection along columns
pairsMatrixCol = exp(scoresMatrix/tempParameter)./repmat(nansum(exp(scoresMatrix/tempParameter),1),size(scoresMatrix,1),1);

% Find columns that have any NaN values where they should not
NaNcolumns = find(any(isnan(pairsMatrixCol) & ~isnan(scoresMatrix), 1));
if ~isempty(NaNcolumns)
    [~, maxRows] = max(scoresMatrix(:,NaNcolumns),[],1);
    pairsMatrixCol(:,NaNcolumns) = NaN;
    pairsMatrixCol(sub2ind(size(pairsMatrixCol),maxRows, NaNcolumns)) = 1;
end
pairsMatrixCol = pairsMatrixCol >= repmat(1./sum(~isnan(pairsMatrixCol),1), size(pairsMatrixCol,1), 1);
%%
pairsMatrix(:) = false;
pairsMatrix(SelRows, SelCols) = pairsMatrixRow & pairsMatrixCol;
