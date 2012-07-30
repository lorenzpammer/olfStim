function smell = calculateMfcFlowRates(trialNum, smell)
% calculateMfcFlowRates(trialNum, smell) calculates the flow rate for the two mass
% flow controllers, given the desired final concentration of odorant and
% the desired total rate of flow. The function updates the global smell structure.
%
% To do: 
% Fix error handling: if desired concentration cannot be reached because 
% the Nitrogen mfc only has a limited range, give an error and return
% without triggering the trial.
%
% lorenzpammer July, 2012


%% 

% Calculate flow rate ratio between 100% flow of both MFCs 
ratio = smell.olfactometerSettings.maxFlowRateMfcNitrogen/smell.olfactometerSettings.maxFlowRateMfcAir;
% Calculate the desired dilution factor to reach the desired concentration,
% given the odorant dilution in the vial:
dilutionFactorForTrial = smell.trial(trialNum).concentrationAtPresentation / (ratio * smell.trial(trialNum).odorantDilution);
% Flow rate of the Nitrogen MFC at 100% flow of the air MFC, to reach the
% desired concentration:
flowRateMfcN = smell.olfactometerSettings.maxFlowRateMfcNitrogen * dilutionFactorForTrial; 
% The combined flow rate of the two MFCs to reach the desired
% concentration, with 100% flow rate of the air MFC:
totalFlowRate = flowRateMfcN + smell.olfactometerSettings.maxFlowRateMfcAir;

% Find the index of the MfcTotalFlow field in the olfactometerInstructions:
index = find(strcmp({smell.trial(trialNum).olfactometerInstructions.name},'mfcTotalFlow'));

% Ratio to reach the desired total flow rate:
ratio = smell.trial(trialNum).olfactometerInstructions(index).value / totalFlowRate;
% Multiply the calculated flow rates by the ratio, to get the flow rates
% to reach the desired concentration with the desired combined (total) flow
% rate:
flowRateMfcN = flowRateMfcN * ratio;
flowRateMfcAir = smell.olfactometerSettings.maxFlowRateMfcAir * ratio;

% Check if the desired flow rates can be reached given the maximum flow
% rates of the MFCs. If not give an error:
if flowRateMfcN > smell.olfactometerSettings.maxFlowRateMfcNitrogen || ...
        flowRateMfcAir > smell.olfactometerSettings.maxFlowRateMfcAir
    errormsg = sprintf('Concentration can not be reached.\nDesired: flowRateMfcAir = %f\nflowRateMfcN=%f.',flowRateMfcAir,flowRateMfcN);
    error(errormsg)
    clear errormsg
else
    % Update smell structure:
    smell.trial(trialNum).flowRateMfcN = flowRateMfcN;
    smell.trial(trialNum).flowRateMfcAir = flowRateMfcAir;
end

end