function [new_centers,clustersFinal] = K_Means_constrained(train_set_p, point_rowIdx_p, k, threshold) 
    tic
    %% INIT
    %extraction of a row from those with right k
    rows_unique_p = unique(point_rowIdx_p);
    [marker_per_row,~] = histc(point_rowIdx_p, rows_unique_p);
    candidates_center_row = rows_unique_p(marker_per_row==k);
    new_centers = train_set_p(point_rowIdx_p == candidates_center_row(11),:);
    
    kmeans_iter = 0;
    mean_dist = +inf;
    [n_train_p,~] = size(train_set_p);
    
    %% K-MEANS
    while (true)
        
        kmeans_iter = kmeans_iter + 1;
        dist_old = mean_dist;
        
        centers = repmat(new_centers,size(train_set_p,1),1);
        
        d = sqrt(sum((repelem(train_set_p,k,1) - centers).^2,2));
        d = reshape(d,k,[])';
        
        clustersFinal = zeros(n_train_p,1);
        minDistances = zeros(n_train_p,1);
        
        for r = rows_unique_p'
            rows = point_rowIdx_p == r;
            d_ = d(rows,:);
            [n_iteration_, ~] = min(size(d_));
            
            clusters_ = zeros(sum(rows),1);
            freeClusters_ = ones(k,1);
            minDistances_ = zeros(sum(rows),1);
            
            [values, clustersIndex] = min(d_,[],2);
        
            for u=1:n_iteration_
                [minValue, pointIndex] = min(values);
                
                clusters_(pointIndex) = freeClusters_(clustersIndex(pointIndex)) * clustersIndex(pointIndex);
                minDistances_(pointIndex) = freeClusters_(clustersIndex(pointIndex)) * minValue;
                freeClusters_(clustersIndex(pointIndex)) = 0;
                
                values(pointIndex) = +Inf;
            end
            
            clustersFinal(rows,1) = clusters_;
            minDistances(rows,1) = minDistances_;
        end
        
        for i = 1:k  
            new_centers(i,:) = mean(train_set_p(clustersFinal==i,:));
        end
        
        mean_dist = mean(minDistances(clustersFinal ~= 0));
        diff = abs(mean_dist - dist_old);
        
        if (diff <= threshold)
            fprintf('Done: Iterations %d\t\tmean_dist = %f\t', kmeans_iter, mean_dist)
            toc
            break
        end
       
    end
    
end