function sequentialStructure = sequentialize(cellArrayOfStructures)
% sequentialTrialOdor = createSequentialTrialOdor(cellArrayOfStructures)
% The input to this function must be an array of structures with equal
% architectures. The function will merge them into one structure of the
% same architecture where the fields are cell arrays containing the values
% of the fields of the input structures.
% Use this function to merge multiple trialOdor or olfactometerInstructions
% structures for a sequential trial.
%
% lorenzpammer 2013/04

%% Create the new trialOdor structure for sequences
% Merge field entries of provided single trial odor into a cell of the
% corresponding field in the new sequential trialOdor structure
fieldNames = fields(cellArrayOfStructures{1});
sequentialStructure = [];
for h = 1 : length(cellArrayOfStructures{1}) % step through every entry of the structures
    for i = 1 : length(fieldNames) % step through each field of the structure
        for j = 1 : length(cellArrayOfStructures) % step through each structure, which should be merged
            temp{j} = getfield(cellArrayOfStructures{j}(h),fieldNames{i}); % Get values for field i of structure entry h of all structures
        end
        if h == 1
            sequentialStructure = setfield(sequentialStructure,fieldNames{i},temp); % Write the values into new structure
        else
            if i == 1
                sequentialStructure(h) = setfield(sequentialStructure(h-1),fieldNames{i},temp);
            else
                sequentialStructure(h) = setfield(sequentialStructure(h),fieldNames{i},temp);
            end
        end
        clear temp
    end
end

end