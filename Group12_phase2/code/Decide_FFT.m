warning off;
clc;clear;
InputData = xlsread('output/Decide.csv');
[rows,cols] = size(InputData);
%InputDataTranspose = InputData';
%%newMat = [];
%for i = 1:34:rows
%    newMat = [newMat;InputDataTranspose(:,i:i+33)];
%end
%variance = var(newMat);
%[VarianceValue, index] = maxk(variance,5);
Y = [];
Fs = 2000;                                      % Sampling Frequency
Fn = Fs/2;                                      % Nyquist Frequency
Fv = linspace(0, 1, fix(cols/2)+1)*Fn;          % Frequency Vector (Hz)
Iv = 1:length(Fv);                              % Index Vector
figure(1);
hold on;

index=[26, 27, 28, 4, 5, 6, 23, 24, 25];
sensors = ["ALX","ALY","ALZ","ARX","ARY","ARZ","EMG0L","EMG1L","EMG2L","EMG3L","EMG4L","EMG5L","EMG6L","EMG7L","EMG0R","EMG1R","EMG2R","EMG3R","EMG4R","EMG5R","EMG6R","EMG7R","GLX","GLY","GLZ","GRX","GRY","GRZ","ORL","OPL","OYL","ORR","OPR","OYR"];

for feature = 1:length(index)
    j = index(feature);
    X = InputData(j,:);
    X(isnan(X))=[];
    X = fft(X,2);
    for i = j+34:34:rows
        A = InputData(i,:);
        A(isnan(A))=[];
        A = fft(A,2);
        X = [X; A];
    end
    plot(Fv, abs(X(Iv))*2,'DisplayName',sensors(j));
    Y = [Y; X'];
end
finalMat = Y';
%figure(1);
%plot(abs(finalMat));
xlabel('Frequency (in hertz)');
ylabel('Magnitude');
title('Magnitude Response');
legend('Location','NorthEast');
figure(2);
ZScore = zscore(finalMat);
[coeff, score, latent, tsquared, explained, mu] = pca(ZScore);
%NewProjection = ZScore * latent;
scatter3(score(:,1),score(:,2),score(:,3))
axis equal
xlabel('First Principal Component')
ylabel('Second Principal Component')
zlabel('Third Principal Component')
title('Data Points on Latent Axis')
xlswrite('EigenVectors\DecideEigens',coeff);
