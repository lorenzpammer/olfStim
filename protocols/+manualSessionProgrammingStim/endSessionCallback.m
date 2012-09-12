function endSessionCallback(~,~,callbackFunctionName)
%
% This function will remove all smell trials which have not been executed
% at the timepoint endSession Button was pressed.
% 
% lorenzpammer september 2012


%%

global smell
global trialNum

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Delete the non-executed trials from the progress figure

numberOfNotExecutedTrials = length(smell.trial) - trialNum;
protocolUtilities.progressPanel(h,'remove',[],[],'numberOfTrialsToRemove',numberOfNotExecutedTrials);


%% Delete entries from smell
% If 
if length(smell.trial) > trialNum
    smell.trial(trialNum+1 : end) = [];
end


end