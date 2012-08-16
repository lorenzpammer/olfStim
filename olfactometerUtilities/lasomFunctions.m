function lasomH = lasomFunctions(instruction,lasomH, varargin)
%
% lasomFunctions(instruction, lasomH, varargin)
% The argument instruction is a string 
%   - 'checkConnection', checks whether a connection to the LASOM can be
%      established, if yes results in a positive message, if no, results in an
%      error message, and will terminate olfStim. No input arguments
%      besides instruction is necessary.
%   - 'connect', establishes a connection to the LASOM. 
%   - 'sendLsqToLasom' - clears old loaded sequences, sends the lsq code
%      to the lasom board, and compiles it. The handle to the LASOM board
%      and the path to the lsq file, that should be sent have to be
%      provided as arguments.
%   - 'loadAndRunSequencer', providing this argument will start the
%      sequencer with the previously loaded and compiled lsq file.
%   - 'setMfcFlowRate', varargin: (flowRateMfcAir, flowRateMfcN). In l/min

%
% lorenzpammer 2012/07

%% Check arguments to function

if nargin < 1
    error('Not enough input arguments.')
end
if nargin < 2 && strcmp(instruction,'loadAndRunSequencer') || ...
        nargin < 2 && strcmp(instruction,'setMfcFlowRate') 
    error('Not enough input arguments.')
end
if nargin < 2
    lasomH = [];
    varargin = {[]};
end
if nargin <3
    varargin = {[]};
end


%% extablish connection to LASOM

if strcmp(instruction,'checkConnection')
   lasomH = actxcontrol('LASOMX.LASOMXCtrl.1');
    success = invoke(lasomH, 'DevOpen', 0, 1);
    if success == 0
        pause(2)
        disp('Connecting to LASOM successful.')
        release(lasomH)
    else
         error('Could not connect to LASOM.')
    end
    
    

elseif strcmp(instruction,'connect')
    lasomH = actxcontrol('LASOMX.LASOMXCtrl.1');
    success = invoke(lasomH, 'DevOpen', 0, 0);
    if success ~= 0
        error('Could not connect to LASOM.')
    end
    invoke(lasomH, 'GetLastError');
    invoke(lasomH, 'GetID');

    
elseif strcmp(instruction,'sendLsqToLasom')
    if isempty(varargin{1}) || isempty(lasomH)
        errormsg=sprintf('Not enough input arguments. \nThe handle to the lasom board and the path to the lsq file, \nwhich should be parsed have to be provided.');
        error(errormsg)
        clear errormsg
    end
    lsqFilePath = varargin{1};
    % Clear old sequence:
    success = invoke(lasomH, 'ClearSequence');
    if success ~= 0
        error('Could not clear old sequence on LASOM.')
    end
    % Send new sequence defined by it's location on the hard drive to the
    % LASOM
    success = invoke(lasomH, 'ParseSeqFile', lsqFilePath);
    if success ~= 0
        error('Could not send trial sequence LASOM.')
    end
    % Compile the new sequence:
    success = invoke(lasomH, 'CompileSequence');
    if success ~= 0
        error('Could not compile trial sequence.')
    end

    
elseif strcmp(instruction,'loadAndRunSequencer')
    % Load the sequencer and run it:
    success = invoke(lasomH, 'LoadAndRunSequencer',0);
    if success ~= 0
        error('Could not start sequencer with new sequence file.')
    end

elseif strcmp(instruction,'setMfcFlowRate')
    if isempty(varargin{1}) || isempty(lasomH)
        errormsg=sprintf('Not enough input arguments. \nThe handle to the lasom board and the MFC flow rates, \nhave to be provided.');
        error(errormsg)
        clear errormsg
    end
    % Clear old sequence
    lsqFilePath = varargin{1};
    invoke(lasomH, 'ClearSequence')
    invoke(lasomH, 'ParseSeqFile', lsqFilePath) 
    invoke(lasomH, 'CompileSequence')
end

end