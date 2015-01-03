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
global trialNum
global olfactometerInstructions
timeForEachVial = 1800; % time which is spent for every step of the cleaning procedure (eg pushing ethanol or blowing air) per vial in seconds.

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
set(h.progress.figure,'XColor',[1 1 1],'YColor',[1 1 1],'Xtick',[]); 
set(h.progress.panel,'Title',[]); 

% Set up olfactometerInstructions
olfactometerSettings([],'setUpStructure');

% Overwrite the default I/O settings. For cleaning we don't need any I/O.
io = protocolUtilities.ioControl.ioConfiguration('empty');
appdataManager('olfStimGui','set',io)

%% Interact with the user 

% Make sure user has Ethanol in the vials & give instructions on what to do:
message = sprintf(['\n \n',...
'Instructions: \n',...
'Fill all odor vials (vials 1 - 9) with 97%% Ethanol. \n',...
'. \n',...
'Fill also the dummy vial (vial #10 with Ethanol. \n',...
'\n']);
disp(message)

% Prompt user for input to confirm that Ethanol is in the vials
xPosition = get(h.progress.figure,'xlim');
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
%% Prepare sequence of cleaning steps by altering the smell structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% First two steps for each slave for dealing with the dummy vial

for i = 1 : numberOfSlavesToClean
    stepIndex = 20 * (i-1) + 1; % calculates the cleaning step in which
    
    trialOdor = smell.olfactometerOdors.sessionOdors(1); %
    
    buildSmell('update',[],trialOdor,stepIndex,'cleanOlfactometerStim')
    buildSmell('update',[],trialOdor,stepIndex+1,'cleanOlfactometerStim')
    
    [smell.trial(stepIndex:stepIndex+1).slave] = deal(i); % which slave
    [smell.trial(stepIndex:stepIndex+1).vial] = deal([]); % no odor vial used, because only dealing with dummy valve.
    smell.trial(stepIndex).concentrationAtPresentation = 1;
    smell.trial(stepIndex).flowRateMfcAir = 0; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex).flowRateMfcN = smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex).trialNum = stepIndex;

    % Adapt olfactometerInstructions for these trials:
    % Define what to write in olfactometerInstructions:
    settingName = {'mfcTotalFlow' 'powerFinalValve' 'unpowerFinalValve'};
    settingValue = [smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen timeForEachVial/2 timeForEachVial];
    olfactometerInstructions = updateOlfactometerInstructions(olfactometerInstructions,settingName,settingValue);
    smell.trial(stepIndex).olfactometerInstructions = olfactometerInstructions;
    
    % TO DO: see what command LASOM expects to open the MFC completely
    % Also check whether there is any N2 flow when MFCAir is opened all the
    % way.
    smell.trial(stepIndex+1).flowRateMfcAir = smell.olfactometerSettings.slave(i).maxFlowRateMfcAir; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex+1).flowRateMfcN = smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex+1).concentrationAtPresentation = smell.trial(stepIndex+1).flowRateMfcN/(smell.trial(stepIndex+1).flowRateMfcAir+smell.trial(stepIndex+1).flowRateMfcN); % have to define this even though it doesn't make sense, because later in processing it is used
    smell.trial(stepIndex+1).odorName = 'Air';
    smell.trial(stepIndex+1).odorantPurity = 1;
    smell.trial(stepIndex+1).odorantDilution = 1;
    smell.trial(stepIndex+1).odorantPurity = 1;
    smell.trial(stepIndex+1).trialNum = stepIndex+1;
    
    % Adapt olfactometerInstructions for these trials:
    % Define what to write in olfactometerInstructions:
    settingName = {'mfcTotalFlow' 'powerFinalValve' 'unpowerFinalValve'};
    settingValue = [smell.olfactometerSettings.slave(i).maxFlowRateMfcAir+smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen ...
        timeForEachVial/2 timeForEachVial];
    olfactometerInstructions = updateOlfactometerInstructions(olfactometerInstructions,settingName,settingValue);
    % Update smell structure
    smell.trial(stepIndex+1).olfactometerInstructions = olfactometerInstructions;
end


%% Steps of ethanol cleaning (every odd cleaning step)
% In these steps only the N2 MFC is opened a small amount, to ensure that
% there is some 

