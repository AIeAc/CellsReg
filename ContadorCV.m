% --- BLOQUE PRINCIPAL ---
list = dir('*.jpg'); 
number_of_files = length(list); 

figure(1); 
maximize_window = true;

for i = 1:number_of_files
    filename = list(i).name;
    I = imread(filename);
    
    [num_celulas, imagen_coloreada] = procesar_imagen(I);
    
    % --- VISUALIZACIÓN ---
    clf;
    
    subplot(1, 2, 1); 
    imshow(I); 
    title(['Archivo: ', filename], 'Interpreter', 'none');
    
    subplot(1, 2, 2); 
    imshow(imagen_coloreada); 
    title(['Conteo: ', num2str(num_celulas), ' células']);
    
    fprintf('Procesando %s... Detectadas: %d\n', filename, num_celulas);
    
    pause(3); 
end

disp('--- Procesamiento de todas las imágenes completado ---');


% --- DEFINICIÓN DE LA FUNCIÓN ---
function [numCells, rgbMask] = procesar_imagen(img)
    if size(img, 3) == 3
        blueChannel = img(:,:,3);
    else
        blueChannel = img;
    end

    imgSmooth = imgaussfilt(blueChannel, 2);

    bw = imbinarize(imgSmooth, 'global');
    bw = imfill(bw, 'holes');
    bw = bwareaopen(bw, 10);

    D = bwdist(~bw);          
    D_inv = -D;            
    
    mask = imextendedmin(D_inv, 2); 
    D_mod = imimposemin(D_inv, mask);
    
    L = watershed(D_mod);   
    bw(L == 0) = 0;         

    [labeledImage, numCells] = bwlabel(bw);
    
    rgbMask = label2rgb(labeledImage, 'jet', 'k', 'shuffle');
end