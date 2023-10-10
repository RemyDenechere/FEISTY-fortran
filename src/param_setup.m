function param = param_setup(param)

    %% Root directory: 
    if param.Rockfish % root directory to run on rockfish.ucsd.edu
        param.rootdir = '/project/';
    else % root directory to on local computer
        param.rootdir = 'Z:/';
    end
    
    %% Parameter for color range for global data: 
    if param.newColor
        param.col_inf = -2;
        param.col_sup = 1;
        param.save_name_color = '_Color';
    else
        param.col_inf = -2;
        param.col_sup = 2;
        param.save_name_color = '';
    end
end 