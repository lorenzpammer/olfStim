function h = setUpPushButtons(h,smell,stimProtocol)

%%
import protocolUtilities.*

%%

numberOfOdorVials = length(smell.olfactometerOdors.sessionOdors);

% 2. Buttons for triggering odor presentation
% Define positions:
figurePosition = get(h.guiHandle,'Position');
position = get(h.progress.panel,'Position');
protocolChooserPosition = get(h.panelProtocolChooser,'Position');
spacing = 3;
pushButtonArea(1) =  protocolChooserPosition(1)+protocolChooserPosition(3) + 40; % X position to the right of protocol chooser panel
pushButtonArea(3) = figurePosition(3)-pushButtonArea(1)-3; % Width of the area for the buttons
pushButtonWidth = (pushButtonArea(3) - (8*spacing)) / numberOfOdorVials;
pushButtonHeight = 25;
pushButtonArea(2)= position(2) - pushButtonHeight - 3;
pushButtonArea(4)= pushButtonHeight;

%
%
% h.protocolSpecificHandles.triggerOdorPanel = uipanel('Parent',h.guiHandle,'Title','Protocol Controls',...
%         'FontSize',12,'TitlePosition','centertop',...
%         'Units','pixels','Position',panelPosition); % 'Position',[x y width height]


pushButtonPosition = [pushButtonArea(1) pushButtonArea(2) pushButtonWidth pushButtonHeight];
textPosition = [pushButtonArea(1)-40, pushButtonPosition(2)+5, 35, 15];

% Find which slaves are used
mixtures = [smell.olfactometerOdors.sessionOdors.mixture]; % Find which session odors are mixtures
activeSlaves = {smell.olfactometerOdors.sessionOdors.slave}; % Find for every session odor which slaves are used
activeSlaves = cell2mat(activeSlaves(~mixtures)); % Throw away the entries for the mixtures
activeSlaves = unique(activeSlaves); % Find all unique slaves which are used

% Set up gui controls for push buttons
for j = 1 : length(activeSlaves)
    odorCounter=0;
    % create the text saying which slave:
    h.staticText.slave(j) = uicontrol(h.guiHandle,'Style','text','String',['Slave ' num2str(j)],'Position',textPosition);
    usedVials = [smell.olfactometerOdors.slave(j).sessionOdors(:).vial];
    for i = 1 : numberOfOdorVials % go through every position of the olfactometer
        
        if sum(ismember(usedVials,i))>0.1 % checks whether there is an odor vial in the current (i) position of the olfactometer
            odorCounter = odorCounter+1;
            h.protocolSpecificHandles.trigger(j,i) = uicontrol(h.guiHandle,'Style','pushbutton',...
                'String',smell.olfactometerOdors.slave(j).sessionOdors(odorCounter).odorName,...
                'Units','pixels','Position',pushButtonPosition,...
                'Callback',{str2func([stimProtocol '.triggerOdorCallback']),smell.olfactometerOdors.slave(j).sessionOdors(odorCounter),stimProtocol});
            
        else
            h.protocolSpecificHandles.trigger(j,i) = uicontrol(h.guiHandle,'Style','pushbutton',...
                'String','',...
                'Units','pixels','Position',pushButtonPosition,'Callback',str2func([stimProtocol '.triggerEmptyOdorCallback']));
            
        end
        
        pushButtonPosition(1) = pushButtonPosition(1)+pushButtonWidth+spacing; % redefine pushButtonPosition for next loop iteration
        
        
    end
    
    % Redefine position for concentration settings.
    pushButtonPosition(1) = pushButtonArea(1);
    pushButtonPosition(2) = pushButtonPosition(2) - pushButtonPosition(4) - 3;
    textPosition(2) = pushButtonPosition(2) + 5;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Concentration edit fields
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    odorCounter=0;
    % create the text declaring the row of concentration edit fields
    h.protocolSpecificHandles.staticText.concentration(j) = uicontrol(h.guiHandle,'Style','text','String','Concentrations','Position',textPosition);
    usedVials = [smell.olfactometerOdors.slave(j).sessionOdors(:).vial];
    for i = 1 : numberOfOdorVials % go through every vial of the olfactometer
        
        if sum(ismember(usedVials,i))>0.1 % checks whether there is an odor vial in the current (i) position of the olfactometer
            odorCounter = odorCounter+1;
            % Calculate the maximum possible concentration given the MFC
            % flow rates, the user defined total flow and the dilution of
            % the odorant in the vial.
            settingNames = get(h.olfactometerSettings.text,'Tag');
            settingIndex = strcmp('mfcTotalFlow',settingNames);
            totalFlow = str2num(get(h.olfactometerSettings.edit(settingIndex),'String'));
            maximumPossibleConcentration = smell.olfactometerSettings.slave(j).maxFlowRateMfcNitrogen / totalFlow * smell.olfactometerOdors.slave(j).sessionOdors(odorCounter).odorantDilution;
            % Set up the fields, and append the gui handle structure
            h.protocolSpecificHandles.concentration(j,i) = uicontrol(h.guiHandle,'Style','edit',...
                'String',maximumPossibleConcentration,...
                'Units','pixels','Position',pushButtonPosition,'Callback',{@concentrationEditCallback,j,i});
        end
        
        pushButtonPosition(1) = pushButtonPosition(1)+pushButtonWidth+spacing; % redefine pushButtonPosition for next loop iteration
        
    end
    
    % Redefine pushButtonPosition for next slave
    pushButtonPosition(1) = pushButtonArea(1);
    pushButtonPosition(2) = pushButtonPosition(2) - pushButtonPosition(4) - 3;
    textPosition(2) = pushButtonPosition(2) + 5;
    
end
end