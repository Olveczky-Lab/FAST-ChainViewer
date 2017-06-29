function [borderLeft, borderRight, borderUp, borderDown] = borderScrollMinimap(borderLeft, borderRight, borderUp, borderDown, scroll, mouse)


moveByTime = 0.2; % Slide minimap viewer by a fraction of xlim
moveByVolts = 0.2; % Slide minimap viewer by a fraction of ylim

% separately for x and y axes
% Scrolling down gives a positive scroll value - should zoom out
% Scrolling up gives a negative scroll value - should zoom in

% X axis (Time)
% First check if mouse position is within xlims
if mouse(1) >= borderLeft && mouse(1) <= borderRight
    borderRight = borderRight + scroll*(borderRight-mouse(1))*moveByTime;
    borderLeft = borderLeft - scroll*(mouse(1)-borderLeft)*moveByTime;    
end


% Y axis (Amps)
% Check if mouse position is within ylims
if mouse(2) >= borderDown && mouse(2) <= borderUp
    borderUp = borderUp + scroll*(borderUp-mouse(2))*moveByVolts;
    borderDown = borderDown - scroll*(mouse(2)-borderDown)*moveByVolts;    
end

borderRight = ceil(borderRight);
borderLeft = floor(borderLeft);
borderUp = ceil(borderUp*1e5)/1e5;
borderDown = floor(borderDown*1e5)/1e5;


if borderLeft <= 0
%     borderLeft = 1e-5;
end

if borderRight <= 0
    borderRight = 1;
end

end