function triggerOdorCallback(~,~,trialOdor,stimProtocol)
% This trial triggering function should be used in all stimulation
% protocols.

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
