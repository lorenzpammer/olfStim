function olfactometerH = connect(debug)
% olfactometerH = olfactometerAccess.connect(debug)
% Establishes a connection to the LASOM and returns the activeX control
% handle "olfactometerH". If no connection is posible, throws an error.
% In testing mode it will return [].
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
    varargout = cell(1,10);
    % Write a dummy lasom handle into the appdata of the figure:
    olfactometerH=[];
    return
end

%% Connect to Lasom and write LASOM handle into appdata

olfactometerH = actxcontrol('LASOMX.LASOMXCtrl.1'); % Set up the activeX connetction to the olfactometer
success = invoke(olfactometerH, 'DevOpen', 0, 0); % invoke(olfactometerH, 'DevOpen',???, show/notShow the debugWindow)
if success ~= 0
    if debug
        olfStimDebug(dbstack,fprintf('LASOM returned: ishandle = %d, connection success = %d\n',iscom(olfactometerH),success));
    end
    error('Could not connect to LASOM.')
else
    disp('Successfully connected to LASOM.')
end
lastError = invoke(olfactometerH, 'GetLastError');
olfactometerID = invoke(olfactometerH, 'GetID');
if debug
    olfStimDebug(dbstack,...
        fprintf('Connecting to LASOM. LASOM returned: ishandle = %d, connection success = %d,\nLast error = %s, LASOM ID = %s\n',...
        iscom(olfactometerH),success,lastError,olfactometerID)); % should be
end

% % Write the lasom handle into the appdata of the figure:
% appdataManager('olfStimGui','set',olfactometerH);

end