clear,clc
load m_pre.mat
load m_t.mat
adjecent = maprho;
L = 3; %Sliding length
m = 10;%Training length
adjecent = logical(adjecent);
%% data processing
n = size(Rec_time,2);%Overall length
predict = [];%Record the predicted value
delta_record = [];%Record the error value

Rec_time = p_data(Rec_time);% Data preprocessing
%% 

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
        for i = 1 : sum(adjecent(:,k))%Traverse through the connection nodes
                Adj_Rec_time = Rec_time2(adjecent(:,k),:);%Retrieve the connection node data
                Adj_predict =  predict(adjecent(:,k),:);
                Adj_data = data(adjecent(:,k),:);
            for j = 1 : L%Travers the prediction time
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
        H(k,t-m) = sum(edge);%entropy
    end
end
%% Hypothetical sample t-test
Ht = sum(H)/size(H,2);%Calculate the mean network entropy of the network at each moment in time。
pt = [];%Record 1/p
warning_point=[];%Record the change point
for i = 2 : size(Ht,2)
    [~,pp] = ttest(Ht(1:i-1),Ht(i));
    if 1/pp > 20
        warning_point = [warning_point,i-1];
    end
    pt = [pt,1/pp];
end
%% visualization
figureHandel = setHandel(16,12);
C0 = [1	0.850980392156863	0.184313725490196];
C = [1 0 0];
C2 = [0.117647058823529	0.564705882352941	1];
area(Ht,'LineWidth',2,'FaceColor',C2,'EdgeColor',C2,...
     'FaceAlpha',.3,'EdgeAlpha',1);
hold on 

stem(warning_point(1),Ht(warning_point(1)),'Marker','o','MarkerSize',30,'Color',C0,'LineWidth',1.5)
stem(warning_point(1),Ht(warning_point(1)),'filled','Marker','p','MarkerSize',30,'Color',C)
% Remove the white edges
set(gca,'LooseInset',get(gca,'TightInset'))
outpng(figureHandel,16,12,'m_entropy2')
%% Calculate the initial metric
H0 = Ht;
t0 = warning_point;
%% Plot the error
save m_error.mat delta_record
error = mean(delta_record,'all');
[X,Y] = meshgrid(m+1:n-L+1,1:length(name));
Stem3D(X,Y,delta_record)
save m_init_index.mat H0 t0 H 





