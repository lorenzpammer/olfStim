% open one LASOM boards
% program DAC channel 1..4 to 100 mV time 1..4
% Get analog chip temperature and power supply voltage.
h2 = actxcontrol('LASOMX.LASOMXCtrl.1')
invoke(h2, 'DevOpen', 0, 1)
invoke(h2, 'GetLastError')
% invoke(h2, 'AboutBox')
invoke(h2, 'GetID')
invoke(h2, 'SetDac', 1, 1, 0.100)
invoke(h2, 'SetDac', 1, 2, 0.200)
invoke(h2, 'SetDac', 1, 3, 0.300)
invoke(h2, 'SetDac', 1, 4, 0.400)
temp_degC = invoke(h2, 'GetAdcMeasure2', 1, 5)
temp_degC;
vdd = invoke(h2, 'GetAdcMeasure2', 1, 6)
vdd;
release(h2)
