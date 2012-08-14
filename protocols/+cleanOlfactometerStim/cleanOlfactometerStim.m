function cleanOlfactometerStim
% This protocol is meant for cleaning the olfactometer over night.
% The procedure for the user is as follows:
% 1. Replace the odor vials with vials containing Ethanol. 
% 2. Make sure the olfactometer is connected to 2 bar of air & 2 bar of
% nitrogen as in the normal setup. 
% 3. Start the cleaning protocol.
%
% The cleaning procedure:
% Starting with the dummy vial going toward odor vial 1, 
%
% lorenzpammer 2011/12
%

%% Set up needed variables

global smell
global olfactometerOdors
global trialNum

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all functions of the current stimulation protocol
import cleanOlfactometerStim.*
import protocolUtilities.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These variables have to be defined in every stimulation paradigm
% trialNum = 0;
stimProtocol = 'cleanOlfactometerStim';


%% Starting up

% Set up the progress panel
h=progressPanel(h,'setUp');

% Adapt it for the cleaning protocol
set(h.progressFigure,'XColor',[1 1 1],'YColor',[1 1 1],'Xtick',[]); 
set(h.progressPanel,'Title',[]); 

% Set up olfactometerInstructions
olfactometerSettings([],'setUpStructure');


% Make sure user has Ethanol in the vials:

% Give instructions on what to do:
message = sprintf(['\n \n',...
'Instructions: \n',...
'Fill all odor vials (vials 1 - 9) with 97%% Ethanol. \n',...
'. \n',...
'Fill also the dummy vial (vial #10 with Ethanol. \n',...
'\n']);
disp(message)

% Prompt user for input to confirm that Ethanol is in the vials
xPosition = get(h.progressFigure,'xlim');
xPosition = sum(xPosition)/2 - 2;
yPosition = 0.1;
width=4;height = 0.8;
infoHandle.box = rectangle('Position',[xPosition yPosition width height],'FaceColor', [0.8 0.8 0.8]); % plot rectangle in the progress figure

infoHandle.dynamicText = text(xPosition+0.5,yPosition+0.4,'Is cleaning solution in the vials?','Fontsize',18,'Color','r');
message = sprintf('\n \n Is claning solution in the vials? \n \n');
disp(message)

figurePosition = get(h.guiHandle,'Position');
buttonWidth = 70; buttonHeight = 50;
buttonPosition(1) = figurePosition(3)/2 - buttonWidth/2; % [x y width height]
buttonPosition(2) = figurePosition(4)/2 - buttonHeight/2;
buttonPosition(3) = buttonWidth;
buttonPosition(4) = buttonHeight;

h.continue = uicontrol('Parent',h.guiHandle,'Style','pushbutton',...
    'String','Continue','Units','pixels','Position',buttonPosition,'Callback',@continuePushButton_Callback);

% Following commands set up a 3D matrix: 3 entries for every pixel of the
% pushbutton. [1 0 0] in RGB is red
colorMatrix(:,:,1) = zeros(buttonHeight,buttonWidth);
colorMatrix(:,:,2) = ones(buttonHeight,buttonWidth);
colorMatrix(:,:,3) = zeros(buttonHeight,buttonWidth);
set(h.continue,'CData',colorMatrix) % set color of push button to color defined in colorMatrix
clear colorMatrix;

uiwait % wait until the continue button is pressed


% Make sure user the olfactometer is connected to the gas sources:

% Give instructions on what to do:
message = sprintf(['\n \n',...
'Instructions: \n',...
'As for normal operation connect the olfactometer to a 2bar air source and \n',...
'a 2 bar N2 source. \n',...
'\n']);
disp(message)

delete(infoHandle.dynamicText)
infoHandle.dynamicText = text(xPosition+0.5,yPosition+0.4,'Are air & N2 connected?','Fontsize',18,'Color','r');
message = sprintf('\n \n Are air & N2 connected? \n \n');
disp(message)
uiwait




% User has to define how many slaves have to be cleaned.
message = sprintf(['\n \n',...
'How many slaves should be cleaned? \n \n']);
disp(message)

delete(infoHandle.dynamicText)
infoHandle.dynamicText = text(xPosition+0.05,yPosition+0.4,'How many slaves should be cleaned?','Fontsize',18,'Color','r');
editPosition(1) = buttonPosition(1);
editPosition(2) = buttonPosition(2) + buttonPosition(4) +5;
editPosition(3:4) = buttonPosition(3:4) - [0 5];
infoHandle.nSlaves = uicontrol('Parent',h.guiHandle,...
        'Style','edit','String','1','Position', editPosition);
uiwait

numberOfSlavesToClean = str2num(get(infoHandle.nSlaves,'String')); % extract the number of slaves from edit field, change from string to number

