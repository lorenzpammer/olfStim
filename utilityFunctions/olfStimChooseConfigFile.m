function olfStimChooseConfigFile
%
%
% lorenzpammer 2015/01




%% Send osq file of the current trial to the LASOM

configFn = 'olfStimConfiguration.m';
configPath = which(configFn);
configPath(length(configPath)-length(configFn):length(configPath))=[];

% Find all files in the folder
files=dir(configPath);
files = {files.name};

% See whether the config file is present
index = strcmp(files,'olfStimConfiguration.m');
if any(index)
    configIndex = find(index);
else
    warning('There might be a problem with the olfStimConfiguration. No previous olfStimConfiguration.m file was found. This should not be the case.')
end

% Check whether the default config file is available
index = strcmp(files,'olfStimConfiguration_Default.m');
if any(index)
    defaultConfigIndex=find(index);
else
    error('No olfStimConfiguration_Default.m file was found.')
end

%% Find personal config files

% Use regular expressions to find only the right files (make sure no .~ or
% .asv files etc. are found
index = regexp(files,'^olfStimConfiguration_.*\.m$');
index = ~cellfun(@isempty,index); % detects the non empty (= matching cells)
personalConfig = files(index); % remove all irrelevant files
temp = strcmp('olfStimConfiguration_Default.m',personalConfig); % find default again
personalConfig(temp) = []; % delete default name


%% Choose which config file to use
% If there are personal config files in the folder let the user choose
% which one to use, if there are none, choose the default.

if ~isempty(personalConfig)
    % First see whether the user already specified their default
    % configuration
    userDefaultExists = strcmp(files,'userDefault.txt');
    if any(userDefaultExists)
        selectedConfig = fileread([configPath filesep  'userDefault.txt']);
        configFile = fileread([configPath filesep  selectedConfig]);
    else
        listOfConfigOptions = cellfun(@(x) x(22:end-2), personalConfig,'UniformOutput',false); % Extract names of personal config files
        listOfConfigOptions = [listOfConfigOptions 'Default'];
        
        h = figure(         'MenuBar','none', ...
            'Toolbar','none', ...
            'HandleVisibility','callback', ...
            'Color', get(0,...
            'defaultuicontrolbackgroundcolor'),...
            'Position',[561   575   231   120]);
        % Title of the gui
        hText = uicontrol(...
            'Parent', h, ...
            'Units','normalized',...
            'Position',[0.1 0.7 0.8 0.25],...
            'HandleVisibility','callback', ...
            'String',['Select the olfStim configuration file.'],...
            'Fontsize',14,'Style','text');
        % Popupmenu with the configuration choices
        hPopupmenu = uicontrol(... % List of available types of plot
            'Parent', h, ...
            'Units','normalized',...
            'Position',[0.05 0.23 0.5 0.3],...
            'HandleVisibility','callback', ...
            'String',listOfConfigOptions,...
            'Style','popupmenu');
        % Checkbox to remember configuration
        hCheckbox = uicontrol(... % List of available types of plot
            'Parent', h, ...
            'Units','normalized',...
            'Position',[0.57 0.35 0.2 0.2],...
            'HandleVisibility','callback', ...
            'Style','checkbox');
        hCheckboxText = uicontrol(... % List of available types of plot
            'Parent', h, ...
            'Units','normalized',...
            'Position',[0.65 0.2 0.3 0.4],...
            'HandleVisibility','callback', ...
            'String',['Remember the choice. Don''t ask again.'],...
            'Style','text');
        % Enter button
        hEnterButton = uicontrol(... % Button for updating selected plot
            'Parent', h, ...
            'Units','normalized',...
            'HandleVisibility','callback', ...
            'Position',[0.25 0.05 0.5 0.2],...
            'String','Enter',...
            'Callback', {@hEnterButtonCallback});
        
        uiwait(h)
        
        % Select the user's choice
        choice = get(hPopupmenu,'Value');
        selectedConfig = listOfConfigOptions{choice};
        rememberSelection=logical(get(hCheckbox,'Value'));
        
        delete(h)
        
        % Load the selected confic files
        selectedConfig = ['olfStimConfiguration_' selectedConfig '.m'];
        configFile = fileread([configPath filesep  selectedConfig]);
        
        % If the user wants to remember the selection write this into the local
        % file
        if rememberSelection
        fid = fopen([configPath filesep  'userDefault.txt'],'w');
        fprintf(fid,'%s',selectedConfig);
        fclose(fid);
        clear fid;
        end
    end
    
else % if no personal files are available, use default file
    disp('Using the default configuration file.')
    configFile = fileread([configPath filesep  'olfStimConfiguration_Default.m']);
end








%% Save olfStimConfiguration file:
fid = fopen([configPath filesep  'olfStimConfiguration.m'],'w');
fprintf(fid,'%s',configFile);
fclose(fid);
clear fid;



%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GUI Callbacks

    function hEnterButtonCallback(hObject, eventdata)
        % Callback function run when the Update button is pressed
        uiresume(h)
    end

end