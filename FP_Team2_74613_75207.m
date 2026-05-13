%% Objetivo
%Detetar e delimitar o contorno 
%externo do parênquima cerebral. 
%Calcular a área total delimitada em 
%píxeis e o perímetro do contorno. 
%% Leitura de dados e Ponderações

img = imread('T02_brain_mri_axial.jpg');
%a imagem é uma matriz 3D, ou seja, não está com a escala de cinzentos mas sim cores
size(img)
img_gray = rgb2gray(img);
size(img_gray)

%%OTSU 1 - Provar que não funciona diretamente
level = graythresh(img_gray);
img_otsu = imbinarize(img_gray, level);

figure Name Original
subplot(1,3,1); imshow(img_gray); title('Imagem Original');
subplot(1,3,2); imhist(img_gray);  title('Histograma Original');
subplot(1,3,3); imshow(img_otsu);  title('Otsu'); %Não funciona diretamente na imagem original, imagem incompleta

%% Pré-processamento

%EqHist
img_eqhist = histeq(img_gray);

%CLAHE 1
img_clahe_normal = adapthisteq(img_gray);

%CLAHE 2
img_clahe = adapthisteq(img_gray, 'NumTiles',[16 16], 'Distribution','rayleigh');


%% OTSU

%%OTSU 1
level = graythresh(img_eqhist);
img_bin1 = imbinarize(img_eqhist, level);

%%OTSU 2
level = graythresh(img_clahe_normal);
img_bin2 = imbinarize(img_clahe_normal, level);

%%OTSU 3
level = graythresh(img_clahe);
img_bin3 = imbinarize(img_clahe, level);

%% Visualização

figure Name 'Pré-Processamento'
subplot(3,2,1); imshow(img_eqhist); title('Eqhist (Default)');
subplot(3,2,2); imhist(img_eqhist);  title('Histograma Equhist (Default)');
subplot(3,2,3); imshow(img_clahe_normal);  title('CLAHE NORMAL');
subplot(3,2,4); imhist(img_clahe_normal);  title('CLAHE NORMAL');
subplot(3,2,5); imshow(img_clahe);  title('CLAHE RAYLEIGH');
subplot(3,2,6); imhist(img_clahe);  title('Histograma CLAHE RAYLEIGH');%Melhor porque tem maior separação

figure Name 'OTSU'
subplot(1,3,1); imshow(img_bin1);  title('Otsu EqHist');
subplot(1,3,2); imshow(img_bin2);  title('Otsu CLAHE NORMAL');
subplot(1,3,3); imshow(img_bin3);  title('Otsu CLAHE RAYLEIGH'); 

%% Region Growing

mask1 = zeros(size(img_clahe)); %-0.13
mask1(58:end-155,58:end-65) = 1; %(y, x)
img_actc1 = activecontour(img_clahe, mask1, 1100, 'Chan-Vese', 'ContractionBias', -0.13); %aumento do tempo de processamento mas boa deteção
img_actc1(178:end,:) = 0; %fazer uma função para detetar

mask2 = zeros(size(img_clahe)); %-0.11
mask2(65:end-135,48:end-45) = 1; %(y, x)
img_actc2 = activecontour(img_clahe, mask2, 1100, 'Chan-Vese', 'ContractionBias', -0.11); %aumento do tempo de processamento mas boa deteção
img_actc2(178:end,:) = 0; %fazer uma função para detetar

mask3 = zeros(size(img_clahe)); %-0.14
mask3(65:end-155,48:end-45) = 1; %(y, x)
img_actc3 = activecontour(img_clahe, mask3, 1100, 'Chan-Vese', 'ContractionBias', -0.14); %aumento do tempo de processamento mas boa deteção
img_actc3(178:end,:) = 0; %fazer uma função para detetar

%% Visualização

figure Name 'Region Growing',
subplot (3,3,1), imshow(labeloverlay(img_clahe, mask1)), subplot(3,3,2), imshow(img_actc1), title("Mask 1"), subplot(3,3,3), imshow(labeloverlay(img_clahe, img_actc1)),
subplot (3,3,4), imshow(labeloverlay(img_clahe, mask2)), subplot(3,3,5), imshow(img_actc2), title("Mask 2"),subplot(3,3,6), imshow(labeloverlay(img_clahe, img_actc2)),
subplot (3,3,7), imshow(labeloverlay(img_clahe, mask3)), subplot(3,3,8), imshow(img_actc3), title("Mask 3"),subplot(3,3,9), imshow(labeloverlay(img_clahe, img_actc3))

