%Kmeans++
clc;clear;
load h_t.mat
%% Data dynamics transformation
A = transition(t_data);
%% clustering
% Select the optimal number of clusters using a specified range (K value)
temp_krecord = inf;
for i = 1 : 2000
    fh = @(X,K)(kmeans(X,K));
    eva = evalclusters(A,fh,"CalinskiHarabasz","KList",1:20);% Classification Scope
    clear fh
    K = eva.OptimalK;
    % shows the standard value for cluster calculations
    if temp_krecord > K
       temp_krecord = K;
       final_eva = eva;
    end
end
%% 
K = final_eva.OptimalK;
clusterIndices = final_eva.OptimalY;
%% tSNE
C = [0.141176470588235	0	0.847058823529412
    0.113725490196078	0.180392156862745	0.976470588235294
    0.207843137254902	0.458823529411765	1
    0.329411764705882	0.678431372549020	1
    0.490196078431373	0.847058823529412	1
    0.674509803921569	0.949019607843137	1
    0.890196078431373	0.996078431372549	1
    1	0.992156862745098	0.890196078431373
    1	0.898039215686275	0.674509803921569
    1	0.713725490196078	0.490196078431373
    1	0.450980392156863	0.329411764705882
    0.988235294117647	0.207843137254902	0.227450980392157
    0.886274509803922	0.105882352941176	0.192156862745098
    0.647058823529412	0	0.129411764705882];
figureHtsne = setHandel(16,12);
Y = tsne(t_data);
gscatter(Y(:,1), Y(:,2),clusterIndices,C,'.',10,'on');
legend('off')
outpng(figureHtsne,16,12,'tsne2')


%% Other evaluation criteria were calculated
eva_CHI=max(eva.CriterionValues);%CH index
eva2 = evalclusters(A,clusterIndices,"DaviesBouldin");%Davies-Bouldin
eva_DBI=eva2.CriterionValues;% DBI 
eva3 = evalclusters(A,clusterIndices,"silhouette");%silhouette
eva_SC=eva3.CriterionValues;% silhouette

%% 保存结果
save h_kmeans2.mat clusterIndices  A eva_CHI eva_DBI eva_SC final_eva