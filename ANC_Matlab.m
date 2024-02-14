
%% Create Random Noise Signal

noise = rand(1, 10000);
noise = noise - 0.5;

noise(1) = -0.09739685;
noise(2) = -0.3682251;
noise(3) = -0.332809;
noise(4) = 0.2197113;
noise(5) = -0.213791;
noise(6) = 0.0005951;
noise(7) = 0.116455;




%% LMS Filter Update

filt_length = 32;
wts = zeros(1, filt_length);  %set initial filter weights to 0 of length 32
leakage = 1;
mu = 0.1;
x = zeros(1, filt_length);
temp = zeros(1, filt_length);


y = zeros(size(noise));

for k = 1:(length(noise))
    y(k) = fir_filter(noise(k), wts);
    
    temp_x = zeros(size(x));
    temp_x(2:32) = x(1:(32-1));
    x = temp_x;
    x(1) = noise(k);
    e = noise(k) - y(k);
    wts = wts + (mu*e).*x;

end
y_inv = y .* -1;
error = noise + y_inv;

sound(error)
plot(error)
hold on
plot(noise)
plot(y_inv)
hold off
%stem(wts)


function y = fir_filter(x, h)
    persistent temp len_impulse; % Persistent internal filter memory
    if isempty(temp)
        len_impulse = length(h);
        temp = zeros(size(h));
    end
    y = 0;
    for n=len_impulse:-1:1
        if (n >= 2)
            %right shift
            temp(n) = temp(n-1);
            if (n == 2)
                temp(1) = x;
            end
        end
        y = y + (h(n) * temp(n));
    end
end
