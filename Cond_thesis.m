% File names
files = {'Temp 45.csv', 'Temp 90.csv', 'VF 45.csv', 'VF 90.csv', 'WHF.csv'};
data = cell(1, numel(files));

for i = 1:numel(files)
    fid = fopen(files{i}, 'r');
    if fid == -1
        error('Could not open file: %s', files{i});
    end

    % Skip to [Data]
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if strcmp(line, '[Data]')
            break;
        end
    end
    fgetl(fid); % Skip header

    % Read numeric values
    temp_data = [];
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if isempty(line)
            continue;
        end
        values = textscan(line, '%f%f', 'Delimiter', ',');
        if ~isempty(values{1}) && ~isempty(values{2})
            temp_data(end+1, :) = [values{1}, values{2}]; %#ok<AGROW>
        end
    end
    fclose(fid);

    if isempty(temp_data)
        warning('No data read from file: %s', files{i});
    else
        data{i} = temp_data;
        fprintf('Loaded %d rows from %s\n', size(temp_data,1), files{i});
    end
end

% ===== Plot and Save Functions =====
savePlot = @(figHandle, name) print(figHandle, name, '-dmeta');

% ===== Temperature 45 =====
if ~isempty(data{1})
    fig = figure;
    plot(data{1}(:,1)/100, data{1}(:,2), 'Color', [0.3, 0.6, 0.9], 'LineWidth', 1.8); % Calm blue
    xlabel('Relative Radial Position', 'Interpreter', 'latex');
    ylabel('Temperature [K]', 'Interpreter', 'latex');
    title('Temperature at $\theta = 45^\circ$', 'Interpreter', 'latex');
    grid on;
    savePlot(fig, 'Temp_45');
end

% ===== Temperature 90 =====
if ~isempty(data{2})
    fig = figure;
    plot(data{2}(:,1)/100, data{2}(:,2), 'Color', [0.9, 0.5, 0.2], 'LineWidth', 1.8); % Calm orange
    xlabel('Relative Radial Position', 'Interpreter', 'latex');
    ylabel('Temperature [K]', 'Interpreter', 'latex');
    title('Temperature at $\theta = 90^\circ$', 'Interpreter', 'latex');
    grid on;
    savePlot(fig, 'Temp_90');
end

% ===== Volume Fraction 45 =====
if ~isempty(data{3})
    fig = figure;
    plot(data{3}(:,1)/100, data{3}(:,2), 'Color', [0.4, 0.8, 0.4], 'LineWidth', 1.8); % Calm green
    xlabel('Relative Radial Position', 'Interpreter', 'latex');
    ylabel('Liquid Volume Fraction', 'Interpreter', 'latex');
    title('Volume Fraction at $\theta = 45^\circ$', 'Interpreter', 'latex');
    grid on;
    savePlot(fig, 'VF_45');
end

% ===== Volume Fraction 90 =====
if ~isempty(data{4})
    fig = figure;
    plot(data{4}(:,1)/100, data{4}(:,2), 'Color', [0.7, 0.5, 0.8], 'LineWidth', 1.8); % Calm purple
    xlabel('Relative Radial Position', 'Interpreter', 'latex');
    ylabel('Liquid Volume Fraction', 'Interpreter', 'latex');
    title('Volume Fraction at $\theta = 90^\circ$', 'Interpreter', 'latex');
    grid on;
    savePlot(fig, 'VF_90');
end

% ===== Wall Heat Flux =====
if ~isempty(data{5})
    fig = figure;
    plot(data{5}(:,1)/100/35, data{5}(:,2), 'Color', [0.3, 0.3, 0.3], 'LineWidth', 1.8); % Calm black/gray
    xlabel('Cooling wall relative position', 'Interpreter', 'latex');
    ylabel('Wall Heat Flux [W/m$^2$]', 'Interpreter', 'latex');
    title('Wall Heat Flux Distribution', 'Interpreter', 'latex');
    grid on;
    savePlot(fig, 'WHF');
end
