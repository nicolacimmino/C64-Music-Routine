function plotwav(filename)
pwd
[y,fs] = audioread(filename);
time=1000*(1:length(y))/fs;
figure;
plot(time,y);
grid on;
set (gca, "xminorgrid", "on");
endfunction
