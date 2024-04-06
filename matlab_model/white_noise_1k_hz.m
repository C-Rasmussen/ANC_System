duration = 180; 
fs = 20000; 
f_cutoff = 1000;


white_noise = randn(1, duration * fs);

[b, a] = butter(6, f_cutoff / (fs/2), 'low');

filtered_noise = filter(b, a, white_noise);

% Normalize 
filtered_noise = filtered_noise / max(abs(filtered_noise));

audiowrite('filtered_noise.wav', filtered_noise, fs);



filename = 'filtered_noise.wav';
[y, fs] = audioread(filename);

t = (0:length(y)-1) / fs;
subplot(2,1,1);
plot(t, y);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Waveform');

N = length(y);
f = (-N/2:N/2-1) * fs / N;

Y = fftshift(fft(y));
Pyy = abs(Y).^2 / N;
subplot(2,1,2);

plot(f, 10*log10(Pyy));
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Spectrum');
xlim([-fs/2, fs/2]);