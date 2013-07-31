function triggerOdorCallback(~,~,trialOdor,stimProtocol)
% This trial triggering function should be used in all stimulation
% protocols.

global trialNum
global smell

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%% Import function packages

% Import all utility functions
import protocolUtilities.*

%% First save the current smell file to the temp folder in case anything happens.

saveTemporarySmell(smell)

%% Now extract all the information for the trial, and write it into smell

trialNum = round(trialNum+1); % every time a odor is triggered a new trial is counted

% 1. extract the current olfactometerSettings. 
%   This will update the global olfactometerSettings structure to the
%   current instructions from the gui.
protocolUtilities.olfactometerSettings(h,'get');

% 2. extract the concentration from gui and update trialOdor
trialOdor.concentrationAtPresentation = str2num(get(h.protocolSpecificHandles.concentration(trialOdor.slave,trialOdor.vial),'string'));

% 3. extract the current sessionSettings & write the updated version in the
% appdata of the gui
sessionSettings(h,'get');

% 4. update the smell structure
 buildSmell('update',[],trialOdor,trialNum,stimProtocol); % update smell structure

% 5. update the progress panel on the gui
 protocolUtilities.progressPanel(h,'update',trialOdor,trialNum,'Color',[0.5 0.5 0.5]); % 

end