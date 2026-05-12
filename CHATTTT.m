%% Objetivo
%Detetar e delimitar o contorno 
%externo do parênquima cerebral. 
%Calcular a área total delimitada em 
%píxeis e o perímetro do contorno. 
%% Leitura de dados
img = imread('T02_brain_mri_axial.jpg');
%a imagem é uma matriz 3D, ou seja, não está com a escala de cinzentos mas sim cores
size(img)
img_gray = rgb2gray(img);
size(img_gray)
figure, subplot(1,2,1), imshow(img_gray), title("Imagem Original"), subplot(1,2,2), imhist(img), title("Hitograma Original")


%% 1. Pré-processamento
% Melhoramento de contraste local sem suavização para preservar as arestas rigorosamente.
img_clahe = adapthisteq(img_gray, 'NumTiles', [8 8], 'ClipLimit', 0.01);

%% 2. Binarização (Limiarização)
% Método de Otsu para separar o tecido brilhante (cérebro/pele) do fundo.
level = graythresh(img_clahe);
img_bin = imbinarize(img_clahe, level);

%% 3. Pós-processamento Morfológico (Skull Stripping)
% 3.1. Definir o elemento estruturante (bisturi)
% Um disco de raio 3 ou 4 quebra as pontes entre o cérebro e o couro cabeludo.
se = strel('disk', 3); 

% 3.2. Erosão para quebrar ligações anatómicas
img_eroded = imerode(img_bin, se);

% 3.3. Extrair apenas a maior componente (o parênquima)
img_brain_only = bwareafilt(img_eroded, 1);

% 3.4. Dilatação para restaurar o tamanho original (Abertura Morfológica)
img_dilated = imdilate(img_brain_only, se);

% 3.5. Preenchimento de buracos (Hole filling)
% Garante que ventrículos escuros no interior do cérebro contem para a área total.
img_final_mask = imfill(img_dilated, 'holes');

%% 4. Medição Quantitativa
% Extrair as propriedades exigidas pela Tabela 1
stats = regionprops(img_final_mask, 'Area', 'Perimeter');

% Extrair contorno para visualização visual
img_perim = bwperim(img_final_mask);

% Imprimir resultados na Command Window (Requisito Obrigatório)
fprintf('================================================\n');
fprintf('   RESULTADOS DA EXTRAÇÃO - EQUIPA T02\n');
fprintf('================================================\n');
fprintf('Área do Parênquima:      %.2f píxeis\n', stats.Area);
fprintf('Perímetro do Contorno:   %.2f píxeis\n', stats.Perimeter);
fprintf('================================================\n');

%% 5. Visualização e Apresentação de Resultados
% Criar uma imagem de sobreposição (contorno a vermelho sobre a imagem original)
img_overlay = imoverlay(img_gray, img_perim, [1 0 0]);

figure('Name', 'Pipeline de Processamento - T02', 'NumberTitle', 'off', 'Position', [50, 50, 1400, 700]);

% Evolução da Pipeline
subplot(2,3,1); imshow(img_gray); title('1. Original');
subplot(2,3,2); imshow(img_clahe); title('2. CLAHE');
subplot(2,3,3); imshow(img_bin); title('3. Binarização (Otsu)');
subplot(2,3,4); imshow(img_eroded); title('4. Erosão (Corte de Ligações)');
subplot(2,3,5); imshow(img_final_mask); title('5. Máscara Final (Maior + Preenchida)');
subplot(2,3,6); imshow(img_overlay); title('6. Resultado: Contorno Delimitado');