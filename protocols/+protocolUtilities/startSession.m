function h = startSession(h,callbackFunctionName,buttonPosition)
%
%
%
% lorenzpammer 2011


%% 
    if nargin < 2
      callbackFunctionName = [];
    elseif nargin < 3
       figurePosition = get(h.quitSession,'Position');
       buttonWidth = 70; buttonHeight = 50;
       spacing = 5;
       buttonPosition(1) = figurePosition(1); % [x y width height]
       buttonPosition(2) = figurePosition(2) + figurePosition(4) + spacing;
       buttonPosition(3) = buttonWidth;
       buttonPosition(4) = buttonHeight;
    end
    
    %% Create function handle for the function defined in the argument
    
    functionHandle = str2func(callbackFunctionName);
   
    %% Set up Start session button
    
    h.startSession = uicontrol('Parent',h.guiHandle,'Style','togglebutton',...
        'String','Start session','Units','pixels','Position',buttonPosition,'Callback',functionHandle);
    % Following commands set up a 3D matrix: 3 entries for every pixel of the
    % pushbutton. [1 0 0] in RGB is red
    colorMatrix(:,:,1) = zeros(buttonHeight,buttonWidth);
    colorMatrix(:,:,2) = ones(buttonHeight,buttonWidth);
    colorMatrix(:,:,3) = zeros(buttonHeight,buttonWidth);
    set(h.startSession,'CData',colorMatrix) % set color of push button to color defined in colorMatrix

end

% function startSessionPushButton_Callback(source,eventdata)
% global smell
% % Disconnect from olfactometer
% % Round up smell structure
% % save smell structure
% 
% callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function
% olfStimPath = which(callingFunctionName);
% olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];
% olfStimPath=[olfStimPath '/data/'];
% clear callingFunctionName
% 
% defaultTitle = [datestr(date,'yyyy.mm.dd') '_smell'];
% % check if file with same name already exists
% 
% [filename,pathname]=uiputfile('.mat','Save session data',[olfStimPath defaultTitle]);
% if ischar(filename) && ischar(pathname) % only if filename and path specified
%     extendedPath = [pathname filename];
%     save(extendedPath,'smell')
%     
%     flush
% else
%     disp('To save the session data please select a filename and path.')
% end
% 
% end