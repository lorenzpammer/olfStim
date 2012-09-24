Readme.txt
for deliver.zip

This collection of files demonstrates at a primitive level how to manage a LASOM based olfactometer from Matlab.
Although odors could be selected directly from Matlab, and that capability may be useful for set up or debugging the experiment,
in general it is more useful to use the sequencer within the LASOM controller to directly drive valves and report progress via digital outputs.
This will take advantage of the sub millisecond timing capabilities of the sequencer.
Control from the host PC via Matlab or the equivalent has much less precise timing.

This simple example sets up and emits an odor three times.
The Matlab output as it executes Deliver.m has been saved in the file MatLabLog.txt.
The Matlab script enables the LASOM debug window. That output is saved in DebugWindowLog.txt.

Normally, do not enable the debug window since it does not behave well after the first time. (Set last Open parameter to 0, not 1).

The LASOM debug log shows the emit status messages arriving at the PC.
Note that by the time MatLab Deliver.m checks the sequence count, three status messages have been received for each trial.
Deliver.m only sees the last of the three since it is blindly pausing during the sequencer operation.
You can of course do more in Matlab while waiting for the status changes.

The MFC commands fail since there was no MFC available for this demo, but should work the device is attached.

The Matlab script controls the sequencer by using some of the 8 sequencer variables.
The PC can read and write the variable values.
The varable values are included in emit status messages from the sequencer.

Here, a variable is used to plan which odor will be used,
and another is used to actually allow the sequencer program to proceed and deliver the selected odor.

