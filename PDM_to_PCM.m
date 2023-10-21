fs_pdm = 3.072e6;       % PDM sample rate (3.072 MHz)
fs_pcm = 48e3;          % Desired PCM sample rate (48 kHz)
decimation_factor = fs_pdm / fs_pcm; % Decimation factor = 64

% Generate a random PDM signal 
pdm_signal = randi([0, 1], 1, 1e6); % 1 million PDM samples

%order = 64, stopFs = 24kHz, passFs = 20KHz
impulse_response = [ ...
  -3.557557098602e-07, 1.552722576098e-06, -4.782346637354e-06, 1.216657503782e-05, ...
  -2.728150962451e-05, 5.575324920561e-05, -0.0001059433825349, 0.0001896707240157, ...
  -0.0003228927294278, 0.0005262481540667, -0.000825342915295, 0.001250656434102, ...
  -0.001836951334451, 0.002622095348755, -0.003645246790083, 0.004944413007386, ...
  -0.006553464207209, 0.008498760280479, -0.01079562259307, 0.01344494352157, ...
  -0.01643026409747, 0.0197156586386, -0.02324473717611, 0.02694101101163, ...
  -0.03070976763618, 0.03444147593842, -0.0380166010643, 0.04131156735346, ...
  -0.04420548197584, 0.04658713479037, -0.04836173667517, 0.04945685517659, ...
   0.9501729443786, 0.04945685517659, -0.04836173667517, 0.04658713479037, ...
  -0.04420548197584, 0.04131156735346, -0.0380166010643, 0.03444147593842, ...
  -0.03070976763618, 0.02694101101163, -0.02324473717611, 0.0197156586386, ...
  -0.01643026409747, 0.01344494352157, -0.01079562259307, 0.008498760280479, ...
  -0.006553464207209, 0.004944413007386, -0.003645246790083, 0.002622095348755, ...
  -0.001836951334451, 0.001250656434102, -0.000825342915295, 0.0005262481540667, ...
  -0.0003228927294278, 0.0001896707240157, -0.0001059433825349, 5.575324920561e-05, ...
  -2.728150962451e-05, 1.216657503782e-05, -4.782346637354e-06, 1.552722576098e-06, ...
  -3.557557098602e-07 ...
];
lowpass_filter = fir1(64, 24000/ (3.072e6 / 2));
filtered_signal = filter(lowpass_filter, 1, pdm_signal);

% filtered_signal = zeros(1, length(pdm_signal));
% for i = 1:length(pdm_signal)
%     filtered_signal(i) = myFIRfilter(pdm_signal(i), impulse_response);
% end
freqz(filtered_signal);

decimation_factor = 64;
num_stages = 4;     % Number of CIC filter stages
differential_delay = 1; % Differential delay
%cic_filter = dsp.CICDecimator(decimation_factor, num_stages, differential_delay);

pcm_signal = myCIC(filtered_signal, decimation_factor, num_stages, differential_delay);
%filtered_signal = reshape(filtered_signal, [], 1);
%pcm_signal = step(cic_filter, filtered_signal);


% PCM signal to 16 bits
pcm_signal = int16(pcm_signal * (2^15));

% Plot the original and converted signals
% subplot(2,1,1);
% plot(pdm_signal(1:500), 'r');
% title('Original PDM Signal');
% xlabel('Sample Index');
% ylabel('Amplitude');
% 
% subplot(2,1,2);
% plot(pcm_signal, 'b');
% title('Converted PCM Signal');
% xlabel('Sample Index');
% ylabel('Amplitude');


%audiowrite('output_pcm.wav', double(pcm_signal), fs_pcm);

function y = myFIRfilter(x, b)
    %% 
    persistent z L; % Persistent internal filter memory
    if isempty(z)
        L = length(b);
        z = zeros(size(b)); % Initialize to zero
    end
    y = 0;
    for n=L:-1:1
        if (n >= 2)
            z(n) = z(n-1);
        if (n == 2)
            z(1) = x;
        end
        end
        y = y + b(n) * z(n);
    end
end


function output = myCIC(input, decimate_factor, num_stages, delay)
    % Initialize state variables
    state = zeros(1, num_stages);

    % Main loop
    for i = 1:length(input)
        % CIC filter core operations
        state(1) = input(i) + state(1);
        for j = 2:num_stages
            state(j) = state(j - 1) + state(j);
        end

        % Comb stage
        if mod(i, decimate_factor) == 0
            output(i / decimate_factor) = state(num_stages);
            if i >= decimate_factor * num_stages
                state(num_stages) = state(num_stages) - state(1);
            end
        end

        % Differential delay
        if i > delay
            state(num_stages) = state(delay);
        end
    end
end