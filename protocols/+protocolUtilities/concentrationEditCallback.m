function concentrationEditCallback(~,~,slave,vialNumber)
% concentrationEditCallback(~,~,slave,vialNumber)

%%
global smell
global olfactometerInstructions

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');


%% Import function packages

% Import all functions of the current stimulation protocol
import protocolUtilities.*


%% Create a pseudo smell structure
% This pseudo smell 

pseudoSmell = smell;
% Find the index of the vial where the concentration was changed in the
% olfactometerOdors information:
index = find([pseudoSmell.olfactometerOdors.slave(slave).sessionOdors(:).vial]==vialNumber);
% Get all the information about the odor for which the concentration
% changed:
currentOdor = pseudoSmell.olfactometerOdors.slave(slave).sessionOdors(index);
% Extract all the fields of information for the odor:
currentOdorFields = fields(pseudoSmell.olfactometerOdors.slave(slave).sessionOdors(index));
% Go through each field and populate the dummy smell structure:
for i = 1 : length(currentOdorFields)
    pseudoSmell.trial(1) = setfield(pseudoSmell.trial(1),currentOdorFields{i},getfield(currentOdor,currentOdorFields{i}));
end

% Get the concentration, which was entered by the user into the edit field:
pseudoSmell.trial(1).concentrationAtPresentation = str2num(get(h.protocolSpecificHandles.concentration(slave,vialNumber),'string'));

% Get the olfactometerInstructions
olfactometerSettings(h,'get');

% Write olfactometerInstructions into pseudoSmell structure
pseudoSmell.trial(1).olfactometerInstructions = olfactometerInstructions;


%% Test whether the values are allowed

calculateMfcFlowRates(1,pseudoSmell,'popUp');

end