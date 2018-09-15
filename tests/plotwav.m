function plotwav(filename)
  [y,fs] = audioread(filename);
  time=1000*(1:length(y))/fs;
  figure(1, 'position',[0,0,800,300]);
  plot(time,y);
  grid on;
  set (gca, "xminorgrid", "on");
  png_filename=strrep(filename,'.wav','.png');
  print(png_filename, '-dpng', '-S800,300');
endfunction
