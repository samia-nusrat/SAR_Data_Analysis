clear; clc;

% Files
filesPerMonth = {
    {'june2023.csv', 'june2023_2.csv', 'june2023_3.csv', 'june2023_4.csv', 'june2023_5.csv', 'june2023_6.csv', 'june2023_7.csv'},  % June 2023
    {'jan2023.csv', 'jan2023_2.csv', 'jan2023_3.csv', 'jan2023_4.csv', 'jan2023_5.csv'},                                          % January 2023
    {'feb2023.csv', 'feb2023_2.csv', 'feb2023_3.csv', 'feb2023_4.csv'},                                                           % February 2023
    {'march2023.csv', 'march2023_2.csv', 'march2023_3.csv', 'march2023_4.csv'},                                                     % March 2023
    {'april2023.csv', 'april2023_2.csv', 'april2023_3.csv', 'april2023_4.csv', 'april2023_5.csv'},                                   % April 2023
    {'may2023.csv', 'may2023_2.csv', 'may2023_3.csv', 'may2023_4.csv', 'may2023_5.csv', 'may2023_6.csv', 'may2023_7.csv'},           % May 2023
    {'july2023.csv', 'july2023_2.csv', 'july2023_3.csv', 'july2023_4.csv', 'july2023_5.csv', 'july2023_6.csv', 'july2023_7.csv', 'july2023_8.csv'},  % July 2023
    {'aug2023.csv', 'aug2023_2.csv', 'aug2023_3.csv', 'aug2023_4.csv', 'aug2023_5.csv', 'aug2023_6.csv', 'aug2023_7.csv', 'aug2023_8.csv', 'aug2023_9.csv'},  % August 2023
    {'sep2023.csv', 'sep2023_2.csv', 'sep2023_3.csv', 'sep2023_4.csv', 'sep2023_5.csv', 'sep2023_6.csv', 'sep2023_7.csv', 'sep2023_8.csv'},  % September 2023
    {'oct2023.csv', 'oct2023_2.csv', 'oct2023_3.csv', 'oct2023_4.csv', 'oct2023_5.csv', 'oct2023_6.csv', 'oct2023_7.csv', 'oct2023_8.csv'},  % October 2023
    {'nov2023.csv', 'nov2023_2.csv', 'nov2023_3.csv', 'nov2023_4.csv', 'nov2023_5.csv', 'nov2023_6.csv'},                          % November 2023
    {'dec2023.csv', 'dec2023_2.csv', 'dec2023_3.csv', 'dec2023_4.csv', 'dec2023_5.csv'}                                            % December 2023
};

months = {'June', 'January', 'February', 'March', 'April', 'May', 'July', 'August', 'September', 'October', 'November', 'December'};

% Loop through each month's file list
for monthIdx = 1:length(filesPerMonth)
    % Get the files for the current month
    files = filesPerMonth{monthIdx};  
    allLat = [];
    allLon = [];
    allDensity = [];
    
    % Loop through each file for the current month to read and process the data
    for i = 1:length(files)
        data = readtable(files{i});
        
        % Extract density, latitude, and longitude columns
        % Ship density column
        density = data.Var1; 
        % Latitude column
        lat = data.Var4;     
        % Longitude column
        lon = data.Var5;     
        
        % Process density, latitude, and longitude
        if iscell(density)
            density = regexprep(density, '[^\d.]', '');
            density = cellfun(@str2double, density);
        end
        if iscell(lat), lat = cellfun(@str2double, lat); end
        if iscell(lon), lon = cellfun(@str2double, lon); end
        validIndices = ~isnan(density) & ~isnan(lat) & ~isnan(lon);
        
        % Add to the overall data for the current month
        allDensity = [allDensity; density(validIndices)];
        allLat = [allLat; lat(validIndices)];
        allLon = [allLon; lon(validIndices)];
    end
    
    % Sum all density values for the current month
    totalDensity = sum(allDensity);  
    fprintf('%s  -  Total density: %.2f\n', months{monthIdx}, totalDensity);
    
    % Estimate the number of ships for the current month
    % Divide by 730 to get the number of ships
    estimatedShips = totalDensity / 730;  
    fprintf('%s  -  Estimated number of ships: %.2f\n\n', months{monthIdx}, estimatedShips);
end
