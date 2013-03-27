function log = extract(numberOfTrials)
% log = extract(numberOfTrials)
%
% lorenzpammer 2013/03

%% Check inputs
if nargin < 1
    numberOfTrials = [];
end

%% Get a couple of needed variables and packages
h = appdataManager('olfStimGui','get','h');
import protocolUtilities.logWindow.*

%% Extract the contents of the log window
% Check whether the log field exists in the gui handle structure:
if isfield(h,'log')
    % Check whether the logWindow field exists in the h.log handle structure:
    if isfield(h.log,'logWindow')
        if ~isempty(h.log.logWindow)
            % Extract the current log from the window:
            log = get(h.log.logWindow,'String');
            % Find the log messages which denote beginning of trials:
            trialStartIndex = strfind(log,'Started to execute trial');
            trialStartIndex = cellfun(@(x) ~isempty(x),trialStartIndex);
            if all(trialStartIndex == 0)
                warnstr = sprintf('No strings indicating the beginning of trials could be found in the log window. Did the log message change?');
                issueLogMessage(warnstr);
            elseif ~isempty(numberOfTrials)
                trialStartIndex = find(trialStartIndex);
                index = trialStartIndex(end-numberOfTrials+1:end);
                log = log(min(index):end);
            end
        else
            log = '';
        end
    else
        log = [];
    end
else 
    log = [];
end

end