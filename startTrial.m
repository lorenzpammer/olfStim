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
% - prompt LASOM to get the maximum flow rate of the Mfcs
% - Continuously get flow rate of MFCs and write them into smell. I'm doing
% this now but variables are not returned from callbacks.
%
% lorenzpammer dec 2011

%% Fetch some variables from the gui appdata
% Extract the gui handle structure from the appdata of the figure:
h = appdataManager('olfStimGui','get','h');
% Extract the lasom handle from the appdata of the figure:
lasomH = appdataManager('olfStimGui','get','lasomH');

%% 
% Check whether lasomH has not been released properly. If so, close it.
if iscom(lasomH)
    disp('The connection to the LASOM wasn''t released properly in a previous trial. Closing it now.')
    release(lasomH);
end
clear lasomH;

%% Build the lsq file for the current trial
% buildTrialLsq.m will create an lsq file taking into account the
% olfactometerInstructions for the current trial.
%trialLsq = buildTrialLsq(trialNum,smell);

% Add the lsq file for the current trial into the smell structure:
%smell.trial(trialNum).trialLsqFile = trialLsq;

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function
lsqPath = which(callingFunctionName);
lsqPath(length(lsqPath)-length(callingFunctionName):length(lsqPath))=[];
lsqPath=[lsqPath filesep 'lsq' filesep];
clear callingFunctionName
trialLsq = fileread([lsqPath 'test.lsq']);

%% Connect to LASOM and set it up
lasomFunctions('connect');

%% Get the lasom handle from appdata after connecting to LASOM
% Extract the lasom handle from the appdata of the figure:
lasomH = appdataManager('olfStimGui','get','lasomH');

%% Update smell:
if trialNum == 1
    smell.olfactometerSettings.lasomID = lasomH.GetID;
    % - prompt LASOM to get the maximum flow rate of the Mfcs and write
    % into smell.olfactometerSettings
    %     [smell.olfactometerSettings.flowRateMfcAir, units] = lasomH.GetMfcCapacity(1,1,);
    %     [smell.olfactometerSettings.flowRateMfcN, units] = get(lasomH,'GetMfcCapacity'1,2,);
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
lasomFunctions('sendLsqToLasom',pathTrialLsq);


%% Set MFC flow rates

slave = smell.trial(trialNum).slave;
smell = calculateMfcFlowRates(trialNum,smell);
percentOfCapacityAir = smell.trial(trialNum).flowRateMfcAir / smell.olfactometerSettings.maxFlowRateMfcAir * 100;
percentOfCapacityN = smell.trial(trialNum).flowRateMfcN / smell.olfactometerSettings.maxFlowRateMfcNitrogen * 100;
invoke(lasomH,'SetMfcFlowRate',slave,1,percentOfCapacityAir);
invoke(lasomH,'SetMfcFlowRate',slave,2,percentOfCapacityN);

clear percentOfCapacityAir percentOfCapacityN

%% Start sequencer

lasomFunctions('loadAndRunSequencer');
% clear a
% for i = 1:150
%    a(1,i) =  get(lasomH,'SeqUpdateEnable');
%    a(2,i) = get(lasomH,'SeqUpdateVarState',1);
%     pause(0.1)
% end

% Trigger trial:
%Triggering is done from an external device.

%% Prepare for timer action

% Delete all old timers
try
    stop(timerfindall);
end
delete(timerfindall);


%% Measure MFC flow rate continuously throughout the trial
% Starting and stopping the measurement

% Define timepoints when Mfc flow rate should be measured. Measure every
% x seconds, from the start of the trial (0s) to the end, defined by the end
% of the sequencer.
% Problem, that measuring takes quite a long time, therefore long
% intervals:
measurementInterval = 2; % measurement interval in seconds
slave = smell.trial(trialNum).slave;


% Set up the timer, and its callbacks for measuring the mfc flow
mfcMeasureTimer = timer('ExecutionMode','fixedRate','Period',measurementInterval,...
    'StartDelay',0,'TasksToExecute',Inf,...
    'TimerFcn',@measureMfcFlowRate,'StopFcn',@measureMfcFlowStopped,...
    'BusyMode','error','ErrorFcn',@measureMfcErrorFcn);

% Start the timer, only once the sequencer received the trial start signal.
% Check for this with another timer (readLasomStatusTimer - see below)
% ticID = tic;
% set(mfcMeasureTimer,'UserData',ticID);
% start(mfcMeasureTimer);
% pause(5);
% if isvalid(mfcMeasureTimer)
%     stop(mfcMeasureTimer)
% end


% Callback functions of timer:
    function measureMfcFlowRate(obj,event)
        % Every 100 ms, jump into this function measure the mfc flow rates
        % and write the returned values into the smell structure:
        measurementNo = get(mfcMeasureTimer,'TasksExecuted');
        elapsedTime = toc(get(mfcMeasureTimer,'UserData'));
        smell.trial(trialNum).lasomEventLog.flowRateMfcAir(1,measurementNo) = ...
            elapsedTime;
        smell.trial(trialNum).lasomEventLog.flowRateMfcN(1,measurementNo) = ...
            elapsedTime;
        smell.trial(trialNum).lasomEventLog.flowRateMfcAir(2,measurementNo) = ...
            get(lasomH, 'MfcFlowRateMeasurePercent', slave, 1);
        smell.trial(trialNum).lasomEventLog.flowRateMfcN(2,measurementNo) = ...
            get(lasomH, 'MfcFlowRateMeasurePercent', slave, 2);
        disp('measuring flow');
    end
    function measureMfcFlowStopped(varargin)
        % At the end of the trial, after last measurement of mfc flow, jump
        % into this function and stop the timer.
         stop(mfcMeasureTimer);
        delete(mfcMeasureTimer);
                disp('mfcMeasure timer stopped');
    end
    function measureMfcErrorFcn(~,~)
        warning('Can''t fulfill MFC measuring requests at the set interval. Giving up.')
        stop(mfcMeasureTimer)
    end


