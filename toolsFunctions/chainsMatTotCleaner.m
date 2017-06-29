function [chainsMatTot] = chainsMatTotCleaner(chainsMatTot)
% This function allows to clean the chainsMatTot of the chains contained in
% the last opened file. These chains would be add at the next run.

lastFile = chainsMatTot(end).names{1};
chainsMatTotTmp = [];

for a = 1 : length(chainsMatTot)
    if strcmp(chainsMatTot(a).names{1}, lastFile) == 0
        chainsMatTotTmp = [chainsMatTotTmp; chainsMatTot(a)];
    end
end

chainsMatTot = chainsMatTotTmp;

end
        
