function [L2backgroundAmpsCell, L2backgroundTimesCell, chainsVecTmp, L2chainsMatTotTmp, L2background, maxNum, maxNumTmp] = chainsTreatment(chainsVec, chainsVecTmp, L2chainsVec, nameFileVec, chainsMatTotTmp, L2chainsMatTotTmp, L2background, maxNum, maxNumTmp, L2backgroundTimesCell, L2backgroundAmpsCell, firstFile)
% This function allow to convert the time and the numbers of the chains and
% L2 chains in function of the gaps and the previous chains. 


%%%%%%%%%%%
% PROCESS %
%%%%%%%%%%%
for a = 1 : length(chainsVec)
    fileNumber = a;
    fileCell = chainsVec{a};
    L2fileCell = L2chainsVec{a};
    [MATLABdatetime] = double(str2num(['uint64(' nameFileVec{a} ')'])) - double(str2num(['uint64(' firstFile ')']));
    MATLABdatetime = (MATLABdatetime * 1e-7) * 30000;
    
    for b = 1 : length(fileCell);
        chainsCell = fileCell(b);
        L2chainsCell = L2fileCell(b);
        
        if a == 1
            chainsCell.num = chainsCell.num + maxNum;
            chainsCell.times = double(chainsCell.times) + MATLABdatetime;
            L2chainsCell.trueNumber = num2str(L2chainsCell.num);
            L2chainsCell.num = L2chainsCell.num + maxNum;
            L2chainsCell.times = double(L2chainsCell.times) + MATLABdatetime;
       
        else
            chainsCell.num = chainsCell.num + maxNumTmp;
            chainsCell.times = double(chainsCell.times) + MATLABdatetime;
            L2chainsCell.trueNumber = num2str(L2chainsCell.num);
            L2chainsCell.num = L2chainsCell.num + maxNumTmp;
            L2chainsCell.times = double(L2chainsCell.times) + MATLABdatetime;
        end
        
        chainsCell.names = nameFileVec(a);
        chainsMatTotTmp = [chainsMatTotTmp, chainsCell];
        L2chainsMatTotTmp = [L2chainsMatTotTmp, L2chainsCell];
    end
    
    if a == 1
        L2backgroundTimesCell{end+1} = [L2fileCell(end).times + MATLABdatetime];
        
    else
        L2backgroundTimesCell{end+1} = [L2fileCell(end).times + MATLABdatetime];
    end
    
    L2backgroundAmpsCell{end+1} = L2fileCell(end).amps;
    
    if a == length(chainsVec) - 1
        maxNum = max([chainsMatTotTmp.num]) + 1;
        maxNumTmp = maxNum;
    end
    if a ~= length(chainsVec)
        maxNumTmp = max([chainsMatTotTmp.num]) + 1;
    end
    chainsVecTmp{end+1} = chainsMatTotTmp;
    chainsMatTotTmp = [];
end
end