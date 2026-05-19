clear,clc
load h_pre.mat
load h_t.mat
adjecent = maprho;
L = 3; %Sliding length
m = 10;%Training length
adjecent = logical(adjecent);

%% data processing
n = size(Rec_time,2); % Overall length
predict = []; 
delta_record = [];    

Rec_time = p_data(Rec_time); % Data preprocessing

%% ===================== ARNN 主计算部分（保持原样） =====================
for t = m+1 : n-L+1
    t
    Rec_time2 = Rec_time(:,t-m:t-1+L);
    C = corr(Rec_time2'+0.001,"type","Pearson");
    C(isnan(C)) = 0;

    for i = 1:size(Rec_time,1)
        index = find(abs(C(i,:)) >= 0.6);
        Rec_time2_related = Rec_time2(index,:);
        [predict(i,:),RMSE] = refine_Main_ARNN(Rec_time2_related',m,L+1,...
                                               find(index==i),size(Rec_time2_related,1));
        delta_record(i,t-m) = RMSE;
    end

    predict(predict<0) = 0;
    data = [Rec_time2(:,1:end-L),predict];

    % ================= Network entropy ================
    for k = 1:size(adjecent,1)
        p = [];
        coef = [];
        for i = 1:sum(adjecent(:,k))
            Adj_Rec_time = Rec_time2(adjecent(:,k),:);
            Adj_predict = predict(adjecent(:,k),:);
            Adj_data = data(adjecent(:,k),:);

            for j = 1:L
                p(i,j) = abs(corr(Adj_Rec_time(i,1:end-L)',Rec_time2(k,1:end-L)') - ...
                            corr([Adj_Rec_time(i,2:end-L),Adj_predict(i,j)]',...
                                 [Rec_time2(k,2:end-L),predict(k,j)]'));
                if isnan(p(i,j)), p(i,j)=0; end
                coef(j) = abs(var(Rec_time2(k,1:end-L)) - ...
                              var([Rec_time2(k,2:end-L),predict(k,j)]))./...
                              log(sum(adjecent(:,k))+0.001);
            end
        end
        p = p./(sum(p)+0.001);
        p_logp = p.*log(p+0.001);
        edge = -sum(p_logp.*coef,2);
        H(k,t-m) = sum(edge);
    end
end

%% ===================== t-test & 找变化点 =====================
Ht = sum(H)/size(H,2);
pt = [];
warning_point = [];

for i = 2:size(Ht,2)
    [~,pp] = ttest(Ht(1:i-1),Ht(i));
    if 1/pp > 20
        warning_point = [warning_point, i-1];
    end
    pt = [pt,1/pp];
end

%% ============= Replace AREA 图部分（无黑块，无透明 bug） =============
figureHandel = setHandel(16,12);

C0 = [1 0.85098039 0.1843137];   % 黄色圆圈
C  = [1 0 0];                    % 红色五角星
C2 = [0.117647 0.5647059 1];     % 浅蓝色（面积 + 折线）

x = 1:length(Ht);
y = Ht;

% ---- 使用 patch 重画浅蓝面积图（替代 area，彻底解决黑块问题） ----
patch([x fliplr(x)], [y zeros(size(y))], C2, ...
      'EdgeColor', 'none', 'FaceAlpha', 1);  % 不透明最安全
hold on;

% ---- 折线 ----
plot(x, y, 'Color', C2, 'LineWidth', 2);

% ---- 标记显著变化点 ----
stem(warning_point(1),Ht(warning_point(1)),...
     'Marker','o','MarkerSize',30,'Color',C0,'LineWidth',1.5);
stem(warning_point(1),Ht(warning_point(1)),...
     'filled','Marker','p','MarkerSize',30,'Color',C);

% 去白边、字体等
set(gca,'LooseInset',get(gca,'TightInset'));
set(gca,'FontSize',12,'FontName','Helvetica');
set(gcf,'Color','w');

% ===== 输出三种格式 =====
set(gcf,'Renderer','painters'); % 强制矢量渲染

print(gcf,'-dsvg','h_entropy_clean.svg');
print(gcf,'-dmeta','h_entropy_clean.emf');
print(gcf,'-dpdf','h_entropy_clean.pdf');

disp('✨ h_entropy_clean.svg / emf / pdf 输出完成（无黑色区域） ✨');

%% ===================== 后续计算保持不变 =====================
H0 = Ht;
t0 = warning_point;

save h_error.mat delta_record

error = mean(delta_record,'all');
[X,Y] = meshgrid(m+1:n-L+1,1:length(name));

Stem3D(X,Y,delta_record)

save h_init_index.mat H0 t0 H
