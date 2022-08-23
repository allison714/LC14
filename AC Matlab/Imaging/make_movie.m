
%% show a movie

movie_var = imgFrames_ch1; % store movie in movie_var

figure('units','normalized','Position',[0, 0.03, 1, 0.9]); hold on;
fig = imagesc(movie_var(:,:,1));
colormap(gray);
ylim([1, size(movie_var,1)])
xlim([1, size(movie_var,2)])
%axis off

for i = 2 : size(movie_var,3)
    pause(0.005); % sets inverse frame rate
    fig.CData = movie_var(:,:,i);
end

%% save movie of alignment

movie_var = imgFrames_ch1;

v = VideoWriter('ONOFF_Vert_060921_01.mp4', 'MPEG-4');
open(v)

figure('units','normalized','Position',[0, 0.03, 1, 0.9]); hold on;
fig = imagesc(movie_var(:,:,1));
colormap(gray);
ylim([1, size(movie_var,1)])
xlim([1, size(movie_var,2)])
axis off

for i = 1 : 5000
    fig.CData = movie_var(:,:,i);
    drawnow
    F = getframe(gcf);
    writeVideo(v, getframe(gcf));
end

close(v)
