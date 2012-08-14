h2 = actxcontrol('LASOMX.LASOMXCtrl.1')
invoke(h2, 'DevOpen', 0, 1)
invoke(h2, 'GetLastError')
% invoke(h2, 'AboutBox')
invoke(h2, 'GetID')
t2 = -3
t2;
t2 = invoke(h2, 'GetMfcFlowRateMeasure2', 2, 1)
t2;
t3 = -2
t3;
t3 = get(h2, 'MfcFlowRateMeasurePercent', 2, 1)
t3;
release(h2)
