function h=progressPanel(h,instruction,trialOdor,trialNum,panelPosition)
% progressPanel(h,instruction,trial,position) builds a panel in the gui where
% current and previous odor presentations are plotted.
% instruction expects a string either 'setUp' or 'update'. Depending on
% whether the presented odors panel should be set up (when building the
% gui) or whether a new odor has been presented.
% trialOdor
%
% lorenzpammer 2011/09
%%

global smell

%% Setting up the progress panel
% When setting up the gui the following lines are called
if strmatch(instruction,'setUp')
    if nargin<4
        position = get(h.guiHandle,'Position'); % get position of main gui window
        panelWidth=position(3)-10; panelHeight = 100; % set the width and height of the progress panel
        panelPosition =[5 position(4)-panelHeight panelWidth panelHeight]; % set the position vector for the progress panel
        
    end
    
    % Set up the progress panel
    h.progressPanel = uipanel('Parent',h.guiHandle,'Title','Presented Odors',...
        'FontSize',12,'TitlePosition','centertop',...
        'Units','pixels','Position',panelPosition); % 'Position',[x y width height] 
    
    
    h.progressFigure = axes('Units','Pixels');
    figurePosition(1) = panelPosition(1)+5; % Set the x position of the progress figure
    figurePosition(2) = panelPosition(2)+15; % Set the y position of the progress figure
    figurePosition(3) = panelPosition(3)-10; % Set the width of the progress figure
    figurePosition(4) = panelPosition(4)-30; % Set the height of the progress figure
    % Set up the figure where progress gets plotted
    set(h.progressFigure,'Ytick',[],'Xtick',(0:10000))
    set(h.progressFigure,'Position',figurePosition)
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
    rectangle('Position',[xPosition yPosition width height],'FaceColor', [1.0000    0.8000    0.2000]); % plot rectangle in 
    if ~trialOdor.mixture % for normal odors
        text(xPosition+0.03,yPosition+0.2,[{trialOdor.odorName} {trialOdor.concentrationAtPresentation}])
    else % for mixtures
        display{1} = [trialOdor.odorName{1} ' ' num2str(trialOdor.concentrationAtPresentation{1})];
        display{2} = [trialOdor.odorName{2} ' ' num2str(trialOdor.concentrationAtPresentation{2})];
        text(xPosition+0.03,yPosition+0.2,display)
    end
    if trialNum>10
        xlim([trialNum-10 trialNum] + 0.5)
    end
end


end