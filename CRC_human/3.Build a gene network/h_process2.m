load h_t.mat
load h_kmeans2.mat %Import categorical metrics
%% Consolidate data based on cluster labels
c_set = unique(clusterIndices);
Rec_time = zeros(length(c_set),size(t_data,2));%Store categorical data
name = num2cell(zeros(length(c_set),1));%Record the best subclass under the large category
Rec_point = zeros(length(c_set),1);
for i = 1 : length(c_set)
    datai = t_data(clusterIndices==i,:);
    pointi = point(clusterIndices==i,:);
    [~,b_p] = max(sum(datai,2));
    name(i) = pointi(b_p);
    datai_mean = mean(datai);
    Rec_time(i,:) = datai_mean;
end
c_clust = num2cell(clusterIndices);
Rec_point = [point,c_clust];
Rec_A = transition(Rec_time);
%% Plot a heat map of the correlation coefficient
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
rho = corr(Rec_time'+0.001);
fheatmap = setHandel(12,8);
hh = heatmap(rho,'Colormap',C);
outpng(fheatmap,12,8,'h_heatmap')
maprho = zeros(size(rho));
%% Construct a network
maprho(abs(rho)>=0.6) = 1;
for i = 1 : size(maprho,1)
    maprho(i,i)=0;
end
save h_pre.mat maprho Rec_A Rec_time name Rec_point 