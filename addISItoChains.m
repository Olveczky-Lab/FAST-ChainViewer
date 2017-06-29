function addISItoChains(fpath, L1path)
% Add L1 ISIs to chainsMatTot to save time when loading chains

addpath('./toolsFunctions');

% Cycle through tetrodes
for ChGroup = [0:15]
    disp(ChGroup);
    
    % Load L2chainsMatTot
    if exist([fpath 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAll.mat'], 'file') == 2
        load([fpath 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAll.mat']);
        
        if ~isfield(L2chainsMatTotAll, 'isi')
            for c = 1 : length(L2chainsMatTotAll)-1
                L2chainsMatTotAll(c).isi = getIsi(L2chainsMatTotAll(c), L1path); 
            end

            save([fpath 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAll.mat'], 'L2chainsMatTotAll', '-v7.3');
        end
    end
    
    % Load L2chainsMatTotBis
    if exist([fpath 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAllBis.mat'], 'file') == 2
        load([fpath 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAllBis.mat']);
        
        if ~isfield(L2chainsMatTotAll, 'isi')
            for c = 1 : length(L2chainsMatTotAll)-1
                L2chainsMatTotAll(c).isi = getIsi(L2chainsMatTotAll(c), L1path); 
            end

            save([fpath 'ChGroup_' num2str(ChGroup) '\L2chainsMatTotAllBis.mat'], 'L2chainsMatTotAll', '-v7.3');
        end
    end
end



