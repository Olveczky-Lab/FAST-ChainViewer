function [x,y] = DrawConvexHull

dcm = datacursormode(gcf);
datacursormode off;
dcm.removeAllDataCursors()

oldLineHandle = findobj(gcf, 'type', 'line');
delete(oldLineHandle);

% [x,y] = DrawConvexHull
% allows the user to draw a convex hull on the current axis
% and returns the x,y points on that hull
%
% ADR 1998
% Status PROMOTED
% version V4.1
%
% RELEASED as part of MClust 2.0
% See standard disclaimer in Contents.m
% 
% ADR fixed to handle empty inputs

% Modified to show convex hull boundaries while drawing. (B. Hangya, CSHL;
% balazs.cshl@gmail.com)

usemycode = 1;
% global MClust_Colors


if usemycode
    iClust = get(gcbo,'UserData') + 1;
%     clr = MClust_Colors(iClust,:);
     clr = [0,0,0];
    pointcntr = 0;
    isenter = 0;
    A = gca;
    F = gcf;
    set(F,'Pointer','arrow')
    
    % Remove ButtonDownFcn
    bdf = get(A,'ButtonDownFcn');
    set(A,'ButtonDownFcn',[])
    set(allchild(A),'ButtonDownFcn',[])
    
    % Draw polygon
    seltyp = get(F,'SelectionType');  % click type
    if isequal(seltyp,'normal') || pointcntr == 0;
        point1 = get(A,'CurrentPoint'); % button down detected
        point1x = point1(1,1);
        point1y = point1(1,2);
        point0x = point1(1,1);
        point0y = point1(1,2);
        L = [];
        bp = 1;
        while bp
            bp = waitforbuttonpress;    % wait for mouse click
            if ~isequal(gcf,F)      % the user clicked on another figure window
                x = [];
                y = [];
                return
            end
        end
        seltyp2 = get(F,'SelectionType');  % click type
        while isequal(seltyp2,'normal') && ~isenter
            point2 = get(A,'CurrentPoint'); % button down detected
            point2x = point2(1,1);
            point2y = point2(1,2);
            if pointcntr > 0
                L(end+1) = line([point1x point2x],[point1y point2y],'Color',clr,'LineWidth',1);
            end
            point0x = [point0x point2x];
            point0y = [point0y point2y];
            pointcntr = pointcntr + 1;
            point1x = point2x;
            point1y = point2y;
            bp = 1;
            while bp
                bp = waitforbuttonpress;    % wait for mouse click
                if ~isequal(gcf,F)      % the user clicked on another figure window
                    x = [];
                    y = [];
                    return
                end
                cchar = get(F,'CurrentCharacter');
                if bp && isequal(double(cchar),13)    % Enter pressed
                    bp = 0;
                    isenter = 1;
                end
            end
            seltyp2 = get(F,'SelectionType');  % click type
        end
        L(end+1) = line([point2x point0x(2)],[point2y point0y(2)],'Color',clr,'LineWidth',1);
    end
    x = point0x(2:end);
    y = point0y(2:end);
    
    % Restore ButtonDownFcn
    set(A,'ButtonDownFcn',bdf)
    set(allchild(A),'ButtonDownFcn',bdf)
    
    % delete(L)   % delete lines
else
    [x,y] = ginput;
    if isempty(x) || isempty(y)
        return
    end
end

if length(x) < 3    % no convex hull
    x = [];
    y = [];
    return
end

% x
% y
% 
% k = convexhull(x,y);
% x = x(k);
% y = y(k);