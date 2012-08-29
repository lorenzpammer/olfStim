function selectedProtocol = protocolChooserSubGui

% lorenzpammer 2011/09


global selectedProtocol

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%%

% Construct the components of the gui.
position = get(h.guiHandle,'Position');
guiHeight = position(4);
panelHeight = 130;
panelPosition = [5,guiHeight-100-panelHeight-5,110,panelHeight]; % The PresentedOdors panel which will be added later to the figure is 100 pixels high.
h.panelProtocolChooser = uipanel('Parent',h.guiHandle,'Title','Stim Protocols',...
    'FontSize',8,'TitlePosition','centertop',...
    'Units','pixels','Position',panelPosition);
clear guiHeight;clear panelHeight;

buttonWidth = 70;buttonHeight = 25;
buttonPosition(1) = panelPosition(1) + (panelPosition(3)/2) - buttonWidth/2;
buttonPosition(2) = panelPosition(2) +3;
buttonPosition(3:4) = [buttonWidth,buttonHeight];
h.start    = uicontrol('Style','pushbutton',...
    'String','Start','Units','pixels','Position',buttonPosition,'Callback',@startbutton_Callback);
% Following commands set up a 3D matrix: 3 entries for every pixel of the
% pushbutton. [0 1 0] in RGB is green
colorMatrix(:,:,1) = zeros(buttonHeight,buttonWidth);
colorMatrix(:,:,2) = ones(buttonHeight,buttonWidth);
colorMatrix(:,:,3) = zeros(buttonHeight,buttonWidth);
set(h.start,'CData',colorMatrix) % set color of push button to color defined in colorMatrix
clear buttonHeight;clear buttonWidth;clear buttonPosition;
clear colorMatrix

% Define path to protocols relatively to the initiation function for
% olfactometer control software
callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function in the highest
path = which(callingFunctionName);
path(length(path)-length(callingFunctionName):length(path))=[];
path=[path filesep 'protocols'];
clear callingFunctionName

counter=0;
protocolFolderEntries = dir(path);
for i = 1 : length(protocolFolderEntries)
    try
        if strcmp(protocolFolderEntries(i).name(end-3:end),'Stim')
            counter=counter+1;
            protocols{counter}=protocolFolderEntries(i).name(2:end);
        end
    catch
    end
end
clear protocolFolderEntries;clear i;clear counter;

popupWidth = 100;popupHeight = 25;
popupPosition(1) = panelPosition(1) + (panelPosition(3)/2) - popupWidth/2;
popupPosition(2) = panelPosition(2) + (panelPosition(4)/2) - popupHeight/2;
popupPosition(3:4) = [popupWidth,popupHeight];
h.popupProtocols = uicontrol('Style','popupmenu',...
    'String',protocols,...
    'Position',popupPosition,'Callback',@popup_menu_Callback); % 'Position',[x y width height]

popupPosition(2) = popupPosition(2) + popupPosition(4);
popupPosition(4) = 15;
h.staticText.popup = uicontrol('Style','text','String','Select Protocol',...
    'Position',popupPosition);
% align([h.start,h.popupProtocols,h.popupText],'Left','None');
clear position; clear popupWidth;clear popupHeight;clear popupPosition;
clear panelPosition;

%% Update h structure in the appdata

% Write the structure h containing all handles for the figure as appdata:
appdataManager('olfStimGui','set',h)


%%
uiwait % keeps function active until start pushbutton is pressed
end

%  Pop-up menu callback. Read the pop-up menu Value property to
%  determine which item is currently displayed and make it the
%  current data. This callback automatically has access to
%  current_data because this function is nested at a lower level.
function popup_menu_Callback(source,eventdata,h)
global selectedProtocol

%         Determine the selected data set.
str = get(source, 'String');
val = get(source,'Value');
selectedProtocol = str{val};
clear str;clear val;
%         % Set current data to the selected data set.
%         switch str{val};
%             case 'Peaks' % User selects Peaks.
%                 current_data = peaks_data;
%             case 'Membrane' % User selects Membrane.
%                 current_data = membrane_data;
%             case 'Sinc' % User selects Sinc.
%                 current_data = sinc_data;
%         end
end

function startbutton_Callback(source,eventdata)
% Determine the selected data set.
global selectedProtocol

if ~isempty(selectedProtocol)
    uiresume
else
    warning('Choose stimualation protocol.')
end
%         functionHandle = str2func(selectedProtocol);
%         functionHandle();
end

