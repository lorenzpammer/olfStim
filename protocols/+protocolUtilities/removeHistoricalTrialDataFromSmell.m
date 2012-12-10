function smell = removeHistoricalTrialDataFromSmell(smell)
% This is important, as there might be data which are continuously written
% to smell during a trial (eg MFC flow rates). If an old smell structure is
% used to instruct olfStim for a new session, this data has to be removed,
% otherwise weird behavior can happen.
%
% lorenzpammer september 2012


%% Delete trial specific information from the individual trials

for i = 1 : length(smell.trial)
    smell.trial(i).stimProtocol = [];
    smell.trial(i).time = [];
    smell.trial(i).notes = [];
    smell.trial(i).flowRateMfcAir = [];
    smell.trial(i).flowRateMfcN = [];
    
    settingNames = {smell.trial(1).sessionInstructions.name};
    index = strmatch('scientist',settingNames);
    smell.trial(i).sessionInstructions(index).value = [];
    index = strmatch('animalName',settingNames);
    smell.trial(i).sessionInstructions(index).value = [];
    smell.trial(i).lasomEventLog.flowRateMfcAir = [];
    smell.trial(i).lasomEventLog.flowRateMfcN = [];
    smell.trial(i).trialLsqFile = [];
end

%% Delete session specific information from smell
smell.olfactometerOdors = [];
for i = 1 : length(smell.olfactometerSettings.slave)
    smell.olfactometerSettings.slave(i).maxFlowRateMfcAir = [];
    smell.olfactometerSettings.slave(i).maxFlowRateMfcNitrogen= [];
end
smell.olfactometerSettings.olfactometerID = [];

end