function varargout = lasomFunctions(instruction, debug, varargin)
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
%   - 'getMaxFlowRateMfc', 
%        [capacity,units] = lasomFunctions(getMfcMaxFlowRate',slave, MfcID)
%                             MfcID air: 1 , # MfcID Nitrogen: 2
%   - 'getFlowRateSettingMfc',

%
% lorenzpammer 2012/07

%% Get some data from the gui



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
            olfStimDebug(dbstack,fprintf('LASOM returned: ishandle = %d, connection success = %d\n',iscom(lasomH),success));
        end
        error('Could not connect to LASOM.')
    else
        disp('Successfully connected to LASOM.')
    end
    lastError = invoke(lasomH, 'GetLastError');
    olfactometerID = invoke(lasomH, 'GetID');
    if debug
        olfStimDebug(dbstack,...
            fprintf('Connecting to LASOM. LASOM returned: ishandle = %d, connection success = %d,\nLast error = %s, LASOM ID = %s\n',...
            iscom(lasomH),success,lastError,olfactometerID)); % should be 
    end
    % Write the lasom handle into the appdata of the figure:
    appdataManager('olfStimGui','set',lasomH);


    
elseif strcmp(instruction,'sendLsqToLasom')
    if isempty(varargin{1})
        error(sprintf('Not enough input arguments. \n The handle to the lasom board and the path to the lsq file, \nwhich should be parsed have to be provided.'));
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
        error(fprintf('Could not start sequencer with new sequence file.\nLasom handle = %s, Load and run sequencer = %d',lasomH,success))
    end

    
elseif strcmp(instruction,'setMfcFlowRate')
    print('setMfcFlowRate not done yet!')
    return
    
    if isempty(varargin{1})
        errormsg=sprintf('Not enough input arguments. \nThe MFC flow rates have to be provided.');
        error(errormsg)
    end
    % Extract the lasom handle from the appdata of the figure:
    lasomH = appdataManager('olfStimGui','get','lasomH');
    % Clear old sequence
    lsqFilePath = varargin{1};
    invoke(lasomH, 'ClearSequence')
    invoke(lasomH, 'ParseSeqFile', lsqFilePath)
    invoke(lasomH, 'CompileSequence')
    
    
elseif strcmp(instruction,'getMaxFlowRateMfc')
    if length(varargin) ~= 2
        errormsg = sprintf('Not enough input arguments. Slave and number of MFC have to be provided\nto get the maximum MFC flow rate.');
        error(errormsg)
    else
        slave = varargin{1};
        mfcId = varargin{2};
    end
    % Extract the lasom handle from the appdata of the figure:
    lasomH = appdataManager('olfStimGui','get','lasomH');

    % Query mass flow controller for its capacity
    [~,mfcCapacity,units]=lasomH.GetMfcCapacity(slave,mfcId,1000.0,''); % The 3rd and 4th argument don't seem to matter
    
    % Check in which units the capacity of the MFCs is returned and convert
    % if necessary:
    if strncmp(units,'ln/min',6)
        units = 'l/min';
        % Do nothing. liters per minutes are the unit we're using.
    elseif strncmp(units,'mln/min',7)
        % If units are in ml/min, convert to liters/min
        mfcCapicity = mfcCapacity / 1000;
        units = 'l/min';
    else
        errormsg = sprintf('Mass flow controllers returned flow rate in ''%s''.\nUnknown unit, add another case for this unit.',unit);
        error(errormsg)
    end
    varargout{1} = mfcCapacity;
    varargout{2} = units;
    
    
elseif strcmp(instruction,'getFlowRateSettingMfc')
    if length(varargin) < 2
        errormsg = sprintf('Not enough input arguments. Slave and number of MFC have to be provided\nto query the MFC flow rate setting.');
        error(errormsg)
    else
        slave = varargin{1};
        mfcId = varargin{2};
    end
    % Extract the lasom handle from the appdata of the figure:
    lasomH = appdataManager('olfStimGui','get','lasomH');
    % Query for the flow rate setting:
    [~,flowRateSettingInPercent]=lasomH.GetMfcFlowRateSetting(slave,mfcId,100);
    varargout{1} = flowRateSettingInPercent;
end

end