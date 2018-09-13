function out = ml_run_process(processName,inputs,outputs,params)
    % out = ml_run_process(processName,inputs,outputs,params)
    % runs a mountainlab processors with inputs and outputs being structures
    % giving the names inputs and outputs of the function
    % params is likewise

    conda_path = get_conda_path();
    runStr = ['. ' conda_path ';conda activate base;ml-run-process ' processName ' '];
    
    inStr = ['-i ' makeKeyStr(inputs)];
    outStr = ['-o ' makeKeyStr(outputs)];
    if exist('params','var')
        pStr = ['-p ' makeKeyStr(params)];
    else
        pStr = '';
    end
    runStr = [runStr ' ' inStr ' ' outStr ' ' pStr];
    disp(['Executing command: ' runStr])
    [errCode,out] = system(runStr,'-echo');
    if errCode~=0
        error('Something went wrong! Derp!\n%s',out)
    end
        

    function oStr = makeKeyStr(s)
        % makes string in key:value format from structure
        oStr = '';
        FNs = fieldnames(s);
        for k=1:numel(FNs)
            val = s.(FNs{k});
            if isnumeric(val)
                val = num2str(val);
            end
            oStr = [oStr,FNs{k},':',val];
            if k<numel(FNs)
                oStr = [oStr,' '];
            end
        end

