load short_modem_rx.mat

% The received signal includes a bunch of samples from before the
% transmission started so we need discard these samples that occurred before
% the transmission started. 

start_idx = find_start_of_signal(y_r,x_sync);
% start_idx now contains the location in y_r where x_sync begins
% we need to offset by the length of x_sync to only include the signal
% we are interested in
y_t = y_r(start_idx+length(x_sync):end); % y_t is the signal which starts at the beginning of the transmission


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Put your decoder code here
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c = cos(2*pi*f_c/Fs*[0:length(y_t)-1]');
y_c = y_t.*c;

f = linspace(-Fs/2*2*pi, 2*pi*Fs/2 - 2*pi*Fs/length(y_c), length(y_c));
plot(f, fftshift(abs(fft(y_c))))

%plot(y_c);

% LPF

x_d = conv(y_c, (f_c/Fs)*sinc((f_c/Fs)*[-1000:1000]'))/2;
x_d_down = downsample(x_d, 100);
above_thresh = find(abs(x_d_down) > 0.009);
start_point = above_thresh(1);
end_point = above_thresh(end);
x_d_cut = x_d_down(start_point+1:end_point+2);
%pad with 0s
%x_d_cut = [x_d_cut, zeros((8-mod(length(x_d_cut),8))*mod(length(x_d_cut)>0,8), 1)];

% convert to a string assuming that x_d is a vector of 1s and 0s
% representing the decoded bits
BitsToString(x_d_cut>0)