%% Métodos Morfológicos

%Teste a mostrar que não funciona
img_overhull = bwconvhull(img_actc3);

%Maior precisão
img_clean = bwmorph(img_actc3,'clean') %remove pontos espalhados

kernel_sphere = strel("sphere",3)
img_closed = imclose(img_clean, kernel_sphere); %Completa o contorno da imagem

%Hole Filling
img_area = imfill(img_closed, 'holes');

%% Visualização

figure Name 'Over Hull', 
subplot (1,2,1), imshow(img_overhull),
subplot(1,2,2), imshow(labeloverlay(img_clahe, img_overhull))

figure Name 'Evolução Morfológica', 
subplot (2,2,1), imshow(img_actc3), subplot(2,2,2), imshow(img_clean)
subplot (2,2,3), imshow(img_closed), subplot(2,2,4), imshow(img_area)

%% Área

area = regionprops(img_area, 'Area');
fprintf('Valor do Perímetro: %.3f px\n', area(1).Area);

%% Perimetro

img_contour = bwperim(img_area);
perimetro = regionprops(img_contour, 'Perimeter');
img_contour_sobel = edge(img_area, "sobel");
perimetro_sobel = regionprops(img_contour_sobel, 'Perimeter');
img_contour_log = edge(img_area, "log");
perimetro_log = regionprops(img_contour_log, 'Perimeter');
img_contour_cannys = edge(img_area, "log");
perimetro_cannys = regionprops(img_contour_cannys, 'Perimeter');
fprintf('Valor do Perímetro: %.3f px\n', perimetro(1).Perimeter);
fprintf('Valor do Perímetro Sobel: %.3f px\n', perimetro_sobel(1).Perimeter);
fprintf('Valor do Perímetro LoG: %.3f px\n', perimetro_log(1).Perimeter);
fprintf('Valor do Perímetro Cannys: %.3f px\n', perimetro_cannys(1).Perimeter);

%% Vsualização

figure Name 'Área e Perímetro', 

% criar vetor com as imagens
masks = zeros(size(img_gray));
masks(img_area) = 1;
masks(img_contour) = 2;

% cores personalizadas
cores = [
    0 0 1;   % azul
    1 0 0    % vermelho
    ];

overlay = labeloverlay(img_gray, masks, 'Colormap', cores);
imshow(overlay);

hold on;

h1 = plot(nan,nan,'r');
h2 = plot(nan,nan,'b');

legend([h1 h2], {'Área','Perímetro'});
title('Resultado Final');
hold off;

%% Tronco Cerebral
%Optimal Image
img_adj = imadjust(img_gray, [0.4 0.9], [0 1]);

%Region Growing
mask3 = zeros(size(img_adj)); %-0.14
mask3(145:end-95,130:end-105) = 1; %(y, x)
img_tronco = activecontour(img_adj, mask3, 700, 'Chan-Vese', 'ContractionBias', 0.18); %aumento do tempo de processamento mas boa deteção


%Morfologia
img_clean = bwmorph(img_tronco,'clean')
kernel_disk = strel('disk',5)
img_area_tc = imclose(img_clean, kernel_disk); %Completa o contorno da imagem

figure Name 'Tronco Cerebral',  imshow(labeloverlay(img_clahe,img_area_tc))



%% Córtex Cerebral

% Optimal Image
img_adj = imadjust(img_gray, [0.3 0.8], [0 1]);

%Region Growing
mask3 = zeros(size(img_adj)); %-0.14
mask3(95:end-155,125:end-85) = 1; %(y, x)
img_all = activecontour(img_adj, mask3, 700, 'Chan-Vese'); %aumento do tempo de processamento mas boa deteção
img_dil = imdilate(img_all, kernel_disk); % este dilate serve para aumentar mais o all e evitar que haja restícios significativos
img_cc = img_actc3 - img_dil;
img_cc = img_cc > 0;

%Morfologia
img_closed = imclose(img_cc, kernel_sphere); %Completa o contorno da imagem primeirom, para garantir distinção de áreas
img_clean = bwareafilt(img_closed, 1); %Deixa apenas o maior objeto
kernel_sphere = strel("sphere",3);
img_cc_area = imfill(img_clean, 'holes');
figure Name 'Córtex Cerebral', imshow(labeloverlay(img_clahe, img_cc_area))