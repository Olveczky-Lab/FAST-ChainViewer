function chainsWind = findChainsWind(chainsMatTot, channel, borderLeft, borderRight, borderUp, borderDown)

% This version checks if any chain centroid is within the minimap window

allCentroids = vertcat(chainsMatTot(1:end-1).centroid);

allCentroids = allCentroids(:, [1 channel+1]);
allCentroids(:,2) = allCentroids(:,2) * 1.95e-7;

keep = false(size(chainsMatTot));
keep(1:end-1) = allCentroids(:,1) >= borderLeft & allCentroids(:,1) <= borderRight & allCentroids(:,2) >= borderDown & allCentroids(:,2) <= borderUp;
chainsWind = chainsMatTot(keep);


% This version checks if any L2 spike is within the minimap window
% 
% keep = false(size(chainsMatTot));
% for c = 1 : length(chainsMatTot)-1
%     times = chainsMatTot(c).times;
%     amps = chainsMatTot(c).amps;
%     amps = double(amps(:,channel))*1.95e-7;
%     
%     if any(times >= borderLeft & times <= borderRight & amps >= borderDown & amps <= borderUp)
%         keep(c) = true;
%     end
% end
% 
% chainsWind = chainsMatTot(keep);