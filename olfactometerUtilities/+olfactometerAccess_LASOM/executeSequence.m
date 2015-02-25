function success = executeSequence(debug,olfactometerH)
% success = olfactometerAccess.executeSequence(debug,olfactometerH)
% Send start command to sequencer. The sequencer will then start executing
% the loaded & compiled sequence. 
% Function returns 0 if execution was started successfully. Function will
% throw errors if execution could not be started successfully.
% 
% lorenzpammer 2012/07

%% Set global variables

global olfStimTestMode

%% Check arguments to function

if nargin < 2
    success = [];
    error('Not enough input arguments.')
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    return
end

%% Send start command to sequencer. Sequencer will then start executing the loaded & compiled sequence

% Load the sequencer and run it:
success = invoke(olfactometerH, 'LoadAndRunSequencer',1);
if success ~= 0
    warnStr = sprintf('Could not start sequencer with new sequence file.\nLasom handle = %s, Load and run sequencer = %d',olfactometerH,success);
    protocolUtilities.logWindow.issueLogMessage(['Fatal error: ' warnStr]);
    error(warnStr)
end

end