function clearSessionDataCallback(~,~)
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

%%

selection = questdlg('Are you sure you want to clear all data associated with this session?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        % Clear the global smell variable
        clearvars -global 'smell'
        % set trialNum
        trialNum = 0;
        
        % Now set up a fresh smell structure.
        selectedProtocol=appdataManager('olfStimGui','get','selectedProtocol');
        buildSmell('setUp',[],[],selectedProtocol);
        
        % Clear progress panel
        delete(get(h.progress.figure,'Children'))
        xlim(h.progress.figure,[0.5 10.5])
        
    case 'No'
        return
end

end