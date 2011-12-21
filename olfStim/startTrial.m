function startTrial(trialNum)
% startTrial(trialNum)
% This function assumes all information for the current trial are present
% in smell and that these values are correct. From here on no more checking
% whether numbers make sense or not. Will just result in errors or
% incorrect triggering of the vials.
%
% lorenzpammer dec 2011

global smell

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Build the lsq file for this trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function in the highest
path = which(callingFunctionName);
path(length(path)-length(callingFunctionName):length(path))=[];
path=[path '/lsq/'];
clear callingFunctionName

coreLsq = fileread([path 'core.lsq']); % read in the core 
trialLsq = coreLsq;

if smell.trial(trialNum).mixture == 0  %
    
    % 
    replaceString = 'Param, odorValveIndex, 1';
    replaceLocation = strfind(trialLsq,replaceString);
    if isempty(replaceLocation)
        error([replaceString ' not found in lsq file. No updating possible.'])
    end
    replaceString(end) = num2str(smell.trial(trialNum).vial);
    trialLsq(replaceLocation:replaceLocation+length(replaceString)-1) = replaceString;
    
    
    
    
    
    
elseif smell.trial(trialNum).mixture == 1
    error('Not programmed yet.')
    
else
    error('No information whether the odor is drawn from multiple vials or of one vial.')
end



end