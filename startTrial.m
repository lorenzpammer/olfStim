function startTrial(trialNum)
% startTrial(trialNum)
% This function assumes all information for the current trial are present
% in smell and that these values are correct. From here on no more checking
% whether numbers make sense or not. Will just result in errors or
% incorrect triggering of the vials.
%
% lorenzpammer dec 2011

global smell

trialLsq = buildTrialLsq(trialNum);


pause(1) 
disp(['Triggered trial ' num2str(trialNum)])
    

end