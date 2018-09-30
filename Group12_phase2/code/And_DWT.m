clear;clc;
InputData = xlsread('output\And.csv');
[rows,cols] = size(InputData);
%transposeInputData = InputData';
%newMat = [];
%for i = 1:34:rows
%    newMat = [newMat;transposeInputData(:,i:i+33)];
%end
%variance = var(newMat);
%[VarianceValue, index] = maxk(variance,10);

LowPassValues1 = [];
Fs = 2000;                                      % Sampling Frequency
Fn = Fs/2;                                      % Nyquist Frequency
Fv = linspace(0, 1, fix(cols/2)+1)*Fn;          % Frequency Vector (Hz)
Iv = 1:length(Fv);                              % Index Vector
figure(1);
hold on;

index=[32,33,34,26,27,28];
sensors = ["ALX","ALY","ALZ","ARX","ARY","ARZ","EMG0L","EMG1L","EMG2L","EMG3L","EMG4L","EMG5L","EMG6L","EMG7L","EMG0R","EMG1R","EMG2R","EMG3R","EMG4R","EMG5R","EMG6R","EMG7R","GLX","GLY","GLZ","GRX","GRY","GRZ","ORL","OPL","OYL","ORR","OPR","OYR"];

for feature = 1:length(index)
    j = index(feature);
    X = InputData(j,:);
    [a,b] = dwt(X,'db1');
    [c,d] = dwt(b,'db2');
    [e,f] = dwt(d,'db3');
    [g,h] = dwt(f,'db4');
    LowPassValues = g;
    %plot(g);
    for i = j+34:34:rows  
        A = InputData(i,:);
        [a,b] = dwt(A,'db1');
        [c,d] = dwt(b,'db2');
        [e,f] = dwt(d,'db3');
        [g,h] = dwt(f,'db4');
        %plot(g);
        LowPassValues = [LowPassValues; g];
    end
    plot(Fv, abs(LowPassValues(Iv))*2,'DisplayName',sensors(j));
    LowPassValues1=[LowPassValues1;LowPassValues'];
end
xlabel('Frequency (in hertz)');
ylabel('Magnitude');
title('Magnitude Response');
legend('Location','North');
ZScore = zscore(LowPassValues1');
[coeff, score, latent, tsquared, explained, mu] = pca(ZScore);
%NewProjection = ZScore * latent;
figure(2);
scatter3(score(:,1),score(:,2),score(:,3))
axis equal
xlabel('First Principal Component')
ylabel('Second Principal Component')
zlabel('Third Principal Component')
title('Data Points on Latent Axis')
xlswrite('EigenVectors\AndEigens',coeff);
