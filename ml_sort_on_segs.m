function out = ml_sort_on_segs(resDir,varargin)


    geom = []; % optional csv defining electrode geometry (not needed for tetrodes)
    adjacency_radius = -1; % use all channels are one neighborhood (for tetrodes)
    detect_sign=1; % sign of spikes to detect
    detect_threshold = 3; % detection threshold for spike in st. dev from mean
    tet_list = [];
    samplerate = 30000;

    assignVars(varargin)


    % Get tetrode list
    tetDirs = dir([resDir filesep '*.nt*']);
    tetDirs = {tetDirs.name};
    pat = '\w+.nt(?<tet>[0-9]+).\w+';
    tmp = cellfun(@(x) regexp(x,pat,'names'),tetDirs);
    allTets = str2double({tmp.tet});
    if isempty(tet_list)
        tet_list = allTets;
    else
        missing = setdiff(tet_list,allTets);
        tet_list = intersect(tet_list,allTets);
        if ~isempty(missing)
            disp('Cannot find data for tetrodes:')
            disp(missing)
        end
        keep = arrayfun(@(x) find(allTets==x),tet_list);
        tetDirs = tetDirs(keep);
    end

    % TODO: Use timeseries.mda from day directory to determine epoch offsets
    % TODO: Split into epoch segments using pyms
    % TODO: Sort each segment
    % TODO: Anneal Segments
    
    % Sort entire file at once
    params.adjacency_radius = adjacency_radius;
    params.detect_sign = detect_sign;
    params.detect_threshold = 3;
    out = cell(numel(tetDirs),2);
    for k=1:numel(tetDirs)
        tD = [resDir filesep tetDirs{k}];

        % Sort 
        pName = 'ms4alg.sort';
        inputs.timeseries = [tD filesep 'pre.mda.prv'];
        outputs.firings_out = [tD filesep 'firings_raw.mda'];
        if ~isempty(geom)
            inputs.geom = geom;
        end
        console_out = ml_run_process(pName,inputs,outputs,params);
        % output file have array NxL where the rows are
        % channels_used,timestamp,cluster_labels and L is num data points
        out{k,1} = outputs.firings_out;

        % Compute cluster metrics
        pName = 'ephys.compute_cluster_metrics';
        if exist([tD filesep 'params.json'],'file')
            metParams = jsondecode(fileread([tD filesep 'params.json']));
        else
            metParams = struct('samplerate',samplerate);
        end
        metInputs.firings = outputs.firings_out;
        metInputs.timeseries = inputs.timeseries;
        metOutputs.metrics_out = [tD filesep 'metrics_raw.json'];
        console_out = ml_run_process(pName,metInputs,metOutputs,metParams);
        out{k,2} = metOutputs.metrics_out;
    end


