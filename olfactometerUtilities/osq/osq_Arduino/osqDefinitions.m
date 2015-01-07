function [sequencerName, timeFactor] = osqDefinitions
% Define some properties of this particular sequencer.

sequencerName = 'Arduino';
timeFactor = []; % All olfstim values are in seconds. Add the multiplication factor necessary for the sequencer. Eg LASOM expects milliseconds -> timeFactor 1000

end