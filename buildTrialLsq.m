function trialLsq = buildTrialLsq(trialNum,smell)

% trialLsq = buildTrialLsq(trialNum,smell)
%   will construct an LSQ file for the current trial using the information
%   from the smell structure for the current trial. It returns the lsq file
%   for the current trial and saves it in the /lsq folder in the olfStim
%   directory.
%
% The .lsq files are sequencer files in a language readable by the LASOM
% sequencer. This function allows a flexible creation of the
%
% This function is called from startTrial.m
%
% TO DO:
% - Fix how the digital outputs are triggered on LASOM. For now I hacked
% the timestamp triggers into the lsq files. 
% - Support presenting mixtures.
%
% lorenzpammer 2011/12

%% Build the lsq file for this trial

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function
lsqPath = which(callingFunctionName);
lsqPath(length(lsqPath)-length(callingFunctionName):length(lsqPath))=[];
lsqPath=[lsqPath filesep 'lsq' filesep];
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
    % As the sequencer defines the vial#1 as the dummy vial, and vial#2 as
    % the first odor vial, we have to add 1 to the vial number.
    if ~isempty(smell.trial(trialNum).vial)
        % Rewrite the trialLsq with the correct value in the parameter
        % definition for the current trial
        replaceString = 'Param, odorValveIndex, 1';
        replacementString = [replaceString(1:end-1) num2str(smell.trial(trialNum).vial + 1)];
        trialLsq = replacePlaceHolderInLsq(trialLsq,replaceString,replacementString);
        
        % if no odor gating valves have to be opened (air is presented)
    elseif isempty(smell.trial(trialNum).vial)
        replaceString = 'Param, odorValveIndex, 1';
        replacementString = [replaceString(1:end-1) num2str(0)];
        trialLsq = replacePlaceHolderInLsq(trialLsq,replaceString,replacementString);
    end
    
    % 3. change parameter in which slave the vial is located. The slave
    % parameter only applies to odor gating valves, as all other valves
    % (final, sniffing, etc.) are on slave 1
    if ~isempty(smell.trial(trialNum).vial)
        % Rewrite the trialLsq with the correct value in the parameter
        % definition for the current trial
        replaceString = 'Param, slaveIndex, 1';
        replacementString = [replaceString(1:end-1) num2str(smell.trial(trialNum).slave)];
        trialLsq = replacePlaceHolderInLsq(trialLsq,replaceString,replacementString);
    end
    
    
    %% Sort the actions according to their timing
    
    % Define the actions and the sequence of actions of the
    % olfactometer and create the sequencer code to carry them out
    
    
    % Find the mfcTotalFlow field. Make a logical indexing vector
    % denoting the actions (fields), that have to be dealt with in the
    % sequencer:
    ai{1} = ~strcmp('mfcTotalFlow',{smell.trial(trialNum).olfactometerInstructions.name});
    ai{2} = ~strcmp('purge',{smell.trial(trialNum).olfactometerInstructions.name});
    olfactometerActionsIndex = logical(ai{1} .* ai{2});
    clear ai;
    % Timing of the different actions
    timesOfAction = {smell.trial(trialNum).olfactometerInstructions.value};
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
        
        % If the action is used:
        if smell.trial(trialNum).olfactometerInstructions(i).used
            
            % Add 1 to the action counter.
            actionNumber = actionNumber+1;
            
            if actionNumber==1
                %    read the lsq file that includes the command for the current
                % action in the1 loop iteration
                currentActionLsq = fileread([lsqPath smell.trial(trialNum).olfactometerInstructions(i).name '.lsq']);
                
                % If the first action tzpe is called multiple times within
                % a trial, the first action of the trial will also be the
                % first of the multiple calls of the same action. Therefore
                % take the first value from the instructions:
                currentActionValueIndex = 1;
                
                % in the first action of a trial the wait time is the
                % time when the first action should be triggered:
                waitTime = smell.trial(trialNum).olfactometerInstructions(i).value(currentActionValueIndex)*1000;% *1000 because LASOM expects ms, values in smell are in s
                currentActionLsq = sprintf([';\nwait, %d \n' currentActionLsq], waitTime);
                % Start the timer in the beginning of the trial:
                currentActionLsq = sprintf([';\nstartTimer, 2 ; Starts the timer for the trial \n' currentActionLsq]);
                
