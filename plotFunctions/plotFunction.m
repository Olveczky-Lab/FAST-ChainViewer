function plotFunction(type, chainsToPlot, channel, handles, channel_4_1, channel_4_2)
% This function allows to plot the information in function of the chosen
% mode : chains, energy, waveforms, pca.
cla(handles.axes2);
axes(handles.axes2);

v1 = num2str(type(1));
v2 = num2str(type(2));
v3 = num2str(type(3));
v4 = num2str(type(4));
v5 = num2str(type(5));
v6 = num2str(type(6));
v7 = num2str(type(7));
type = [v1 v2 v3 v4 v5 v6 v7];

features = [chainsToPlot.features];

switch type
    % Amplitudes.
    case '1000000'
        featureToPlot = double(vertcat(chainsToPlot.amps)) * 1.95e-7;
        
    % Energy.
    case '0100000'
        featureToPlot = double(vertcat(features.energy)) * 1.95e-7;
        
    % Waveforms. 
    case '0010000'     
        featureToPlot = [];
        
        plotSpikeWaveforms(chainsToPlot);
        
        cla(handles.axes4);
        axes(handles.axes4);
        plotSpikeWaveforms(chainsToPlot)
        
    %PCA.
    case '0001000'
        featureToPlot = vertcat(features.pc1);
        
    case '0000001'
        featureToPlot = vertcat(features.pc2);    
        
    % Valley
    case '0000100'
        featureToPlot = vertcat(features.valley);
        
    % Width
    case '0000010'
        featureToPlot = vertcat(features.width);
end

if ~isempty(featureToPlot)

    hold all;
    for a = 1 : length(chainsToPlot)
        chainsToPlot(a).color = repmat(chainsToPlot(a).color, length(chainsToPlot(a).times), 1);
    end
    
    % Plot Chains versus time
    scatter(vertcat(chainsToPlot.times), featureToPlot(:,channel), 30, vertcat(chainsToPlot.color),'.'); 
    ylabel(['Ch ' num2str(channel)]);
    xlabel(['Time']);
    xlim auto; ylim auto;
    
    % Plot chain feature versus chain feature
    cla(handles.axes4);
    axes(handles.axes4);
    
    scatter(featureToPlot(:,channel_4_1), featureToPlot(:,channel_4_2), 30, vertcat(chainsToPlot.color),'.'); 
    ylabel(['Ch' num2str(channel_4_2)]);
    xlabel(['Ch' num2str(channel_4_1)]);
    xlim auto; ylim auto;

end



