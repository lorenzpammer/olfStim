function h = startSession(h,callbackFunctionName,buttonPosition)
%
%
%
% lorenzpammer 2011


%% 
    if nargin < 2
      callbackFunctionName = [];
    elseif nargin < 3
        % If there is a end session button, put it above that button.
        figurePosition = get(h.endSession,'Position');
        buttonWidth = figurePosition(3); buttonHeight = figurePosition(4);
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
        'String','Start session','Units','pixels','Position',buttonPosition,...
        'backgroundcolor',[0 1 0],'Callback',{functionHandle,callbackFunctionName});


end