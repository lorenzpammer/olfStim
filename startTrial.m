function startTrial(trialNum)
% startTrial(trialNum)
% This function assumes all information for the current trial are present
% in smell and that these values are correct. From here on no more checking
% whether numbers make sense or not. Will just result in errors or
% incorrect triggering of the vials.
%
% - To do: get the actual timing of events from LASOM and write it into the
% smell structure.
%
% lorenzpammer dec 2011

global smell

%% Build the lsq file for the current trial
% buildTrialLsq.m will create an lsq file taking into account the
% olfactometerInstructions for the current trial.

trialLsq = buildTrialLsq(trialNum);
smell.trial(trialNum).trialLsqFile = trialLsq;
% Add the lsq file for the current trial into the smell structure

%%
% lasomFunctions('connect');


%% set up LASOM
% invoke(h2, 'ClearSequence') 
% % invoke(h2, 'SetParamValue', 'WaitTime1', 400) 
% invoke(h2, 'ParseSeqFile', 'Example7.lsq') 
% invoke(h2, 'CompileSequence') 
% invoke(h2, 'LoadAndRunSequencer')
% 
% % check the state of the variable
% get(h2, 'SequencerVar', 1)

pause(1) 
disp(['Triggered trial ' num2str(trialNum)])
    

end