function [uncompatibleList] = scoreTemp(compatibleList, tempParameter)
% This function allows to return the selected parterns in function of a
% temperature parameter.

vecScore = [];

for element = 1 : length(compatibleList)
    vecScore = [vecScore, compatibleList{element}(3)]; %log(compatibleList{element}(3)
end

scoreSelected = [];
uncompatibleList = {};

resultVec = [];
maxScore = max(vecScore);
for one = 1 : length(vecScore)
    % Determination of the score.
    score = (exp(vecScore(one) / tempParameter)) / (sum(exp(vecScore(:) / tempParameter)));
    resultVec = [resultVec, score];
    
    % Selection of the score if it is higher than the threshold (1/n)
    if score < 1 / length(vecScore)
        uncompatibleList{end + 1} = compatibleList{one};
    end
    if vecScore(one) == maxScore
        indice = one;
    end
end

if sum(isnan(resultVec)) > 0
    uncompatibleList = compatibleList(linspace(1, length(compatibleList), length(compatibleList)) ~= indice);
end

end

