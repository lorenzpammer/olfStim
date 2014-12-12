function trialOsq = buildTrialOsq(trialNum,smell)
% trialOsq = buildTrialOsq(trialNum,smell)
%   will construct an Osq (olfactometer sequence) file for the current
%   trial using the information from the smell structure for the current
%   trial. It returns the osq file for the current trial and saves it in
%   the /osq folder in the olfStim directory.
%
% The .osq files are sequencer files in a language readable by the
% microprocessor used for actually switching valves (eg the LASOM
% olfactometer board). This function allows the flexible creation of the
% sequencer file for the current trial using instructions from the smell
% structure.
%
% This function is called from startTrial.m
%
% TO DO:
% - Fix how the digital outputs are triggered on LASOM. For now I hacked
% the timestamp triggers into the osq files. 
% - Support presenting mixtures.
%
% lorenzpammer 2011/12

%% Build the osq file for this trial

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function
osqPath = which(callingFunctionName);
osqPath(length(osqPath)-length(callingFunctionName):length(osqPath))=[];
osqPath=[osqPath filesep 'olfactometerUtilities/osq' filesep];
ioOsqPath=[osqPath filesep 'ioCodes' filesep];
clear callingFunctionName

[sequencerName timeFactor] = osqDefinitions; % information of specific sequencer used (eg LASOM or Arduino, etc.)

coreOsq = fileread([osqPath 'core.osq']); % read in the core osq file (a text file)
trialOsq = coreOsq; % Use trial Osq for creating the trial specific Osq


