% lpammer July 2011

start the program by executing the command initOlfStim in the Matlab command line

Nomenclature for the workings of the olfactometer:
MFC - mass flow controllers. 
gatingValveTime = open door gating valves & close empty vial gating valves.
purgeTime = both MFCs are set to maximal flow, to purge the line.

To add control of a new valve: 
At the moment there's no easy way to connect new valves to the olfactometer and use them right away. 
The code has to be altered in a bunch of places:
olfactometerSettings.m - when setting up the olfactometerInstructions structure
			- 
			- subfunction trialSeqButton
timeStampDefinitions.m - 