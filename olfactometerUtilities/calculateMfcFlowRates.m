function smell = calculateMfcFlowRates(trialNum, smell)
% calculateMfcFlowRates(trialNum, smell) calculates the flow rate for the two mass
% flow controllers, given the desired final concentration of odorant and
% the desired total rate of flow. The function updates the global smell structure.
%
% To do: 
% - Fix error handling: if desired concentration cannot be reached because 
% the Nitrogen mfc only has a limited range, give an error and return
% without triggering the trial.
% - How should we deal with the problem: Which of the two pieces of
% information should be used to calculate flow rates?
% olfactometerInstructions.flowRateMfcAir/N or
% smell.trial(i).concentrationAtPresentation? 
%
% lorenzpammer July, 2012


%% Do the calculation and update smell

flowRateMfcN = smell.trial(trialNum).concentrationAtPresentation * smell.olfactometerSettings.maxFlowRateMfcNitrogen;
flowRateMfcAir = smell.olfactometerSettings.maxFlowRateMfcNitrogen - flowRateMfcN;

totalFlow = flowRateMfcN + flowRateMfcAir;

% Find the index of the MfcTotalFlow field in the olfactometerInstructions:
index = find(strcmp({smell.trial(trialNum).olfactometerInstructions.name},'mfcTotalFlow'));

ratio = smell.trial(trialNum).olfactometerInstructions(index).value / totalFlow;
flowRateMfcN = flowRateMfcN * ratio;
flowRateMfcAir = flowRateMfcAir * ratio;

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