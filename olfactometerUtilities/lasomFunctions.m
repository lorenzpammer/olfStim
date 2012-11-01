function lasomFunctions(instruction, debug, varargin)
%
% lasomFunctions(instruction, debug, varargin)
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
if nargin < 2
    debug = false;
end
if nargin < 3
    varargin = {[]};
end

%% extablish connection to LASOM

if strcmp(instruction,'checkConnection')
   lasomH = actxcontrol('LASOMX.LASOMXCtrl.1');
   success = invoke(lasomH, 'DevOpen', 0, 1); % invoke(lasomH, 'DevOpen',???, show/notShow the debugWindow)
    if success == 0
        disp('Successfully connected to LASOM. Now closing connection.')
        pause(2)
        release(lasomH)
    else
         error('Could not connect to LASOM.')
    end
    
    
elseif strcmp(instruction,'connect')
    lasomH = actxcontrol('LASOMX.LASOMXCtrl.1');
    success = invoke(lasomH, 'DevOpen', 0, 0); % invoke(lasomH, 'DevOpen',???, show/notShow the debugWindow)
    if success ~= 0
        if debug
            olfStimDebug(dbstack,fprintf('LASOM returned: handle = %s, connection success = %d\n',lasomH,success));
        end
        error('Could not connect to LASOM.')
    else
        disp('Successfully connected to LASOM.')
    end
    lastError = invoke(lasomH, 'GetLastError');
    lasomID = invoke(lasomH, 'GetID');
    if debug
        olfStimDebug(dbstack,...
            fprintf('Connecting to LASOM. LASOM returned: handle = %s, connection success = %d\nLast error = %d, LASOM ID = %s',...
            lasomH,success,lastError,lasomID));
    end
    % Write the lasom handle into the appdata of the figure:
    appdataManager('olfStimGui','set',lasomH);


    
elseif strcmp(instruction,'sendLsqToLasom')
    if isempty(varargin{1})
        errormsg=sprintf('Not enough input arguments. \nThe handle to the lasom board and the path to the lsq file, \nwhich should be parsed have to be provided.');
        error(errormsg)
        clear errormsg
    end
    % Extract the lasom handle from the appdata of the figure:
    lasomH = appdataManager('olfStimGui','get','lasomH');
    
    pathTrialLsq = varargin{1};
    % Clear old sequence:
    success = invoke(lasomH, 'ClearSequence');
    if success ~= 0
        error('Could not clear old sequence on LASOM.')
    end
    % Send new sequence defined by it's location on the hard drive to the
    % LASOM
    success = invoke(lasomH, 'ParseSeqFile', pathTrialLsq);
    if success ~= 0
        error('Could not send trial sequence LASOM.')
    end
    % Compile the new sequence:
    success = invoke(lasomH, 'CompileSequence');
    if success ~= 0
        error('Could not compile trial sequence.')
    end
    

    
elseif strcmp(instruction,'loadAndRunSequencer')
    % Extract the lasom handle from the appdata of the figure:
    lasomH = appdataManager('olfStimGui','get','lasomH');
    % Load the sequencer and run it:
    success = invoke(lasomH, 'LoadAndRunSequencer',1);
    if success ~= 0
        error(fprintf('Could not start sequencer with new sequence file.\nLasom handle = %s, Load and run sequencer = %d',lasomH,success)
    end

elseif strcmp(instruction,'setMfcFlowRate')
    if isempty(varargin{1})
        errormsg=sprintf('Not enough input arguments. \nThe MFC flow rates have to be provided.');
        error(errormsg)
        clear errormsg
    end
    % Extract the lasom handle from the appdata of the figure:
    lasomH = appdataManager('olfStimGui','get','lasomH');
    % Clear old sequence
    lsqFilePath = varargin{1};
    invoke(lasomH, 'ClearSequence')
    invoke(lasomH, 'ParseSeqFile', lsqFilePath) 
    invoke(lasomH, 'CompileSequence')
end

end