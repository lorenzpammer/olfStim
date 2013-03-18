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
%
% lorenzpammer dec 2011

%% Decide whether to output information to the command window for debugging;

debug = true;
% debug = false;

%% Fetch some variables from the gui appdata

global olfStimTestMode

% Extract the gui handle structure from the appdata of the figure:
h = appdataManager('olfStimGui','get','h');
% Extract the lasom handle from the appdata of the figure:
olfactometerH = appdataManager('olfStimGui','get','olfactometerH');
% % Extract the olfStimTestMode variable
% olfStimTestMode = appdataManager('olfStimGui','get','olfStimTestMode');

%% 
% Check whether olfactometerH has not been released properly. If so, close it.
if iscom(olfactometerH)
    disp('The connection to the LASOM wasn''t released properly in a previous trial. Closing it now.')
    release(olfactometerH);
end
clear olfactometerH;

%% Build the lsq file for the current trial
% buildTrialLsq.m will create an lsq file taking into account the
% olfactometerInstructions for the current trial.
trialLsq = buildTrialLsq(trialNum,smell);

% Add the lsq file for the current trial into the smell structure:
smell.trial(trialNum).trialLsqFile = trialLsq;

% callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function
% lsqPath = which(callingFunctionName);
% lsqPath(length(lsqPath)-length(callingFunctionName):length(lsqPath))=[];
% lsqPath=[lsqPath filesep 'lsq' filesep];
% clear callingFunctionName
% trialLsq = fileread([lsqPath 'test.lsq']);

if debug
    disp(trialLsq)
end

%% Connect to LASOM and set it up
olfactometerH = olfactometerAccess.connect(debug);

% Write the olfactometer activeX handle into the appdata of the figure:
% make this conditional to allow SCRIPTING
appdataManager('olfStimGui','set',olfactometerH);

%% Update smell:

if trialNum == 1 && ~olfStimTestMode
    % Get the ID from the olfactometer:
    smell.olfactometerSettings.olfactometerID = olfactometerAccess.getID(debug,olfactometerH);
end

%% Send lsq file of the current trial to the LASOM

callingFunctionName = 'startTrial.m'; % Define the name of the initalizing function
lsqPath = which(callingFunctionName);
lsqPath(length(lsqPath)-length(callingFunctionName):length(lsqPath))=[];
dd = filesep();
lsqPath=[lsqPath dd 'lsq' dd];
clear callingFunctionName
pathTrialLsq = [lsqPath 'trial.lsq'];

% Clear old sequences, send new one to olfactometer and compile it.
olfactometerAccess.sendSequence(debug,olfactometerH,pathTrialLsq);

%% Set MFC flow rates

slave = smell.trial(trialNum).slave;
smell = calculateMfcFlowRates(trialNum,smell,'error');
percentOfCapacityAir = smell.trial(trialNum).flowRateMfcAir / smell.olfactometerSettings.slave(slave).maxFlowRateMfcAir * 100;
percentOfCapacityN = smell.trial(trialNum).flowRateMfcN / smell.olfactometerSettings.slave(slave).maxFlowRateMfcNitrogen * 100;

% These commands should be externalized into the olfactometerAccess function.
if ~olfStimTestMode
    olfactometerAccess.setMfcFlowRate(debug, olfactometerH, slave, 1, percentOfCapacityAir);
    olfactometerAccess.setMfcFlowRate(debug, olfactometerH, slave, 2, percentOfCapacityN);
end

%% Start sequencer

olfactometerAccess.executeSequence(debug,olfactometerH);

if olfStimTestMode
    disp('olfStim is currently in test mode. No interaction with olfactometer.')
end

