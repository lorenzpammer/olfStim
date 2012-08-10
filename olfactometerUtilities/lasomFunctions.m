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
elseif nargin < 2
    lasomH = [];
    varargin = {[]};
elseif nargin <3
    varargin = {[]};
end


%% extablish connection to LASOM

if strcmp(instruction,'checkConnection')
    dbstack
    disp(': Checking connection not yet programmed.')
    

elseif strcmp(instruction,'connect')
    lasomH = actxcontrol('LASOMX.LASOMXCtrl.1');
    invoke(lasomH, 'DevOpen', 0, 1);
    invoke(lasomH, 'GetLastError');
    invoke(lasomH, 'GetID');

    
elseif strcmp(instruction,'sendLsqToLasom')
    if isempty(varargin{1}) || isempty(lasomH)
        errormsg=sprintf('Not enough input arguments. \nThe handle to the lasom board and the path to the lsq file, \nwhich should be parsed have to be provided.');
        error(errormsg)
        clear errormsg
    end
    % Clear old sequence
    lsqFilePath = varargin{1};
    invoke(lasomH, 'ClearSequence')
    invoke(lasomH, 'ParseSeqFile', lsqFilePath) 
    invoke(lasomH, 'CompileSequence')

    
elseif strcmp(instruction,'loadAndRunSequencer')
    % Load the sequencer and run it:
    invoke(lasomH, 'LoadAndRunSequencer') 
    

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