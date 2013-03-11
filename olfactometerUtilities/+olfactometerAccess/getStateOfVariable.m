function variableStatus = getStateOfVariable(debug, olfactometerH, variableIndex)
% variableStatus = olfactometerAccess.getStateOfVariable(debug, olfactometerH,variableIndex)
% Will return the current status of the olfactometer.
% 
% lorenzpammer 2012/12

%% Set global variables

global olfStimTestMode

%% Check arguments to function

if nargin < 3
    errormsg = sprintf('Not enough input arguments.');
    error(errormsg)
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    variableStatus = [];
    return
end

%% Query LASOM to get back the current status of the defined variable

variableStatus = get(olfactometerH,'SeqUpdateVarState',variableIndex);
% Strangely this code variableStatus =
% olfactometerH.SeqUpdateVarState(variableIndex); leads to an error with
% not enough arguments.

end