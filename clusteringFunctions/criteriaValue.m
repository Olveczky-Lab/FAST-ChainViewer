function [criteria] = criteriaValue(links, distWeight, corrWeight, isiWeight, distExp, corrExp, isiExp)
% This function allows to comput the criteria value for a couple of chains.
%% 1
distCriteria = (1 / distWeight) * (links(:, 11)) .^ (distExp);
corrCriteria = corrWeight * (links(:, 6)) .^ corrExp;
isiCriteria = isiWeight * (links(:, 10)) .^ isiExp;

if isnan(links(:, 10)) == 1
    isiCriteria = 0;
end

criteria = (1 ./ distCriteria) + corrCriteria + isiCriteria;
% end

%% 2
% rowObj = linksMatrix(:, 1);
% 
% for row = 1 : size(links, 1)
%     indices = find(rowObj == rowObj(row));
%     
%     distCriteria = (1 / distWeight) * (links(row, 11) / mean(links(indices, 11))) .^ (distExp);
%     corrCriteria = corrWeight * (links(row, 6) / mean(links(indices, 6))) .^ corrExp;
%     isiCriteria = isiWeight * (links(row, 10) / mean(links(indices, 10))) .^ isiExp;
%     
%     if isnan(links(:, 10)) == 1
%         isiCriteria = 0;
%     end
%     
%     indices = find(rowObj == rowObj(row));
%     criteria = (1 ./ (distCriteria)) + corrCriteria + isiCriteria;
% end

    
    
    