function [var_ps] = load_all_variable_params(datadir,netType)
run_num=load([datadir '/run_num.mat']); run_num=run_num.run_num;
surr_info=load(['simulation_code/surrogate_info_' netType '.mat']); surr_info=surr_info.surrogate_info;
params2vary=surr_info.params2vary;
for i=1:run_num
    curdir = [datadir '/' num2str(i)];
    if (exist([curdir '/p.mat'],'file'))
        p=load([curdir '/p.mat']); p=p.p;
        for j=1:length(params2vary)
            var_ps(i,j) = p.(params2vary{j});
        end
    else
        p=extract_params([curdir '/params.txt']);
        for j=1:length(params2vary)
            var_ps(i,j) = p.(params2vary{j});
        end
    end
end

end

