function odorLibrary=odorLibraryGenerator
%
% This function creates the odorLibrary structure. This structure contains
% information to every odor used in the Laurent lab.
% To change the information to a given odorant of the odorLibrary, change
% entries for the respective odor in C). 
% To add an odor add the popular name of the odor to the odorNames array in
% A) and add a new field for the odor in C), following the conventions of
% the other odors.
%
% Lorenz Pammer, March/2011
%

%% A) List odors in the library:

odorNames = {'Benzyl alcohol','Butanone','Camphor','Cineole','Citral', ...
    'Eugenol','Geranyl acetate','Hexanal','1-Hexanol','2-Hexanone','Isoamyl acetate', ...
    'Vanillin','Paraffin oil','Mineral oil','Water','Empty'}; % Cell array of strings with names of odorants in Library


%% B) Set up the property fields of each odor

odorLibrary(1:length(odorNames)) = struct('odorName',[],'iupacName',[],'CASNumber',[],...
    'producingCompany',[], 'odorantPurity',[], 'state', [], 'odorantDilution', 0.1,...
    'dilutedIn', [], 'concentrationAtPresentation', 0.005, 'inflectionPointResponseCurve',[]); % each property to characterize the odorant is added as a field.

for i = 1 : length(odorNames)
    odorLibrary(i).odorName = odorNames{i}; % for every odor (odorLibrary(1:n(odors)) its name as specified in 'odorNames' is written into the odor specific structure
end


%% C) Define further properties for every individual odor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Odor 1
odor = 'Benzyl alcohol'; % make sure the name is the same as specified in the 'odorNames' cell array above
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = 'Phenylmethanol'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '100-51-6'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = []; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = []; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = []; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 2
odor = 'Butanone';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '2-Butanone'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '78-93-3'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Acros'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.99; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 3
odor = 'Camphor';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '1,7,7-Trimethylbicyclo[2.2.1]heptan-2-one'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '76-22-2'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Sigma'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.96; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'solid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end


%% Odor 4
odor = 'Cineole';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '1,3,3-trimethyl-2-oxabicyclo[2,2,2]octane'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '470-82-6'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Sigma'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.99; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = 'Paraffin oil'; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 5
odor = 'Citral';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '3,7-dimethylocta-2,6-dienal'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '5392-40-5'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Roth'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.93; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 6
odor = 'Eugenol';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '4-Allyl-2-methoxyphenol'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '97-53-0'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Sigma'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.99; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = 'Paraffin oil'; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 7
odor = 'Geranyl acetate';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '3,7-Dimethyl-2,6-octadiene acetate'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '105-87-3'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = []; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = []; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 8
odor = 'Hexanal';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = 'Hexanal'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '66-25-1'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = []; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = []; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = []; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 9
odor = '1-Hexanol';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '1-Hexanol'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '111-27-3'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = []; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = []; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = []; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 10
odor = '2-Hexanone';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = 'Hexan-2-one'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '591-78-6'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Sigma'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.995; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 11
odor = 'Isoamyl acetate'; % also known as isopentyl acetate
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '3-methyl-1-butyl acetate'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '123-92-2'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Sigma'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.99; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 0.1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = 'Paraffin oil'; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 12
odor = 'Vanillin';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = '4-Hydroxy-3-methoxybenzaldehyde'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '121-33-5'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Sigma'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.99; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'solid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 13
odor = 'Paraffin oil';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = 'Paraffin oil'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '??????'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Sigma'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.99; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 14
odor = 'Mineral oil';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = 'Mineral oil'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '??????'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = 'Fisher'; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.99; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 15
odor = 'Water';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = 'Water'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = '7732-18-5'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = []; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 0.99; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'liquid'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

%% Odor 16
odor = 'Empty';
for i = 1 : length(odorLibrary)
    if strcmp(odorLibrary(i).odorName, odor) % at the respective odor write the following properties to the structure:
        odorLibrary(i).iupacName = 'Empty'; % the name of the molecule following IUPAC convention as a string
        odorLibrary(i).CASNumber = 'xxxxxx'; % the CAS registry number identifying the molecule as a string
        odorLibrary(i).producingCompany = []; % the name of the company that produced the odorant: 'Sigma', 'Roth', etc.
        odorLibrary(i).odorantPurity = 1; % purity of the molecule given as a fraction, usually above 0.95: 0-1
        odorLibrary(i).state = 'gas'; % string describing whether the state of the molecule is liquid or solid: 'liquid' or 'solid'
        odorLibrary(i).odorantDilution = 1; % volume fraction (v(odorant)/v(dilutive solution)) of odorant in the vial after diluting it with water or oil: 0-1
        odorLibrary(i).dilutedIn = []; % in which solution the odor was diluted: 'Water' 'Paraffin oil' 'Mineral oil' or [] if no dilution
        odorLibrary(i).concentrationAtPresentation = 0.005; % concentration as volume fraction (v/v) of saturated headspace, which is presented to the animal: 0-1
        odorLibrary(i).inflectionPointResponseCurve = []; % concentration (v/v, of saturated head space) of presented odorant at which the response curve as measured in olfactory nerve has its inflection point.
    end
end

end