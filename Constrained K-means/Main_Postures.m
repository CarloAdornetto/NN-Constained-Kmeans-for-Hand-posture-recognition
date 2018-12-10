%% GESTURE RECOGNITION PREPROCESSING (k-MEANS)
clear
clc

%% Load Dataset
Dataset = load('Postures.txt');

Postures = Dataset(:,1);
Dataset(:,1) = [];
% deleting Users
Dataset(:,1) = [];

N_postures = 5;
Active_marker = [7,11,9,10,11];

tic
%% Indexing & Clearing
[nrow_sample, ncol_sample] = size(Dataset);
point_rowIndex = repelem((1:nrow_sample)', 12);

Dataset = reshape(Dataset',3,[])';
point_rowIndex = point_rowIndex((Dataset(:,1) ~= -1));
Dataset = Dataset((Dataset(:,1) ~= -1),:);

%%
threshold = 0.1;

%the third parameter is 0 to clear for each posture or 1 to clear on all ones
[points_to_delete] = cleanOutliers(Dataset, Postures, point_rowIndex, 0);
points_to_retain = ~points_to_delete;

%Cleared dataset and indexing to the original file nx36
Train_set = Dataset(points_to_retain,:);
Point_rowIndexes = point_rowIndex(points_to_retain);

%Dataset = [];
%point_rowIndex = [];

%% Clustering
centers_pXmarker = cell(N_postures,1);
Ordered_Dataset = cell(N_postures,1);

for p = 1:N_postures

    fprintf('POSTURE %d\n', p)
    train_set_p = Train_set(Postures(Point_rowIndexes) == p,:);
    point_rowIdx_p = Point_rowIndexes(Postures(Point_rowIndexes) == p);
    
    k = Active_marker(p);
    
    [centers,clustersFinal] = K_Means_constrained(train_set_p, point_rowIdx_p, k, threshold);
    centers_pXmarker{p} = centers;
    
    clusterized = clustersFinal~=0;
    
    Clusters_result = clustersFinal(clusterized);
    Rows_result = point_rowIdx_p(clusterized);
    Train_result = train_set_p(clusterized,:);
    
    uniqueRows = unique(Rows_result);
    nrow_result = size(uniqueRows,1);
    [~,rows_result] = histc(Rows_result, uniqueRows);
    
    Dataset_result = ones(nrow_result, ncol_sample).*-1;
    for i = 1:sum(clusterized)
        Dataset_result(rows_result(i),((Clusters_result(i)*3)-2):(Clusters_result(i)*3)) = Train_result(i,1:3);
    end
    
    Ordered_Dataset{p} = Dataset_result;
    plottingResult()
    fprintf('\n')
end
%%
retaineddata=0;
for p = 1:N_postures
    [dr,~]=size(Ordered_Dataset{p});
    retaineddata=retaineddata+dr;
end

%% CENTERS PLOT

figure, hold on, grid on
for p=1:N_postures
    c=centers_pXmarker{p};
    col = 'yrbmc';
    s = ['.', col(p)];
    plot(c(:,1), c(:,2),s,'MarkerSize', 50);
end