clear editPosition; clear buttonPosition;
delete(infoHandle.dynamicText); delete(infoHandle.nSlaves); delete(h.continue); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prepare sequence of cleaning steps (here using the trial structure)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% First two steps for each slave for dealing with the dummy vial
for i = 1 : numberOfSlavesToClean
    stepIndex = 20 * (i-1) + 1; % calculates the cleaning step in which
    
    trialOdor = olfactometerOdors.sessionOdors(1); %
    
    buildSmell('update',trialOdor,stepIndex,'cleanOlfactometerStim')
    
    [smell.trial(stepIndex:stepIndex+1).slave] = deal(i); % which slave
    [smell.trial(stepIndex:stepIndex+1).vial] = deal([]); % no odor vial used, because only dealing with dummy valve.
    smell.trial(stepIndex).concentrationAtPresentation = 1;
    smell.trial(stepIndex).flowRateMfcAir = 0; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex).flowRateMfcN = smell.olfactometerSettings.maxFlowRateMfcNitrogen; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex).trialNum = stepIndex;
        
    % Adapt olfactometerInstructions for these trials:
    % Define what to write in olfactometerInstructions:
    settingName = {'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' 'powerFinalValve' 'unpowerFinalValve' ...
    'closeSuctionValve' 'openSuctionValve' 'openSniffingValve' 'closeSniffingValve' ...
    'powerHumidityValve' 'unpowerHumidityValve' 'purge' 'cleanNose'};
    settingValue = [smell.olfactometerSettings.maxFlowRateMfcNitrogen ...
                    0 0 900 1800 0 0 0 0 0 0 0 0];
    settingUsed =  [1 0 0 1 1 0 0 0 0 0 0 0 0];
    
    for j = 1 : length(settingName)
        index = find(strcmp(settingName{j},{olfactometerInstructions.name}));
        olfactometerInstructions(index).value = settingValue(j);
        olfactometerInstructions(index).used = settingUsed(j);  
    end
    smell.trial(stepIndex).olfactometerInstructions = olfactometerInstructions;
    
    
    % TO DO: see what command LASOM expects to open the MFC completely
    % Also check whether there is any N2 flow when MFCAir is opened all the
    % way.
    smell.trial(stepIndex+1).flowRateMfcAir = smell.olfactometerSettings.maxFlowRateMfcAir; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex+1).flowRateMfcN = smell.olfactometerSettings.maxFlowRateMfcNitrogen; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex+1).concentrationAtPresentation = smell.trial(stepIndex+1).flowRateMfcN/(smell.trial(stepIndex+1).flowRateMfcAir+smell.trial(stepIndex+1).flowRateMfcN); % have to define this even though it doesn't make sense, because later in processing it is used
    smell.trial(stepIndex+1).odorName = 'Air';
    smell.trial(stepIndex+1).odorantPurity = 1;
    smell.trial(stepIndex+1).odorantDilution = 1;
    smell.trial(stepIndex+1).odorantPurity = 1;
    smell.trial(stepIndex+1).trialNum = stepIndex+1;
    
    % Adapt olfactometerInstructions for these trials:
    % Define what to write in olfactometerInstructions:
    settingName = {'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' 'powerFinalValve' 'unpowerFinalValve' ...
    'closeSuctionValve' 'openSuctionValve' 'openSniffingValve' 'closeSniffingValve' ...
    'powerHumidityValve' 'unpowerHumidityValve' 'purge' 'cleanNose'};
    settingValue = [smell.olfactometerSettings.maxFlowRateMfcAir+smell.olfactometerSettings.maxFlowRateMfcNitrogen ...
                    0 0 900 1800 0 0 0 0 0 0 0 0];
    settingUsed =  [1 0 0 1 1 0 0 0 0 0 0 0 0];
    
    % Write olfactometerInstructions for the current cleaning step
    for j = 1 : length(settingName)
        index = find(strcmp(settingName{j},{olfactometerInstructions.name}));
        olfactometerInstructions(index).value = settingValue(j);
        olfactometerInstructions(index).used = settingUsed(j);  
    end
    % Update smell structure
    smell.trial(stepIndex+1).olfactometerInstructions = olfactometerInstructions;
end


%% Steps of ethanol cleaning (every odd cleaning step)
% In these steps only the N2 MFC is opened a small amount, to ensure that
% there is some 

% Define what to write in olfactometerInstructions:
settingName = {'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' 'powerFinalValve' 'unpowerFinalValve' ...
    'closeSuctionValve' 'openSuctionValve' 'openSniffingValve' 'closeSniffingValve' ...
    'powerHumidityValve' 'unpowerHumidityValve' 'purge' 'cleanNose'};
settingValue = [smell.olfactometerSettings.maxFlowRateMfcNitrogen ...
 0 1800 900 1800 0 0 0 0 0 0 0 0];
settingUsed =  [1 1 1 1 1 0 0 0 0 0 0 0 0];

