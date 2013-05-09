function io = ioConfiguration(instruction)
% io = ioConfiguration(instruction)
% instruction can be:
%   - 'default':user defaults as defined in olfStimConfiguration
%   - 'empty': all I/O actions will be set to unused.
%
% lorenzpammer 2013/02

%%
if nargin < 1
    instruction = 'default';
end

%% Example
% io(i).label = 'nameOfIOAction';
% io(i).type = 'string'; % indicate IO type by 'input' or 'output'
% io(i).value = 1; % the value which should 
% io(i).time = 0;
% io(i).used = 1;

if strcmp(instruction,'default')
    % Fetch the user's configuration settings:
    [label type value used time] = olfStimConfiguration('io');
    
    % Create the structure
    io = olfStimConfiguration('io','structure');
end

if strcmp(instruction,'empty') 
    % Fetch the user's configuration settings:
    io = olfStimConfiguration('io','structure');
    [io.used] = deal(false);
end

end