function h = endSession(h,callbackFunctionName,buttonPosition)
% endSession(h,callbackFunctionName,buttonPosition)
% This function will end the execution of the startSessionCallback.
% It will delete all 
%
% lorenzpammer september 2012


%%
if nargin < 2
    error('Provide callbackfunction')
end
if nargin < 3
    figurePosition = get(h.guiHandle,'Position');
       buttonWidth = 70; buttonHeight = 50;
       spacing = 3;
       buttonPosition(1) = figurePosition(3)- buttonWidth - spacing; % [x y width height]
       buttonPosition(2) = spacing;
       buttonPosition(3) = buttonWidth;
       buttonPosition(4) = buttonHeight;
end

    
    %% Create function handle for the function defined in the argument
    
    functionHandle = str2func(callbackFunctionName);
   
    %% Set up End session button
    
    h.endSession = uicontrol('Parent',h.guiHandle,'Style','togglebutton',...
        'String','End session','Units','pixels','Position',buttonPosition,...
        'Callback',{functionHandle,callbackFunctionName},'backgroundColor',[1 0 0]);
end