% Trigger trial:
% Triggering is done from an external device.

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
measurementInterval = 0.5; % measurement interval in seconds
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
        % Every 2000 ms, jump into this function measure the mfc flow rates
        % and write the returned values into the smell structure:
        measurementNo = get(mfcMeasureTimer,'TasksExecuted');
        elapsedTime = toc(get(mfcMeasureTimer,'UserData'));
        smell.trial(trialNum).lasomEventLog.flowRateMfcAir(1,measurementNo) = ...
            elapsedTime;
        smell.trial(trialNum).lasomEventLog.flowRateMfcN(1,measurementNo) = ...
            elapsedTime;
        if ~olfStimTestMode % only execute when we aren't in test mode
            % Get the current MFC flow rate measurement. Will be returned
            % in percentage of total flow:
            smell.trial(trialNum).lasomEventLog.flowRateMfcAir(2,measurementNo) = ...
                olfactometerAccess.getMfcFlowRateMeasure(debug,olfactometerH,slave,1);
            smell.trial(trialNum).lasomEventLog.flowRateMfcN(2,measurementNo) = ...
                olfactometerAccess.getMfcFlowRateMeasure(debug,olfactometerH,slave,2);
            
            % Calculate flow rates in l/min:
            mfcAirFlow=(smell.trial(trialNum).lasomEventLog.flowRateMfcAir(2,measurementNo)/100)*smell.olfactometerSettings.slave(slave).maxFlowRateMfcAir;
            mfcNFlow=(smell.trial(trialNum).lasomEventLog.flowRateMfcN(2,measurementNo)/100)*smell.olfactometerSettings.slave(slave).maxFlowRateMfcNitrogen;

            % Check whether the measured flow rates deviate by more than 5%
            % from the target flow rates
                        
            deviationAirFlow = abs(smell.trial(trialNum).lasomEventLog.flowRateMfcAir(2,measurementNo) - percentOfCapacityAir);
            if deviationAirFlow > 5
                fprintf('ATTENTION! Air flow rate deviates by more than 5%% from target flow. Measured air flow: %.3f %%, Target air flow: %.3f %%.\n',...
                smell.trial(trialNum).lasomEventLog.flowRateMfcAir(2,measurementNo), percentOfCapacityAir);
            end 
            deviationNFlow = abs(smell.trial(trialNum).lasomEventLog.flowRateMfcN(2,measurementNo) - percentOfCapacityN);
            if  deviationNFlow > 5
                fprintf('ATTENTION! Nitrogen flow rate deviates by more than 5%% from target flow. Measured N flow: %.3f %%, Target N flow: %.3f %%.\n',...
                smell.trial(trialNum).lasomEventLog.flowRateMfcN(2,measurementNo), percentOfCapacityN);
            end
            
            % Print the measured flow rates to the command window:
            fprintf('Measurement of MFC flow #%d. Air: %.3f l/min, N2: %.3f l/min.\n',...
                measurementNo,mfcAirFlow, mfcNFlow);
        end
    end
    function measureMfcFlowStopped(varargin)
        % At the end of the trial, after last measurement of mfc flow, jump
        % into this function and stop the timer.
         stop(mfcMeasureTimer);
        delete(mfcMeasureTimer);
        if debug
            disp('Stopped measuring MFC flowrate.');
        end
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

readStatusInterval = 1; % measurement interval in seconds 1000Hz
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
%     release(olfactometerH)
% end
% if isvalid(mfcMeasureTimer)
%  disp('stopped mfc timer from timeout')
%     stop(mfcMeasureTimer)
%     release(olfactometerH)
% end
% 

wait(readLasomStatusTimer) % keeps function active until timer stops (once sequencer is idle)

delete(readLasomStatusTimer)

if iscom(olfactometerH)
    release(olfactometerH)
end
if ~isempty(timerfindall)
    delete(timerfindall)
end

