function startSessionCallback(~,~,callbackFunctionName)
% startSessionCallback(~,~) is a callback function called when pressing the
% startSession button.
%
% lorenzpammer september 2012


%% Fetch some globals and variables from the gui

global smell
global trialNum

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Set up some variables
stimProtocol = 'manualSessionProgrammingStim';
functionHandle = str2func(callbackFunctionName);

%% Do a couple of checks:

% In case smell wasn't loaded correctly or not setup, ie no information for
% the trials is present, throw a warning and exit the function, set
% everything as it was before.
if length(smell.trial) == 1 && isempty(smell.trial(1).odorName)
    warning(sprintf('No instructions to execute on, are available for this session. \n Check whether you created a session sequence or loaded an old session sequence.'))
    % Reset the toggle button to the original settings.
    set(h.startSession,'String','Start session','backgroundcolor',[0 1 0],'Value',0,...
        'Callback',{functionHandle,callbackFunctionName});
    return % exit the function
end

%% Change the startSession button to the Pause button.
% If the start session button is pressed again (=toggle off) the sequential
% execution of trials will be pause. Also clear the callbackfunction, as
% this should only be called once.
set(h.startSession,'backgroundcolor',[1 0 0],'String','Pause','Callback','')

 %% Remove all the information that is stored in smell during execution of a trial
% % This is important, as there might be data which are continuously written
% % to smell during a trial (eg MFC flow rates). If an old smell structure is
% % used to instruct olfStim for a new session, this data has to be removed,
% % otherwise weird behavior can happen.
smell = protocolUtilities.removeHistoricalTrialDataFromSmell(smell);
protocolUtilities.repopulateSmell;

%% Start executing one trial after the other:

if get(h.startSession,'Value') == 1 % if the startSessionButton is pressed
    
    trialNum = 1; % reset trialNum to 1
    
    % Go through every trial:
    for i = trialNum : length(smell.trial)
        
        %% Pause the execution if user pressed the button again
        
        if get(h.startSession,'Value') == 0
            set(h.startSession,'backgroundcolor',[0 1 0],'String','Continue')
            disp('Session paused.')
            while get(h.startSession,'Value') == 0
                pause(2)
                % If the user presses the end session button after pressing
                % the pause button, end session.
                if get(h.endSession,'Value') == 1
                    % Set button back to ground state.
                    set(h.startSession,'String','Start session','backgroundcolor',[0 1 0],'Value',0,...
                        'Callback',{functionHandle,callbackFunctionName})
                    set(h.endSession,'Value',0)
                    disp('Session terminated by user.')
                    return % exit the function
                end
            end
            disp('Continuing session.')
            set(h.startSession,'backgroundcolor',[1 0 0],'String','Pause')
        end
        
        %% Stop the execution of the session if End session button has been pressed
        
        if get(h.endSession,'Value') == 1
            % Set button back to ground state.
            set(h.startSession,'String','Start session','backgroundcolor',[0 1 0],'Value',0,...
                'Callback',{functionHandle,callbackFunctionName})
            set(h.endSession,'Value',0)
            disp('Session terminated by user.')
            return % exit the function
        end
        
        %% Execute the current trial
        
        disp(['Started trial ' num2str(i) ', presenting odor ' smell.trial(i).odorName '.'])
        trialNum = smell.trial(i).trialNum; % every time an odor is triggered a new trial is counted
        
        %% First save the current smell file to the temp folder in case anything happens.
        callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function
        olfStimPath = which(callingFunctionName);
        olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];
        olfStimPath=[olfStimPath filesep 'User Data' filesep 'temp' filesep];
        clear callingFunctionName
        
        defaultTitle = [datestr(date,'yyyy.mm.dd') '_smell_temp'];
        extendedPath = [olfStimPath defaultTitle '.mat'];
        save(extendedPath,'smell')
        clear olfStimPath defaultTitle
        
        %% Now trigger the trial
        
        trialOdor = smell.trial(trialNum);
        
        % 3. Update certain smell fields:
        buildSmell('updateFields',[],[],trialNum,stimProtocol,[],...
            'notes','stimProtocol','time','scientist','animalName','log');
        
        % 4. update the progress panel on the gui
        protocolUtilities.progressPanel(h,'update',trialOdor,trialNum);
        
        % 5. start the new trial
        %   This will build the lsq file for the current trial, send the
        %   instructions to the olfactometer and trigger the trial.
        smell = olfStimStartTrial(trialNum, smell);
        
        % % Wait for a time period, defined in interTrialInterval until
        % doing the next loop iteration.
        if trialNum < length(smell.trial) % don't do it for the last trial
            index = strmatch('interTrialInterval',{smell.trial(trialNum+1).sessionInstructions.name});
            if isempty(index)
                error('No interTrialInterval setting can be found.')
            elseif isempty(smell.trial(trialNum+1).sessionInstructions(index).value)
                warning(sprintf('No value defined for interTrialInterval in trial %d. Defaulting to 0 seconds.\n',trialNum+1))
                smell.trial(trialNum+1).sessionInstructions(index).value = '0';
            end
            interTrialInterval = str2num(smell.trial(trialNum+1).sessionInstructions(index).value);
            disp(['Waiting for the intertrial interval period of ' num2str(interTrialInterval) ' seconds.'])
            pause(interTrialInterval)
        else
            fprintf('Last trial in programmed sequence was reached. Session ended successfully.\n')
            % Set button back to ground state.
            set(h.startSession,'String','Start session','backgroundcolor',[0 1 0],'Value',0,...
                'Callback',{functionHandle,callbackFunctionName})
            break
        end
        
    end
    
end
end