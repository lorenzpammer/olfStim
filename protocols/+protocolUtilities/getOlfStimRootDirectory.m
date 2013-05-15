function olfStimPath = getOlfStimRootDirectory()
% olfStimPath = getOlfStimRootDirectory()
% This function returns the path to the olfStim root directory, without a
% fileseparator at the very end.
% 
% lorenzpammer 2013/05

%% Save the temporary smell structure

% Get the location of initOlfStim.m - this is the root directory of olfStim
callingFunctionName = 'initOlfStim.m'; 
olfStimPath = which(callingFunctionName);
olfStimPath(length(olfStimPath)-length(callingFunctionName):length(olfStimPath))=[];

end