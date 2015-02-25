function loadSequenceOfTrialsInstructionsCallback(~,~,callbackFunctionName)
% loadSequenceOfTrialsInstructionsCallback(~,~,callbackFunctionName)
% This callback function will load sequence of trial instructions and smell
% structures. It will remove all historical trial execution specific data
% from smell and will update the progress panel to show the list of
% unexecuted trials.
% 
% lorenzpammer september 2012


%% 

global smell
global trialNum

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Prompt user to open the smell structure for

% Get the path to the olfStim main directory
olfStimPath = protocolUtilities.getOlfStimRootDirectory;

[fileName,pathName,filterIndex] = uigetfile([olfStimPath filesep '*.mat'],'Select a smell.mat or olfStimTrialSeq.mat, specifying the sequence of trials for a session.');
if fileName == 0
    return
end
pathToFile = [pathName fileName];
load(pathToFile);

%% Remove all the information that is stored in smell during execution of a trial
% This is important, as there might be data which are continuously written
% to smell during a trial (eg MFC flow rates). If an old smell structure is
% used to instruct olfStim for a new session, this data has to be removed,
% otherwise weird behavior can happen.
smell = protocolUtilities.removeHistoricalTrialDataFromSmell(smell);

%% Repopulate smell with the information of the current session
% This is necessary as we removed some session specific data as well. Eg
% olfactometerOdors and session protocol

protocolUtilities.repopulateSmell();

%% Update the gui

for i = 1 : length(smell.trial)
    protocolUtilities.progressPanel(h,'update',smell.trial(i),i,'Color',[0.5 0.5 0.5]);
end

end