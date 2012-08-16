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
trialLsq = buildTrialLsq(trialNum);

% Add the lsq file for the current trial into the smell structure:
smell.trial(trialNum).trialLsqFile = trialLsq;

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

% Clear old sequences, send new one to LASOM and compile it. 
lasomFunctions('sendLsqToLasom',lasomH,pathTrialLsq);


%% Set MFC flow rates

slave = smell.trial(trialNum).slave;
smell = calculateMfcFlowRates(trialNum,smell);
percentOfCapacityAir = smell.trial(trialNum).flowRateMfcAir / smell.olfactometerSettings.maxFlowRateMfcAir * 100;
percentOfCapacityN = smell.trial(trialNum).flowRateMfcN / smell.olfactometerSettings.maxFlowRateMfcNitrogen * 100;
invoke(lasomH,'SetMfcFlowRate',slave,1,percentOfCapacityAir);
invoke(lasomH,'SetMfcFlowRate',slave,2,percentOfCapacityN);

clear percentOfCapacityAir percentOfCapacityN

%% Start sequencer

lasomFunctions('loadAndRunSequencer',lasomH);


%% Trigger trial:
% Triggering is done from an external device.


%% Measure MFC flow rate continuously throughout the trial

settingNames = {smell.trial(trialNum).olfactometerInstructions.name};
index = ~strcmp('mfcTotalFlow',settingNames);
olfactometerTimes = [smell.trial(trialNum).olfactometerInstructions(index).value];
timeOfLastAction = max(olfactometerTimes);
measurementInterval = 0.1; % measurement interval in seconds
% Define timepoints when Mfc flow rate should be measured. Measure every
% 100 ms, from the start of the trial (0s) to 3 seconds after the last
% action.
measurementPoints = 0:0.1:timeOfLastAction+3; 
smell.trial(trialNum).lasomEventLog.flowRateMfcAir(1,:) = measurementPoints;
smell.trial(trialNum).lasomEventLog.flowRateMfcN(1,:) = measurementPoints;

% Set up the timer, and its callbacks for measuring the mfc flow
mfcMeasureTimer = timer('ExecutionMode','fixedRate','Period',measurementInterval,...
    'StartDelay',0,'TasksToExecute',length(measurementPoints),...
    'TimerFcn',@measureMfcFlowRate,'StopFcn',@measureMfcFlowStopped);

start(mfcMeasureTimer)

% Callback functions of timer:
    function measureMfcFlowRate(varargin)
        % Every 100 ms, jump into this function measure the mfc flow rates
        % and write the returned values into the smell structure:
        measurementNo = get(mfcMeasureTimer,'TasksExecuted');
        smell.trial(trialNum).lasomEventLog.flowRateMfcAir(2,measurementNo) = ...
            get(lasomH, 'MfcFlowRateMeasurePercent', slave, 1);
        smell.trial(trialNum).lasomEventLog.flowRateMfcN(2,measurementNo) = ...
            get(lasomH, 'MfcFlowRateMeasurePercent', slave, 2);
    end
    function measureMfcFlowStopped(varargin)
        % At the end of the trial, after last measurement of mfc flow, jump
        % into this function and stop the timer.
        stop(mfcMeasureTimer)
        delete(mfcMeasureTimer)
        release(lasomH)
    end

clear measurementPoints index olfactometerTimes timeOfLastAction measurementInterval

%% Purge at the end of trial

% Extract the time at which purge should start:
settingNames = {smell.trial(trialNum).olfactometerInstructions.name};
index = find(strcmp('purge',settingNames));
purgeTime = smell.trial(trialNum).olfactometerInstructions(index).value;

% if the purge is used, set the mfc flow rate at the time defined as the
% purge time point:
if smell.trial(trialNum).olfactometerInstructions(index).used
    
    purgeTimer = timer('ExecutionMode','singleShot','StartDelay',purgeTime,...
        'TimerFcn',@purgeOlfactometer,'StopFcn',@purgeTimerStopped)
    
    start(purgeTimer)
    
end

% Callback functions of timer:
    function purgeOlfactometer(varargin)
        % At the timepoint defined by purge time, jump into this callback
        % function and set mfcs to maximum flow rate: 
        invoke(lasomH,'SetMfcFlowRate',slave,1,100);
        invoke(lasomH,'SetMfcFlowRate',slave,2,100);
    end
    function purgeTimerStopped(varargin)
        stop(purgeTimer)
        delete(purgeTimer)
    end

%% Wait until Sequencer is finished
% Sequencer file (lsq) ends with the command 'EmitStatus' this results in
% the sequencer queuing a status message to the USB host. Here the function
% waits until receiving that message. Then continue.
% For now write the release command in the stop function of the mfc
% measurement.



%% Disconnect from Lasom


end