%% Callback functions of timer:
    function readLasomStatusUntilTrialStart(obj,event)
        % Every 1000 ms, jump into this function and read the last emitted
        % status:
        measurementNo = get(readLasomStatusTimer,'TasksExecuted');
        if ~olfStimTestMode % only execute when we aren't in test mode
            lasomStatus = olfactometerAccess.getUpdate(debug,olfactometerH);
            startVariableStatus = olfactometerAccess.getStateOfVariable(debug,olfactometerH,1);
        else
            % if we're in test mode set the two variables:
            lasomStatus = 1;
            startVariableStatus = 1;
        end
        if debug
            fprintf('Checking sequencer status. Sequencer status: %d, Start variable: %d\n',...
                lasomStatus, startVariableStatus);
        end
        
        % If the variable with index 1 ($Var1) is set to 1, this means
        % the sequencer has started to execute the trial (eg after
        % exiting the initial whileloop).
        if lasomStatus == 1 && ...
                startVariableStatus == 1;    
            
            if debug
                fprintf('Started to execute trial.\n');
            end
            
            ticID = tic;
            set(mfcMeasureTimer,'UserData',ticID);
            start(mfcMeasureTimer);
            
            stop(readLasomStatusTimer) % will execute trialStarted subfunction.
            fprintf('Trial #%d started.\n',trialNum)
           
        end
        if measurementNo >= 2 && (lasomStatus == 205 || startVariableStatus == 205)
            warning('LASOM throws error 205 at reading status. Stopped reading status & measuring flow. Not purging.')
            
            stop(mfcMeasureTimer)
            % Release the connection to the olfactometer
            stop(readLasomStatusTimer)
            %             delete(readLasomStatusTimer)
            
            release(olfactometerH)
        end
    end

    function trialStarted(obj,event)
        set(readLasomStatusTimer,'Period',2); % Once the trial started read statuses at a rate of 10 Hz
        set(readLasomStatusTimer,'TimerFcn',@readLasomStatusAfterTrialStart);
        set(readLasomStatusTimer,'StopFcn','');
        start(readLasomStatusTimer);
        if debug
            disp('2nd phase of checking LASOM status initiated.')
        end
    end

    function readLasomStatusAfterTrialStart(obj,event)
        if ~olfStimTestMode % only execute when we aren't in test mode
            lasomStatus = olfactometerAccess.getUpdate(debug,olfactometerH);
            startVariableStatus = olfactometerAccess.getStateOfVariable(debug,olfactometerH,1);
        else
            % if we're in test mode set the two variables:
            lasomStatus = 0;
            startVariableStatus = 0;
        end
        if debug
            fprintf('2nd phase of checking sequencer status. Sequencer status: %d, Start variable: %d\n',...
                lasomStatus, startVariableStatus);
        end
        if startVariableStatus == 0 %lasomStatus == 0 && ...
            if lasomStatus ~= 0
                disp('Sequencer didn''t terminate. Still quitting trial.')
            end
            % At the end of the trial, jump into this function and stop the timer.
            stop(readLasomStatusTimer)
            if debug
                fprintf('Sequencer finished. Stopped the timer readLasomStatus.\n');
            end
            % If purging is used by the user, set mfcs to maximum flow rate
            % at the end of the trial:
            settingNames = {smell.trial(trialNum).olfactometerInstructions.name};
            index = find(strcmp('purge',settingNames));
            if smell.trial(trialNum).olfactometerInstructions(index).used && ~olfStimTestMode
                olfactometerAccess.setMfcFlowRate(debug,olfactometerH,slave,1,100);
                olfactometerAccess.setMfcFlowRate(debug,olfactometerH,slave,2,100);                
                fprintf('Purging olfactometer.\n')
            end
            
            % Stop measuring the Mfc flow:
            stop(mfcMeasureTimer)
            
            % To do get events after trial.
            %             test = get(olfactometerH, 'SequencerLabelTimeValue', '@')
            
            % Release the connection to the olfactometer
            if ~olfStimTestMode
                release(olfactometerH)
            end
            
            fprintf('Executed trial %d successfully.\n',trialNum)
        end
    end
    function readLasomStatusErrorFcn(~,~)
        % Need to put add an error function for this timer, because the MFC
        % measuring can take longer than the defined measurement interval,
        % and then has to be stopped, as it would result overloading the
        % computer and a lot of unwanted behavior.
        warning('Can''t fulfill LASOM reading requests at the set interval. Giving up.')
        disp(lasterror)
        stop(readLasomStatusTimer)
    end
end
