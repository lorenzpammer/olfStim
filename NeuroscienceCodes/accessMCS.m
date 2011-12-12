function [data, metadata] = accessMCS(path, channels, time)
% accessMCS(path, channels, time) "path" is a string giving the path and
% file name of the .raw electrophysiology data file. "channels" are the
% channels which should be extracted. For analog data channel 3 this would
% be {'E03'}, for digital channel 2 {'D2'}. Time is a 2 element vector
% containing the beginning and end of a 
% Function extracts data from raw electrophysiology files exported by the
% Multichannel software. Accesses data in memory-compatible junks directly
% from hard drive.
% 
% To do:
%   - Check how the MCS system defines the analog channels in the header.
%   Then recode accordingly
%
% Based heavily on Ingmar Schneider's ImportMCS function, adapted with the
% help of Andreas to the present form.
% lorenzpammer 12/2011

%% check inputs 

if nargin < 3
   time = []; 
end

    %% Select and open raw file
    
    fid = fopen(path, 'r', 'ieee-le.l64');
    
    
    %% Read all hdr fields and convert to an array
    dataHdr = [];
    HdrTemp = textscan(fid, '%s', 8, 'delimiter', '\b'); % Read the topmost 8 lines of text
    position = ftell(fid);
    disp(['position after header: ' num2str(position)]);
    
    FileNameMCS = textscan(HdrTemp{1,1}{3,1}, '%s', 'delimiter', sprintf('\"'));
    FileNameTemp = regexp(FileNameMCS{1,1}{2,1}, '\\', 'split');
    dataHdr.FileName = strcat(FileNameTemp{1,end}(1:(end-4)),'.raw'); 
        
    dataHdr.Import.MC_DataToolVersion = HdrTemp{1,1}{2,1};
    
    SampleRateTemp = textscan(HdrTemp{1,1}{4,1}, '%s');
    dataHdr.SampleRate = str2double(SampleRateTemp{1,1}{4,1});
    
    ADCTemp = textscan(HdrTemp{1,1}{5,1}, '%s');
    dataHdr.Import.ADC_Zero = str2double(ADCTemp{1,1}{4,1});
    
    ADStepTemp = textscan(HdrTemp{1,1}{6,1}, '%s', 'delimiter', ';');
    
    % Alternative determination of ADStep for electrode and analog-Channels
    for s = 1:size(ADStepTemp{1,1})
        if strncmp('An', ADStepTemp{1,1}{s,1}, 2) == 1;
            dataHdr.Import.An_ADStep = str2double(ADStepTemp{1,1}{s,1}(6:11));
        elseif strncmp('El', ADStepTemp{1,1}{s,1}, 2) == 1;
            dataHdr.Import.El_ADStep = str2double(ADStepTemp{1,1}{s,1}(6:11));
        elseif strncmp('Di', ADStepTemp{1,1}{s,1}, 2) == 1;
            % No AD-conversion for digital inputs!
        end;
    end;
    
    ChannelTemp = textscan(HdrTemp{1,1}{7,1},  '%s', 'delimiter', ';');
    ChannelTemp{1,1}{1,1} = ChannelTemp{1,1}{1,1}(11:end);  % Cut away the trailing 'Streams = '
    dataHdr.Channels = ChannelTemp{1,1};
    
    dataHdr.Import.DimOrd = 'ChannelxTime';
    
    %% Use fread to import RawData
    
        nbr_channels = numel(dataHdr.Channels);
        status = fseek(fid, 0, 'eof'); % command sends the index fid to the end of the file (eof) on the hard drive
        nbr_bytes_last_entry = ftell(fid); % gives the number of bytes in the file
        
        % check if has fixed length, otherwise remember position after after
        % header and move by 2 bytes.
        offset_header = position + 2; % header is eg 410, plus 1 block of 2 bytes (2 bytes signal end of header)
        
        % bytes per data point
        bytes_per_data_point = 2;
        % uint16 has 2 bytes per datapoint, hence we divide by 2.
        nbr_samples_per_channel = (nbr_bytes_last_entry - offset_header) / nbr_channels / bytes_per_data_point;
        
        for i = 1 : length(channels)
            channelToRead = channels{i};
            
            if ~isempty(strmatch(channelToRead(1), 'D')) % digital channel
                digitalChannelNo = str2num(channelToRead(2));
                channelToRead = digitalChannelNo;
                disp('Di')
                if isempty(strmatch(dataHdr.Channels{channelToRead}(1),'D'))
                    error('Digital chanel doesn''t exist')
                end
            elseif ~isempty(strmatch(channelToRead(1), 'E')) % electrode channel
                channelName = [channelToRead(1) 'l_' channelToRead(2:3)];
                channelToRead = strmatch(channelName,dataHdr.Channels);
                disp('E')
            elseif ~isempty(strmatch(channelToRead(1), 'A')) % LEFT TO DO analog channels
                
            end
            clear digitalChannelNo;clear channelName;
            
            % position to start reading
            if ~isempty(time)
                pos_to_start_reading = (channelToRead - 1) * 2 + (time(1) * nbr_channels * 2);
                pos_to_end_reading = (channelToRead - 1) * 2 + (time(2) * nbr_channels * 2);
