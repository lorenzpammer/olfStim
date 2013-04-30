function repopulateSmell(olfactometerOdors,selectedProtocol)
%% repopulateSmell(smell,selectedProtocol)
% When loading previously saved sequence of trials to use that sequence,
% repopulateSmell will repopulate that saved smell structure with
% information specific to the current session.
% selectedProtocol and olfactometerOdors are optional input. If the
% function is used for scripting, these inputs have to be provided. If the
% gui is used the function will automatically get the data from appdata.
%
% The following data are updated in the smell structure:
% - smell.olfactometerOdors
% - smell.trial(i).stimProtocol
% - smell.trial(i). - all odor information from olfactometerOdors except
% whatever is specified in this function. 
% 
% Furthermore this function performs checks:
%   - whether the odors that are present in the sequence of trials have also
%     been loaded in the olfactometer.  
%   - whether the concentrations defined in the sequence of trials are
%   possible with the given odorants & MFC flow rates.
% smell.version will be updated for every trial from buildSmell.m
%
% lorenzpammer 2012/11
%%

global smell

%%

%if nargin < 1
 %   error('smell has to be provided to the function.')
if nargin < 1
    olfactometerOdors = appdataManager('olfStimGui','get','olfactometerOdors');
    % Extract the gui handle structure from the appdata of the figure:
    h=appdataManager('olfStimGui','get','h');
    selectedProtocol = appdataManager('olfStimGui','get','selectedProtocol');
elseif nargin < 2
    % Extract the gui handle structure from the appdata of the figure:
    h=appdataManager('olfStimGui','get','h');
    selectedProtocol = appdataManager('olfStimGui','get','selectedProtocol');
end

%% Set the session parameters.

% The positions of odorants can change in the olfactometer
smell.olfactometerOdors = olfactometerOdors;

% Set the maximum flow rate of the Mass flow controllers & the
% olfactometerID
buildSmell('updateFields',[],[],[],[],[],'maxFlowRateMfc','olfactometerID');

%% Repopulate the trial structures

% Exclude the following fields in smell.trial from updating:
excludeFields = {'concentrationAtPresentation'};

for trialNum = 1 : length(smell.trial)
    % selected protocol
    smell.trial(trialNum).stimProtocol = selectedProtocol;
    
    % As location of vials in olfactometer, producer company of an odorant
    % etc. can change, also update the odorant information of each trial in
    % smell from the olfactometerOdors.
    loadedOdors = {olfactometerOdors.sessionOdors.odorName};
    index = strmatch(smell.trial(trialNum).odorName,loadedOdors);
    
    if isempty(index)
        % If the odor specified in the sequence of trials (smell) doesn't match
    % any of the loaded odorants give an error
        warnString = sprintf('The odor %s which is present in the specified trial sequence has not been loaded into the olfactometer (as specified by you in the olfactometer odor selection gui). All session data will be cleared.',smell.trial(trialNum).odorName);
        warndlg(warnString)
        protocolUtilities.clearSessionDataCallback([],[],false);
        return
    else
        trialOdor = olfactometerOdors.sessionOdors(index);
        trialOdorFields = fields(trialOdor); % get name of fields in trialOdor (also present in smell
        % get the indices of the fields which should be removed
        for j = 1 : length(excludeFields)
            excludeFieldIndex(j) = strmatch(excludeFields{j},trialOdorFields);
        end
        updateFieldIndex = 1 : length(trialOdorFields); % get an index for all fields
        updateFieldIndex(excludeFieldIndex)=[]; % remove the index of the field which should be included
        % update first couple of fields (same as in trialOdor) with the data for the current trial.
        for j = updateFieldIndex
            smell.trial(trialNum) = setfield(smell.trial(trialNum),trialOdorFields{j},getfield(trialOdor,trialOdorFields{j}));
        end
        
        % Test whether the concentrationAtPresentation values specified in
        % the sequence of trials are allowed given the dilution of odorant
        % in the vial and 
        try
            % If concentration can not be achieved, give an error
            calculateMfcFlowRates(trialNum,smell,'error');
        catch
            % If it can't be reached catch the error, give a warning and
            % set smell back to base state.
            warnString = sprintf('The concentration of trial %d can not be presented given the dilution of odorant and MFC flow rates. All session data will be cleared.',trialNum);
            warndlg(warnString)
            protocolUtilities.clearSessionDataCallback([],[],false);
            return
        end
        
    end
end
end