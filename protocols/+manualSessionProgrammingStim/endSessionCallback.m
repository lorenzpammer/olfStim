function endSessionCallback(~,~,callbackFunctionName)
% This function doesn't do anything. Only startSessionCallback will check
% whether the Togglebutton has been pressed.


%%
global smell

% Extract the gui handle structure from the appdata of the figure:
h=appdataManager('olfStimGui','get','h');

%%


end