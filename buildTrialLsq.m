function trialLsq = buildTrialLsq(trialNum)
% buildTrialLsq(trialNum)
%   will construct an LSQ file for the current trial using the information
%   from the smell structure for the current trial.
%
% The .lsq files are sequencer files in a language readable by the LASOM
% sequencer. This function allows a flexible creation of the 
%
% This function is called f
%
% lorenzpammer 2011/12

global smell



%% Build the lsq file for this trial

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function in the highest
lsqPath = which(callingFunctionName);
lsqPath(length(lsqPath)-length(callingFunctionName):length(lsqPath))=[];
lsqPath=[lsqPath '/lsq/'];
clear callingFunctionName

coreLsq = fileread([lsqPath 'core.lsq']); % read in the core
trialLsq = coreLsq;

if smell.trial(trialNum).mixture == 0  %
    
    %
    replaceString1 = 'Param, odorValveIndex, 1';
    replaceString2 = 'Label, @startTrial';
    replaceLocation1 = strfind(trialLsq,replaceString1);
    replaceLocation2 = strfind(trialLsq,replaceString2);
    
    
    if isempty(replaceLocation)
        error([replaceString ' not found in lsq file. No updating possible.'])
    end
    if ~isempty(smell.trial(trialNum).vial) % if the odor gating valves are specified
        replaceString1(end) = num2str(smell.trial(trialNum).vial);
        trialLsq(replaceLocation1:replaceLocation1+length(replaceString1)-1) = replaceString1;
        odorValveLsq = fileread([lsqPath 'odorValve.lsq']); % read in the core
        
        trialLsq(replaceLocation2+length(replaceString2)+1 : replaceLocation2+length(replaceString2)+length([odorValveLsq trialLsq(replaceLocation2+length(replaceString2) : end)])) = ...
            [odorValveLsq trialLsq(replaceLocation2+length(replaceString2) : end)];
        
    else
        replaceString1(end) = num2str(0);
        trialLsq(replaceLocation:replaceLocation+length(replaceString1)-1) = replaceString1;
    end
    
    
    
    
elseif smell.trial(trialNum).mixture == 1
    error('Not programmed yet.')
    
else
    error('No information whether the odor is drawn from multiple vials or of one vial.')
end
