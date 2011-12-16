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

global h;
global smell;

%% Starting up

% Set up the progress panel
progressPanel('setUp')

% Adapt it for the cleaning protocol
set(h.progressFigure,'XColor',[1 1 1],'YColor',[1 1 1],'Xtick',[]); 
set(h.progressPanel,'Title',[]); 

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

infoHandle.dynamicText = text(xPosition+0.5,yPosition+0.4,'Is Ethanol in the vials?','Fontsize',18,'Color','r');
message = sprintf('\n \n Is Ethanol in the vials? \n \n');
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


%% Set up the smell structure

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

smell.olfactometerOdors.sessionOdors(numberOfSlavesToClean*9).odorName = 'Ethanol'; % set up for the number of vials = number of slaves * 9

[smell.olfactometerOdors.sessionOdors(:).odorName] = deal('Ethanol');
[smell.olfactometerOdors.sessionOdors(:).iupacName] = deal('Ethanol');
[smell.olfactometerOdors.sessionOdors(:).CASNumber] = deal([]);
[smell.olfactometerOdors.sessionOdors(:).odorantDilution] = deal(1);
[smell.olfactometerOdors.sessionOdors(:).concentrationAtPresentation] = deal(1);
[smell.olfactometerOdors.sessionOdors(:).mixture] = deal(0);
[smell.olfactometerOdors.sessionOdors(:).producingCompany] = deal([]);
[smell.olfactometerOdors.sessionOdors(:).dilutedIn] = deal([]);
[smell.olfactometerOdors.sessionOdors(:).odorantPurity] = deal(1);
[smell.olfactometerOdors.sessionOdors(:).state] = deal([]);

% go through each session odor and define the slave & vial
for i =  1: length(smell.olfactometerOdors.sessionOdors)
    slaveNr = ceil(i/9);
    vialNr = i - (slaveNr-1) * 9;
    smell.olfactometerOdors.sessionOdors(i).sessionOdorNumber = i;
    smell.olfactometerOdors.sessionOdors(i).slave = slaveNr;
    smell.olfactometerOdors.sessionOdors(i).vial = vialNr;
end
clear slaveNr;clear vialNr;



%% Prepare sequence of cleaning steps (here using the trial structure)

% First two steps for each slave for dealing with the dummy vial
for i = 1 : numberOfSlavesToClean
    stepIndex = 20 * (i-1) + 1; % calculates the cleaning step in which
    [smell.trial(stepIndex:stepIndex+1).slave] = deal(i); % which slave
    [smell.trial(stepIndex:stepIndex+1).vial] = deal([]); % no odor vial used
    [smell.trial(stepIndex:stepIndex+1).sniffValveUsed] = deal(logical(0)); % not used
    [smell.trial(stepIndex:stepIndex+1).noseCleaningUsed] = deal(logical(0)); % not used
    [smell.trial(stepIndex:stepIndex+1).humidAirValveUsed] = deal(logical(0)); % not used
    [smell.trial(stepIndex:stepIndex+1).odorGatingValves] = deal([]); % time in seconds [power unpower]
    [smell.trial(stepIndex:stepIndex+1).emptyVialGatingValves] = deal([]); % time in seconds [power unpower]
    [smell.trial(stepIndex:stepIndex+1).finalValve] = deal([1 900]); % time in seconds [power unpower]
    [smell.trial(stepIndex:stepIndex+1).suctionValve] = deal([]); % not used
    [smell.trial(stepIndex:stepIndex+1).sniffingValve] = deal([]); % not used
    
    smell.trial(stepIndex).odorName = 'Ethanol';
    smell.trial(stepIndex).MFCAir = 0; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex).MFCNitrogen = 0.1; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex).trialNum = stepIndex;
    % TO DO: see what command LASOM expects to open the MFC completely
    % Also check whether there is any N2 flow when MFCAir is opened all the
    % way.
    smell.trial(stepIndex+1).MFCAir = 'max'; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex+1).MFCNitrogen = 'max'; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex+1).odorName = 'Air';
    smell.trial(stepIndex+1).odorantPurity = 1;
    smell.trial(stepIndex+1).odorantDilution = 1;
    smell.trial(stepIndex+1).odorantPurity = 1;
    smell.trial(stepIndex+1).trialNum = stepIndex+1;
