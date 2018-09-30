warning off;
clc;clear;
users = ["DM02";"DM03";"DM04";"DM05";"DM06";"DM07";"DM08";"DM09";"DM10";"DM12"];
xlData = ["User","DT_Accuracy","DT_Precision","DT_Recall","DT_F1","SVM_Accuracy","SVM_Precision","SVM_Recall","SVM_F1","NN_Accuracy","NN_Precision","NN_Recall","NN_F1"];
action = "GoOut";
for usr = 1:length(users)
user = users(usr);
[InputData,Textdata] = xlsread('output2/'+ user +'.csv');
M = [user];
transposeInputData = InputData';
[rows,cols] = size(InputData);
newMat = [];
LowPassValues1 = [];
for i = 1:34:rows
    newMat = [newMat;transposeInputData(:,i:i+33)];
end
variance = var(newMat);
[VarianceValue, index] = maxk(variance,10);
sensors = ["ALX","ALY","ALZ","ARX","ARY","ARZ","EMG0L","EMG1L","EMG2L","EMG3L","EMG4L","EMG5L","EMG6L","EMG7L","EMG0R","EMG1R","EMG2R","EMG3R","EMG4R","EMG5R","EMG6R","EMG7R","GLX","GLY","GLZ","GRX","GRY","GRZ","ORL","OPL","OYL","ORR","OPR","OYR"];

countacton = tabulate(Textdata);
countacton2 = countacton(:,2);
count= [];
%disp(countacton2);
idx_arr = [];
count_action = 1;
for k=1:length(countacton2)
    
   idx_arr(k) = count_action;
   temp = cell2mat(countacton2(k));   
   count_action = count_action + (temp/34);
   count(k)= temp/34;
end
%index=[31,32,33,34, 26, 27, 28];
Y = [];
% figure(1);
% hold on;
for feature = 1:length(index)
    j = index(feature);
    X = InputData(j,:);
    %X(isnan(X))=[];
    varX = var(X);
    for i = j+34:34:rows  
        A = InputData(i,:);
        %A(isnan(A))=[];
        A = var(A);
        varX = [varX; A];
    end
    %plot(varX,'DisplayName',sensors(j));
    Y = [Y; varX'];
end

f = Y';

ZScore = zscore(f);
[coeff, score, latent, tsquared, explained, mu] = pca(ZScore);

start_idx = idx_arr(9);
countOfRequiredAction = count(9);

NewProjection = ZScore * coeff;
%disp(NewProjection);
[rows , cols] = size(NewProjection);
newcol = zeros(1,rows);

for p = start_idx: (start_idx + countOfRequiredAction - 1)
    newcol(p) =1;    
end



NewProjection = [NewProjection newcol'];

positive = NewProjection(start_idx:(start_idx + countOfRequiredAction - 1),:);
negative = NewProjection(1: start_idx-1,:);
negative = [negative;NewProjection((start_idx + countOfRequiredAction - 1) +1 :rows , :)];

p = .6 ;     % proportion of rows to select for training
N1 = size(positive,1);  % total number of rows 
tf = false(N1,1);    % create logical index vector
tf(1:round(p*N1)) = true ;    
tf = tf(randperm(N1));   % randomise order
N2 = size(negative,1);
tf2 = false(N2,1);    % create logical index vector
tf2(1:round(p*N2)) = true ;    
tf2 = tf2(randperm(N2));   % randomise order

dataTraining = positive(tf,:) ;
dataTraining = [dataTraining;negative(tf2,:)];
dataTesting = positive(~tf,:) ;
dataTesting = [dataTesting;negative(~tf2,:)]; 
%disp(dataTraining(:,21));
t = fitctree(dataTraining(:,1:cols),dataTraining(:,cols+1));
svmd = fitcsvm(dataTraining(:,1:cols),dataTraining(:,cols+1));
%nn = nftool(dataTraining(:,1:20),dataTraining(:,21));
nndatatrain1 = NewProjection(:,1:cols);
nntrainoutput = NewProjection(:,cols+1);
view(t, 'mode','graph')
j = dataTesting(:,1:cols);
Act_label = dataTesting(:,cols+1);

Plabeldt = predict(t,j);
Plabelsvm = predict(svmd,j);
%disp('Metrics for Decision Tree');
stat = perf(Act_label',Plabeldt');
M = [M stat];
%disp('Metrics for SVM');
perf(Act_label',Plabelsvm');
M = [M stat];

sv = svmd.SupportVectors;
figure;
gscatter(NewProjection(:,2),NewProjection(:,3),NewProjection(:,cols+1));
hold on;
plot(sv(:,1),sv(:,2),'ko','MarkerSize',10);
legend('class 0','class 1','Support Vector');
xlabel('Feature 1');
ylabel('Feature 2');
title('Graphical Representation of Support Vectors');
hold off;

NNInputFeatures = nndatatrain1';
NNInputClassVariables = nntrainoutput';
net = patternnet(10);

net.divideParam.trainRatio = 40/100;
net.divideParam.valRatio = 10/100;
net.divideParam.testRatio = 50/100;
net.trainFcn = 'trainscg';
net.trainParam.min_grad = 1.0000e-15;
net.trainParam.lr = 0.0001;
net.trainParam.epochs=1000;
net.layers{2}.transferFcn = 'tansig';
[net,tr] = train(net,nndatatrain1',nntrainoutput');
testX = NNInputFeatures(:,tr.testInd);
actualTestClass = NNInputClassVariables(:,tr.testInd);
nntraintool;

predictNN = net(testX);
testIndices = vec2ind(predictNN);
perf(actualTestClass,predictNN);
M = [M stat];
xlData = [xlData;M];
end

Excel = actxserver('excel.application');
WB = Excel.Workbooks.Open(fullfile(pwd, 'performance.xlsx'), 0, false);
WS = WB.Worksheets;
WS.Add([], WS.Item(WS.Count));
WS.Item(WS.Count).Name = action;
WB.Save();
Excel.Quit();
xlswrite('performance.xlsx',xlData,action);

function stats = perf(testT,testY)
[c,cm] = confusion(testT,testY);
fprintf('Accuracy : %f\n', (1-c));
%fprintf('Percentage Incorrect Classification : %f%\n', 100*c);
recallNN = cm(2,2)/(cm(1,2) + cm(2,2));
precNN = cm(2,2)/(cm(2,2) + cm(2,1));
F1NN = 2*((recallNN*precNN)/(recallNN + precNN));
stats = [1-c, precNN, recallNN, F1NN];
end
