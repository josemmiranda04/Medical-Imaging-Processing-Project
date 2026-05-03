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

%% Pré-processamento

%estica o histograma para maximizar a diferença de intensidade entre o tecido cerebral(claro) e o líquido/fundo(escuros)
img_adj = imadjust(img_gray);
figure, imhist(img) %apresenta bimodalidade

%Gaussian
%h = fspecial('gaussian', [3 3], 0.5);
%img_gauss = imfilter(img_adj, h);

%%CLAHE
img_clahe = adapthisteq(img_adj);
figure, imhist(img_clahe) %apresenta bimodalidade inferior

%%OTSU 1
level = graythresh(img_gray);
img_bin1 = imbinarize(img_gray, level);

%%OTSU 2
level = graythresh(img_adj);
img_bin2 = imbinarize(img_adj, level);

%%OTSU 3
level = graythresh(img_clahe);
img_bin3 = imbinarize(img_clahe, level);
%% 
%Visualização
figure
subplot(2,2,1); imshow(img_gray); title('Imagem Original');
subplot(2,2,2); imshow(img_adj);  title('Imajudst (Default)'); %provavelmente responde melhor ao método de ótsu
%subplot(2,2,3); imshow(img_gauss);  title('Gaussiana');
subplot(2,2,4); imshow(img_clahe);  title('CLAHE');

figure
subplot(1,3,1); imshow(img_bin1);  title('Otsu Norm');
subplot(1,3,2); imshow(img_bin2);  title('Otsu Hist');
subplot(1,3,3); imshow(img_bin3);  title('Otsu CLAHE'); %estranhamente foi o melhor, n sei explicar porquê
%% Adicional
%Sendo o CLAHE o que teve melhor desempenho, será necessário melhorar a sua
%nitidez
figure, imshow(img_clahe)

% Melhoria de Nitidez Feito a Olho
kernel = fspecial("average", [5 5]);
clahe_pb = imfilter(img_clahe, kernel);
img_Nclahe = img_clahe - clahe_pb.*0.5;
img_Nclahe = img_Nclahe.*2;

figure, imshow(img_Nclahe)

level = graythresh(img_Nclahe);
img_bin_n = imbinarize(img_Nclahe, level);
figure, imshow(img_bin_n) %apresenta certas partes desconectadas mas revela mais detalhes
figure, imshow(img_bin3)
figure, imshow(img_clahe)

%Não funciona tão bem como o de ótsu
%mask = zeros(size(img_clahe)); 
%mask(25:end-25,25:end-25) = 1;
%img_actc = activecontour(img_clahe, mask, 2000); %aumento do tempo de processamento mas boa deteção
%figure, imshow(img_actc)

%Fiz só porque sim
%img_canny = edge(img_Nclahe, "canny");
%figure, imshow(img_canny), title("Canny") talvez fazer dilatações no
%uncanny?

%AGORA É EXPRIMENTAR UMAS EROSÕES E DILATAÇÕES
kernel = strel("sphere",1)
img_dil = imopen(img_bin_n,kernel)
%img_dil = imclose(img_dil,kernel)
figure, imshow(img_dil) %Como podemos retirar o contorno do crânio?





