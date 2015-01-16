function triggerOdorCallback(~,~,trialOdor,stimProtocol)
% This trial triggering function should be used in all stimulation
% protocols, which use the setUpOdorPushButtons.m function to create odor
% pushbuttons on the gui. 
% The function has to be localized in the +folder of the stimulation
% protocol. The function has to be adapted, depending on what you want to
% do once an odor's pushbutton has been clicked. For example in the
% manualStim it will start the trial. In the manualProgrammingStim on the
% other hand it will only add a new trial to the smell structure, update
% the progress panel etc. but not start a trial.
%%

global trialNum
global smell

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');
%% Import function packages

% Import all functions of the current stimulation protocol
import manualStim.*
import protocolUtilities.*

%% First save the current smell file to the temp folder in case anything happens.

saveTemporarySmell(smell);

%% Now trigger the trial

trialNum = round(trialNum+1); % every time a odor is triggered a new trial is counted

% 1. extract the current olfactometerSettings. 
%   This will update the global olfactometerSettings structure to the
%   current instructions from the gui.
olfactometerSettings(h,'get');

% 2. extract the concentration of from gui and update trialOdor
trialOdor.concentrationAtPresentation = str2num(get(h.protocolSpecificHandles.concentration(trialOdor.slave,trialOdor.vial),'string'));

% 3. update the smell structure
 buildSmell('update',[],trialOdor,trialNum,stimProtocol); % update smell structure

% 4. update the progress panel on the gui
 progressPanel(h,'update',trialOdor,trialNum);

% 5. Start the new trial
%   This will build the lsq file for the current trial, send the
%   instructions to the olfactometer and trigger the trial.
smell = olfStimStartTrial(trialNum, smell);

end