odorNr = 0;
addToIndex = 0;
for i = 1 : length(smell.olfactometerOdors.sessionOdors) % starting at 3 because steps 1 & 2 are for dummy vials
    % Define the index in the sequence of steps where the current step has
    % to be written. Need to jump through some hoops here:
    calcIndex = i*2 - 1 + 2; % start with an ethanol cleaning step
    odorNr = odorNr+1;
    
    try
        previousSlave = smell.olfactometerOdors.sessionOdors(odorNr-1).slave;
        currentSlave = smell.olfactometerOdors.sessionOdors(odorNr).slave;
        if previousSlave<currentSlave
            addToIndex = addToIndex+2;
        end
    catch
    end
    stepIndex = calcIndex + addToIndex;
    
    buildSmell('update',smell.olfactometerOdors.sessionOdors(odorNr),stepIndex,'cleanOlfactometerStim');
    
    smell.trial(stepIndex).concentrationAtPresentation = 1;
    smell.trial(stepIndex).flowRateMfcAir = 0; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex).flowRateMfcN = smell.olfactometerSettings.maxFlowRateMfcNitrogen; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex).trialNum = stepIndex;
    
    
    % Write olfactometerInstructions for the current cleaning step
    for j = 1 : length(settingName)
        index = find(strcmp(settingName{j},{olfactometerInstructions.name}));
        olfactometerInstructions(index).value = settingValue(j);
        olfactometerInstructions(index).used = settingUsed(j);  
    end
    % Update smell structure
    smell.trial(stepIndex).olfactometerInstructions = olfactometerInstructions;
    
end
clear odorNr;

%% Steps of blowing the tubes dry with high gas flow


%% Adapt olfactometerInstructions for these trials:
    % Define what to write in olfactometerInstructions:
    settingName = {'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' 'powerFinalValve' 'unpowerFinalValve' ...
    'closeSuctionValve' 'openSuctionValve' 'openSniffingValve' 'closeSniffingValve' ...
    'powerHumidityValve' 'unpowerHumidityValve' 'purge' 'cleanNose'};
    settingValue = [smell.olfactometerSettings.maxFlowRateMfcAir+smell.olfactometerSettings.maxFlowRateMfcNitrogen ...
                    0 1800 900 1800 0 0 0 0 0 0 0 0];
    settingUsed =  [1 1 1 1 1 0 0 0 0 0 0 0 0];

addToIndex = 0;
for i = 1 : length(smell.olfactometerOdors.sessionOdors)
    calcIndex = i*2 + 2; % all even cleaning steps are high gas flow steps
    % In case multiple slaves are used, adapt the index:
    try
        previousSlave = smell.olfactometerOdors.sessionOdors(i-1).slave;
        currentSlave = smell.olfactometerOdors.sessionOdors(i).slave;
        if previousSlave<currentSlave
            addToIndex = addToIndex+2;
        end
    catch
    end
    stepIndex = calcIndex + addToIndex;
    
    smell.trial(stepIndex).odorName = 'Air';
    smell.trial(stepIndex).slave = smell.trial(stepIndex-1).slave;
    smell.trial(stepIndex).vial = smell.trial(stepIndex-1).vial;
    smell.trial(stepIndex).odorantPurity = 1;
    smell.trial(stepIndex).odorantDilution = 1;

    % TO DO: see what command LASOM expects to open the MFC completely
    % Also check whether there is any N2 flow when MFCAir is opened all the
    % way.
%     smell.trial(stepIndex).MFCAir = 'max'; % Open all the way when blowing a lot of air
%     smell.trial(stepIndex).MFCNitrogen = 'max'; 
    smell.trial(stepIndex).flowRateMfcAir = smell.olfactometerSettings.maxFlowRateMfcAir; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex).flowRateMfcN = smell.olfactometerSettings.maxFlowRateMfcNitrogen; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex).concentrationAtPresentation = smell.trial(stepIndex).flowRateMfcN/(smell.trial(stepIndex).flowRateMfcAir+smell.trial(stepIndex).flowRateMfcN); % have to define this even though it doesn't make sense, because later in processing it is used
    smell.trial(stepIndex).trialNum = stepIndex;
    
    
    % Write olfactometerInstructions for the current cleaning step
    for j = 1 : length(settingName)
        index = find(strcmp(settingName{j},{olfactometerInstructions.name}));
        olfactometerInstructions(index).value = settingValue(j);
        olfactometerInstructions(index).used = settingUsed(j);  
    end
    % Update smell structure
    smell.trial(stepIndex).olfactometerInstructions = olfactometerInstructions;
    
end

[smell.trial(:).mixture] = deal(logical(0));
[smell.trial(:).odorantDilution] = deal(1);
[smell.trial(:).stimProtocol] = deal('cleanOlfactometerStim');

%% Start cleaning

infoHandle.dynamicText = text(xPosition+0.5,yPosition+0.4,'Cleaning Olfactometer','Fontsize',18);

for i = 1 : length(smell.trial)
    % Display message in command window of the current status:
    message = sprintf(['\n',...
        'Currently purging with ' smell.trial(i).odorName ' from vial #' num2str(smell.trial(i).vial),...
        ' in slave #' num2str(smell.trial(i).slave) '\n']);
    disp(message)
    
    smell = startTrial(i,smell);
end

delete(infoHandle.dynamicText);
infoHandle.dynamicText = text(xPosition+0.5,yPosition+0.4,'Finished cleaning','Fontsize',18);

end


function continuePushButton_Callback(~,~)

uiresume

end