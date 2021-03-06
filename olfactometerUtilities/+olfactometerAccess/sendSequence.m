function [parseSuccess, compileSuccess] = sendSequence(debug,olfactometerH,pathToTrialLsq)
% [parseSuccess, compileSuccess] = olfactometerAccess.sendSequence(debug,olfactometerH,pathToTrialLsq)
% Clears old loaded sequences, sends the lsq code to the lasom board, and
% compiles it. The handle to the LASOM board and the path to the lsq file,
% that should be sent have to be provided as arguments.
% Returns zeros if parsing and compiling were successful. Gives errors in
% case clearing old sequence, transmitting the lsq file or compiling fails. 
% 
% lorenzpammer 2012/07

%% Set global variables

global olfStimTestMode

%% Check arguments to function

if nargin < 3
    error('Not enough input arguments.')
end

%% See whether we're in test mode

% if in test mode, don't interact with the olfactometer.
if olfStimTestMode
    parseSuccess = [];
    compileSuccess = [];
    return
end

% %% Rename the osq file into an lsq file for LASOM
% 
% fid = fopen([osqPath 'trial.osq'],'w');
% fprintf(fid,'%s',trialOsq);
% fclose(fid);
% clear fid;

%% Send sequencer file (lsq) to Lasom and compile

if isempty(pathToTrialLsq) || isempty(olfactometerH)
    error(sprintf('Not enough input arguments. \n The handle to the lasom board and the path to the lsq file, \nwhich should be parsed have to be provided.'));
end

% Clear old sequence:
success = invoke(olfactometerH, 'ClearSequence');
if success ~= 0
    lastError = invoke(olfactometerH, 'GetLastError');
    disp(lastError)
    errormsg = 'Could not clear old sequence on LASOM.';
    protocolUtilities.logWindow.issueLogMessage(['Fatal error: ' errormsg]);
    error(errormsg)
    
end
% Send new sequence defined by it's location on the hard drive to the
% LASOM
parseSuccess = invoke(olfactometerH, 'ParseSeqFile', pathToTrialLsq);
if parseSuccess ~= 0
    lastError = invoke(olfactometerH, 'GetLastError');
    disp(lastError)
    errormsg = 'Could not send trial sequence LASOM.';
    protocolUtilities.logWindow.issueLogMessage(['Fatal error: ' errormsg]);
    error(errormsg)
end
% Compile the new sequence:
compileSuccess = invoke(olfactometerH, 'CompileSequence');
if compileSuccess ~= 0
    lastError = invoke(olfactometerH, 'GetLastError');
    disp(lastError)
    errormsg = 'Could not compile trial sequence.';
    protocolUtilities.logWindow.issueLogMessage(['Fatal error: ' errormsg]);
    error(errormsg)
end

end