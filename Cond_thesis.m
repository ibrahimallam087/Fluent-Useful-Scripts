clc;
clear;
close all;

% --------- CONFIGURATION ---------
materialFolders = {'R32a', 'R134a', 'R410a'};
subfolders = {'E = 0.2', 'E = 0.4', 'E = 0.6', 'E = 0.8'};
fileNames = {'Temp45.csv', 'Temp90.csv', 'VF45.csv', 'VF90.csv'};
saveFolder = 'SavedFigures';

% LaTeX plot style
set(0, 'DefaultTextInterpreter', 'latex');
set(0, 'DefaultAxesTickLabelInterpreter', 'latex');
set(0, 'DefaultLegendInterpreter', 'latex');

% Colors & styles
colors = lines(max(length(materialFolders), length(subfolders)));
lineStyles = {'-', '--', ':', '-.', '-'};
markers = {'o', 's', 'd', '^', 'none'};

% Font sizes
fontSizeMultiplier = 2;
baseFontSize = 12;

% Create folder if it doesn't exist
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

% ========== PLOT 1: Per Material - Varying E ==========
for m = 1:length(materialFolders)
    material = materialFolders{m};
    for f = 1:length(fileNames)
        fig = figure('Position', [100, 100, 1600, 800]);
        ax1 = axes('Position', [0.08, 0.15, 0.6, 0.75]); hold(ax1, 'on');
        ax2 = axes('Position', [0.72, 0.15, 0.25, 0.75]); hold(ax2, 'on');
        legendEntries = {};

        for i = 1:length(subfolders)
            folderPath = fullfile(material, subfolders{i});
            filePath = fullfile(folderPath, fileNames{f});
            if exist(filePath, 'file') == 2
                data = read_data(filePath);
                x = data(:, 1) / 100;
                y = data(:, 2);

                % Plot
                plot(ax1, x, y, 'DisplayName', subfolders{i}, ...
                    'LineWidth', 2.5, 'Color', colors(i, :), ...
                    'LineStyle', lineStyles{i}, 'Marker', markers{i});
                plot(ax2, x, y, ...
                    'LineWidth', 2.5, 'Color', colors(i, :), ...
                    'LineStyle', lineStyles{i}, 'Marker', markers{i});
            else
                warning('File not found: %s', filePath);
            end
        end

        % Labels and titles
        xlabel(ax1, 'Radial Position', 'FontSize', baseFontSize * fontSizeMultiplier);
        ylabel(ax1, fileNames{f}(1:end-4), 'FontSize', baseFontSize * fontSizeMultiplier);
        title(ax1, sprintf('%s - %s', material, fileNames{f}(1:end-4)), 'FontSize', baseFontSize * fontSizeMultiplier);
        legend(ax1, 'show', 'Location', 'best', 'FontSize', baseFontSize * fontSizeMultiplier);
        grid(ax1, 'on'); set(ax1, 'LineWidth', 1.5);

        xlabel(ax2, 'Radial Position', 'FontSize', baseFontSize * fontSizeMultiplier);
        title(ax2, '(Zoomed)', 'FontSize', baseFontSize * fontSizeMultiplier);
        xlim(ax2, [0 0.2]);
        grid(ax2, 'on'); set(ax2, 'LineWidth', 1.5);

        % Save
        outName = sprintf('%s_%s.emf', material, fileNames{f}(1:end-4));
        save_plot_as_png(fig, fullfile(saveFolder, outName));
    end
end

% ========== PLOT 2: Per E - Varying Material ==========
% For only VF45.csv and VF90.csv
vfFiles = {'VF45.csv', 'VF90.csv'};

for vf = 1:length(vfFiles)
    for e = 1:length(subfolders)
        fig = figure('Position', [100, 100, 1600, 800]);
        ax1 = axes('Position', [0.08, 0.15, 0.6, 0.75]); hold(ax1, 'on');
        ax2 = axes('Position', [0.72, 0.15, 0.25, 0.75]); hold(ax2, 'on');

        for m = 1:length(materialFolders)
            material = materialFolders{m};
            folderPath = fullfile(material, subfolders{e});
            filePath = fullfile(folderPath, vfFiles{vf});
            if exist(filePath, 'file') == 2
                data = read_data(filePath);
                x = data(:, 1) / 100;
                y = data(:, 2);

                plot(ax1, x, y, 'DisplayName', material, ...
                    'LineWidth', 2.5, 'Color', colors(m, :), ...
                    'LineStyle', lineStyles{m}, 'Marker', markers{m});
                plot(ax2, x, y, ...
                    'LineWidth', 2.5, 'Color', colors(m, :), ...
                    'LineStyle', lineStyles{m}, 'Marker', markers{m});
            else
                warning('File not found: %s', filePath);
            end
        end

        xlabel(ax1, 'Radial Position', 'FontSize', baseFontSize * fontSizeMultiplier);
        ylabel(ax1, vfFiles{vf}(1:end-4), 'FontSize', baseFontSize * fontSizeMultiplier);
        title(ax1, sprintf('E = %.1f - %s (All Materials)', str2double(subfolders{e}(5:end)), vfFiles{vf}(1:end-4)), ...
              'FontSize', baseFontSize * fontSizeMultiplier);
        legend(ax1, 'show', 'Location', 'best', 'FontSize', baseFontSize * fontSizeMultiplier);
        grid(ax1, 'on'); set(ax1, 'LineWidth', 1.5);

        xlabel(ax2, 'Radial Position', 'FontSize', baseFontSize * fontSizeMultiplier);
        title(ax2, '(Zoomed)', 'FontSize', baseFontSize * fontSizeMultiplier);
        xlim(ax2, [0 0.2]);
        grid(ax2, 'on'); set(ax2, 'LineWidth', 1.5);

        outName = sprintf('AllMaterials_E%.1f_%s.emf', str2double(subfolders{e}(5:end)), vfFiles{vf}(1:end-4));
        save_plot_as_png(fig, fullfile(saveFolder, outName));
    end
end

% ---------- Helper Functions ---------- %

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
