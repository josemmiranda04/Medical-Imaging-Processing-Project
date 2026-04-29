%% Leitura de dados
img = imread('T02_brain_mri_axial.jpg');
%a imagem é uma matriz 3D, ou seja, não está com a escala de cinzentos mas sim cores
size(img)
img_gray = rgb2gray(img);
size(img_gray)

%% Pré-processamento

%estica o histograma para maximizar a diferença de intensidade entre o tecido cerebral(claro) e o líquido/fundo(escuros)
img_adj = imadjust(img_gray);

%Gaussian
%h = fspecial('gaussian', [3 3], 0.5);
%img_gauss = imfilter(img_adj, h);

%%CLAHE
img_clahe = adapthisteq(img_adj);

%%OTSU
level = graythresh(img_clahe);
img_bin = imbinarize(img_clahe, level);
%% 
%Visualização
subplot(2,2,1); imshow(img_gray); title('Imagem Original');
subplot(2,2,2); imshow(img_adj);  title('Imajudst (Default)');
%subplot(2,2,3); imshow(img_gauss);  title('Gaussiana');
subplot(2,2,4); imshow(img_clahe);  title('CLAHE');

figure
imshow(img_bin)



