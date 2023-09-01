function [scores,sub_scores] = load_scores(datadir,redo,responseType)
run_num = load([datadir '/run_num.mat']); run_num=run_num.run_num;
for i=1:run_num
    curdir = [datadir '/' num2str(i)];
    if (~exist(curdir,'dir'))
        disp([curdir ' does not exist'])
    end
    if (~exist([curdir '/score.mat']) || strcmp(redo,'yes'))
        try
            [score,ss] = get_objective_score([datadir '/' num2str(i)],'knn',1,10,responseType);
            scores(i) = score;
            sub_scores(i,:)=ss;
        catch
            if (i~=run_num)
                disp('score unable to be computed from a run other than the last')
            else
                disp(['score for currently running network not available'])
            end
        end
    else
        switch responseType
            case 'spikes'
                score = load([curdir '/score_spikes.mat']); score=score.score;
                ss = load([curdir '/sub_scores_spikes.mat']); ss=ss.sub_scores;
                scores(i) = score;
                sub_scores(i,:) = ss;
            case 'firing rates'
                score = load([curdir '/score_frs.mat']); score=score.score;
                ss = load([curdir '/sub_scores_frs.mat']); ss=ss.sub_scores;
                scores(i) = score;
                sub_scores(i,:) = ss;
        end
    end 
end
end

