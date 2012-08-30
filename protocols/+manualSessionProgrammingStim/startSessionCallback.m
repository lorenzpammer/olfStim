function startSessionCallback(~,~)
% startSessionCallback(~,~) is an external function called 


%%
global smell

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Set up some variables
stimProtocol = 'manualSessionProgrammingStim'; 


%%

for i = 1 : length(smell.trial)
    trialNum = smell.trial(i).trialNum; % every time a odor is triggered a new trial is counted
    
    %% First save the current smell file to the temp folder in case anything happens.
    callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function
    olfStimPath = which(callingFunctionName);
    olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];
    olfStimPath=[olfStimPath filesep 'temp' filesep];
    clear callingFunctionName
    
    defaultTitle = [datestr(date,'yyyy.mm.dd') '_smell_temp'];
    extendedPath = [olfStimPath defaultTitle '.mat'];
    save(extendedPath,'smell')
    clear olfStimPath defaultTitle
    
    %% Now trigger the trial
    trialOdor = smell.trial(trialNum);
    
    % 3. Update certain smell fields:
    
    buildSmell('updateFields',[],trialNum,stimProtocol,[],'notes','stimProtocol','time','interTrialInterval',interTrialInterval)
    
    % 4. update the progress panel on the gui
    protocolUtilities.progressPanel(h,'update',trialOdor,trialNum);
    
    % 5. star the new trial
    %   This will build the lsq file for the current trial, send the
    %   instructions to the olfactometer and trigger the trial.
     smell = startTrial(trialNum, smell);    
    
end


end