function varargout = appdataManager(handle,instruction,varargin)
% appdataToFigureComponent(handle,varargin)
% handle can either be a handle to a figure (component) or a tag name that 
% instructions include:
%    - 'clear' : clears all appdata of the specified figure component.
%    - 'set' : add the appdata (variables) for the specified figure component
%    - 'get' : get the specified appdata (variable names) of the specified
%    figure component 
% varargin - 
%
% lorenzpamemr 2012/08

%%
if nargin < 1
    error('Arguments handle, instruction, data missing.')
elseif nargin < 2
    error('Arguments instruction, data missing.')
    
elseif nargin < 3 && ~strcmp('clear',instruction)
    error('Provide data, that should be written into figure component.')
end


%% Make sure to have the right handle
% See if the provided first argument is a handle to a figure. If it isn't,
% function assumes it's a tagname of a figure component.
if ~all(ishandle(handle))
    % Look for the handle of the tagged object:
    handle = findobj('Tag', handle);
    if isempty(handle)
        warning('problem - GUI gone?');
        varargout={};
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