%% Create the osq file for the current trial:
% Check whether the odor presented in this trial is a pure odor or whether
% odors from different slaves have to be mixed:
if smell.trial(trialNum).mixture == 0
    %% Define the parameters in the osq file
    
    % 1. Add the current trial number to the osq file
    % Rewrite the trialOsq with the correct value in the parameter
    % definition for the current trial
    replaceString = 'Param, trialNum, 1';
    replacementString = [replaceString(1:end-1) num2str(trialNum)];
    trialOsq = replacePlaceHolderInOsq(trialOsq,replaceString,replacementString);
    
    % 2. change parameter from which vial the odor is drawn:
    % As the sequencer defines the vial#1 as the dummy vial, and vial#2 as
    % the first odor vial, we have to add 1 to the vial number.
    if ~isempty(smell.trial(trialNum).vial)
        % Rewrite the trialOsq with the correct value in the parameter
        % definition for the current trial
        replaceString = 'Param, odorValveIndex, 1';
        replacementString = [replaceString(1:end-1) num2str(smell.trial(trialNum).vial + 1)];
        trialOsq = replacePlaceHolderInOsq(trialOsq,replaceString,replacementString);
        
        % if no odor gating valves have to be opened (air is presented)
    elseif isempty(smell.trial(trialNum).vial)
        replaceString = 'Param, odorValveIndex, 1';
        replacementString = [replaceString(1:end-1) num2str(0)];
        trialOsq = replacePlaceHolderInOsq(trialOsq,replaceString,replacementString);
    end
    
    % 3. change parameter in which slave the vial is located. The slave
    % parameter only applies to odor gating valves, as all other valves
    % (final, sniffing, etc.) are on slave 1
    if ~isempty(smell.trial(trialNum).vial)
        % Rewrite the trialOsq with the correct value in the parameter
        % definition for the current trial
        replaceString = 'Param, slaveIndex, 1';
        replacementString = [replaceString(1:end-1) num2str(smell.trial(trialNum).slave)];
        trialOsq = replacePlaceHolderInOsq(trialOsq,replaceString,replacementString);
    end
    
    
    %% Sort the actions according to their timing
    
    % Define the actions and the sequence of actions of the
    % olfactometer and create the sequencer code to carry them out
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1. Get the actions saved in olfactometer instructions
    % flow
    %
    % Find the mfcTotalFlow field. Make a logical indexing vector
    % denoting the actions (fields), that have to be dealt with in the
    % sequencer:
    ai{1} = ~strcmp('mfcTotalFlow',{smell.trial(trialNum).olfactometerInstructions.name});
    ai{2} = ~strcmp('purge',{smell.trial(trialNum).olfactometerInstructions.name});
    olfactometerActionsIndex = logical(ai{1} .* ai{2});
    clear ai;
    % Timing of the different actions from olfactometer instructions:
    timesOfAction = {smell.trial(trialNum).olfactometerInstructions.value};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2. Deal with the I/O and trial flow information
    timesOfAction = [timesOfAction {smell.trial(trialNum).io.time}];
    
    % Create indices that allow to backinfer which action entries come from
    % olfactometerSettings and which from io
    olfactometerSettingsActions = 1:length(smell.trial(trialNum).olfactometerInstructions);
    ioActions = length(smell.trial(trialNum).olfactometerInstructions)+1 : length(timesOfAction);
    
    % Create an index that allows to backinfer which times of actions
    % correspond to which type of action. Need to jump through some hoops
    % here, in order to be able to deal with multiple opening/closing times
    % of a single valve during one trial:
    instructionIndexOfTimesOfAction = [];
    for i = 1: length(timesOfAction)
        instructionIndexOfTimesOfAction(length(instructionIndexOfTimesOfAction)+1:length(instructionIndexOfTimesOfAction)+1+length(timesOfAction{i})-1) = ...
            ones(1,length(timesOfAction{i}))*i;
    end
    % Sort the actions in the sequence in which they will be triggered
    % during the trial:
    [sortedTimesOfAction,sequenceIndexOfActions]=sort(cell2mat(timesOfAction));
    
    % Overwrite sequenceIndexOfActions with the indices for the actions:
    sequenceIndexOfActions = instructionIndexOfTimesOfAction(sequenceIndexOfActions);
    
    % If an olfactometerSettings action and a I/O action are supposed to
    % occur at the same time, we will first execute the I/O action. Sort
    % the actions according to this principle:
    [b,m,n]=unique(sortedTimesOfAction);
    
    
    for i = 1 : length(m)
       if i == 1
           sameValues = 1:m(i);
           tempIoActions = ismember(sequenceIndexOfActions(sameValues),ioActions);
           [~,c]=sort(tempIoActions,'descend');
           reorderedValues = sameValues(c);
           sequenceIndexOfActions(sameValues) = sequenceIndexOfActions(reorderedValues);
       else
           sameValues = m(i-1):m(i);
           tempIoActions = ismember(sequenceIndexOfActions(sameValues),ioActions);
           [~,c]=sort(tempIoActions,'descend');
           reorderedValues = sameValues(c);
           sequenceIndexOfActions(sameValues) = sequenceIndexOfActions(reorderedValues);
           
       end
    end
    
    % Write an index of which actions are used
    usedActions = [[smell.trial(trialNum).olfactometerInstructions(:).used] logical([smell.trial(trialNum).io.used])];
    
    %% Build sequence of actions in the right order from osq building blocks
    %
    % Go through a sorted loop, and add the sequencer commands for the
    % each action to the end of the osq file. The order of the
    % resulting sequence of actions corresponds to the defined timing
    % of the actions.
    actionNumber=0;
    loopIteration=0;
    actionOsq = [];
    for i = sequenceIndexOfActions
        loopIteration = loopIteration+1;
        % if the current action is not handled by the sequencer skip it
        % (some fields in the olfactometerSettings structure are not
        % handled by the sequencer, eg MFC flow rates. io actions are all
        % handled by the sequencer).
        if ~ismember(i,find(olfactometerActionsIndex)) && i <= max(olfactometerSettingsActions)
            continue % to next iteration of for loop
        end
        
        % If the action is used:
        if usedActions(i)
            
            % Add 1 to the action counter.
            actionNumber = actionNumber+1;
            
            if actionNumber==1
                %    read the osq file that includes the command for the current
                % action in the1 loop iteration
                if ismember(i,olfactometerSettingsActions)
                    currentActionOsq = fileread([osqPath smell.trial(trialNum).olfactometerInstructions(i).name '.osq']);
                elseif ismember(i,ioActions)
                    index = i - max(olfactometerSettingsActions);
                    currentActionOsq = fileread([ioOsqPath smell.trial(trialNum).io(index).label '.osq']);
                end
                
                % If the first action type is called multiple times within
                % a trial, the first action of the trial will also be the
                % first of the multiple calls of the same action. Therefore
                % take the first value from the instructions:
                currentActionValueIndex = 1;
                
                % In the first action of a trial the wait time is the
                % time at which the first action should be triggered:
                if ismember(i,olfactometerSettingsActions)
                    waitTime = smell.trial(trialNum).olfactometerInstructions(i).value(currentActionValueIndex)*timeFactor;% * values in smell are in s (eg LASOM expects ms)
                    currentActionOsq = sprintf([';\nwait, %d \n' currentActionOsq], waitTime);
                elseif ismember(i,ioActions)
                    index = i - max(olfactometerSettingsActions);
                    waitTime = smell.trial(trialNum).io(index).time(currentActionValueIndex)*timeFactor;% values in smell are in s (eg LASOM expects ms)
                    currentActionOsq = sprintf([';\nwait, %d \n' currentActionOsq], waitTime);
                end
                
