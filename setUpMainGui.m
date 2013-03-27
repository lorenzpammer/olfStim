function setUpMainGui(position)
% setUpMainGui(position) creates the main figure for the GUI using the
% optional argument position. If no position argument is given, a default
% of [360,500,800,360] is assumed.
% The handle structure h is set up and written as appdata 'h' to the figure.
%
%
% lorenzpammer 2012/08
%%
if nargin < 1
    position = [360,500,800,360];
end
%% Set up gui

% Give the gui the tag olfStimGui, which can be used in other functions to
% search for the handle of this figure:
h.guiHandle = figure('Visible','on','Position',position,'NumberTitle','off',...
    'Name','OlfStim', 'Tag', 'olfStimGui','CloseRequestFcn',@myCloseFcn);


% Save the handle for the gui as application data in the gui. In order to
% be able to access the latest handles in subfunctions etc.
setappdata(h.guiHandle, 'h', h);


end

function myCloseFcn(~,~)
% User-defined close request function to display a question dialog box 
   selection = questdlg('Are you sure you want to terminate olfStim without saving?',...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         flush
      case 'No'
      return 
   end
end