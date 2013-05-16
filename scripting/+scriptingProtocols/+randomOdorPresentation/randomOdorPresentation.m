function randomOdorPresentation(numberOfTrials,sessionInstructions)
% randomOdorPresentation(numberOfTrials,sessionInstructions)
%
% This scripting protocol, will randomly draw for every trial one odor from
% the odorants provided in the global smell.olfactometerOdors.sessionOdors
% structure. It will then present this odor and wait for the
% intertrialInterval defined in smell.trial(n).sessionInstructions(x).value
% x being the index of the interTrialInterval instruction. It will stop
% after numberOfTrials have been executed.
%
% lorenzpammer 2013/05


%% Set globals

global smell

%% Define the name of the scripting protocol
tmp = dbstack;
currentFunctionName = tmp.name;
protocolName = ['scripting.' currentFunctionName];


%% Start the execution of trials

for trialNum = 1 : numberOfTrials
    % Save the temporary smell structure in case anything happens:
    protocolUtilities.saveTemporarySmell(smell);
    
    % Pick a random odor from the odors loaded in the olfactometer:
    randomIndex = ceil(rand*length(smell.olfactometerOdors.sessionOdors));
    trialOdor = smell.olfactometerOdors.sessionOdors(randomIndex);
    
    % Update the smell structure
    buildSmell('updateFields',[],trialOdor,trialNum,protocolName,[],...
        'trialOdor','trialNum','olfactometerInstructions','sessionInstructions',sessionInstructions,...
        'stimProtocol','time','maxFlowRateMfc','olfactometerID','io');
    
    % Start to execute the trial
    smell = startTrial(trialNum,smell);
    
    % Wait for the provided inter trial interval before jumping to the next
    % loop iteration.
    isiIndex=strcmp('interTrialInterval',{smell.trial(trialNum).sessionInstructions.name});
    fprintf('Waiting for the inter trial interval of %d seconds.\n',smell.trial(trialNum).sessionInstructions(isiIndex).value);
    pause(smell.trial(trialNum).sessionInstructions(isiIndex).value)
end

end