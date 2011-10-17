function flush
% Typing flush in the command window clears all data from the olfStim
% paradigm.
global h

if isstruct(h)
    delete(get(h.guiHandle,'Children'))
end
close all;

clear all;
clear classes;
clear functions;



end