%                 % Add the command to send a timestamp:
%                 sendTimestampOsq = fileread([osqPath 'sendTimestamp.osq']);
%                 replacementString = num2str(smell.trial(trialNum).olfactometerInstructions(i).timeStampID);
%                 sendTimestampOsq = replacePlaceHolderInOsq(sendTimestampOsq,'MYTIMESTAMP',replacementString);
%                 % Add the command to send a timestamp to the
%                 % currentActionOsq:
%                 currentActionOsq = [currentActionOsq sendTimestampOsq];
                
                actionOsq = currentActionOsq;
                
                clear waitTime currentActionOsq
                
                
            else
                clear currentActionOsq
                % Read the osq file that includes the command for the current
                % action in the loop iteration
                if ismember(i,olfactometerSettingsActions)
                    currentActionOsq = fileread([osqPath smell.trial(trialNum).olfactometerInstructions(i).name '.osq']);
                elseif ismember(i,ioActions)
                    index = i - max(olfactometerSettingsActions);
                    currentActionOsq = fileread([ioOsqPath smell.trial(trialNum).io(index).label '.osq']);
                end
                
                if isempty(currentActionOsq) 
                   errormsg=sprintf('No osq template for the current action found.\nCurrent action: %s',smell.trial(trialNum).olfactometerInstructions(i).name) 
                   error(errormsg)
                end
                % Read in the sequencer code, which allows to check
                % whether the next action should be triggered or
                % whether it should wait.
                % This is for the sequencer to know whether the time for
                % triggering the action has come.
                timeLapseOsq = fileread([osqPath 'timeLapse.osq']);
                
                % In cases where one action (eg opening a valve) is called
                % multiple times within a trial, we have to know which
                % of the several times of action calling we're in now:
                currentActionCallsInTrial = find(sequenceIndexOfActions==i);
                if length(currentActionCallsInTrial)>1
                    currentActionValueIndex = find(currentActionCallsInTrial == loopIteration);
                else
                    currentActionValueIndex = 1;
                end
                
                % First change the timing of the when it lapses:
                if ismember(i,olfactometerSettingsActions)
                    replaceString = 'MYVAL';
                    waitTime = num2str(smell.trial(trialNum).olfactometerInstructions(i).value(currentActionValueIndex)*timeFactor); % values in smell are in s (eg LASOM expects ms)
                    timeLapseOsq = replacePlaceHolderInOsq(timeLapseOsq,replaceString, waitTime);
                    clear waitTime
                elseif ismember(i,ioActions)
                    index = i - max(olfactometerSettingsActions);
                    replaceString = 'MYVAL';
                    waitTime = num2str(smell.trial(trialNum).io(index).time(currentActionValueIndex)*timeFactor); % values in smell are in s (eg LASOM expects ms)
                    timeLapseOsq = replacePlaceHolderInOsq(timeLapseOsq,replaceString, waitTime);
                    clear waitTime
                end
                
                % Now change the label to jump to, when it lapses out:
                replaceString = '@lapsedOut';
                replacementString = [replaceString num2str(actionNumber)];
                timeLapseOsq = replacePlaceHolderInOsq(timeLapseOsq,replaceString,replacementString);
                
                % Add the label marking where to continue, once the
                % timer lapses out:
                label = ['label, ' replacementString];
                currentActionOsq = sprintf([timeLapseOsq '\n' label '\n' currentActionOsq]);
                
                clear  replaceString replacementString timeLapseOsq
                
