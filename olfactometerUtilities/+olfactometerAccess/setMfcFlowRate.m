function olfactometerH = setMfcFlowRate(debug,)
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

if nargin < 1
    debug = false;
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    varargout = cell(1,10);
    % Write a dummy lasom handle into the appdata of the figure:
    olfactometerH=[];
    %     appdataManager('olfStimGui','set',olfactometerH);
    return
end

%% Set the flow rates of the mass flow controller

warning('setMfcFlowRate not done yet!')
return

if isempty(varargin{1})
    errormsg=sprintf('Not enough input arguments. \nThe MFC flow rates have to be provided.');
    error(errormsg)
end
% Clear old sequence
lsqFilePath = varargin{1};
invoke(olfactometerH, 'ClearSequence')
invoke(olfactometerH, 'ParseSeqFile', lsqFilePath)
invoke(olfactometerH, 'CompileSequence')

end