x_in = [1 2 3 4 5 6 7 8 9 10];
h_in = [10 9 8 7];
out = zeros(1,length(x_in)+length(h_in)-1);
for k=1:(length(x_in))
    out(1,k) = my_fir_filter(x_in(k), h_in);
end
disp(out);
disp(conv(x_in, h_in));

function y = my_fir_filter(x, h)
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
