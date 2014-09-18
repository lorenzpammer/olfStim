function presentPredefinedOdorList(smellFilename)
% presentPredefinedOdorList(smellFilename)
%
% This scripting protocol will load the smell structure defined in
% smellFilename and then execute one by one every trial defined in the
% smell structure. It will stop once all trials defined in smell have been
% executed.
% Some fields of smell.trial will be updated with the execution of the
% trial. Namely: name of stimulation protocol, time of execution,
% olfactometerID, trial log.
%
% lorenzpammer 2014/09


%% Set globals

global smell

smell = []; % If there is any global smell file left clear it, below we'll load the defined smell.

%% Set variables and paths

import scriptingProtocols.* % Import the scripting protocols
import scriptingProtocols.scriptingUtilityFunctions.* % Import common utility functions for all scripting protocols

%% Load the predefined list of odorants in form of a smell file

load(smellFilename);

%% Define the name of the scripting protocol
% All scripting protocols should start have names starting with
% 'scripting.'.

tmp = dbstack;
currentFunctionName = tmp.name;
protocolName = ['scripting.' currentFunctionName];

%% Start the execution of trials

for trialNum = 1 : length(smell.trial)
    % Save the temporary smell structure in case anything happens:
    protocolUtilities.saveTemporarySmell(smell);
    
    % Update the smell structure. Instruct which fields should be updated
    buildSmell('updateFields',[],[],trialNum,protocolName,[],...
        'trialNum','stimProtocol','time','olfactometerID','log');
    
    % Start to execute the trial
    smell = startTrial(trialNum,smell);
    
    % Wait for the provided inter trial interval before jumping to the next
    % loop iteration.
    isiIndex=strcmp('interTrialInterval',{smell.trial(trialNum).sessionInstructions.name});
    fprintf('Waiting for the inter trial interval of %d seconds.\n',smell.trial(trialNum).sessionInstructions(isiIndex).value);
    pause(smell.trial(trialNum).sessionInstructions(isiIndex).value)
end

end