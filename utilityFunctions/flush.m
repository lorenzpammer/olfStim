function flush
% Typing flush in the command window clears all data from the olfStim
% paradigm.
%
% lorenzpammer 2011/11

%% Get the handle for the gui
% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%%

if isstruct(h)
    delete(get(h.guiHandle,'Children'))
    delete(h.guiHandle)
end
% close all;
clear
clear all
clear classes
clear functions
cleavars -global
clear global


end