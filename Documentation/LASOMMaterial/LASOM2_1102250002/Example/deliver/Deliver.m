slave = 1
lasomID = 0
h2 = actxcontrol('LASOMX.LASOMXCtrl.1')
resultOpen = invoke(h2, 'DevOpen', lasomID, 1)
resultLastError = invoke(h2, 'GetLastError')
% invoke(h2, 'AboutBox')
resultID = invoke(h2, 'GetID')
resultParse = invoke(h2, 'ParseSeqFile', 'Deliver.lsq')
resultCompile = invoke(h2, 'CompileSequence')
resultLoadRun = invoke(h2, 'LoadAndRunSequencer', 1)

% seqEnable should always be nonzero, since we never really stop the sequencer
seqEnable1 = get(h2, 'SeqUpdateEnable')

% seqCount should increment with each emit status, one way to observer progress
seqCount1 = get(h2, 'SeqUpdateCount')

% seqStep indicates which step did the last emit status, one way to observer progress
seqStep1 = get(h2, 'SeqUpdateStep')

%
% for Deliver.lsq
% sequencer var 1 controls the odor selection
% Sequencer var 2 control execution of the trial
%   set 0 to abort the trial
%   set nonzero to use the odor selection and start the trial
%
var4odor = 1
var4control = 2

% varControl indicates a particular variable state upon the last emit status, one way to observer progress
varControl1 = get(h2, 'SeqUpdateVarState', var4control)

% pick odor 3
resultSetOdor3 = invoke(h2, 'SetSequencerVar',var4odor,3)

%
% enable the trial sequence
resultSetControl = invoke(h2, 'SetSequencerVar',var4control,1)

% (for example) abort the trial sequence
%%%% invoke(h2, 'SetSequencerVar(var4control,0)

% add code to check for emit status events, and from which step
% We should see at least two count changes.
% The step number will be back to the original when the sequencer is back to the label@ReStartTrial
% This code just checks received emit status messages, it does not bother the sequencer with requests.
% The sequencer program will set the control var to zero when the trial is done, so we could check that also.
seqCount2 = get(h2, 'SeqUpdateCount')
seqStep2 = get(h2, 'SeqUpdateStep')
varControl2 = get(h2, 'SeqUpdateVarState', var4control)

pause(24);

seqCount2w = get(h2, 'SeqUpdateCount')
seqStep2w = get(h2, 'SeqUpdateStep')
varControl2w = get(h2, 'SeqUpdateVarState', var4control)

%
% We can also just abort the trial, wait here, and then initiate a new trial.
% But the sequecer timing is probably more precise.

%
% Pick another odor (odor 4) and do a trial
%
resultSetOdor4 = invoke(h2, 'SetSequencerVar',var4odor,4)
resultSetControl = invoke(h2, 'SetSequencerVar',var4control,1)

%
% wait for the trial to finish (or abort it)
% ...
%
pause(24);

seqCount3w = get(h2, 'SeqUpdateCount')
seqStep3w = get(h2, 'SeqUpdateStep')
varControl3w = get(h2, 'SeqUpdateVarState', var4control)

%
% While the sequencer is waiting for a signal to start the next trial, change an MFC flow rate.
%
mfc = 2
resultSetMFC2to50 = invoke(h2,'SetMfcFlowRate', slave, mfc, 50.0)
%
% Check the flow rate
%
t3 = get(h2, 'MfcFlowRateMeasurePercent', slave, mfc)

%
% Pick another odor (odor 5) and do a trial
%
resultSetOdor5 = invoke(h2, 'SetSequencerVar',var4odor,5)
resultSetControl = invoke(h2, 'SetSequencerVar',var4control,1)

%
% wait for the trial to finish (or abort it)
% ...
%
pause(24);

seqCount4w = get(h2, 'SeqUpdateCount')
seqStep4w = get(h2, 'SeqUpdateStep')
varControl4w = get(h2, 'SeqUpdateVarState', var4control)

release(h2)
