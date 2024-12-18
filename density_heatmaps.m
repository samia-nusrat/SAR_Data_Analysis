% Clear all previous data
clear; clc;

% List of files to process
files = {'april2023.csv', 'april2023_2.csv', 'april2023_3.csv', 'april2023_4.csv', ...
         'april2023_5.csv'};

% Initialize arrays to store all data
allLat = [];
allLon = [];
allDensity = [];

% Loop through each file and extract data
for i = 1:length(files)
    data = readtable(files{i}); 
    
    % Extract ship density, latitude, and longitude
    density = data.Var1; % Var1 contains ship density
    lat = data.Var4;     % Var4 contains latitude values
    lon = data.Var5;     % Var5 contains longitude values
    
    % Convert density, cleaning up non-numeric characters
    if iscell(density)
        density = regexprep(density, '[^\d.]', ''); 
        density = cellfun(@str2double, density);    
    end
    
    % Convert latitude and longitude to numeric 
    if iscell(lat)
        lat = cellfun(@str2double, lat);
    end
    if iscell(lon)
        lon = cellfun(@str2double, lon);
    end
    
    % Remove NaN values resulting from non-numeric data
    validIndices = ~isnan(density) & ~isnan(lat) & ~isnan(lon);
    density = density(validIndices);
    lat = lat(validIndices);
    lon = lon(validIndices);
    
    % Append to the arrays
    allDensity = [allDensity; density];
    allLat = [allLat; lat];
    allLon = [allLon; lon];
end

% Combine latitude, longitude, and density into a single matrix
combinedData = [allLat, allLon, allDensity];

% Find unique rows based on latitude and longitude
[uniqueLatLon, ~, idx] = unique(combinedData(:, 1:2), 'rows');

% Aggregate density for each unique (lat, lon) pair
aggregatedDensity = accumarray(idx, combinedData(:, 3), [], @sum);

% Set custom density ranges and corresponding colors
densityRanges = [0, 1, 2, 5, 10, 20, 50, 100, 200];
cmap = [
    1.0, 1.0, 0.8;   % Light yellow for 0 - 1
    1.0, 0.9, 0.6;   % Pale orange for 1 - 2
    1.0, 0.7, 0.4;   % Orange for 2 - 5
    1.0, 0.5, 0.2;   % Red-orange for 5 - 10
    1.0, 0.3, 0.3;   % Red for 10 - 20
    0.8, 0.1, 0.1;   % Dark red for 20 - 50
    0.6, 0.0, 0.0;   % Brown for 50 - 100
    0.3, 0.0, 0.0;   % Dark brown for 100 - 200
];

% Discretize the densities according to the ranges
discretizedDensity = discretize(aggregatedDensity, densityRanges);

% Plot the map
figure;
geobasemap('colorterrain'); 
hold on;

% Plot each density range with corresponding color
for k = 1:length(densityRanges)-1
    % Get indices for this density range
    rangeIndices = (discretizedDensity == k);
    
    % Scatter plot for the current density range with the corresponding color
    geoscatter(uniqueLatLon(rangeIndices, 1), uniqueLatLon(rangeIndices, 2), ...
        10, 'filled', 'MarkerFaceColor', cmap(k, :), 'MarkerEdgeAlpha', 0.1);
end

% Colorbar setup
colormap(cmap);
caxis([0 200]);
colorbar('Ticks', densityRanges, 'TickLabels', string(densityRanges));
title('april-2023');

% Set geographic limits (optional)
geolimits([45 75], [-80 -20]); 

hold off;
 