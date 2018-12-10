%% Outliers Cleaner

%% clcAll 
% is a boolean that decide if the clearing will be done on allthe dataset 
% or for each posture separately
    
function [points_to_delete] = cleanOutliers(dataset, postures, point_row_index, clcAll) 
    
    [n_dataset,~] = size(dataset);
    points_to_delete = zeros(n_dataset,1);

    for p = (1+(clcAll*5)):(5+clcAll)
        %% Filtering
        if(p~=6)
            indexes = postures(point_row_index) == p;
            train_points = dataset(indexes,:);
            %t = ['Posture' , num2str(p)];
        else
            indexes = ones(n_dataset,1);
            train_points = dataset;
            %t = 'total';
        end

        [n,~] = size(train_points);

        %% Interquartile Range
        sortedData = sort(train_points,1);  

        if (mod(n,2)~=0)
            Q1 = (sortedData(ceil(n*0.25),:)+sortedData(floor(n*0.25),:))/2;
            Q3 = (sortedData(ceil(n*0.75),:)+sortedData(floor(n*0.75),:))/2;
        else
            Q1 = sortedData(ceil(n*0.25),:);
            Q3 = sortedData(ceil(n*0.75),:);
        end

        coeff = [2, 1.2, 3, 3, 1.55, 1.5];
        iqr = Q3-Q1;
        cut_off = abs(iqr*coeff(p));
        %cut_off = abs(iqr*coeff);
        minor = Q1-cut_off;
        major = Q3+cut_off;

        in = zeros(n,3);
        in(:,1) = train_points(:,1) >= minor(1) & train_points(:,1) <= major(1);
        in(:,2) = train_points(:,2) >= minor(2) & train_points(:,2) <= major(2);
        in(:,3) = train_points(:,3) >= minor(3) & train_points(:,3) <= major(3);

        p_out = ~(in(:,1) & in(:,2) & in(:,3));
        
        points_to_delete(indexes) = p_out;
        
        %% Plot
%         figure
%         
%         subplot(2,2,4)
%         scatter3(train_points(p_out,1),train_points(p_out,2),train_points(p_out,3),3,'r');
%         hold on
%         scatter3(train_points(p_out==0,1),train_points(p_out==0,2),train_points(p_out==0,3),3,'b');
%         title(t)
%         pause(0.3)
% 
%         subplot(2,2,1), hold on
%         
%         plot(train_points(p_out==0,1),train_points(p_out==0,2),'.b')
%         plot(train_points(p_out,1),train_points(p_out,2),'.r')
%         plot(0,0,'oy')
%         title('X-Y')
% 
%         subplot(2,2,2), hold on
%         plot(train_points(p_out,1),train_points(p_out,3),'.r')
%         plot(train_points(p_out==0,1),train_points(p_out==0,3),'.b')
%         plot(0,0,'oy')
%         title('X-Z')
% 
%         subplot(2,2,3), hold on
%         plot(train_points(p_out,2),train_points(p_out,3),'.r')
%         plot(train_points(p_out==0,2),train_points(p_out==0,3),'.b')
%         plot(0,0,'oy')
%         title('Y-Z')
%         hold off
   
    end
    
    
end