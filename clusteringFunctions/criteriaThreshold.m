function [distCriteria] = criteriaThreshold(links)
% This function allows to determine the distance criteria.

distCriteria = (links(:, 3) / (links(:, 4) + links(:, 5)) / 2)) * log(links(:, 7));

end
