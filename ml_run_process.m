function out = ml_run_process(processName,inputs,outputs,params)
    % out = ml_run_process(processName,inputs,outputs,params)
    % runs a mountainlab processors with inputs and outputs being structures
    % giving the names inputs and outputs of the function
    % params is likewise

    conda_path = get_conda_path();
    runStr = ['. ' conda_path ';conda activate base;ml-run-process ' processName ' '];
    
    inStr = ['-i ' makeKeyStr(inputs)];
    outStr = ['-o ' makeKeyStr(outputs)];
    pStr = ['-p ' makeKeyStr(params)];
    runStr = [runStr ' ' inStr ' ' outStr ' ' pStr];
    disp(['Executing command: ' runStr])
    [~,out] = system(runStr);

    function oStr = makeKeyStr(s)
        % makes string in key:value format from structure
        oStr = '';
        FNs = fieldnames(s);
        for k=1:numel(s)
            oStr = [oStr,FNs{k},':',s.(FNs{k})];
            if k<numel(s)
                oStr = [oStr,' '];
            end
        end

