function trialLsq = buildTrialLsq(trialNum)
% buildTrialLsq(trialNum)
%   will construct an LSQ file for the current trial using the information
%   from the smell structure for the current trial.
%
% The .lsq files are sequencer files in a language readable by the LASOM
% sequencer. This function allows a flexible creation of the
%
% This function is called from startTrial.m
%
% - To DO: Check what happens if two actions start at the same time
% - Fix how the digital outputs are triggered on LASOM. For now I'm using
% the dummy output $DigOut1 but I think this can only be set to high or low
% not to give out 8bit binary numbers.
%
% lorenzpammer 2011/12

global smell



%% Build the lsq file for this trial

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function
lsqPath = which(callingFunctionName);
lsqPath(length(lsqPath)-length(callingFunctionName):length(lsqPath))=[];
lsqPath=[lsqPath '/lsq/'];
clear callingFunctionName

coreLsq = fileread([lsqPath 'core.lsq']); % read in the core lsq file (a text file)
trialLsq = coreLsq; % Use trial Lsq for creating the trial specific Lsq


%% Create the lsq file for the current trial:
% Check whether the odor presented in this trial is a pure odor or whether
% odors from different slaves have to be mixed:
if smell.trial(trialNum).mixture == 0
    %% Define the parameters in the lsq file
    
    % 1. Add the current trial number to the lsq file
    % Rewrite the trialLsq with the correct value in the parameter
    % definition for the current trial
    replaceString = 'Param, trialNum, 1';
    replacementString = [replaceString(1:end-1) num2str(trialNum)];
    trialLsq = replacePlaceHolderInLsq(trialLsq,replaceString,replacementString);
    
    % 2. change parameter from which vial the odor is drawn:
    if ~isempty(smell.trial(trialNum).vial)
        % Rewrite the trialLsq with the correct value in the parameter
        % definition for the current trial
        replaceString = 'Param, odorValveIndex, 1';
        replacementString = [replaceString(1:end-1) num2str(smell.trial(trialNum).vial)];
        trialLsq = replacePlaceHolderInLsq(trialLsq,replaceString,replacementString);
        
        % if no odor gating valves have to be opened (air is presented)
    elseif isempty(smell.trial(trialNum).vial)
        replacementString = [replaceString(1:end-1) num2str(0)];
        trialLsq = replacePlaceHolderInLsq(trialLsq,replaceString,replacementString);
    end
    
    % 3. change parameter in which slave the vial is located. The slave
    % parameter only applies to odor gating valves, as all other valves
    % (final, sniffing, etc.) are on slave 1
    if ~isempty(smell.trial(trialNum).vial)
        % Rewrite the trialLsq with the correct value in the parameter
        % definition for the current trial
        replaceString = 'Param, slave, 1';
        replacementString = [replaceString(1:end-1) num2str(smell.trial(trialNum).slave)];
        trialLsq = replacePlaceHolderInLsq(trialLsq,replaceString,replacementString);
    end
    
    
    
    %% Sort the actions according to their timing
    
    % Define the actions and the sequence of actions of the
    % olfactometer and create the sequencer code to carry them out
    
    
    % Find the mfcTotalFlow field. Make a logical indexing vector
    % denoting the actions (fields), that have to be dealt with in the
    % sequencer:
    olfactometerActionsIndex = ~strcmp('mfcTotalFlow',{smell.trial(trialNum).olfactometerInstructions.name});
    % Timing of the different actions
    timesOfAction = [smell.trial(trialNum).olfactometerInstructions.value];
    % Sort the actions in the sequence in which they will be triggered
    % during the trial:
    [sortedTimesOfAction,sequenceIndexOfActions]=sort(timesOfAction);
    
    %%
    % Go through a sorted loop, and add the sequencer commands for the
    % each action to the end of the lsq file. The order of the
    % resulting sequence of actions corresponds to the defined timing
    % of the actions.
    actionNumber=0;
    loopIteration=0;
    actionLsq = [];
    for i = sequenceIndexOfActions
        loopIteration = loopIteration+1;
        % if the current action is not handled by the sequencer skip it
        if ~ismember(i,find(olfactometerActionsIndex))
            continue % to next iteration of for loop
        end
        
        % Add 1 to the action counter.
        actionNumber = actionNumber+1;
        smell.trial(trialNum).olfactometerInstructions(i).name
        
        % If the action is used:
        if smell.trial(trialNum).olfactometerInstructions(i).used
            if actionNumber==1
                %    read the lsq file that includes the command for the current
                % action in the1 loop iteration
                currentActionLsq = fileread([lsqPath smell.trial(trialNum).olfactometerInstructions(i).name '.lsq']);
                % in the first action of a trial the wait time is the
                % time when the first action should be triggered:
                waitTime = smell.trial(trialNum).olfactometerInstructions(i).value;
                currentActionLsq = sprintf([';\n wait, %d \n' currentActionLsq], waitTime);
                % Start the timer in the beginning of the trial:
                currentActionLsq = sprintf([';\n startTimer, $Timer1 ; Starts the timer for the trial \n' currentActionLsq]);
                
                actionLsq = currentActionLsq;
                
                clear waitTime currentActionLsq
                
                
            else
                
                % Read the lsq file that includes the command for the current
                % action in the loop iteration
                currentActionLsq = fileread([lsqPath smell.trial(trialNum).olfactometerInstructions(i).name '.lsq']);
                
                
                % Read in the sequencer code, that allows to check
                % whether the next action should be triggered or
                % whether it should wait.
                timeLapseLsq = fileread([lsqPath 'timeLapse.lsq']);
                
                % First change the timing of the when it lapses:
                replaceString = 'MYVAL';
                waitTime = num2str(smell.trial(trialNum).olfactometerInstructions(i).value);
                timeLapseLsq = replacePlaceHolderInLsq(timeLapseLsq,replaceString, waitTime);
                clear waitTime
                
                % Now change the label to jump to, when it lapses out:
                replaceString = 'lapsedOut';
                replacementString = [replaceString num2str(actionNumber)];
                timeLapseLsq = replacePlaceHolderInLsq(timeLapseLsq,replaceString,replacementString);
                
                % Add the label marking where to continue, once the
                % timer lapses out:
                label = ['label, ' replacementString];
                currentActionLsq = sprintf([timeLapseLsq '\n' label '\n' currentActionLsq]);
                
                clear  replaceString replacementString timeLapseLsq
                
                % Add the command to send a timestamp:
                sendTimestampLsq = fileread([lsqPath 'sendTimestamp.lsq']);
                replacementString = num2str(smell.trial(trialNum).olfactometerInstructions(i).timeStampID);
                sendTimestampLsq = replacePlaceHolderInLsq(sendTimestampLsq,'MYTIMESTAMP',replacementString);
                % Add the command to send a timestamp to the
                % currentActionLsq:
                currentActionLsq = [currentActionLsq sendTimestampLsq];
                
                
                % Append currentActionLsq to actionLsq
                actionLsq = [actionLsq currentActionLsq];
            end
            
        end
    end
    clear loopIteration currentActionLsq actionNumber ...
        timeLapseLsq sendTimestampLsq sortedTimesOfAction sequenceIndexOfActions
    
    % Add the sequence of actions (actionLsq) for the current trial into
    % the lsq file for the current trial (trialLsq):
    replaceString = '; eof';
    trialLsq = replacePlaceHolderInLsq(trialLsq,replaceString, actionLsq);
    
    
    disp(trialLsq)
    
elseif smell.trial(trialNum).mixture == 1
    
    error(': Creating Lsq files for mixtures is not yet programmed.')
    
else
    error('No information whether the odor is drawn from multiple vials or of one vial.')
end

end


function updatedLsqFile = replacePlaceHolderInLsq(lsqFile,replaceString,replacementString)
% updatedLsqFile = replacePlaceHolderInLsq(lsqFile, replaceString, replacementString)
% This function replaces the string defined by replaceString with the
% string defined in replacementString in the lsq file and oututs the
% updated lsq file. All 3 arguments are necessary.
%
%%

if nargin < 3
    error('Not enough input arguments. Type >> help replacePlaceHolderInLsq to get information. ')
end

%% 

replaceLocation = strfind(lsqFile,replaceString);

if isempty(replaceLocation)
    error([replaceString ' not found in lsq file. No updating possible.'])
end

updatedLsqFile = sprintf([lsqFile(1:replaceLocation-1) '%s' lsqFile(replaceLocation+length(replaceString):end)], replacementString);

end
