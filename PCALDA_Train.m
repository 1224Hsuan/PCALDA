function [FFACE, TotalMeanFace, pcaTotalFACE, projectPCA, eigvector, prototypeFACE] = PCALDA_Train
% function [FFACE, pcaTotalFACE] = PCALDA_Train
people = 40;
withinsample = 5;
principlenum = 50;

% 200*1024 原始資料的矩陣
FFACE = [];

% 讀取資料
for k = 1:1:people
    for m = 1:2:10
        % 程式與資料在同一個資料夾中
        matchstring = ['orl3232' '\' num2str(k) '\' num2str(m) '.bmp'];

        % matchX為32*32的圖檔
        % 圖檔內數字為灰階值
        matchX = imread(matchstring);

        % 將圖檔格式轉為數字格式
        matchX = double(matchX);

        if(k == 1 && m == 1)
            [row, col] = size(matchX);
        end

        % 用以暫存資料
        matchtempF = [];

        % 將資料串接成1*1024的Vector(圖檔拉成一個Vector)
        for n = 1:row
            matchtempF = [matchtempF, matchX(n,:)];
        end
        
        % FFACE為200*1024的矩陣
        FFACE = [FFACE;matchtempF];
    end
end

% 先進行PCA，再做LDA
% PCA運算，將1024降維成50
% ------------------------------------------------------------------------
TotalMeanFace = mean(FFACE);
FFACE_Norm = FFACE - TotalMeanFace;
Cov_FFACE = FFACE_Norm' * FFACE_Norm;
[Vec, Val] = eig(Cov_FFACE);
eigvalue = diag(Val);

% 由大而小進行排序
[junk, index] = sort(eigvalue, 'descend');

PCA = Vec(:, index);
eigvalue = eigvalue(index);

projectPCA = PCA(:,1:principlenum);
pcaTotalFACE = [];

for i = 1:1:withinsample * people
    tempFACE = FFACE_Norm(i,:);
    % 內積求新座標值
    tempFACE = tempFACE * projectPCA;
    % 儲存投影後的座標值
    pcaTotalFACE = [pcaTotalFACE;tempFACE];
end
%-------------------------------------------------------------------------

% LDA
% 資料每5筆即為一個類別
% 將50降維為20
%-------------------------------------------------------------------------

% 以tmp記錄每5筆資料的內容
tmp = [];
% 以Temp記錄各類別資料Mean的內容
Temp = [];
% 以SW記錄within
SW = [];
% 以SB記錄between
SB = [];

Norm = [];

% 將資料分為每5筆進行個別運算
for i = 1:withinsample:withinsample * people
    tmp = pcaTotalFACE(i:i + withinsample - 1, :);

    FFACE_Mean2 = mean(tmp);
    FFACE_Norm2 = tmp - FFACE_Mean2;
    FFACE_Cov2 = FFACE_Norm2' * FFACE_Norm2;
    Temp = [Temp;FFACE_Mean2];
    Norm = [Norm;FFACE_Norm2];

    % 計算within
    if i == 1
        SW = FFACE_Cov2;
    else
        SW = SW + FFACE_Cov2;
    end
end

% 計算between
%GlobalMean = mean(Temp);
%TempNorm = Temp - GlobalMean;
pcaTotalmean=mean(pcaTotalFACE);
TempNorm = Temp - pcaTotalmean;
SB = TempNorm' * TempNorm;

[Vec, Val] = eig(inv(SW) * SB);
eigvalue = diag(Val);

% 由大而小進行排序
[junk, index] = sort(eigvalue, 'descend');

eigvector = Vec(:, index);
eigvalue = eigvalue(index);

prototypeFACE = pcaTotalFACE * eigvector(:, 1: 30);
%-------------------------------------------------------------------------

end
