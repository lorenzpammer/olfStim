function manualSessionProgrammingStim
%
% lorenzpammer 2012/01

global smell
global olfactometerOdors
global h
global trialNum


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define some variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These variables have to be defined in every stimulation paradigm
trialNum = 0;
stimProtocol = 'manualSessionProgrammingStim';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up common gui components for all stimulation paradigms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 1. Progress panel
progressPanel('setUp'); % progressPanel is a function private to the stimulation protocols

% 2. Button for closing the gui
closeGui; %

% 3. Notes field
sessionNotes('setUp'); % sessionNotes is a function private to the stimulation protocols. Sets up a panel with possibilities for note taking

% % 4. Start session button % not necessary for the manualStim protocol
% startSession;

% 5. End session button
quitSession; % endSession is a function private to the stimulation protocols. Sets up a functional button to end the session, save the smell structure, disconnect from LASOM etc.

% % 6. Pause session button
% pauseSession; % pauseSession is a function private to the stimulation protocols. Sets up a functional button to pause the session

% 7. OlfactometerInstructionsi
olfactometerSettings('setUp');

end