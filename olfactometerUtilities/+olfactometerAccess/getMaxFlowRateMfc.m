function [mfcCapacity, units] = getMaxFlowRateMfc(debug, olfactometerH, slave, MfcID)
% [mfcCapacity, units] = olfactometerAccess.getMaxFlowRateMfc(debug, olfactometerH, slave, MfcID)
% Will return the maximum flow rate of the specified mass flow controller.
% Each mass flow controller is identified by the slave it is connected to
% and the mass flow controller ID on that slave: 
% ID of air MFC: 1  
% ID of  Nitrogen MFC: 2
% If information can not be obtained this function throws an error.
% In testing mode it will return [].
% 
% lorenzpammer 2012/07

%% Set global variables

global olfStimTestMode

%% Check arguments to function

if nargin < 4
    errormsg = sprintf('Not enough input arguments. Olfactometer handle, slave and number of MFC\nhave to be provided to get the maximum MFC flow rate.');
    error(errormsg)
    debug = false;
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    mfcCapacity = [];
    units = [];
    return
end

%% Connect to Lasom and write LASOM handle into appdata

% Query mass flow controller for its capacity
[~,mfcCapacity,units]=olfactometerH.GetMfcCapacity(slave,mfcId,1000.0,''); % The 3rd and 4th argument don't seem to matter

% Check in which units the capacity of the MFCs is returned and convert
% if necessary:
if strncmp(units,'ln/min',6)
    units = 'l/min';
    % Do nothing. liters per minutes are the unit we're using.
elseif strncmp(units,'mln/min',7)
    % If units are in ml/min, convert to liters/min
    mfcCapicity = mfcCapacity / 1000;
    units = 'l/min';
else
    errormsg = sprintf('Mass flow controllers returned flow rate in ''%s''.\nUnknown unit, add another case for this unit.',unit);
    error(errormsg)
end

end