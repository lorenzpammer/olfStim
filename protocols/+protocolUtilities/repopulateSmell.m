function smell = repopulateSmell(smell,selectedProtocol,olfactometerOdors)
%% repopulateSmell(smell,selectedProtocol)
% selectedProtocol and olfactometerOdors are optional input. If the
% function is used for scripting, these inputs have to be provided. If the
% gui is used the function will automatically get the data from appdata.
%
% lorenzpammer 2012/11

if nargin < 2
% Extract the gui handle structure from the appdata of the figure:
    h=appdataManager('olfStimGui','get','h');
    selectedProtocol = appdataManager('olfStimGui','get','selectedProtocol');
elseif nargin < 3
 global olfactometerOdors;
end


%% Repopulate the trial structures

for i = 1 : length(smell.trial)
    % 
    smell.trial(i).stimProtocol = selectedProtocol;
end

%% Set the session parameters.

% The positions of odorants can change in the olfactometer
smell.olfactometerOdors = olfactometerOdors;

end