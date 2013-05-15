function flush
% Typing flush in the command window clears all data from the olfStim
% paradigm.
%
% lorenzpammer 2011/11

global olfStimScriptMode

%%

%% Get the handle for the gui
% Extract the gui handle structure from the appdata of the figure:
if isempty(olfStimScriptMode)
    h=appdataManager('olfStimGui','get','h');
end

%% Clean up everything

if isstruct(h)
    delete(get(h.guiHandle,'Children'))
    delete(h.guiHandle)
end
% close all;
if ~isempty(timerfindall)
    stop(timerfindall)
    delete(timerfindall)
end
clear
clear all
clear classes
clear functions
% cleavars -global
clear global
close all


end