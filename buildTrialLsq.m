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

% Check whether the odor presented in this trial is a pure odor or whether
% odors from different slaves have to be mixed:
if smell.trial(trialNum).mixture == 0  
    
        % Define the parameters in the lsq file
    
    % 1. change parameter from which vial the odor is drawn:
    replaceString = 'Param, odorValveIndex, 1';
    replaceLocation = strfind(trialLsq,replaceString);
    if isempty(replaceLocation)
        error([replaceString ' not found in lsq file. No updating possible.'])
    end
    if ~isempty(smell.trial(trialNum).vial)
        replaceString(end) = num2str(smell.trial(trialNum).vial);
        trialLsq(replaceLocation:replaceLocation+length(replaceString)-1) = replaceString;
    
    % if no odor gating valves have to be opened (air is presented)
    else 
        replaceString(end) = num2str(0);
        trialLsq(replaceLocation:replaceLocation+length(replaceString)-1) = replaceString;
    end
    
    % 2. change parameter in which slave the vial is located. The slave
    % parameter only applies to odor gating valves, as all other valves
    % (final, sniffing, etc.) are on slave 1
    replaceString = 'Param, slave, 1';
    replaceLocation = strfind(trialLsq,replaceString);
    if isempty(replaceLocation)
        error([replaceString ' not found in lsq file. No updating possible.'])
    end
    
    % If an odor is presented
    if ~isempty(smell.trial(trialNum).vial)
        replaceString(end) = num2str(smell.trial(trialNum).slave);
        trialLsq(replaceLocation:replaceLocation+length(replaceString)-1) = replaceString;
    
    % if no odor gating valves have to be opened (air is presented)
    else 
        replaceString(end) = num2str(0);
        trialLsq(replaceLocation:replaceLocation+length(replaceString)-1) = replaceString;
    end
    
        % Define the actions in the lsq file
    
    % 1. Add the command to trigger the odor gating valves
    replaceString = 'Label, @startTrial';
    replaceLocation = strfind(trialLsq,replaceString);
    
    % if the odor gating valves are specified:
    if ~isempty(smell.trial(trialNum).vial)
        
        odorValveLsq = fileread([lsqPath 'odorValve.lsq']); % read in the core
        
        trialLsq(replaceLocation+length(replaceString)+1 : replaceLocation+length(replaceString)+length([odorValveLsq trialLsq(replaceLocation+length(replaceString) : end)])) = ...
            [odorValveLsq trialLsq(replaceLocation+length(replaceString) : end)];
    end
    
    % 2. Send trial start timestamp via digital 
    replaceString = '; eof';
    replaceLocation = strfind(trialLsq,replaceString);
    odorValveLsq = fileread([lsqPath 'odorValve.lsq']); % read in the core
    
    trialLsq(replaceLocation+length(replaceString)+1 : replaceLocation+length(replaceString)+length([odorValveLsq trialLsq(replaceLocation+length(replaceString) : end)])) = ...
        [odorValveLsq trialLsq(replaceLocation+length(replaceString) : end)];
    
    
    
    
    
    
    
    
    disp(trialLsq)
    
elseif smell.trial(trialNum).mixture == 1
    
    error(': Creating Lsq files for mixtures is not yet programmed.')
    
else
    error('No information whether the odor is drawn from multiple vials or of one vial.')
end