%                 % Add the command to send a timestamp:
%                 sendTimestampOsq = fileread([osqPath 'sendTimestamp.osq']);
%                 replacementString = num2str(smell.trial(trialNum).olfactometerInstructions(i).timeStampID);
%                 sendTimestampOsq = replacePlaceHolderInOsq(sendTimestampOsq,'MYTIMESTAMP',replacementString);
%                 % Add the command to send a timestamp to the
%                 % currentActionOsq:
%                 currentActionOsq = [currentActionOsq sendTimestampOsq];
                
                
                % Append currentActionOsq to actionOsq
                actionOsq = [actionOsq currentActionOsq];
            end
            
        end
    end
    clear loopIteration currentActionOsq actionNumber ...
        timeLapseOsq sendTimestampOsq sortedTimesOfAction sequenceIndexOfActions
    
    
    
    %%
    % Add the sequence of actions (actionOsq) for the current trial into
    % the osq file for the current trial (trialOsq):
    replaceString = 'eof';
    trialOsq = replacePlaceHolderInOsq(trialOsq,replaceString, actionOsq);
    
    %% Place some necessary actions at the beginning of the file.
    currentActionOsq = fileread([osqPath 'initiation.osq']);
    replaceString = 'bof';
    trialOsq = replacePlaceHolderInOsq(trialOsq,replaceString, currentActionOsq,'last');
    
elseif smell.trial(trialNum).mixture == 1
    error(': Creating Osq files for mixtures is not yet programmed.')
    
else
    error('No information whether the odor is drawn from multiple vials or of one vial.')
end



%% Save trialOsq file:
fid = fopen([osqPath 'trial.osq'],'w');
fprintf(fid,'%s',trialOsq);
fclose(fid);
clear fid;

end

            %% SUBFUNCTIONS
    
%% Utility functions

function updatedOsqFile = replacePlaceHolderInOsq(osqFile,replaceString,replacementString,instruction)
% updatedOsqFile = replacePlaceHolderInOsq(osqFile, replaceString, replacementString,instruction)
% This function replaces the string defined by replaceString with the
% string defined in replacementString in the osq file and oututs the
% updated osq file. The firest 3 arguments are necessary.
% The last argument instruction can be one of the following:
% - 'one' : THis is the default if nothing is specified. This means there
%           should not be more than one instance of the replaceString found
%           in the osqFile. If there are more than one an error will be
%           thrown.
% - 'last' : If there is more than one instance of the replaceString in the
%           osq file, this argument will result in replacing the last of
%           the replaceString instances to be replaced by replacementString.
%
%%

if nargin < 3
    updatedOsqFile=[];
    error('Not enough input arguments. Type >> help replacePlaceHolderInOsq to get information. ')
end
if nargin < 4
   instruction = 'one'; 
end

%% Fint the replaceString in osqFile and replace it

% Find all instances of replaceString in osqFile:
replaceLocation = strfind(osqFile,replaceString);
% If no instance of replaceString can be found throw an error:
if isempty(replaceLocation)
    error([replaceString ' not found in osq file. No updating possible.'])
end

% Only one instance should be found:
if strmatch(instruction,'one')
    if length(replaceLocation) > 1
        error('Too many instances of a string to replace.')
    end
    updatedOsqFile = sprintf([osqFile(1:replaceLocation-1) '%s' osqFile(replaceLocation+length(replaceString):end)], replacementString);

% This will only replace the last instance of replaceString in osqFile:
elseif strmatch(instruction,'last')    
    updatedOsqFile = sprintf([osqFile(1:replaceLocation(end)-1) '%s' osqFile(replaceLocation(end)+length(replaceString):end)], replacementString);

% If all instances of replaceString in osqFile should be replaced:
elseif strmatch(instruction,'all')    
    numberOfLoops = length(replaceLocation);
    for i = 1 : numberOfLoops
        replaceLocation = strfind(osqFile,replaceString);
        osqFile = sprintf([osqFile(1:replaceLocation(1)-1) '%s' osqFile(replaceLocation(1)+length(replaceString):end)], replacementString);
    end
    updatedOsqFile = osqFile;
end

end

