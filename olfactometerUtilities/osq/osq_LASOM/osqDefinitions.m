function [sequencerName, timeFactor] = osqDefinitions
% Define some aspects of this particular sequencer used.

sequencerName = 'LASOM2';
timeFactor = 1000; % LASOM expects time values in milliseconds. All olfstim values are in seconds.

end