%                 readIndex = pos_to_start_reading : nbr_channels * 2 : pos_to_end_reading;
                
                status = fseek(fid, offset_header + pos_to_start_reading, 'bof');
                samplesToRead = length(time(1) : time(2));
                
                rawData{i} = fread(fid, samplesToRead, 'uint16', (nbr_channels-1)*bytes_per_data_point);
            else
                pos_to_start_reading = (channelToRead - 1) * 2;
                % go to start position
                status = fseek(fid, offset_header + pos_to_start_reading, 'bof');
                
                rawData{i} = fread(fid, nbr_samples_per_channel, 'uint16', (nbr_channels-1)*bytes_per_data_point);
            end
            
        end
 
    
    %% Close the read file
    fclose(fid);
    
    %% Normalization of digital channels
%     if ~isempty(strmatch('D',channels)) % see whether there are digital channels among the ones to extract
%         digitalChannels = strmatch('D',channels);
%         for i = 1 : length(digitalChannels) % Go through all the digital channels
%             rawData{digitalChannels(i)} = DigitalCorr_MCS(rawData{digitalChannels(i)});
%         end
%         clear digitalChannels;
%     end;
    
    %% Scaleing analog data according to AD conversion
    % Analog channels aren't electrode channels, but if the 3 additional
    % inputs are set to record in analog mode. LEFT TO DO! 
    if ~isempty(strmatch('A',channels))
        analogChannels = strmatch('A',channels);
        for i = 1 : length(analogChannels) % Go through all the analog channels
            rawData{analogChannels(i)} = (rawData{analogChannels(i)}-dataHdr.Import.ADC_Zero)*dataHdr.Import.An_ADStep;
        end
        clear analogChannels;
    end;
    
    if ~isempty(strmatch('E',channels))
        electrodeChannels = strmatch('E',channels);
        for i = length(electrodeChannels)
        %% Scaleing electrode data according to AD conversion
         rawData{electrodeChannels(i)} = (rawData{electrodeChannels(i)}-dataHdr.Import.ADC_Zero)*dataHdr.Import.El_ADStep;
        end
%         dataHdr.ElecLayout = [2;3;4;5;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;32;33;34;35];        
        %% Generate time axis according to sampling rate and length of electrode raw data
        TimePoints = [1:size(rawData{electrodeChannels(i)},2)];
        dataHdr.TimeAxis = (TimePoints/dataHdr.SampleRate)*1000; %Milliseconds
        clear electrodeChannels;

%     else
%         %% Create dummy array if no electrode data is available
%         ElecData = [];
%         
%         %% Generate time axis according to analog data if no electrode data is recorded
%         TimePoints = [1:size(AnalogData(1,:),2)];
%         dataHdr.TimeAxis = (TimePoints/dataHdr.SampleRate)*1000; %Milliseconds
    end;

    
    

%% Define variables for output

metadata = dataHdr;
data = rawData;
%% Clear all unnecessary variables
    clear dataHdr AnalogData ElecData DigitalData ArtCorrElecData


end