%                 % Add the command to send a timestamp:
%                 sendTimestampLsq = fileread([lsqPath 'sendTimestamp.lsq']);
%                 replacementString = num2str(smell.trial(trialNum).olfactometerInstructions(i).timeStampID);
%                 sendTimestampLsq = replacePlaceHolderInLsq(sendTimestampLsq,'MYTIMESTAMP',replacementString);
%                 % Add the command to send a timestamp to the
%                 % currentActionLsq:
%                 currentActionLsq = [currentActionLsq sendTimestampLsq];
                
                actionLsq = currentActionLsq;
                
                clear waitTime currentActionLsq
                
                
            else
                clear currentActionLsq
                % Read the lsq file that includes the command for the current
                % action in the loop iteration
                currentActionLsq = fileread([lsqPath smell.trial(trialNum).olfactometerInstructions(i).name '.lsq']);
                
                if isempty(currentActionLsq) 
                   errormsg=sprintf('No lsq template for the current action found.\nCurrent action: %s',smell.trial(trialNum).olfactometerInstructions(i).name) 
                   error(errormsg)
                end
                % Read in the sequencer code, that allows to check
                % whether the next action should be triggered or
                % whether it should wait.
                timeLapseLsq = fileread([lsqPath 'timeLapse.lsq']);
                
                % In cases where one action (opening a valve) is called
                % multiple times within a trial, we have to know which
                % of the several times of action calling we're in now:
                currentActionCallsInTrial = find(sequenceIndexOfActions==i);
                if length(currentActionCallsInTrial)>1
                    currentActionValueIndex = find(currentActionCallsInTrial == loopIteration);
                else
                    currentActionValueIndex = 1;
                end
                % First change the timing of the when it lapses:
                replaceString = 'MYVAL';
                waitTime = num2str(smell.trial(trialNum).olfactometerInstructions(i).value(currentActionValueIndex)*1000); % *1000 because LASOM expects ms, values in smell are in s
                timeLapseLsq = replacePlaceHolderInLsq(timeLapseLsq,replaceString, waitTime);
                clear waitTime
                
                % Now change the label to jump to, when it lapses out:
                replaceString = '@lapsedOut';
                replacementString = [replaceString num2str(actionNumber)];
                timeLapseLsq = replacePlaceHolderInLsq(timeLapseLsq,replaceString,replacementString);
                
                % Add the label marking where to continue, once the
                % timer lapses out:
                label = ['label, ' replacementString];
                currentActionLsq = sprintf([timeLapseLsq '\n' label '\n' currentActionLsq]);
                
                clear  replaceString replacementString timeLapseLsq
                
%                 % Add the command to send a timestamp:
%                 sendTimestampLsq = fileread([lsqPath 'sendTimestamp.lsq']);
%                 replacementString = num2str(smell.trial(trialNum).olfactometerInstructions(i).timeStampID);
%                 sendTimestampLsq = replacePlaceHolderInLsq(sendTimestampLsq,'MYTIMESTAMP',replacementString);
%                 % Add the command to send a timestamp to the
%                 % currentActionLsq:
%                 currentActionLsq = [currentActionLsq sendTimestampLsq];
                
                
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
    
    
%     disp(trialLsq)
    
elseif smell.trial(trialNum).mixture == 1
    error(': Creating Lsq files for mixtures is not yet programmed.')
    
else
    error('No information whether the odor is drawn from multiple vials or of one vial.')
end



%% Save trialLsq file:
fid = fopen([lsqPath 'trial.lsq'],'w');
fprintf(fid,'%s',trialLsq);
fclose(fid);
clear fid;

end

            %% SUBFUNCTIONS
    
%% Utility functions

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

