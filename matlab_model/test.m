% Define the poles
zp1 = 0.75;
zp2 = 0.180;

% Create the filter coefficients (numerator) from the poles
b = [1]; % For example, if you're just interested in the poles, the numerator coefficients are 1

% Create the denominator coefficients using the poles
a = [1, -zp1, -zp2];

% Frequency response calculation
[H, W] = freqz(b, a);

% Plot the magnitude response
subplot(2,1,1);
plot(W/pi, abs(H));
title('Magnitude Response');
xlabel('Normalized Frequency (\times\pi rad/sample)');
ylabel('Magnitude');

% Plot the phase response
subplot(2,1,2);
plot(W/pi, angle(H));
title('Phase Response');
xlabel('Normalized Frequency (\times\pi rad/sample)');
ylabel('Phase (radians)');