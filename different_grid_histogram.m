% Files
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

% Loop through each month
for monthIndex = 1:length(filesPerMonth)
    % Initialize arrays to hold ship density values for each grid size
    all_ship_density_100km = [];
    all_ship_density_50km = [];
    all_ship_density_20km = [];
    all_ship_density_10km = [];

    % Loop through each CSV file for the current month
    for fileIndex = 1:length(filesPerMonth{monthIndex})
        % Read the CSV file as a table
        data = readtable(filesPerMonth{monthIndex}{fileIndex});

        % Extract ship density values from the 'Var1' column
        ship_density_raw = data.Var1;

        % Initialize an array to hold ship density values for this file
        ship_density = zeros(size(ship_density_raw));

        % Loop through each row to extract the density value 
        for i = 1:length(ship_density_raw)
         
            parts = strsplit(ship_density_raw{i}, ',');
            if length(parts) >= 3  
                ship_density(i) = str2double(parts{2}); 
            else
                ship_density(i) = NaN;  
            end
        end

        % Remove NaN values
        ship_density = ship_density(~isnan(ship_density));

        % 100 km grid size (10000 rows)
        for i = 1:10000:length(ship_density)
            if i + 9999 <= length(ship_density)
                all_ship_density_100km(end + 1) = mean(ship_density(i:i + 9999)); 
            end
        end
        
        % 50 km grid size (2500 rows)
        for i = 1:2500:length(ship_density)
            if i + 2499 <= length(ship_density)
                all_ship_density_50km(end + 1) = mean(ship_density(i:i + 2499));  
            end
        end

        % 20 km grid size (400 rows)
        for i = 1:400:length(ship_density)
            if i + 399 <= length(ship_density)
                all_ship_density_20km(end + 1) = mean(ship_density(i:i + 399)); 
            end
        end

        % 10 km grid size (100 rows)
        for i = 1:100:length(ship_density)
            if i + 99 <= length(ship_density)
                all_ship_density_10km(end + 1) = mean(ship_density(i:i + 99));  
            end
        end
    end

    
    figure;

    % Set a fixed bin width
    bin_width = 0.05;  

    % Plot for 100 km grid size
    subplot(2, 2, 1);
    histogram(all_ship_density_100km, 'FaceColor', [1 0 1], 'EdgeColor', 'k', 'BinWidth', bin_width); % Pink color
    title('Ship Density Histogram (100 km Grid Size)');
    xlabel('Ship Density (units per area)');  
    ylabel('Number of Grid Points');
    xlim([0, prctile(all_ship_density_100km, 95)]);
    grid on;

    % Plot for 50 km grid size
    subplot(2, 2, 2);
    histogram(all_ship_density_50km, 'FaceColor', [0 1 0], 'EdgeColor', 'k', 'BinWidth', bin_width); % Green color
    title('Ship Density Histogram (50 km Grid Size)');
    xlabel('Ship Density (units per area)');  
    ylabel('Number of Grid Points');
    xlim([0, prctile(all_ship_density_50km, 95)]);
    grid on;

    % Plot for 20 km grid size
    subplot(2, 2, 3);
    histogram(all_ship_density_20km, 'FaceColor', [0 0 1], 'EdgeColor', 'k', 'BinWidth', bin_width); % Blue color
    title('Ship Density Histogram (20 km Grid Size)');
    xlabel('Ship Density (units per area)'); 
    ylabel('Number of Grid Points');
    xlim([0, prctile(all_ship_density_20km, 95)]);
    grid on;

    % Plot for 10 km grid size
    subplot(2, 2, 4);
    histogram(all_ship_density_10km, 'FaceColor', [0 1 1], 'EdgeColor', 'k', 'BinWidth', bin_width); % Cyan color
    title('Ship Density Histogram (10 km Grid Size)');
    xlabel('Ship Density (units per area)'); 
    ylabel('Number of Grid Points');
    xlim([0, prctile(all_ship_density_10km, 95)]);
    grid on;


    sgtitle([months{monthIndex} ' 2023']);

    % Save the figure as an image with the month name
    saveas(gcf, [months{monthIndex} '_ship_density_histogram_2023.png']);
end