addToIndex = 0;
for i = 1 : length(smell.olfactometerOdors.sessionOdors) % starting at 3 because steps 1 & 2 are for dummy vials
    % Define the index in the sequence of steps where the current step has
    % to be written. Need to jump through some hoops here:
    calcIndex = i*2 - 1 + 2; % start with an ethanol cleaning step
    
    currentSlave = smell.olfactometerOdors.sessionOdors(i).slave;
    try
        previousSlave = smell.olfactometerOdors.sessionOdors(i-1).slave;
        if previousSlave<currentSlave
            addToIndex = addToIndex+2;
        end
    catch
    end
    stepIndex = calcIndex + addToIndex;
    
    % Adapt olfactometerInstructions for this step.
    % Define what to write in olfactometerInstructions:
    settingName = {'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' 'powerFinalValve' 'unpowerFinalValve'};
    settingValue = [smell.olfactometerSettings.slave(currentSlave).maxFlowRateMfcNitrogen ...
        0 timeForEachVial timeForEachVial/2 timeForEachVial];
    olfactometerInstructions = updateOlfactometerInstructions(olfactometerInstructions,settingName,settingValue);
    
    % Update the smell structure through the buildSmell function.
    % oflactometerInstructions will be added in that function
    buildSmell('update',[],smell.olfactometerOdors.sessionOdors(i),stepIndex,'cleanOlfactometerStim');
    
    smell.trial(stepIndex).concentrationAtPresentation = 1;
    smell.trial(stepIndex).flowRateMfcAir = 0; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex).flowRateMfcN = smell.olfactometerSettings.slave(currentSlave).maxFlowRateMfcNitrogen; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex).trialNum = stepIndex;
    
end

%% Steps of blowing the tubes dry with high gas flow

addToIndex = 0;
for i = 1 : length(smell.olfactometerOdors.sessionOdors)
    calcIndex = i*2 + 2; % all even cleaning steps are high gas flow steps
    
    currentSlave = smell.olfactometerOdors.sessionOdors(i).slave;
    % In case multiple slaves are used, adapt the index:
    try
        previousSlave = smell.olfactometerOdors.sessionOdors(i-1).slave;
        if previousSlave<currentSlave
            addToIndex = addToIndex+2;
        end
    catch
    end
    stepIndex = calcIndex + addToIndex;
    
    % Adapt olfactometerInstructions for these trials:
    % Define what to write in olfactometerInstructions:
    settingName = {'mfcTotalFlow' 'powerGatingValve' 'unpowerGatingValve' 'powerFinalValve' 'unpowerFinalValve'};
    settingValue = [smell.olfactometerSettings.slave(currentSlave).maxFlowRateMfcAir+smell.olfactometerSettings.slave(currentSlave).maxFlowRateMfcNitrogen ...
        0 timeForEachVial timeForEachVial/2 timeForEachVial];
    olfactometerInstructions = updateOlfactometerInstructions(olfactometerInstructions,settingName,settingValue);
    
    % Update the smell structure through the buildSmell function.
    % oflactometerInstructions will be added in that function
    buildSmell('update',[],smell.olfactometerOdors.sessionOdors(i),stepIndex,'cleanOlfactometerStim');
    
    % Manually update some fields in smell
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
    smell.trial(stepIndex).flowRateMfcAir = smell.olfactometerSettings.slave(currentSlave).maxFlowRateMfcAir; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex).flowRateMfcN = smell.olfactometerSettings.slave(currentSlave).maxFlowRateMfcNitrogen; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex).concentrationAtPresentation = smell.trial(stepIndex).flowRateMfcN/(smell.trial(stepIndex).flowRateMfcAir+smell.trial(stepIndex).flowRateMfcN); % have to define this even though it doesn't make sense, because later in processing it is used
    smell.trial(stepIndex).trialNum = stepIndex;
    
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
    
    % Start the trial:
    smell = olfStimStartTrial(i,smell);
    
end

delete(infoHandle.dynamicText);
infoHandle.dynamicText = text(xPosition+0.5,yPosition+0.4,'Finished cleaning','Fontsize',18);

end


function continuePushButton_Callback(~,~)

uiresume

end

function olfactometerInstructions = updateOlfactometerInstructions(olfactometerInstructions,settingName,settingValue)
% Subfunction to change olfactometerInstructions
% Set all olfactometerInstructions to non used:
    [olfactometerInstructions.used] = deal(false);    
    % Now update the ones we want
    for j = 1 : length(settingName)
        index = find(strcmp(settingName{j},{olfactometerInstructions.name}));
        if ~isempty(index)
            olfactometerInstructions(index).value = settingValue(j);
            olfactometerInstructions(index).used = true;
        else
            errormsg = sprintf('Error in olfactometerCleaning protocol. The olfactometer setting %s could not be found in the olfStimConfiguration.\nDid you alter the valve names?',settingName{j});
            error(errormsg)
        end
    end
end