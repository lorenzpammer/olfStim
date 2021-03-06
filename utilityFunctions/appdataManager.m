function varargout = appdataManager(handle,instruction,varargin)
% appdataToFigureComponent(handle,varargin)
% handle can either be a handle to a figure (component) or a tag name that 
% instructions include:
%    - 'clear' : clears all appdata of the specified figure component.
%    - 'set' : add the variables provided as input to the funciton to the
%       specified figure component
%    - 'get' : get the specified variable (specify name of variable in form
%    of a string) from the specified figure component 
%
% lorenzpammer 2012/08

%% Check inputs
if nargin < 1
    error('Arguments handle, instruction, data missing.')
elseif nargin < 2
    error('Arguments instruction, data missing.')
    
elseif nargin < 3 && ~strcmp('clear',instruction)
    error('Provide data, that should be written into figure component.')
end

global olfStimScriptMode

%% Check if we're in scripting mode
% If we're in scripting mode, return an empty variable

if olfStimScriptMode
   varargout = cell(1);
   return
end

%% Make sure to have the right handle
% See if the provided first argument is a handle to a figure. If it isn't,
% function assumes it's a tagname of a figure component.
if ~all(ishandle(handle))
    % Look for the handle of the tagged object:
    handle = findobj('Tag', handle);
    if isempty(handle)
        warning('problem - GUI gone?');
        varargout = cell(1);
        return;
    end
end

%% Interact with the gui component to set or get appdata

if strcmp(instruction,'set')
    for i = 1 : length(varargin)
        % Save the handle for the gui as application data in the gui. In order to
        % be able to access the latest handles in subfunctions etc.
        setappdata(handle, inputname(i+2), varargin{i});
    end
elseif strcmp(instruction,'get')
    for i = 1 : length(varargin)
        % Save the handle for the gui as application data in the gui. In order to
        % be able to access the latest handles in subfunctions etc.
        varargout{i} = getappdata(handle, varargin{i});
    end
elseif strcmp(instruction,'clear')
    rmappdata(handle,getappdata(handle));
end
    
end