end

% Steps of ethanol cleaning (every odd cleaning step)
% In these steps only the N2 MFC is opened a small amount, to ensure that
% there is some 
odorNr = 0;
addToIndex = 0;
for i = 1 : length(smell.olfactometerOdors.sessionOdors) % starting at 3 because steps 1 & 2 are for dummy vials
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
    
        
    smell.trial(stepIndex).sniffValveUsed = logical(0);
    smell.trial(stepIndex).noseCleaningUsed = logical(0);
    smell.trial(stepIndex).humidAirValveUsed = logical(0);
    
    smell.trial(stepIndex).odorGatingValves = [1 1800]; % time in seconds [power unpower]
    smell.trial(stepIndex).emptyVialGatingValves = [1 1800]; % time in seconds [power unpower]
    smell.trial(stepIndex).finalValve = [1 900]; % time in seconds [power unpower]
    smell.trial(stepIndex).suctionValve = []; % not used
    smell.trial(stepIndex).sniffingValve = []; % not used
    smell.trial(stepIndex).MFCAir = 0; % turn off when cleaning ethanol. Results in only ethanol being p
    smell.trial(stepIndex).MFCNitrogen = 0.1; % TO DO: see what command LASOM expects to open the MFC completely
    smell.trial(stepIndex).trialNum = stepIndex;
end
clear odorNr;

% Steps of blowing the tubes dry with high gas flow
addToIndex = 0;
for i = 1 : length(smell.olfactometerOdors.sessionOdors)
    calcIndex = i*2 + 2; % all even cleaning steps are high gas flow steps
    
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
    smell.trial(stepIndex).odorantPurity = 1;
    
    smell.trial(stepIndex).sniffValveUsed = logical(0);
    smell.trial(stepIndex).noseCleaningUsed = logical(0);
    smell.trial(stepIndex).humidAirValveUsed = logical(0);
    
    smell.trial(stepIndex).odorGatingValves = [1 1800]; % time in seconds [power unpower]
    smell.trial(stepIndex).emptyVialGatingValves = [1 1800]; % time in seconds [power unpower]
    smell.trial(stepIndex).finalValve = [1 900]; % time in seconds [power unpower]
    smell.trial(stepIndex).suctionValve = []; % not used
    smell.trial(stepIndex).sniffingValve = []; % not used
    % TO DO: see what command LASOM expects to open the MFC completely
    % Also check whether there is any N2 flow when MFCAir is opened all the
    % way.
    smell.trial(stepIndex).MFCAir = 'max'; % Open all the way when blowing a lot of air
    smell.trial(stepIndex).MFCNitrogen = 'max'; 
    smell.trial(stepIndex).trialNum = stepIndex;
    
end

[smell.trial(:).concentrationAtPresentation] = deal(1);
[smell.trial(:).mixture] = deal(logical(0));
[smell.trial(:).odorantDilution] = deal(1);
[smell.trial(:).odorantPurity] = deal(1);
[smell.trial(:).state] = deal([]);
[smell.trial(:).stimProtocol] = deal('cleanOlfactometerStim');



%% Start cleaning

infoHandle.dynamicText = text(xPosition+0.5,yPosition+0.4,'Cleaning Olfactometer','Fontsize',18);

for i = 1 : length(smell.trial)
    % Display message in command window of the current status:
    message = sprintf(['\n',...
        'Currently purging with ' smell.trial(i).odorName ' from vial #' num2str(smell.trial(i).vial),...
        ' in slave #' num2str(smell.trial(i).slave) '\n']);
    disp(message)
    
    
    
    
    
    
end
a=2




end

%%

function continuePushButton_Callback(~,~)

uiresume

end