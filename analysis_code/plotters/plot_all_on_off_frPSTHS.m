function [] = plot_all_on_off_frPSTHS(datadir,whichCells,responseType)
p=load([datadir '/p.mat']); p=p.p;
tvec=p.dt:p.dt*p.FRdownsampleFactor:p.trial_time;
nsmells=p.nsmells;
ngroups=p.ngroups;
frPSTHsON=load([datadir '/frPSTHsON.mat']); frPSTHsON=frPSTHsON.frPSTHsON;
frPSTHsOFF=load([datadir '/frPSTHsOFF.mat']); frPSTHsOFF=frPSTHsOFF.frPSTHsOFF;
switch responseType
    case 'spikes'
        on_responsive=load([datadir '/on_responsive_spikes.mat']); on_responsive=on_responsive.on_responsive;
        off_responsive=load([datadir '/off_responsive_spikes.mat']); off_responsive=off_responsive.off_responsive;
    case 'firing rates'
        on_responsive=load([datadir '/on_responsive.mat']); on_responsive=on_responsive.on_responsive;
        off_responsive=load([datadir '/off_responsive.mat']); off_responsive=off_responsive.off_responsive;
end

group_names = get_group_names(datadir);
for g=1:ngroups
    figure;
    for i=1:nsmells
        switch whichCells
            case 'all'
                maxy=max(max(frPSTHsON{g}{i}(:)),max(frPSTHsOFF{g}{i}(:)));
                if (maxy < 1)
                    maxy=1;
                end
                subplot(2,nsmells,i)
                plot(tvec,frPSTHsON{g}{i},'linew',2); ylim([0 maxy])
                xlabel('Time (s)','fontsize',15,'fontweight','bold'); 
                if (i==1) 
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
                subplot(2,nsmells,i+nsmells)
                plot(tvec,frPSTHsOFF{g}{i},'linew',2); ylim([0 maxy])
                xlabel('Time (s)','fontsize',15,'fontweight','bold'); 
                if (i==1) 
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
            case 'on responsive'
                on=on_responsive{g}{i};
                maxy=max(max(max(frPSTHsON{g}{i}(:,on))),max(max(frPSTHsOFF{g}{i}(:,on))));
                if (isempty(maxy))
                    maxy=10;
                end
                subplot(2,nsmells,i)
                plot(frPSTHsON{g}{i}(:,on),'linew',2); ylim([0 maxy])
                xlabel('Time (s)','fontsize',15,'fontweight','bold')
                if (i==1)
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
                subplot(2,nsmells,i+nsmells)
                plot(frPSTHsOFF{g}{i}(:,on),'linew',2); ylim([0 maxy])
                if (i==1)
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
            case 'off responsive'
                off=off_responsive{g}{i};
                maxy=max(max(max(frPSTHsON{g}{i}(:,off))),max(max(frPSTHsOFF{g}{i}(:,off))));
                if (isempty(maxy))
                    maxy=10;
                end
                subplot(2,nsmells,i)
                plot(frPSTHsON{g}{i}(:,off),'linew',2); ylim([0 maxy])
                xlabel('Time (s)','fontsize',15,'fontweight','bold')
                if (i==1)
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
                subplot(2,nsmells,i+nsmells)
                plot(frPSTHsOFF{g}{i}(:,off),'linew',2); ylim([0 maxy])
                if (i==1)
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
            case 'on but not off responsive'
                on_but_not_off = setdiff(on_responsive{g}{i},off_responsive{g}{i});
                maxy=max(max(max(frPSTHsON{g}{i}(:,on_but_not_off))),max(max(frPSTHsOFF{g}{i}(:,on_but_not_off))));
                if (isempty(maxy))
                    maxy=10;
                end
                subplot(2,nsmells,i)
                plot(frPSTHsON{g}{i}(:,on_but_not_off),'linew',2); ylim([0 maxy])
                xlabel('Time (s)','fontsize',15,'fontweight','bold'); 
                if (i==1) 
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
                subplot(2,nsmells,i+nsmells)
                plot(frPSTHsOFF{g}{i}(:,on_but_not_off),'linew',2); ylim([0 maxy])
                xlabel('Time (s)','fontsize',15,'fontweight','bold'); 
                if (i==1) 
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
            case 'off but not on responsive'
                off_but_not_on = setdiff(off_responsive{g}{i},on_responsive{g}{i});
                maxy=max(max(max(frPSTHsON{g}{i}(:,off_but_not_on))),max(max(frPSTHsOFF{g}{i}(:,off_but_not_on))));
                if (isempty(maxy))
                    maxy=10;
                end
                subplot(2,nsmells,i)
                plot(frPSTHsON{g}{i}(:,off_but_not_on),'linew',2); ylim([0 maxy])
                xlabel('Time (s)','fontsize',15,'fontweight','bold'); 
                if (i==1) 
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
                subplot(2,nsmells,i+nsmells)
                plot(frPSTHsOFF{g}{i}(:,off_but_not_on),'linew',2); ylim([0 maxy])
                xlabel('Time (s)','fontsize',15,'fontweight','bold'); 
                if (i==1) 
                    ylabel('Firing Rate (Hz)','fontsize',15,'fontweight','bold')
                end
        end
    end
    set(gcf,'Position',[10 10 1800 700])
    suptitle([group_names{g} ': ' whichCells])
end
end

