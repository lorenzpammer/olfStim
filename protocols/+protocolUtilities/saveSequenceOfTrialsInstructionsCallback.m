function saveSequenceOfTrialsInstructionsCallback(~,~,callbackFunctionName)
%
% Allows one to save the sequence of trials defined in a protocol (eg in
% manualSessionProgrammingStim) to a file which can then be loaded and used
% in a later olfactory session. Saves the sequence of trials as smell file,
% cleaned of session specific information.
%
% lorenzpammer 2012/11
%%
global smell
global trialNum

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Remove all the information that is stored in smell during execution of a trial
% This is important, as there might be data which are continuously written
% to smell during a trial (eg MFC flow rates). If an old smell structure is
% used to instruct olfStim for a new session, this data has to be removed,
% otherwise weird behavior can happen.
cleanedSmell = protocolUtilities.removeHistoricalTrialDataFromSmell(smell);

%% Prompt user to open the smell structure for

% Get the path to the olfStim main directory
olfStimPath = protocolUtilities.getOlfStimRootDirectory;

defaultTitle = [datestr(date,'yyyy.mm.dd') '_olfStimTrialSeq.mat'];
defaultPath = [olfStimPath filesep 'User Data' filesep 'sequenceOfTrialsInstruction'];

filterSpec = [defaultPath filesep '*.mat']
[userFn,pathname]=uiputfile(filterSpec,'Save sequence of trials',[defaultPath filesep defaultTitle]);

if ischar(userFn) && ischar(pathname) % only if filename and path specified
    s.smell = cleanedSmell;
    extendedPath = [pathname userFn];
    save(extendedPath,'-struct','s')
else
    disp('To save the sequence of trials please select a filename and path.')
end

end