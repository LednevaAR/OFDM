function Tx_OFDM_symbols = OFDM_Mod(Tx_IQ_points, N_fft, N_carrier)
    Tx_OFDM_symbols = zeros(numel(Tx_IQ_points) / N_carrier, N_fft);
    for i = 1 : numel(Tx_IQ_points) / N_carrier
        Tx_IQ = Tx_IQ_points((i - 1) * N_carrier + 1 : i * N_carrier);
        Tx_OFDM_symbols(i, 1 : end) = ifft(Tx_IQ, N_fft);
    end
end