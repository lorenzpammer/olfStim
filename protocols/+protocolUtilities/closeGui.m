function h = closeGui(h,buttonPosition)
% closeGui(h,buttonPosition) closes gui without saving
%
% 

%% Check inputs
if nargin < 2
    % Define Position
    stimProtocolPosition = get(h.panelProtocolChooser,'Position');
    buttonHeight = 25; buttonWidth = stimProtocolPosition(3);
    buttonPosition(1) = stimProtocolPosition(1);
    buttonPosition(2) = 5;
    buttonPosition(3) = buttonWidth;
    buttonPosition(4) = buttonHeight;
end
%% Set up the push button:
h.closeGuiButton = uicontrol('Style','Pushbutton',...
    'String','Close GUI','Units','pixels','Position',buttonPosition,'Callback',@pushButton_Callback);

% Following commands set up a 3D matrix: 3 entries for every pixel of the
% pushbutton. [1 0 0] in RGB is red
colorMatrix(:,:,1) = ones(buttonHeight,buttonWidth);
colorMatrix(:,:,2) = zeros(buttonHeight,buttonWidth);
colorMatrix(:,:,3) = zeros(buttonHeight,buttonWidth);
set(h.closeGuiButton,'CData',colorMatrix) % set color of push button to color defined in colorMatrix


end

function pushButton_Callback(source,eventdata)
    disp('To do: Close Gui function')
end