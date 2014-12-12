function [sequencerName, timeFactor] = osqDefinitions
% Define some aspects of this particular sequencer used.

sequencerName = 'Arduino';
timeFactor = []; % All olfstim values are in seconds. Add the multiplication factor necessary for the sequencer. Eg LASOM expects milliseconds -> timeFactor 1000

end