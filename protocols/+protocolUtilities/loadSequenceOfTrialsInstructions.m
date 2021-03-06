function h = loadSequenceOfTrialsInstructions(h,callbackFunctionName,buttonPosition)
%
%
%
% lorenzpammer september 2012


%% Check inputs & set up position for button

if nargin < 2
    callbackFunctionName = [];
end
if nargin < 3
    % If there is a end session button, put it above that button.
    if isfield(h,'saveSeqOfTrialsInstructions')
        figurePosition = get(h.saveSeqOfTrialsInstructions,'Position');
        buttonWidth = figurePosition(3); buttonHeight = figurePosition(4);
        spacing = 5;
        buttonPosition(1) = figurePosition(1); % [x y width height]
        buttonPosition(2) = figurePosition(2) + figurePosition(4) + spacing;
        buttonPosition(3) = buttonWidth;
        buttonPosition(4) = buttonHeight;
    elseif isfield(h,'startSession') % check whether the start session button exists. Plot above
        figurePosition = get(h.startSession,'Position');
        buttonWidth = figurePosition(3); buttonHeight = figurePosition(4);
        spacing = 5;
        buttonPosition(1) = figurePosition(1); % [x y width height]
        buttonPosition(2) = figurePosition(2) + figurePosition(4) + spacing;
        buttonPosition(3) = buttonWidth;
        buttonPosition(4) = buttonHeight/2;
    elseif isfield(h,'endSession')
        figurePosition = get(h.endSession,'Position');
        buttonWidth = figurePosition(3); buttonHeight = figurePosition(4);
        spacing = 5;
        buttonPosition(1) = figurePosition(1); % [x y width height]
        buttonPosition(2) = figurePosition(2) + figurePosition(4) + spacing;
        buttonPosition(3) = buttonWidth;
        buttonPosition(4) = buttonHeight/2;
    else % create the button in the right bottom corner
        figurePosition = get(h.guiHandle,'Position');
        buttonWidth = 70; buttonHeight = 20;
        spacing = 3;
        buttonPosition(1) = figurePosition(3)- buttonWidth - spacing; % [x y width height]
        buttonPosition(2) = spacing;
        buttonPosition(3) = buttonWidth;
        buttonPosition(4) = buttonHeight;
    end
end

    
    %% Create function handle for the function defined in the argument
    
    functionHandle = str2func(callbackFunctionName);
   
    %% Set up Load sequence of trials instructions button
    
    h.loadSeqOfTrialsInstructions = uicontrol('Parent',h.guiHandle,'Style','pushbutton',...
        'String','Load seq','Units','pixels','Position',buttonPosition,...
        'Callback',{functionHandle,callbackFunctionName});


end