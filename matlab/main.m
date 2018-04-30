% 20180430 Beck Pang
% Initialize the shape from shaping
clc; clear;
src_path = '../../data/data02/';
icosahedron_divide_ratio = 4;
rank_L = 0.7;
rank_H = 0.9;

%% load light vector
light_vec_path = fopen(strcat(src_path,'lightvec.txt'));
light_vec_src = textscan(light_vec_path, '%f %f %f');
light_vec = [light_vec_src{1} light_vec_src{2} light_vec_src{3}];


%% Resampling the light vector
[unique_light_vec, unique_index] = resampling_light_vector(icosahedron_divide_ratio, light_vec);

%% Load the images with only the unique light vector
image_files_path = dir(fullfile(src_path,'*.bmp'));

% get the basics of an image
num_images = length(image_files_path);
[m, n, ~] = size(imread(fullfile(src_path, image_files_path(1).name)));

% store the src image from color to black and white
% read the images after getting the unique vectors
unique_index_size = length(unique_index);
src_images = zeros(m, n, unique_index_size);

for i = 1:unique_index_size
    image_rgb = imread(fullfile(src_path, image_files_path(unique_index(i)).name));
    image_gray = rgb2gray(image_rgb);
    src_images(:, :, i) =  image_gray;
end

%% Select the denominator image by image intensity ranking
rank_L = rank_L * unique_index_size;
rank_H = rank_H * unique_index_size;
rank_L_count = zeros(unique_index_size, 1);
rank_L_sum   = zeros(unique_index_size, 1);

% [test_B, test_index] = sort(src_images(1, 1, :))
rank_image = zeros(m, n, unique_index_size);
for i = 1:m
    for j = 1:n
        [~, index] = sort(src_images(i, j, :));
        rank_image(i, j, :) = index;
    end
end

for k = 1:unique_index_size
    for i = 1:m
        for j = 1:n
            if rank_image(i, j, k) > rank_L
                rank_L_count(k) = rank_L_count(k) + 1;
                rank_L_sum(k)   = rank_L_sum(k) + rank_image(i, j, k);
            end
        end
    end
end

[sorted_rank, index] = sort(rank_L_count);
k = unique_index_size;
while rank_L_sum(index(k)) / rank_L_count(index(k)) > rank_H
    k = k - 1;
end

denominator_image = src_images(:, :, index(k));
% imshow(uint8(denominator_image));

%% Local normal estimation by ratio images
for k = 1:unique_index_size
    src_images(:, :, k) = src_images(:, :, k)./denominator_image;
end
