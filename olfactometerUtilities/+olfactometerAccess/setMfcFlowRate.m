function setMfcFlowRate(debug,olfactometerH,slave,mfcID,percentOfCapacity)
% olfactometerH = olfactometerAccess.setMfcFlowRate(debug)
% Not coded yet.
% Establishes a connection to the LASOM and returns the activeX control
% handle "olfactometerH". If no connection is posible, throws an error.
% In testing mode it will return [].
% 
% lorenzpammer 2012/07

%% Set global variables

global olfStimTestMode

%% Check arguments to function

if nargin < 5
    errormsg = sprintf('Not enough input arguments. Olfactometer handle, slave, number of MFC and\npercentage of maximum capacity to set have to be provided to set the MFC flow rate.');
    error(errormsg)
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    return
end

%% Set the flow rates of the mass flow controller

invoke(olfactometerH,'SetMfcFlowRate',slave,mfcID,percentOfCapacity);

end