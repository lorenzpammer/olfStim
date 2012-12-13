function olfactometerID = getID(debug, olfactometerH)
% olfactometerID = olfactometerAccess.getID(debug, olfactometerH)
% Will return the ID of the olfactometer.
% 
% lorenzpammer 2012/07

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
    olfactometerID = [];
    return
end

%% Query LASOM to get its ID 

olfactometerID = olfactometerH.GetID;

end