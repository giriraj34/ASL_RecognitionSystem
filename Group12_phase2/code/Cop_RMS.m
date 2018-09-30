clc;clear;
InputData = xlsread('output\Cop.csv');
[rows,cols] = size(InputData);
%newMat = [];
%transposeInputData = InputData';
%for i = 1:34:rows
%    newMat = [newMat;transposeInputData(:,i:i+33)];
%end
%variance = var(newMat);
%[VarianceValue, index] = maxk(variance,10);

index=[18,19,20,21,22,28];
sensors = ["ALX","ALY","ALZ","ARX","ARY","ARZ","EMG0L","EMG1L","EMG2L","EMG3L","EMG4L","EMG5L","EMG6L","EMG7L","EMG0R","EMG1R","EMG2R","EMG3R","EMG4R","EMG5R","EMG6R","EMG7R","GLX","GLY","GLZ","GRX","GRY","GRZ","ORL","OPL","OYL","ORR","OPR","OYR"];
figure(1);
hold on;
Y = [];
for feature = 1:length(index)
    j = index(feature);
    X = InputData(j,:);
    X(isnan(X))=[];
    rmsX = rms(X);
    for i = j+34:34:rows  
        A = InputData(i,:);
        A(isnan(A))=[];
        A = rms(A);
        rmsX = [rmsX; A];
    end
    plot(rmsX,'DisplayName',sensors(j));
    Y = [Y; rmsX'];
end
legend('Location','NorthEast');
title('RMS values for selected features');
f = Y';

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
xlswrite('EigenVectors\copEigens',coeff);