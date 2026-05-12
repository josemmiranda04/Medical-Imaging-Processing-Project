% Melhoria de Nitidez Feito a Olho
kernel = fspecial("average", [5 5]);
%% Adicional
%Sendo o CLAHE o que teve melhor desempenho, será necessário melhorar a sua
%nitidez
figure, imshow(img_clahe)
clahe_pb = imfilter(img_clahe, kernel);
img_Nclahe = img_clahe - clahe_pb.*0.5;
img_Nclahe = img_Nclahe.*2;

figure, imshow(img_Nclahe)

level = graythresh(img_Nclahe);
img_bin_n = imbinarize(img_Nclahe, level);
figure, imshow(img_bin_n) %apresenta certas partes desconectadas mas revela mais detalhes
figure, imshow(img_bin3)
figure, imshow(img_clahe)


%Fiz só porque sim
img_canny = edge(img_Nclahe, "canny");
figure, imshow(img_canny), title("Canny")
%%
img_b1 = imdilate(img_b, kernel);
img_b2 = imdilate(img_b1, kernel);
img_show = img_bin3 - img_b2;
figure, imshow(img_show)



%AGORA É EXPRIMENTAR UMAS EROSÕES E DILATAÇÕES
kernel = strel("sphere",1)
img_dil = imopen(img_bin_n,kernel)
%img_dil = imclose(img_dil,kernel)
figure, imshow(img_dil) %Como podemos retirar o contorno do crânio?


%% Extrair detalhe porque sim, talvez dê para substância branca
img_linking = edge(img_actc3, 'canny');
figure, subplot (1,2,1), imshow(img_linking), subplot(1,2,2), imshow(labeloverlay(img_clahe, img_linking))