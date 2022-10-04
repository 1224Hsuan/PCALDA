% 呼叫Train與Test函式
[FFACE, TotalMeanFace, pcaTotalFACE, projectPCA, eigvector, prototypeFACE] = PCALDA_Train;
[correct] = PCALDA_Test(projectPCA, eigvector, prototypeFACE, TotalMeanFace);
