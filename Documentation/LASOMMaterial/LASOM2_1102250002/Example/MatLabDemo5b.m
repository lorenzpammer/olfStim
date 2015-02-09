% open two LASOM boards
% h2 = board with ID 3013
% h3 = board with ID 2023
h2 = actxcontrol('LASOMX.LASOMXCtrl.1')
invoke(h2, 'DevOpen', 3013, 1)
invoke(h2, 'GetLastError')
% invoke(h2, 'AboutBox')
invoke(h2, 'GetID')
invoke(h2, 'SetOdorValve', 1, 3, 1)
invoke(h2, 'SetGateValve', 1, 13, 1)
b1 = invoke(h2, 'GetBeam', 1)
b2 = get(h2, 'Active')
h3 = actxcontrol('LASOMX.LASOMXCtrl.1')
invoke(h3, 'DevOpen', 2023, 1)
invoke(h3, 'GetLastError')
invoke(h2, 'GetID')
invoke(h3, 'GetID')
release(h2)
release(h3)
