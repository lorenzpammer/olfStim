function h = pauseSession(h,instruction,callbackFunctionName,buttonPosition)
% pauseSession(h,instruction,callbackFunctionName,buttonPosition)
% This function will pause the execution of the startSessionCallback.
% However be aware, that it will have some non-intended behaviors:
% In the smell structure the field interTrialInterval will not be updated.
% However the time of start of trial will be updated.
%
% lorenzpammer september 2012


%% 
if nargin < 2
    error('Provide instructions')
    if nargin < 3
      callbackFunctionName = [];
    elseif nargin < 4
       figurePosition = get(h.startSession,'Position');
    end
    
    %% Create function handle for the function defined in the argument
    
    functionHandle = str2func(callbackFunctionName);
   
    %% Set up pause session button
    
    h.pauseSession = uicontrol('Parent',h.guiHandle,'Style','togglebutton',...
        'String','Pause','Units','pixels','Position',buttonPosition,'Callback',functionHandle);
    % Following commands set up a 3D matrix: 3 entries for every pixel of the
    % pushbutton. [1 0 0] in RGB is red
    colorMatrix(:,:,1) = ones(buttonHeight,buttonWidth);
    colorMatrix(:,:,2) = zeros(buttonHeight,buttonWidth);
    colorMatrix(:,:,3) = zeros(buttonHeight,buttonWidth);
    set(h.pauseSession,'CData',colorMatrix) % set color of push button to color defined in colorMatrix

end