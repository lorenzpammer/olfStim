function clearSessionDataCallback(~,~,askForUserApproval)
% loadSequenceOfTrialsInstructionsCallback(~,~,callbackFunctionName)
% This callback function will load sequence of trial instructions and smell
% structures. It will remove all historical trial execution specific data
% from smell and will update the progress panel to show the list of
% unexecuted trials.
%
% lorenzpammer september 2012

%%

global trialNum
% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');
if nargin < 3
    askForUserApproval = true;
end

%% Clear smell

if askForUserApproval
    selection = questdlg('Are you sure you want to clear all data associated with this session?',...
        'Close Request Function',...
        'Yes','No','Yes');
else
    selection = 'Yes';
end

switch selection,
    case 'Yes',
        % Clear the global smell variable
        clearvars -global 'smell'
        % set trialNum to zero
        trialNum = 0;
        
        % Now set up a fresh smell structure.
        selectedProtocol=appdataManager('olfStimGui','get','selectedProtocol');
        olfactometerOdors = appdataManager('olfStimGui','get','olfactometerOdors');
        buildSmell('setUp',olfactometerOdors,[],[],selectedProtocol);
        
        % Clear progress panel
        delete(get(h.progress.figure,'Children'))
        xlim(h.progress.figure,[0.5 10.5])
        
    case 'No'
        return
end

end