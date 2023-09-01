datadir = '/media/ben/Manwe/phd/carlsim/data/EI_net/surrogate_run1';
d=dir(datadir);
nDirs = sum([d.isdir]);
parfor i=1:nDirs
    if (strcmp(d(i).name,'.') || strcmp(d(i).name,'..'))
        continue;
    end
	stfp_net_analysis([datadir '/' num2str(i)],1);
	disp(num2str(i));
end
