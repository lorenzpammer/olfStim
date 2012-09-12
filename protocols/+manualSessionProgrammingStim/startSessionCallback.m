function startSessionCallback(~,~,callbackFunctionName)
% startSessionCallback(~,~) is an external function called 


%%
global smell
global trialNum

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Set up some variables
stimProtocol = 'manualSessionProgrammingStim';
trialNum = 1; % reset trialNum to 1
functionHandle = str2func(callbackFunctionName);

%% Change the startSession button to the Pause button.
% If the start session button is pressed again (=toggle off) the sequential
% execution of trials will be pause. Also clear the callbackfunction, as
% this should only be called once.
set(h.startSession,'backgroundcolor',[1 0 0],'String','Pause','Callback','')


%%
if get(h.startSession,'Value') == 1
    for i = trialNum : length(smell.trial)
        
        %% Pause the execution if user pressed the button again
        if get(h.startSession,'Value') == 0
            set(h.startSession,'backgroundcolor',[0 1 0],'String','Continue')
            counter = 0;
            while get(h.startSession,'Value') == 0
                disp('waiting')
                counter = counter +1;
                pause(2)
            end
            set(h.startSession,'backgroundcolor',[1 0 0],'String','Pause')
        end
        disp(['doing trial ' num2str(i)])
        trialNum = smell.trial(i).trialNum; % every time a odor is triggered a new trial is counted
        %
        %     %% First save the current smell file to the temp folder in case anything happens.
        %     callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function
        %     olfStimPath = which(callingFunctionName);
        %     olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];
        %     olfStimPath=[olfStimPath filesep 'temp' filesep];
        %     clear callingFunctionName
        %
        %     defaultTitle = [datestr(date,'yyyy.mm.dd') '_smell_temp'];
        %     extendedPath = [olfStimPath defaultTitle '.mat'];
        %     save(extendedPath,'smell')
        %     clear olfStimPath defaultTitle
        %
        %     %% Now trigger the trial
        %     trialOdor = smell.trial(trialNum);
        %
        %     % 3. Update certain smell fields:
        %
        %     buildSmell('updateFields',[],trialNum,stimProtocol,[],'notes','stimProtocol','time','interTrialInterval',interTrialInterval)
        %
        %     % 4. update the progress panel on the gui
        %     protocolUtilities.progressPanel(h,'update',trialOdor,trialNum);
        %
        %     % 5. star the new trial
        %     %   This will build the lsq file for the current trial, send the
        %     %   instructions to the olfactometer and trigger the trial.
        %      smell = startTrial(trialNum, smell);
        
        % % Wait for the value defined in interTrialInterval until doing the next
        % loop iteration.
        
        
        if trialNum < length(smell.trial) % don't do it for the last trial
            index = strmatch('interTrialInterval',{smell.trial(trialNum+1).sessionInstructions.name});
            if isempty(index)
                error('No interTrialInterval setting can be found.')
            elseif isempty(smell.trial(trialNum+1).sessionInstructions(index).value)
                warning(sprintf('No value defined for interTrialInterval in trial %d. Defaulting to 30 seconds.\n',trialNum+1))
                smell.trial(trialNum+1).sessionInstructions(index).value = '30';
            end
            interTrialInterval = str2num(smell.trial(trialNum+1).sessionInstructions(index).value);
            disp(['waiting for ' num2str(interTrialInterval)])
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