function [correct] = PCALDA_Test(projectPCA, LDA, prototypeFACE, TotalMeanFace)

principlenum = 50;
ldanum = 30;

people = 40;
withinsample = 5;
totalcount = 0;
correct = 0;

projectLDA = LDA(:, 1:ldanum);

% 計算測試資料集進行運算
% Step.1. 將測試資料進行投影(投影至特徵空間)
% (1x1024 -> 1x50 -> 1x30)
% Step.2. 將測試資料與所有類別(共40個)的距離進行比較
% Step.3. 找出距離最小的值，賦予test資料相對的ID
%-------------------------------------------------------------------------

% 讀取檔案與計算測試資料總數
Test_FFACE = [];

for k = 1:1:people
    for m = 2:2:10
        matchstring = ['orl3232' '\' num2str(k) '\' num2str(m) '.bmp'];
        matchX = imread(matchstring);
        matchX = double(matchX);

        if(k == 1 && m == 2)
            [row, col] = size(matchX);
        end
        matchtempF = [];

        for n = 1:row
            matchtempF = [matchtempF, matchX(n,:)];
        end

        Test_FFACE = [Test_FFACE;matchtempF];
        totalcount = totalcount + 1;
    end
end

%-------------------------------------------------------------------------

% 將測試資料投影至特徵空間
% PCA投影
Test_FFACE_Norm = Test_FFACE - TotalMeanFace;
PCA_FFACE = [];

for i = 1:1:withinsample * people
    tempFACE = Test_FFACE_Norm(i,:);
    tempFACE = tempFACE * projectPCA;
    PCA_FFACE = [PCA_FFACE;tempFACE];
end
Test_FFACE = PCA_FFACE;

% LDA投影
Test_FFACE = Test_FFACE * projectLDA;

%-------------------------------------------------------------------------

% 計算所有測試資料與訓練資料的距離
for i = 1:people * withinsample
    % 記錄最小距離長度
    MinDis = inf;
    % 記錄最小距離類別
    Type = 0;
    
    TempTest = Test_FFACE(i, :);
    for k = 1:people * withinsample
        TempPrototype = prototypeFACE(k, :);
        dis = sum((TempPrototype - TempTest) .^ 2);
        if dis < MinDis
            MinDis = dis;
            Type = floor((k-1) / withinsample) + 1;
        end
    end
    
    % 比對資料是否正確
    if (floor((i-1) / withinsample) + 1) == Type
        correct = correct + 1;
    end
end

%-------------------------------------------------------------------------

% 輸出正確的測資筆數及準確度
fprintf("RecognitionRate = %f\n", correct / totalcount);
fprintf("correct = %d\n", correct);

%-------------------------------------------------------------------------

end
