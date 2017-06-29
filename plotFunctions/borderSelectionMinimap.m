function [borderLeft, borderRight, borderUp, borderDown] = borderSelectionMinimap(borderLeft, borderRight, borderUp, borderDown, direction)


moveByTime = 0.2; % Slide minimap viewer by a fraction of xlim
moveByVolts = 0.15; % Slide minimap viewer by a fraction of ylim
moveByHours = ceil((borderRight-borderLeft)*moveByTime);
moveByAmps = ceil((borderUp-borderDown)*moveByVolts*1e5)/1e5;
        
selectTimeMin = borderLeft;
selectTimeMax = borderRight;         
selectAmpMin = borderDown;
selectAmpMax = borderUp;         

switch direction
    case 0 % Zoom in time.
        selectTimeMin = borderLeft + moveByHours;
        selectTimeMax = borderRight - moveByHours;
    case 1 % Zoom out time.
        selectTimeMin = borderLeft - moveByHours;
        selectTimeMax = borderRight + moveByHours;
    case 2 % To left.
        selectTimeMin = borderLeft - moveByHours;
        selectTimeMax = borderRight - moveByHours;
    case 3 % To right.
        selectTimeMin = borderLeft + moveByHours;
        selectTimeMax = borderRight + moveByHours;
    case 4 % Up
        selectAmpMin = borderDown + moveByAmps;
        selectAmpMax = borderUp + moveByAmps;
    case 5 % Down
        selectAmpMin = borderDown - moveByAmps;
        selectAmpMax = borderUp - moveByAmps;        
    case 6 % Zoom in Amps
        selectAmpMin = borderDown + moveByAmps;
        selectAmpMax = borderUp - moveByAmps;        
    case 7 % Zoom out Amps        
        selectAmpMin = borderDown - moveByAmps;
        selectAmpMax = borderUp + moveByAmps;
    case 10 % Stable.        
end

if (selectTimeMin <= 0)
%     selectTimeMin = 1e-5;
end

if (selectTimeMax <= 0)
    selectTimeMax = 1;
end

borderLeft = selectTimeMin;
borderRight = selectTimeMax;
borderUp = selectAmpMax;
borderDown = selectAmpMin;

end