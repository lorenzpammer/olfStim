function startTrial(trialNum)
% startTrial(trialNum)
% This function assumes all information for the current trial are present
% in smell and that these values are correct. From here on no more checking
% whether numbers make sense or not. Will just result in errors or
% incorrect triggering of the vials.
%
% - To do: get the actual timing of events from LASOM and write it into the
% smell structure.
% - Figure out how to trigger the trial
%
% lorenzpammer dec 2011

global smell

%% Build the lsq file for the current trial
% buildTrialLsq.m will create an lsq file taking into account the
% olfactometerInstructions for the current trial.

trialLsq = buildTrialLsq(trialNum);
smell.trial(trialNum).trialLsqFile = trialLsq;
% Add the lsq file for the current trial into the smell structure

%% Connect to LASOM:
% lasomH = lasomFunctions('connect');

%% Send lsq file of the current trial to the LASOM

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function
lsqPath = which(callingFunctionName);
lsqPath(length(lsqPath)-length(callingFunctionName):length(lsqPath))=[];
lsqPath=[lsqPath '/lsq/'];
clear callingFunctionName

pathTrialLsq = [lsqPath 'trial.lsq'];
% lasomFunctions('sendLsqToLasom',lasomH,pathTrialLsq);

%% Start sequencer

% lasomFunctions('loadAndRunSequencer');

%% Set MFC flow rates


slave = smell.trial(trialNum).slave;
calculateMfcFlowRates(trialNum);
percentOfCapacityAir = smell.trial(trialNum).flowRateMfcAir / smell.olfactometerSettings.maxFlowRateMfcAir;
percentOfCapacityN = smell.trial(trialNum).flowRateMfcN / smell.olfactometerSettings.maxFlowRateMfcNitrogen;
% invoke(lasomH,'SetMfcFlowRate',slave,1,percentOfCapacityAir);
% invoke(lasomH,'SetMfcFlowRate',slave,2,percentOfCapacityN);

clear percentOfCapacityAir;clear percentOfCapacityN;

%% Let concentrations settle

pause(3) % let settle for 3 minutes

%% Trigger trial:



%% Purge at the end of trial

% Extract the time at which purge should start:
settingNames = {smell.trial(trialNum).olfactometerInstructions.name};
index = find(strcmp('purge',settingNames));
purgeTime = smell.trial(trialNum).olfactometerInstructions(index).value;

if smell.trial(trialNum).olfactometerInstructions(index).used
    pause(purgeTime)
    
    % Set mfcs to maximum flow rate:
    % invoke(lasomH,'SetMfcFlowRate',slave,1,1);
    % invoke(lasomH,'SetMfcFlowRate',slave,2,1);
    
end
%%

disp(['Triggered trial ' num2str(trialNum)])
    

end