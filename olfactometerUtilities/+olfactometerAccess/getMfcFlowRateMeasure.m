function mfcFlowRate = getMfcFlowRateMeasure(debug,olfactometerH,slave,MfcID)
% [mfcFlowRate = getMfcFlowRateMeasure(debug,olfactometerH,slave,MfcID)
% Function returns the current Mfc flow rates in percentage of maximum flow
% rate.
% 
% lorenzpammer 2012/12

%% Set global variables

global olfStimTestMode

%% Check arguments to function

if nargin < 4
    errormsg = sprintf('Not enough input arguments. Olfactometer handle, slave and number of MFC\nhave to be provided to get the current MFC flow rate.');
    error(errormsg)
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    mfcFlowRate = [];
    return
end

%% Get current flow rate

% Query mass flow controller for its current flow rate in percent of
% capacity
mfcFlowRate = olfactometerH.GetMfcFlowRateMeasurePercent(slave,mfcID);

end