function olfactometerStatus = getUpdate(debug, olfactometerH)
% olfactometerStatus = olfactometerAccess.getUpdate(debug, olfactometerH)
% Will return the current status of the olfactometer.
% 
% lorenzpammer 2012/12

%% Set global variables

global olfStimTestMode

%% Check arguments to function

if nargin < 2
    errormsg = sprintf('Not enough input arguments.');
    error(errormsg)
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    olfactometerStatus = [];
    return
end

%% Query LASOM to get back the current status 

olfactometerStatus = olfactometerH.SeqUpdateEnable;

end