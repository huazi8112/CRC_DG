clear,clc
load h_pre.mat
load h_t.mat
load h_init_index.mat
adjecent = maprho;
L = 3; % sliding length
m = 10;% Training length
adjecent = logical(adjecent);
%% data processing
Rec_time = p_data(Rec_time);
H_point_value=[];
t_value=[];
for u = [-0.3:0.1:-0.1,0.1:0.1:0.3]
    n = size(Rec_time,2);
    predict = [];
    delta_record = [];
    p_sort_up = ones(size(Rec_time,1),1);
    p_sort_down= ones(size(Rec_time,1),1);
    t_delta = zeros(size(Rec_time,1),1);
    f_delta = zeros(size(Rec_time,1),1);% Record the degree of perturbation
    
    %% 
    for nor  = 1 : size(Rec_time,1)
        temp =  Rec_time(nor,:);
        Rec_time(nor,:) = Rec_time(nor,:) + u*Rec_time(nor,:);
        for t = m+1 : n-L+1
            t
        %ARNN was used to calculate the predicted value of L-day data
            Rec_time2 = Rec_time(:,t-m:t-1+L);
            C = corr(Rec_time2'+0.001,"type","Pearson");
            C(isnan(C))=0;
            for i = 1 : size(Rec_time,1)
                index = find(abs(C(i,:)) >= 0.6);
                Rec_time2_related = Rec_time2(index,:);
                [predict(i,:),RMSE] = refine_Main_ARNN(Rec_time2_related',m,L+1,find(index==i),size(Rec_time2_related,1));
                delta_record(i,t-m) = RMSE;
            end
            predict(predict<0) = 0;
            data = [Rec_time2(:,1:end-L),predict];
        % Calculate the entropy of the ARNN network
            for k = 1 : size(adjecent,1)
                p=[];
                coef=[];
                for i = 1 : sum(adjecent(:,k))
                        Adj_Rec_time = Rec_time2(adjecent(:,k),:);
                        Adj_predict =  predict(adjecent(:,k),:);
                        Adj_data = data(adjecent(:,k),:);
                    for j = 1 : L
                        p(i,j) = abs(corr(Adj_Rec_time(i,1:end-L)',Rec_time2(k,1:end-L)')-corr([Adj_Rec_time(i,2:end-L),Adj_predict(i,j)]',[Rec_time2(k,2:end-L),predict(k,j)]'));
                        if isnan(p(i,j))
                            p(i,j)=0;
                        end
                        coef(j) = abs(var(Rec_time2(k,1:end-L))-var([Rec_time2(k,2:end-L),predict(k,j)]))./log(sum(adjecent(:,k))+0.001);%熵前系数
                    end
                end 
                p = p./(sum(p)+0.001);
                p_logp = p.*log(p+0.001);
                edge = -sum(p_logp.*coef,2);
                H(k,t-m) = sum(edge);
            end
        end
     % Hypothetical sample t-test
        Ht = sum(H)/size(H,2);%Calculate the mean network entropy of the network at each moment in time
        pt = [];%Record 1/p
        warning_point=[];%Record the change point
        for i = 2 : size(Ht,2)
            [~,pp] = ttest(Ht(1:i-1),Ht(i));
            if 1/pp > 20
                warning_point = [warning_point,i-1];
            end
            pt = [pt,1/pp];
        end
    % Calculate sensitivity
        
        [p_up,p_sort_up(nor)] = ttest(Ht,H0);
%         [t_delta(nor),~] = count_wpoint(warning_point,t0);
        Rec_time(nor,:) = temp;
    end
    %% The overall network entropy and initial state change time points under different perturbations were recorded
H_point_value = [H_point_value,p_sort_up];
end
%%
[new_name{1:length(name)}] = deal('196123','162843','010803','148719','198938','163347','138160','131389','065809','060718','164379','064652','120708','198846','155850');
StackedButterflyPlot(H_point_value(:,1:3)',H_point_value(:,4:6)',new_name)    
save h_point_result.mat H_point_value RMSE





