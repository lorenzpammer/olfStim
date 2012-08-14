h2 = actxcontrol('LASOMX.LASOMXCtrl.1')
invoke(h2, 'DevOpen', 0, 1)
invoke(h2, 'GetLastError')
% invoke(h2, 'AboutBox')
invoke(h2, 'GetID')
invoke(h2, 'ParseSeqFile', 'ValveSeriesSeq6.lsq')
invoke(h2, 'CompileSequence')
invoke(h2, 'LoadAndRunSequencer', 1)
b2 = get(h2, 'Active')
t3 = -1.0
t3 = get(h2, 'SequencerLabelTimeValue', '@EndLoop1')
t3;
release(h2)
