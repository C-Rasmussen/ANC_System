fs_pdm = 3.072e6;       % PDM sample rate (3.072 MHz)
fs_pcm = 48e3;          % Desired PCM sample rate (48 kHz)
decimation_factor = fs_pdm / fs_pcm; % Decimation factor = 64
create_sound()

% Generate a random PDM signal 
%pdm_signal = randi([0, 1], 1, 1e6); % 1 million PDM samples
fileID = fopen('pdm_audio.wav', 'rb');
pdmSignal = fread(fileID, 'ubit1');
%close(fileID);

%order = 64, stopFs = 24kHz, passFs = 20KHz
impulse_response = [
    0.0016 0.0017 0.0019 0.0021 0.0025 0.0030 0.0036 0.0044 0.0052 ...
    0.0061 0.0072 0.0083 0.0095 0.0108 0.0121 0.0135 0.0150 0.0165 ...
    0.0179 0.0194 0.0208 0.0222 0.0236 0.0248 0.0260 0.0271 0.0280 ...
    0.0289 0.0296 0.0301 0.0305 0.0307 0.0308 0.0307 0.0305 0.0301 ...
    0.0296 0.0289 0.0280 0.0271 0.0260 0.0248 0.0236 0.0222 0.0208 ...
    0.0194 0.0179 0.0165 0.0150 0.0135 0.0121 0.0108 0.0095 0.0083 ...
    0.0072 0.0061 0.0052 0.0044 0.0036 0.0030 0.0025 0.0021 0.0019 ...
    0.0017 0.0016 ...
];
% lowpass_filter = fir1(64, 24000/ (3.072e6 / 2));
% display(lowpass_filter)
% filtered_signal = filter(impulse_response, 1, pdm_signal);

filtered_signal = zeros(1, length(pdm_signal));
for i = 1:length(pdm_signal)
    filtered_signal(i) = myFIRfilter(pdm_signal(i), impulse_response);
end
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
audiowrite('output_total.wav', pcm_signal, 48000);

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



function create_sound()
    fs = 48000; 
    duration = 5; 
    %f = 1; % test the plots anf funciton
    f = 600; %went online to find a good freq
    t = 0:1/fs:duration-1/fs;
    audio_signal = sin(2*pi*f*t);
    
    pdm_bits = audio_signal > 0.5;
    audio_data = pdm_bits * 2 - 1; % Convert 1-bit PDM to -1/+1 format

    audiowrite('pdm_audio.wav', audio_data, fs);
    fid = fopen('pdm_data.bin', 'wb');
    fwrite(fid, pdm_bits, 'int8');
    fclose(fid);
    
    
    subplot(2, 1, 1);
    plot(t, audio_signal);
    title('Audio Signal');
    
    subplot(2, 1, 2);
    stairs(t, audio_data);
    title('PDM Signal');
    ylim([-0.1 1.1]);
end