clc; % чистка командного окна
close all; % закрыть дополнительные окна 
clear all; % очистить память
rng(1); % фиксирование начального состояния генератора случайных чисел Матлаба

%% 
% Конфигурация модели
% выбор созвездия
Register = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0];
constellation = "16-QAM"; % "BPSK"; % "QPSK"
File = 'HM1.jpg'; % Адрес файла
[Dictionary, D, ~] = constellation_func(constellation); % to-do lab 1
QAM_cells = length(Dictionary); % количество точек созвездия
N_carrier = 400;
N_fft = 1024;
T_guard = N_fft / 8;
Amount_OFDM_Frames = 60;
Amount_OFDM_Symbols_per_Frame = 5;
%%
%Передатчик
Input_Bit_Buffer = file_reader(File);
%disp(sum(Input_Bit_Buffer > 255))
Input_Bit_Buffer_Rand = Input_Bit_Buffer;
Input_Bit_Buffer_Rand = random(Input_Bit_Buffer, Register, Amount_OFDM_Frames);
Tx_IQ_points = mapping(Input_Bit_Buffer_Rand, constellation);
Tx_OFDM_symbols = OFDM_Mod(Tx_IQ_points, N_fft, N_carrier);
Tx_OFDM_Signal = signal_generator(Tx_OFDM_symbols, T_guard);
%%
%PAPR = 10 * log10(max(abs(Tx_OFDM_Signal) .^ 2) / mean(abs(Tx_OFDM_Signal) .^ 2));
%PAPR_slid_wind = compute_PAPR_slid_wind(Tx_OFDM_Signal, N_fft);
%[CCDF, PAPR_sorted] = compute_CCDF(PAPR_slid_wind);
%semilogy(PAPR_sorted, CCDF);
%%
Tx_OFDM_Signal = reshape(Tx_OFDM_Signal, numel(Tx_OFDM_Signal) / Amount_OFDM_Frames, Amount_OFDM_Frames)';
%%
%канал Lab 4-5 
% noiseData = Noise (Tx_OFDM_Signal, SNR); %lab 4 | добавление абгш
% freq_shifted_data = frequense_shift(noiseData, Freq_shift, N_fft,T_guard); % lab 4 | частотный сдвиг
% multi_data = multipath(freq_shifted_data,channel); % lab 4 | многолучевой прием
% time_shifted_data = delay(multi_data,Time_delay); % lab 4
Rx_OFDM_Signal = Tx_OFDM_Signal;
%%
%приемник
Rx_OFDM_Signal = conj(reshape(Rx_OFDM_Signal', 1, numel(Rx_OFDM_Signal)));
%Rx_OFDM_Signal = [Rx_OFDM_Signal(1 + T_guard : end), zeros(1, T_guard)]; %T_guard / 2, T_guard
Rx_OFDM_symbols = OFDM_Signal_Demod(Rx_OFDM_Signal, T_guard, N_fft);
for i = 1 : size(Rx_OFDM_symbols, 1)
    Rx_IQ(i, 1 : N_fft) = fft(Rx_OFDM_symbols(i, 1 : end), N_fft);
    Rx_IQ_points(i, 1 : N_carrier) = Rx_IQ(i, 1 : N_carrier);
end
Rx_IQ_points = conj(reshape(Rx_IQ_points', 1, numel(Rx_IQ_points)));
f = figure();
plot(1 : size(Rx_IQ, 2), abs(Rx_IQ(2, 1 : end)))
xlim([0 1024])
ylim([0 2])
title("Plot")
xlabel("Frequency")
ylabel("Amplitude")
grid on
saveas(f, "АЧХ.fig")
f = figure();
scatter(real(Rx_IQ_points), imag(Rx_IQ_points), "filled")
title("Plot")
xlabel("In-Phase")
ylabel("Quadrature")
xlim([-2 2])
ylim([-2 2])
[Dictionary, Bit_depth_Dict] = constellation_func(constellation);
Dict = name(constellation);
for i = 1:length(Dictionary)
    text(real(Dictionary(i)), imag(Dictionary(i)), '\leftarrow' + Dict(i));
end
grid on
saveas(f, "Const.fig")
Output_Bit_Buffer = demapping(Rx_IQ_points, constellation);
Output_Bit_Buffer_Derand = Output_Bit_Buffer;
Output_Bit_Buffer_Derand = random(Output_Bit_Buffer, Register, Amount_OFDM_Frames);
Probability = Error_check(Input_Bit_Buffer, Output_Bit_Buffer_Derand);
%%
Output_Buffer = num2str(reshape(Output_Bit_Buffer_Derand, numel(Output_Bit_Buffer_Derand) / 8, 8));
for i = 1 : size(Output_Buffer, 1)
    Output(i, 1 : 8) = regexprep(Output_Buffer(i, 1 : end), ' ', '');
end
Output = bin2dec(Output);
Output = Output';
Out = uint8(reshape(Output, 100, 200, 3));
imwrite(Out, 'image.jpg','jpg');
%%
Register = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0];
constellation = "16-QAM"; % "BPSK"; % "QPSK"
File = 'HM1.jpg'; % Адрес файла
[Dictionary, D, ~] = constellation_func(constellation); % to-do lab 1
QAM_cells = length(Dictionary); % количество точек созвездия
N_carrier = 400;
N_fft = 1024;
T_guard = N_fft / 8;
Amount_OFDM_Frames = 60;
Amount_OFDM_Symbols_per_Frame = 5;
%%
%Передатчик
Input_Bit_Buffer = file_reader(File);
%disp(sum(Input_Bit_Buffer > 255))
Input_Bit_Buffer_Rand = Input_Bit_Buffer;
Input_Bit_Buffer_Rand = random(Input_Bit_Buffer, Register, Amount_OFDM_Frames);
Tx_IQ_points = mapping(Input_Bit_Buffer_Rand, constellation);
Tx_OFDM_symbols = OFDM_Mod(Tx_IQ_points, N_fft, N_carrier);
Tx_OFDM_Signal = signal_generator(Tx_OFDM_symbols, T_guard);
%%
f = figure;
PAPR_rand = 10 * log10(max(abs(Tx_OFDM_Signal) .^ 2) / mean(abs(Tx_OFDM_Signal) .^ 2));
PAPR_slid_wind_rand = compute_PAPR_slid_wind(Tx_OFDM_Signal, N_fft);
[CCDF_rand, PAPR_sorted_rand] = compute_CCDF(PAPR_slid_wind_rand);
semilogy(PAPR_sorted_rand, CCDF_rand);
hold on
title("CCDF(PAPR)")
xlabel("PAPR, dB")
ylabel("CCDF")
semilogy(PAPR_sorted, CCDF);
saveas(f, "CCDF.fig")