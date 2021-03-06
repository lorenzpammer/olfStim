function success = checkConnection()
% success = olfactometerAccess.checkConnection
% Checks whether a connection to the LASOM can be established, if yes
% results in a positive message, if no, results in an error message, and
% will terminate olfStim. No input arguments besides instruction is
% necessary.
% Returns 0 for successful conection.
% 
% lorenzpammer 2012/07

%% Set global variables

global olfStimTestMode

%% Check arguments to function

if nargin < 1
    debug = false;
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    success = [];
    return
end

%% Check whether connection to LASOM can be established.

lasomH = actxcontrol('LASOMX.LASOMXCtrl.1');
success = invoke(lasomH, 'DevOpen', 0, true); % invoke(lasomH, 'DevOpen',???, show/notShow the debugWindow)
if success == 0
    disp('Successfully connected to LASOM. Now closing connection.')
    pause(2)
    release(lasomH)
    close all
else
    lastError = invoke(olfactometerH, 'GetLastError');
    disp(lastError)
    warnStr = sprintf('Could not establish connection to LASOM.');
    protocolUtilities.logWindow.issueLogMessage(['Fatal error: ' warnStr]);
    error(warnStr)
end

end