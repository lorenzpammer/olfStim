function mfcTotalFlowEditCallback(~,~)
% mfcTotalFlowEditCallback(~,~)
% This function checks whether the user defined total Mfc flow surpasses
% the  maximal flow of the two mass flow controllers combined. If that's
% the case the function pops up warnings.
%
% lorenzpammer august 2012

%%
global smell
global olfactometerInstructions

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');


%% Import function packages

% Import all functions of the current stimulation protocol
import protocolUtilities.*

%% Find the mfcTotalFlow field and extract the value

for i = 1 : length(h.olfactometerSettings.edit)
    tagNames{i} = get(h.olfactometerSettings.edit(i),'Tag');
end
% Find the index of the mfcTotalFlow field
index = find(strcmp('mfcTotalFlow',tagNames));
% Get the value of the mfcTotalFlow field
userDefinedMfcTotalFlow = str2num(get(h.olfactometerSettings.edit(index),'String'));
clear tagNames index

%% Check whether the flow is too high

maximalFlowRate = smell.olfactometerSettings.slave(1).maxFlowRateMfcAir + smell.olfactometerSettings.slave(1).maxFlowRateMfcNitrogen;

if maximalFlowRate < userDefinedMfcTotalFlow
    selection = warndlg('The desired flow rate cannot be achieved. Please enter a lower value.',...
        'Flow rate too high',...
        'OK');
end

end