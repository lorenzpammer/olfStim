function smell = calculateMfcFlowRates(trialNum, smell,errorType)
% calculateMfcFlowRates(trialNum, smell,errorType) calculates the flow rate
% for the two mass flow controllers, given the desired final concentration
% of odorant and the desired total rate of flow. The function updates the
% global smell structure.
%
% errorType;
% 'popUp' - popup giving warning that the desired concentration can't be
% achieved.
% 'error' - function throws an error if the desired concentration can't be
% achieved
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

flowRateMfcN = smell.trial(trialNum).concentrationAtPresentation * smell.olfactometerSettings.slave(1).maxFlowRateMfcNitrogen / smell.trial(trialNum).odorantDilution;
flowRateMfcAir = smell.olfactometerSettings.slave(1).maxFlowRateMfcNitrogen - flowRateMfcN;

totalFlow = flowRateMfcN + flowRateMfcAir;

% Find the index of the MfcTotalFlow field in the olfactometerInstructions:
index = find(strcmp({smell.trial(trialNum).olfactometerInstructions.name},'mfcTotalFlow'));

ratio = smell.trial(trialNum).olfactometerInstructions(index).value / totalFlow;
flowRateMfcN = flowRateMfcN * ratio;
flowRateMfcAir = flowRateMfcAir * ratio;

% Round the flow rates to 5 digits
flowRateMfcAir = round(flowRateMfcAir*10e5)/10e5;
flowRateMfcN = round(flowRateMfcN*10e5)/10e5;


% Check if the desired flow rates can be reached given the maximum flow
% rates of the MFCs. If not give an error:
if flowRateMfcN > smell.olfactometerSettings.slave(1).maxFlowRateMfcNitrogen || ...
        flowRateMfcAir > smell.olfactometerSettings.slave(1).maxFlowRateMfcAir
    if strmatch(errorType,'error')
        errormsg = sprintf('Concentration can not be reached. Please enter a lower value or reduce the total flow.\nDesired: flowRateMfcAir = %f\nflowRateMfcN=%f.',flowRateMfcAir,flowRateMfcN);
        error(errormsg)
        clear errormsg
    elseif strmatch(errorType,'popUp')
        selection = warndlg('The desired concentration cannot be achieved. Please enter a lower value or reduce the total flow.',...
            'Concentration too high',...
            'OK');
    end
    
else
    % Update smell structure:
    smell.trial(trialNum).flowRateMfcN = flowRateMfcN;
    smell.trial(trialNum).flowRateMfcAir = flowRateMfcAir;
end


% Give warning, if the Nitrogen Mfc is set to less than 2% of its maximal
% flow rate, as it becomes inaccurate around that point
if flowRateMfcN < smell.olfactometerSettings.slave(1).maxFlowRateMfcNitrogen/50
    if strmatch(errorType,'error')
        warningmsg = sprintf('The Nitrogen MFC is set to less than 2%% of its maximal flow rate.\nAs the MFC isn''t accurate below 2%% flow rate, please consider diluting the odorant.')
        warning(warningmsg)
        clear warningmsg;
    elseif strmatch(errorType,'popUp')
        selection = warndlg('Nitrogen MFC is set to less than 2% of its maximal flow rate.As the MFC isn''t accurate below 2% flow rate, please consider diluting the odorant.',...
            'Concentration too low',...
            'OK');
    end
end

end