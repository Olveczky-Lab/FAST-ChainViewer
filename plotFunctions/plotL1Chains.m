function plotL1Chains(chains, chainNums, colors)


figure(2);
clf;
for x = 1 : length(chains)
    plot3(chains(x).times, chains(x).amps(:,1), chains(x).amps(:,2),'.', 'markersize', 3, 'DisplayName', chains(x).num, 'color', colors(x,:)); 
    ylabel('Ch1'); zlabel('Ch2'); xlabel('Time');
    hold all    
end
title(['Chains ' num2str(chainNums)]);
% plot3(chainsBG.times, chainsBG.amps(:,1), chainsBG.amps(:,2),'.', 'markersize', 3, 'DisplayName', 'BG', 'color', [0.5 0.5 0.5]); 

figure(3);
clf;
for x = 1 : length(chains)
    plot3(chains(x).times, chains(x).amps(:,3), chains(x).amps(:,4),'.', 'markersize', 3, 'DisplayName', chains(x).num, 'color', colors(x,:)); 
    ylabel('Ch3'); zlabel('Ch4'); xlabel('Time');
    hold all
end
title(['Chains ' num2str(chainNums)]);
% plot3(chainsBG.times, chainsBG.amps(:,3), chainsBG.amps(:,4),'.', 'markersize', 3, 'DisplayName', 'BG', 'color', [0.5 0.5 0.5]); 

