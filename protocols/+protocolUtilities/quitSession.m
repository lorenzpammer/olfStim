function h = quitSession(h,buttonPosition)
%
%
%
% lorenzpammer 2011


%% 
if nargin < 2
    stimProtocolPosition = get(h.panelProtocolChooser,'Position');
    guiPosition = get(h.guiHandle,'Position');
    spacing = 5;
    buttonHeight = 25; 
    buttonWidth = stimProtocolPosition(3);
    buttonPosition(1) = stimProtocolPosition(1);
    buttonPosition(2) = spacing;
    buttonPosition(3) = buttonWidth;
    buttonPosition(4) = buttonHeight;
end
h.quitSession = uicontrol('Parent',h.guiHandle,'Style','pushbutton',...
    'String','Quit & Save','Units','pixels','Position',buttonPosition,...
    'BackgroundColor',[1 0 0],'Callback',@quitPushButton_Callback);


end

function quitPushButton_Callback(source,eventdata)
global smell
% Disconnect from olfactometer
% Round up smell structure
% save smell structure

callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function
olfStimPath = which(callingFunctionName);
olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];
olfStimPath=[olfStimPath filesep 'User Data' filesep 'data' filesep];
clear callingFunctionName

defaultTitle = [datestr(date,'yyyy.mm.dd') '_smell'];
% check if file with same name already exists

[filename,pathname]=uiputfile('.mat','Save session data',[olfStimPath defaultTitle]);
if ischar(filename) && ischar(pathname) % only if filename and path specified
    extendedPath = [pathname filename];
    save(extendedPath,'smell')
    
    olfStimFlush
else
    disp('To save the session data please select a filename and path.')
end

end
