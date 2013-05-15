function saveTemporarySmell(smell)
% This function will save a temporary smell structure into the temp folder
% of the user data in olfStim. Use this function before starting every
% trial in order to avoid loosing all the user's data.
%
% lorenzpammer 2013/05

%% Save the temporary smell structure

% Get the location of initOlfStim.m - this is the root directory of olfStim
olfStimPath = protocolUtilities.getOlfStimRootDirectory;

% Define the path of the storage folder for temporary smell structures
olfStimPath=[olfStimPath filesep 'User Data' filesep 'temp' filesep];
clear callingFunctionName

% Give a default title for the temporary file:
defaultTitle = [datestr(date,'yyyy.mm.dd') '_smell_temp'];
extendedPath = [olfStimPath defaultTitle '.mat'];

% Save the smell structure
save(extendedPath,'smell')

clear olfStimPath defaultTitle

end