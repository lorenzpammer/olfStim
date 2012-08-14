function h=progressPanel(h,instruction,trialOdor,trialNum,varargin)
% progressPanel(h,instruction,trialNum,'PropertyName','PropertyValue) builds a panel in the gui where
% current and previous odor presentations are plotted.
% instruction expects a string either 'setUp' or 'update'. Depending on
% whether the presented odors panel should be set up (when building the
% gui) or whether a new odor has been presented.
% trialOdor
% Property names:
% - position: position of the progress panel
% - color: color of the update fields
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
else
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
        color =  [1.0000    0.8000    0.2000];
    end
end

%% Setting up the progress panel
% When setting up the gui the following lines are called
if strmatch(instruction,'setUp')
    
    
    % Set up the progress panel
    h.progress.panel = uipanel('Parent',h.guiHandle,'Title','Presented Odors',...
        'Tag','progressPanel','FontSize',8,'TitlePosition','centertop',...
        'Units','pixels','Position',panelPosition); % 'Position',[x y width height] 
    
    
    h.progress.figure = axes('Units','Pixels');
    figurePosition(1) = panelPosition(1)+5; % Set the x position of the progress figure
    figurePosition(2) = panelPosition(2)+20; % Set the y position of the progress figure
    figurePosition(3) = panelPosition(3)-10; % Set the width of the progress figure
    figurePosition(4) = panelPosition(4)-37; % Set the height of the progress figure
    % Set up the figure where progress gets plotted
    set(h.progress.figure,'Ytick',[],'Xtick',(0:10000),'Fontsize',8)
    set(h.progress.figure,'Position',figurePosition)
    xlim([0.5 10.5]); ylim([0 1])
end


%% Updating the progress panel every trial
% Every trial the progress panel is updated
% A new rectangle with the name of the odor and the concentration is
% plotted in the presented odors figure (progressFigure).

if strmatch(instruction,'update')
    xPosition = trialNum-0.45;
    yPosition = 0.25;
    width=0.9;height = 0.5;
    rectangle('Position',[xPosition yPosition width height],'FaceColor',color); % plot rectangle in 
    if ~trialOdor.mixture % for normal odors
        display = sprintf([trialOdor.odorName '\nc=' num2str(trialOdor.concentrationAtPresentation)]);
        text(xPosition+0.03,yPosition+0.2,display,'Fontsize',8)
    else % for mixtures
        display{1} = [trialOdor.odorName{1} ' ' num2str(trialOdor.concentrationAtPresentation{1})];
        display{2} = sprintf([trialOdor.odorName{2} '\nc=' num2str(trialOdor.concentrationAtPresentation{2})]);
        text(xPosition+0.03,yPosition+0.2,display,'Fontsize',8)
    end
    if trialNum>10
        xlim([trialNum-10 trialNum] + 0.5)
    end
end


end