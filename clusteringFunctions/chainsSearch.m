function [chainsList, chainsInd] = chainsSearch(L2chainsMatTot, chainsNumber)
% This function has two inputs : the matrix of L2 chains and a number of
% chains. The function return the L2 chains corresponding to the input
% number. 
chainsInd = [];
chainsList = [];
for a = 1 : length(chainsNumber)
    for b = 1 : length(L2chainsMatTot)
        if chainsNumber(a) == L2chainsMatTot(b).num
            chainsList = [chainsList, L2chainsMatTot(b)];
            chainsInd = [chainsInd, b];
        end
    end
end

