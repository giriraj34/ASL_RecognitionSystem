clc;clear;
InputData = xlsread('output/Can.csv');
[rows,cols] = size(InputData);
%transposeInputData = InputData';
%newMat = [];
%for i = 1:34:rows
%    newMat = [newMat;transposeInputData(:,i:i+33)];
%end
%variance = var(newMat);
%[VarianceValue, index] = maxk(variance,10);
index=[1,2,3,4,5,6];
sensors = ["ALX","ALY","ALZ","ARX","ARY","ARZ","EMG0L","EMG1L","EMG2L","EMG3L","EMG4L","EMG5L","EMG6L","EMG7L","EMG0R","EMG1R","EMG2R","EMG3R","EMG4R","EMG5R","EMG6R","EMG7R","GLX","GLY","GLZ","GRX","GRY","GRZ","ORL","OPL","OYL","ORR","OPR","OYR"];
Y = [];
for feature = 1:length(index)
    j = index(feature);
    X = InputData(j,:);
    X(isnan(X))=[];
    X = rms(X);
    for i = j+34:34:rows  
        A = InputData(i,:);
        A(isnan(A))=[];
        A = rms(A);
        X = [X; A];
    end
    Y = [Y; X'];
end    
f = Y';
figure(1);
subplot(1,2,1);
plot(f(:,1),f(:,4));
xlabel('Accelerometer Left X')
ylabel('Accelerometer Right X')
title('Correlation of left and right X axis')
subplot(1,2,2);
plot(f(:,2),f(:,5));
xlabel('Accelerometer Left Y')
ylabel('Accelerometer Right Y')
title('Correlation of left and right Y axis')
pcc1 = corr(f(:,1),f(:,4));
pcc2 = corr(f(:,2),f(:,5));

figure(2);
ZScore = zscore(f);
[coeff, score, latent, tsquared, explained, mu] = pca(ZScore);
NewProjection = ZScore * latent;
scatter3(score(:,1),score(:,2),score(:,3))
axis equal
xlabel('First Principal Component')
ylabel('Second Principal Component')
zlabel('Third Principal Component')
title('Data Points on Latent Axis')
xlswrite('EigenVectors\canEigens',coeff);
