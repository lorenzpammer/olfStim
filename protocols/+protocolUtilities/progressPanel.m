function h=progressPanel(h,instruction,trialOdor,trialNum,varargin)
% progressPanel(h,instruction,trialNum,'PropertyName','PropertyValue) builds a panel in the gui where
% current and previous odor presentations are plotted.
% instruction expects a string either 
%   - 'setUp' or 
%   - 'update'. Depending on whether the presented odors panel should be set
%        up (when building the gui) or whether a new odor has been presented.
%   - 'remove' if some of the plotted progress should be removed. Requires
%      further information: 'numberOfTrialsToRemove' followed by number.
%   - 'updateLimits' - 
%
% Property names:
% - position: position of the progress panel
% - color: color of the update fields
% - 'numberOfTrialsToRemove': as the name says, # of trials to remove from
%    progress figure
% - 'numberOfTrialsShown' - Define the number of trials that should be
%    shown by default
%
% lorenzpammer 2011/09
%%

global smell

%%

if nargin<1
    error('Not enough input arguments.')
elseif nargin<2
    error('Not enough input arguments.')
elseif nargin<3 && strcmp(instruction,'update')
    error('Not enough input arguments.')
elseif nargin<4
    position = get(h.guiHandle,'Position'); % get position of main gui window
    panelWidth=position(3)-10; panelHeight = 100; % set the width and height of the progress panel
    panelPosition =[5 position(4)-panelHeight panelWidth panelHeight]; % set the position vector for the progress panel
    color =  [1.0000    0.8000    0.2000];
end

% Extract the property names and values, provided as input by the user.
% If none are provided, define defaults.
index = find(strcmpi('position',varargin));
if ~isempty(index)
    position = varargin{index+1};
else
    % Define default position:
    position = get(h.guiHandle,'Position'); % get position of main gui window
    panelWidth=position(3)-10; panelHeight = 100; % set the width and height of the progress panel
    panelPosition =[5 position(4)-panelHeight panelWidth panelHeight]; % set the position vector for the progress panel
end

index = find(strcmpi('color',varargin));
if ~isempty(index)
    color = varargin{index+1};
else
    % Define a default color, here orange:
    color =  [1    0.9922    0.8980];
end

index = find(strcmp('numberOfTrialsShown',varargin));
if ~isempty(index)
    numberOfTrialsShown = varargin{index+1};
else
    % Define 10 trials as a default
    numberOfTrialsShown = 10;
end


%% Setting up the progress panel
% When setting up the gui the following lines are called
if strmatch(instruction,'setUp')
    
    % Set up the progress panel
    h.progress.panel = uipanel('Parent',h.guiHandle,'Title','Presented Odors',...
        'Tag','progressPanel','FontSize',8,'TitlePosition','centertop',...
        'Units','pixels','Position',panelPosition); % 'Position',[x y width height] 
    h.progress.figure = axes('Parent',h.progress.panel,'Units','Pixels');
    figurePosition(1) = 5; % Set the x position of the progress figure
    figurePosition(2) = 15; % Set the y position of the progress figure
    figurePosition(3) = panelPosition(3)-50; % Set the width of the progress figure
    figurePosition(4) = panelPosition(4)-32; % Set the height of the progress figure
    % Set up the figure where progress gets plotted
    set(h.progress.figure,'Ytick',[],'Xtick',(0:10000),'Fontsize',8,'Color',[0.8 0.8 0.8])
    set(h.progress.figure,'Position',figurePosition)
    xlim(h.progress.figure,[0 numberOfTrialsShown]+0.5); ylim(h.progress.figure,[0 1])
    
    % Set up some controls for zooming in, zooming out and moving the limits
    pushButtonPosition(3:4) = [20 20];
    pushButtonPosition(1) = figurePosition(1)+figurePosition(3) + ((panelPosition(3)-figurePosition(1)-figurePosition(3)) / 2 - pushButtonPosition(3)/2);
    pushButtonPosition(2) = figurePosition(2)+figurePosition(4) - pushButtonPosition(4);
    h.progress.zoomIn = uicontrol('Parent',h.progress.panel,'Style','pushbutton',...
        'Position', pushButtonPosition,'String','+','Callback',@zoomIn);
    pushButtonPosition(1:2) = [pushButtonPosition(1) pushButtonPosition(2)-pushButtonPosition(4)-5];
    h.progress.zoomOut = uicontrol('Parent',h.progress.panel,'Style','pushbutton',...
        'Position',pushButtonPosition,'String','-','Callback',@zoomOut);
    
    pushButtonPosition(1) = (pushButtonPosition(1)+pushButtonPosition(3)/2);
    pushButtonPosition(3:4) = [15 20];
    pushButtonPosition(1) = pushButtonPosition(1) - pushButtonPosition(3) - 2.5;
    pushButtonPosition(2) = pushButtonPosition(2)-pushButtonPosition(4)-5;
    h.progress.shiftLeft = uicontrol('Parent',h.progress.panel,'Style','pushbutton',...
        'Position',pushButtonPosition,'String','<','Callback',@shiftLeft);
    pushButtonPosition(1) = [pushButtonPosition(1)+pushButtonPosition(3)+5];
    h.progress.shiftRight = uicontrol('Parent',h.progress.panel,'Style','pushbutton',...
        'Position',pushButtonPosition,'String','>','Callback',@shiftRight);
end


%% Updating the progress panel for every trial
% Every trial the progress panel is updated
% A new rectangle with the name of the odor and the concentration is
% plotted in the presented odors figure (progressFigure).

if strmatch(instruction,'update')
    xPosition = trialNum-0.45;
    yPosition = 0.25;
    width=0.9;height = 0.5;
    rectangle('Parent',h.progress.figure,'Position',[xPosition yPosition width height],'FaceColor',color); % plot rectangle in 
    if ~trialOdor.mixture % for normal odors
        display = sprintf([trialOdor.odorName '\nc=' num2str(trialOdor.concentrationAtPresentation)]);
        text(xPosition+0.03,yPosition+0.2,display,'Fontsize',8)
    else % for mixtures
        display{1} = [trialOdor.odorName{1} ' ' num2str(trialOdor.concentrationAtPresentation{1})];
        display{2} = sprintf([trialOdor.odorName{2} '\nc=' num2str(trialOdor.concentrationAtPresentation{2})]);
        text(xPosition+0.03,yPosition+0.2,display,'Fontsize',8)
    end
    limits = get(h.progress.figure,'xlim');
    numberOfTrialsShown = round(limits(2)-limits(1));
    if trialNum>numberOfTrialsShown
        xlim(h.progress.figure,[trialNum-numberOfTrialsShown trialNum] + 0.5)
    end
end

%% Deleting progress from progress figure

if strmatch(instruction,'remove')
    % Extract relevant properties 
    index = find(strcmpi('numberOfTrialsToRemove',varargin));
    if ~isempty(index)
        numberOfTrialsToRemove = varargin{index+1};
    else
        error('Number of trials which should be removed from the progress figure are not specified.')
    end
    
    plottedProgress = get(h.progress.figure,'Children');
    % The first children in the axes have been constructed last. Each
    % plotted trial consists of two entities: the rectangle and the string.
    % Delete both (=> multiply the number by 2)
    delete(plottedProgress(1:numberOfTrialsToRemove*2));
    
end

%% Redefining axis limits

if strmatch(instruction,'updateLimits')
    
   
end


end

function zoomIn(~,~)
% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');
currentXlim = get(h.progress.figure,'xlim');

if currentXlim(1) < 1
    currentXlim(2) = currentXlim(2) - 2;
else
    currentXlim(1) = currentXlim(1) + 1;
    currentXlim(2) = currentXlim(2) - 1;
end
xlim(h.progress.figure,currentXlim)

% 
% if currentXlim(1) < currentXlim(2)
%     xlim(h.progress.figure,currentXlim)
% end
end

function zoomOut(~,~)
% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');
currentXlim = get(h.progress.figure,'xlim');

if currentXlim(1) < 1
    currentXlim(2) = currentXlim(2) + 2;
else
    currentXlim(1) = currentXlim(1) - 1;
    currentXlim(2) = currentXlim(2) + 1;
end
xlim(h.progress.figure,currentXlim)

% % Get plotted trials from figure:
% plotHandles = get(h.progress.figure,'Children');
% plots=get(plotHandles,'Position');
% if isempty(plots)
%     currentXlim(2) = currentXlim(2) + 2;
% else
%     % The rectangle of the last plotted trials is always in plots{2}. In
%     % plots{2}(1) is the x position of the plotted rectangle. Ceiling this
%     % value gives us the trial number:
%     lastPlot = ceil(plots{2}(1));
% end
end

function shiftLeft(~,~)
% Shift left by half the current xlim range
% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');
currentXlim = get(h.progress.figure,'xlim');
% Calculate the range of trials currently plotted. Half of that range is
% the value to shift:
shiftValue = (currentXlim(2)-currentXlim(1))/2;
xlim(h.progress.figure,currentXlim-shiftValue)
end

function shiftRight(~,~)
% Shift right by half the current xlim range
% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');
currentXlim = get(h.progress.figure,'xlim');
% Calculate the range of trials currently plotted. Half of that range is
% the value to shift:
shiftValue = (currentXlim(2)-currentXlim(1))/2;
xlim(h.progress.figure,currentXlim+shiftValue)
end