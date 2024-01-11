
%% Create Random Noise Signal

noise = rand(1, 10000);


%% LMS Filter Update

filt_length = 32;
wts = zeros(1, filt_length);  %set initial filter weights to 0 of length 32
leakage = 1;
mu = 0.1;

y = zeros(1, length(noise));

for k = 1:(length(noise))
    y(k) = fir_filter(noise(k), wts);
    f = mu*(noise(k)-y(k))*noise(k);
    for i = 1:filt_length-1
        wts(i) = leakage*wts(i+1) + f;
    end
end

disp(y)

function y = fir_filter(x, h)
    persistent temp len_impulse; % Persistent internal filter memory
    if isempty(temp)
        len_impulse = length(h);
        temp = zeros(size(h)); % Initialize to zero
    end
    y = 0;
    for n=len_impulse:-1:1
        if (n >= 2)
            %shift
            temp(n) = temp(n-1);
            if (n == 2)
                temp(1) = x;
            end
        end
        y = y + h(n) * temp(n);
    end
end