clear measurementPoints index olfactometerTimes timeOfLastAction measurementInterval



%% Read status messages coming from LASOM
% Sequencer file (lsq) ends with the command 'EmitStatus' this results in
% the sequencer queuing a status message to the USB host. Here the function
% waits until receiving that message. Then continue.

readStatusInterval = 1.5; % measurement interval in seconds 1000Hz
tasksToExecute = 10e7; % this high number is a hack, because if infinite tasks should be executed one cannot hold the function until the timer is done.
% Set up the timer, and its callbacks for measuring the mfc flow
readLasomStatusTimer = timer('ExecutionMode','fixedRate','Period',readStatusInterval,...
    'StartDelay',0,'TasksToExecute',tasksToExecute,...
    'BusyMode','error','ErrorFcn',@readLasomStatusErrorFcn,...
    'TimerFcn',{@readLasomStatusUntilTrialStart},'StopFcn',{@trialStarted});

start(readLasomStatusTimer)

%  pause(20);
% if isvalid(readLasomStatusTimer)
%  disp('stopped lasom timer from timeout')
%     stop(readLasomStatusTimer)
%     release(lasomH)
% end
% if isvalid(mfcMeasureTimer)
%  disp('stopped mfc timer from timeout')
%     stop(mfcMeasureTimer)
%     release(lasomH)
% end
% 

wait(readLasomStatusTimer) % keeps function active until timer stops (once sequencer is idle)

delete(readLasomStatusTimer)

if iscom(lasomH)
    release(lasomH)
end
if ~isempty(timerfindall)
    delete(timerfindall)
end

%% Callback functions of timer:
    function readLasomStatusUntilTrialStart(obj,event)
        % Every 100 ms, jump into this function and read the last emitted
        % status:
        measurementNo = get(readLasomStatusTimer,'TasksExecuted');
        
        lasomStatus = get(lasomH,'SeqUpdateEnable')
        startVariableStatus = get(lasomH,'SeqUpdateVarState',1)
%         disp('reading')
        
        if lasomStatus == 1 && ...
                startVariableStatus == 1;
            % If the variable with index 1 ($Var1) is set to 1, this means
            % the sequencer has started to execute the trial (eg after
            % exiting the initial whileloop).
            
            disp('Starting mfc measuring')
            ticID = tic;
            set(mfcMeasureTimer,'UserData',ticID);
            start(mfcMeasureTimer);
            
            stop(readLasomStatusTimer)
            fprintf('Trial %d started.\n',trialNum)
        end
        if measurementNo >= 2 && (lasomStatus == 205 || startVariableStatus == 205)
            warning('LASOM throws error 205 at reading status. Stopped reading status & measuring flow. Not purging.')
            
            stop(mfcMeasureTimer)
            % Release the connection to the olfactometer
            stop(readLasomStatusTimer)
%             delete(readLasomStatusTimer)
            
            release(lasomH)
        end
    end

    function trialStarted(obj,event)
        set(readLasomStatusTimer,'Period',2); % Once the trial started read statuses at a rate of 10 Hz
        set(readLasomStatusTimer,'TimerFcn',@readLasomStatusAfterTrialStart);
        set(readLasomStatusTimer,'StopFcn','')
        start(readLasomStatusTimer)
        disp('next step in reading port');
    end

    function readLasomStatusAfterTrialStart(obj,event)
       lasomStatus = get(lasomH,'SeqUpdateEnable')
       startVariableStatus  = get(lasomH,'SeqUpdateVarState',1)
        
        if lasomStatus == 0 && ...
               startVariableStatus == 0
            % At the end of the trial, jump into this function and stop the timer.
            stop(readLasomStatusTimer)
            disp('readLasomStatusTimer timer stopped')
            
            % If purging is used by the user, set mfcs to maximum flow rate
            % at the end of the trial:
            settingNames = {smell.trial(trialNum).olfactometerInstructions.name};
            index = find(strcmp('purge',settingNames));
            if smell.trial(trialNum).olfactometerInstructions(index).used
                invoke(lasomH,'SetMfcFlowRate',slave,1,100);
                invoke(lasomH,'SetMfcFlowRate',slave,2,100);
                sprintf('Purging olfactometer\n')
            end
            
            % Stop measuring the Mfc flow:
            stop(mfcMeasureTimer)
            
            % To do get events after trial.
%             test = get(lasomH, 'SequencerLabelTimeValue', '@')
            
            % Release the connection to the olfactometer
            release(lasomH)

            sprintf('Executed trial %d successfully.\n',trialNum)
        end
    end
    function readLasomStatusErrorFcn(~,~)
        % Need to put add an error function for this timer, because the MFC
        % measuring can take longer than the defined measurement interval,
        % and then has to be stopped, as it would result overloading the
        % computer and a lot of unwanted behavior.
        warning('Can''t fulfill LASOM reading requests at the set interval. Giving up.')
        stop(readLasomStatusTimer)
    end
end
