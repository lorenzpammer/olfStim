function calculateMfcFlowRates(trialNum)
% calculateMfcFlowRates(trialNum) calculates the flow rate for the two mass
% flow controllers, given the desired final concentration of odorant and
% the desired total rate of flow. The function updates the global smell structure.
%
% To do: 
% Fix error handling: if desired concentration cannot be reached because 
% the Nitrogen mfc only has a limited range, give an error and return
% without triggering the trial.
%
% lorenzpammer July, 2012

global smell


%% 


ratio = smell.olfactometerSettings.maxFlowRateMfcNitrogen/smell.olfactometerSettings.maxFlowRateMfcAir;
dilutionFactorForTrial = smell.trial(trialNum).concentrationAtPresentation / ratio;
flowRateMfcN = smell.olfactometerSettings.maxFlowRateMfcNitrogen * dilutionFactorForTrial;

totalFlowRate = flowRateMfcN + smell.olfactometerSettings.maxFlowRateMfcAir;


% Find the index of the MfcTotalFlow field in the olfactometerInstructions:
index = find(strcmp({smell.trial(trialNum).olfactometerInstructions.name},'mfcTotalFlow'));
ratio = smell.trial(trialNum).olfactometerInstructions(index).value / totalFlowRate;

flowRateMfcN = flowRateMfcN * ratio;
flowRateMfcAir = smell.olfactometerSettings.maxFlowRateMfcAir * ratio;

if flowRateMfcN > smell.olfactometerSettings.maxFlowRateMfcNitrogen || ...
        flowRateMfcAir > smell.olfactometerSettings.maxFlowRateMfcAir
    errormsg = sprintf('Concentration can not be reached.\nDesired: flowRateMfcAir = %f\nflowRateMfcN=%f.',flowRateMfcAir,flowRateMfcN);
    error(errormsg)
    clear errormsg
else
    smell.trial(trialNum).flowRateMfcN = flowRateMfcN;
    smell.trial(trialNum).flowRateMfcAir = flowRateMfcAir;
end

end