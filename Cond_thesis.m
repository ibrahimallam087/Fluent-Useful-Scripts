clc;
clear all;
close all;

% Top-level folder (current directory)
baseFolder = pwd;

% List of refrigerant folders
refrigerants = {'R32a', 'R134a', 'R410a'};

% List of E-subfolders
subfolders = {'E = 0.2', 'E = 0.4', 'E = 0.6', 'E = 0.8'};

% File names to process
fileNames = {'Temp45.csv', 'Temp90.csv', 'VF45.csv', 'VF90.csv'};

% LaTeX formatting for plots
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');

% Line/marker styles
lineStyles = {'-', '--', ':', '-.'};
markers = {'o', 's', 'd', '^'};

% Folder to save figures
saveFolder = 'SavedFigures';
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

% Font sizes
fontSizeMultiplier = 2;
baseFontSize = 12;

% ---------- First: Plot per refrigerant (your current logic) ----------
for r = 1:length(refrigerants)
    refrigerant = refrigerants{r};
    colors = lines(length(subfolders));

    for f = 1:length(fileNames)
        fig = figure('Position', [100, 100, 1600, 800]);
        ax1 = axes('Position', [0.08, 0.15, 0.6, 0.75]); hold(ax1, 'on');
        ax2 = axes('Position', [0.72, 0.15, 0.25, 0.75]); hold(ax2, 'on');
        legendEntries = {};

        for i = 1:length(subfolders)
            folderPath = fullfile(baseFolder, refrigerant, subfolders{i});
            filePath = fullfile(folderPath, fileNames{f});

            if exist(filePath, 'file') == 2
                data = read_data(filePath);
                x = data(:, 1) / 100;
                y = data(:, 2);

                plot(ax1, x, y, 'DisplayName', subfolders{i}, ...
                    'LineWidth', 2.5, 'Color', colors(i, :), ...
                    'LineStyle', lineStyles{i}, 'Marker', markers{i});
                plot(ax2, x, y, ...
                    'LineWidth', 2.5, 'Color', colors(i, :), ...
                    'LineStyle', lineStyles{i}, 'Marker', markers{i});
            else
                warning('File %s does not exist.', filePath);
            end
        end

        xlabel(ax1, 'Radial Position', 'FontSize', baseFontSize * fontSizeMultiplier);
        ylabel(ax1, fileNames{f}(1:end-4), 'FontSize', baseFontSize * fontSizeMultiplier);
        title(ax1, sprintf('%s - %s', refrigerant, fileNames{f}(1:end-4)), ...
            'FontSize', baseFontSize * fontSizeMultiplier);
        legend(ax1, 'show', 'Location', 'best', 'FontSize', baseFontSize * fontSizeMultiplier);
        grid(ax1, 'on'); set(ax1, 'LineWidth', 1.5);

        xlabel(ax2, 'Radial Position', 'FontSize', baseFontSize * fontSizeMultiplier);
        title(ax2, '(Zoomed)', 'FontSize', baseFontSize * fontSizeMultiplier);
        xlim(ax2, [0 0.2]);
        grid(ax2, 'on'); set(ax2, 'LineWidth', 1.5);

        % Save plot
        saveName = sprintf('%s_%s.emf', refrigerant, fileNames{f}(1:end-4));
        save_plot_as_png(fig, fullfile(saveFolder, saveName));
    end
end

% ---------- Second: Plot across refrigerants at fixed E-value ----------
colors = lines(length(refrigerants)); % for refrigerants

for f = 1:length(fileNames)
    for i = 1:length(subfolders)
        fig = figure('Position', [100, 100, 1600, 800]);
        ax1 = axes('Position', [0.08, 0.15, 0.6, 0.75]); hold(ax1, 'on');
        ax2 = axes('Position', [0.72, 0.15, 0.25, 0.75]); hold(ax2, 'on');

        for r = 1:length(refrigerants)
            folderPath = fullfile(baseFolder, refrigerants{r}, subfolders{i});
            filePath = fullfile(folderPath, fileNames{f});

            if exist(filePath, 'file') == 2
                data = read_data(filePath);
                x = data(:, 1) / 100;
                y = data(:, 2);

                plot(ax1, x, y, 'DisplayName', refrigerants{r}, ...
                    'LineWidth', 2.5, 'Color', colors(r, :), ...
                    'LineStyle', lineStyles{r}, 'Marker', markers{r});
                plot(ax2, x, y, ...
                    'LineWidth', 2.5, 'Color', colors(r, :), ...
                    'LineStyle', lineStyles{r}, 'Marker', markers{r});
            else
                warning('File %s does not exist.', filePath);
            end
        end

        xlabel(ax1, 'Radial Position', 'FontSize', baseFontSize * fontSizeMultiplier);
        ylabel(ax1, fileNames{f}(1:end-4), 'FontSize', baseFontSize * fontSizeMultiplier);
        title(ax1, sprintf('%s - %s', subfolders{i}, fileNames{f}(1:end-4)), ...
            'FontSize', baseFontSize * fontSizeMultiplier);
        legend(ax1, 'show', 'Location', 'best', 'FontSize', baseFontSize * fontSizeMultiplier);
        grid(ax1, 'on'); set(ax1, 'LineWidth', 1.5);

        xlabel(ax2, 'Radial Position', 'FontSize', baseFontSize * fontSizeMultiplier);
        title(ax2, '(Zoomed)', 'FontSize', baseFontSize * fontSizeMultiplier);
        xlim(ax2, [0 0.2]);
        grid(ax2, 'on'); set(ax2, 'LineWidth', 1.5);

        % Save plot
        saveName = sprintf('%s_%s_CompareRefrigerants.emf', subfolders{i}, fileNames{f}(1:end-4));
        save_plot_as_png(fig, fullfile(saveFolder, saveName));
    end
end

% ---------- Helper Functions ----------
function save_plot_as_png(figHandle, filePath)
    exportgraphics(figHandle, filePath, 'Resolution', 300);
end

function data = read_data(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
    while ~feof(fid)
        line = fgetl(fid);
        if contains(line, '[Data]')
            break;
        end
    end
    data = [];
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            line_data = sscanf(line, '%f,%f');
            if numel(line_data) == 2
                data = [data; line_data'];
            end
        end
    end
    fclose(fid);
    if isempty(data)
        error('No valid data found in file: %s', filename);
    end
end
