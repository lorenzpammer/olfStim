function smell = startTrial(trialNum, smell)
% smell = startTrial(trialNum, smell)
% This function assumes all information for the current trial are present
% in smell and that these values are correct. From here on no more checking
% whether numbers make sense or not. Will just result in errors or
% incorrect triggering of the vials.
%
% To do: 
% -get the actual timing of events from LASOM and write it into the
%   smell structure.
% - Figure out how to trigger the trial
% - CRITICAL: figure out how to remain in function until the LASOM is
% finished with its task.
% - prompt LASOM to get the maximum flow rate of the Mfcs
% - Continuously get flow rate of MFCs and write them into smell.
%
% lorenzpammer dec 2011


%% Build the lsq file for the current trial
% buildTrialLsq.m will create an lsq file taking into account the
% olfactometerInstructions for the current trial.
trialLsq = fileread('E:\Stephan\Matlab\olfStim\lsq\test.lsq')
% trialLsq = buildTrialLsq(trialNum);
smell.trial(trialNum).trialLsqFile = trialLsq;
% Add the lsq file for the current trial into the smell structure

%% Connect to LASOM and set it up
lasomH = lasomFunctions('connect');


%% Update smell:
if trialNum == 1
%     smell.olfactometerSettings.lasomID = invoke(lasomH,'GetID');
    % - prompt LASOM to get the maximum flow rate of the Mfcs and write
    % into smell.olfactometerSettings
%     [smell.olfactometerSettings.flowRateMfcAir, units] = invoke(lasomH,'GetMfcCapacity',1);
%     [smell.olfactometerSettings.flowRateMfcN, units] = invoke(lasomH,'GetMfcCapacity',2);
end

%% Send lsq file of the current trial to the LASOM

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function
lsqPath = which(callingFunctionName);
lsqPath(length(lsqPath)-length(callingFunctionName):length(lsqPath))=[];
dd = filesep();
lsqPath=[lsqPath dd 'lsq' dd];
clear callingFunctionName

pathTrialLsq = [lsqPath 'trial.lsq'];
lasomFunctions('sendLsqToLasom',lasomH,pathTrialLsq);

%% Start sequencer

lasomFunctions('loadAndRunSequencer',lasomH);

%% Set MFC flow rates


slave = smell.trial(trialNum).slave;
smell = calculateMfcFlowRates(trialNum,smell);
percentOfCapacityAir = smell.trial(trialNum).flowRateMfcAir / smell.olfactometerSettings.maxFlowRateMfcAir * 100;
percentOfCapacityN = smell.trial(trialNum).flowRateMfcN / smell.olfactometerSettings.maxFlowRateMfcNitrogen * 100;
invoke(lasomH,'SetMfcFlowRate',slave,1,percentOfCapacityAir);
invoke(lasomH,'SetMfcFlowRate',slave,2,percentOfCapacityN);

clear percentOfCapacityAir;clear percentOfCapacityN;

%% Let concentrations settle

pause(3) % let settle for 3 seconds

%% Trigger trial:

%% Measure MFC flow rate continuously throughout the trial

 flowRateMfcAir = get(lasomH, 'MfcFlowRateMeasurePercent', 1, 1)
 flowRateMfcN = get(lasomH, 'MfcFlowRateMeasurePercent', 1, 2)



%% Purge at the end of trial

% Extract the time at which purge should start:
settingNames = {smell.trial(trialNum).olfactometerInstructions.name};
index = find(strcmp('purge',settingNames));
purgeTime = smell.trial(trialNum).olfactometerInstructions(index).value;

% if the purge is used, set the mfc flow rate
if smell.trial(trialNum).olfactometerInstructions(index).used
    pause(purgeTime)
    
    % Set mfcs to maximum flow rate:
    invoke(lasomH,'SetMfcFlowRate',slave,1,100);
    invoke(lasomH,'SetMfcFlowRate',slave,2,100);
    
end
%%

disp(['Triggered trial ' num2str(trialNum)])


%% Wait until Sequencer is finished
% Sequencer file (lsq) ends with the command 'EmitStatus' this results in
% the sequencer queuing a status message to the USB host. Here the function
% waits until receiving that message. Then continue.



%% Disconnect from Lasom
release(lasomH)

end