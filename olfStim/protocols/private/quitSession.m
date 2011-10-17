function quitSession(buttonPosition)

global h


%% 
    if nargin < 1
       figurePosition = get(h.guiHandle,'Position');
       buttonWidth = 70; buttonHeight = 50;
       spacing = 3;
       buttonPosition(1) = figurePosition(3)- buttonWidth - spacing; % [x y width height]
       buttonPosition(2) = spacing;
       buttonPosition(3) = buttonWidth;
       buttonPosition(4) = buttonHeight;
    end
    h.quitSession = uicontrol('Parent',h.guiHandle,'Style','togglebutton',...
        'String','Quit','Units','pixels','Position',buttonPosition,'Callback',@quitPushButton_Callback);
    % Following commands set up a 3D matrix: 3 entries for every pixel of the
    % pushbutton. [1 0 0] in RGB is red
    colorMatrix(:,:,1) = ones(buttonHeight,buttonWidth);
    colorMatrix(:,:,2) = zeros(buttonHeight,buttonWidth);
    colorMatrix(:,:,3) = zeros(buttonHeight,buttonWidth);
    set(h.quitSession,'CData',colorMatrix) % set color of push button to color defined in colorMatrix

end

function quitPushButton_Callback(source,eventdata)
    disp('To do: Close Gui function')
    % Disconnect from olfactometer
    % Round up smell structure
    % save smell structure
    

end
