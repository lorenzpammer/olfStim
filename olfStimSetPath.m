function olfStimSetPath
% olfStimSetPath()
% This function adds all folders necessary for running olfStim to the
% Matlab path. Users only have to add the the top folder to their matlab
% path.
%
% lorenzpammer October 2012

%% Adding the necessary folders to the Matlab path

callingFunctionName = 'initOlfStim.m'; % Define the name of the initalizing function in the top level folder
olfStimTopDirectory = which(callingFunctionName);
olfStimTopDirectory(length(olfStimTopDirectory)-length(callingFunctionName):length(olfStimTopDirectory))=[];


addpath([olfStimTopDirectory filesep 'lsq'],...
        [olfStimTopDirectory filesep 'odorLibrary'],...
        [olfStimTopDirectory filesep 'odorSelection'],...
        [olfStimTopDirectory filesep 'olfactometerUtilities'],...
        [olfStimTopDirectory filesep 'protocols'],...
        [olfStimTopDirectory filesep 'utilityFunctions']);

end