% Clear all previous data
clear; clc;

% Files and months
filesPerMonth = {
    {'june2023.csv', 'june2023_2.csv', 'june2023_3.csv', 'june2023_4.csv', 'june2023_5.csv', 'june2023_6.csv', 'june2023_7.csv'},  % June 2023
    {'jan2023.csv', 'jan2023_2.csv', 'jan2023_3.csv', 'jan2023_4.csv', 'jan2023_5.csv'},                                          % January 2023
    {'feb2023.csv', 'feb2023_2.csv', 'feb2023_3.csv', 'feb2023_4.csv'},                                                           % February 2023
    {'march2023.csv', 'march2023_2.csv', 'march2023_3.csv', 'march2023_4.csv'},                                                  % March 2023
    {'april2023.csv', 'april2023_2.csv', 'april2023_3.csv', 'april2023_4.csv', 'april2023_5.csv'},                                % April 2023
    {'may2023.csv', 'may2023_2.csv', 'may2023_3.csv', 'may2023_4.csv', 'may2023_5.csv', 'may2023_6.csv', 'may2023_7.csv'},        % May 2023
    {'july2023.csv', 'july2023_2.csv', 'july2023_3.csv', 'july2023_4.csv', 'july2023_5.csv', 'july2023_6.csv', 'july2023_7.csv', 'july2023_8.csv'},  % July 2023
    {'aug2023.csv', 'aug2023_2.csv', 'aug2023_3.csv', 'aug2023_4.csv', 'aug2023_5.csv', 'aug2023_6.csv', 'aug2023_7.csv', 'aug2023_8.csv', 'aug2023_9.csv'},  % August 2023
    {'sep2023.csv', 'sep2023_2.csv', 'sep2023_3.csv', 'sep2023_4.csv', 'sep2023_5.csv', 'sep2023_6.csv', 'sep2023_7.csv', 'sep2023_8.csv'},  % September 2023
    {'oct2023.csv', 'oct2023_2.csv', 'oct2023_3.csv', 'oct2023_4.csv', 'oct2023_5.csv', 'oct2023_6.csv', 'oct2023_7.csv', 'oct2023_8.csv'},  % October 2023
    {'nov2023.csv', 'nov2023_2.csv', 'nov2023_3.csv', 'nov2023_4.csv', 'nov2023_5.csv', 'nov2023_6.csv'},                          % November 2023
    {'dec2023.csv', 'dec2023_2.csv', 'dec2023_3.csv', 'dec2023_4.csv', 'dec2023_5.csv'}                                        % December 2023
};
months = {'June', 'January', 'February', 'March', 'April', 'May', 'July', 'August', 'September', 'October', 'November', 'December'};

% Set density ranges and corresponding colors
densityRanges = [0, 5, 20, Inf]; % Low: 0-2, Medium: 2-30, High: >30
cmap = [
    1.0, 1.0, 0.0;   % Yellow for low density (0 - 2)
    1.0, 0.5, 0.0;   % Orange for medium density (2 - 30)
    1.0, 0.0, 0.0;   % Red for high density (>30)
];

% Iterate through each month's data
for m = 1:length(filesPerMonth)
    files = filesPerMonth{m};
    
    % Initialize arrays to store all data for the month
    allLat = [];
    allLon = [];
    allDensity = [];
    
    % Loop through each file and extract data
    for i = 1:length(files)
        data = readtable(files{i}); 
        
        % Extract ship density, latitude, and longitude
        density = data.Var1; %  Var1 contains ship density
        lat = data.Var4;     % Var4 contains latitude values
        lon = data.Var5;     %  Var5 contains longitude values
        
        % Convert density, cleaning up non-numeric characters
        if iscell(density)
            density = regexprep(density, '[^\d.]', ''); 
            density = cellfun(@str2double, density);    
        end
        
     
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
    
 
    [uniqueLatLon, ~, idx] = unique(combinedData(:, 1:2), 'rows');
    

    aggregatedDensity = accumarray(idx, combinedData(:, 3), [], @sum);
    
 
    discretizedDensity = discretize(aggregatedDensity, densityRanges);
    
    % Plot the map for this month
    figure;
    geobasemap('colorterrain'); %
    hold on;
    
  
    for k = 1:length(densityRanges)-1
  
        rangeIndices = (discretizedDensity == k);
        
     
        geoscatter(uniqueLatLon(rangeIndices, 1), uniqueLatLon(rangeIndices, 2), ...
            10, 'filled', 'MarkerFaceColor', cmap(k, :), 'MarkerEdgeAlpha', 0.1);
    end
    
    % Colorbar setup
    colormap(cmap);
    colorbar('Ticks', [0, 5, 20, 200], 'TickLabels', {'Low', 'Medium', 'High'});
    title(['Ship Density - ', months{m}, ' 2023']);
    
    
    geolimits([45 75], [-80 -20]); 
    
    hold off;
    
    % Save the figure as an image
    saveas(gcf, ['ShipDensity_', months{m}, '_2023.png']);
end