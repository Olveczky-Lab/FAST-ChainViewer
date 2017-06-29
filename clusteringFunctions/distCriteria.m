function [distCriteria] = distCriteria(links)
distCriteria = (links(:, 3) ./  ((links(:, 4) + links(:, 5)) / 2));
