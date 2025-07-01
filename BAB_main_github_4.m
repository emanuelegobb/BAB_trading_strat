%% BAB strategy monthly rebalance
% This script implements a Betting Against Beta (BAB) trading strategy
% with a core portfolio construction logic. Proprietary signal generation
% and its application for dynamic weighting have been removed for
% confidentiality purposes.

clc; clear;

% --- Data Loading (Update paths as needed for your environment) ---
% These files should be placed in the same directory as this script,
% or you should provide their full paths.
% Data is assumed to be daily simple returns for SP500 stocks.
T = readtable("Filtered_SP500_Returns_Corrected_3.csv");
dates_str = T{:,1};       
Data      = T{2:end,2:end};   % returns in Data

dates = datetime(dates_str(2:end), 'InputFormat', 'dd/MM/yyyy'); % Skip header

Data = Data(:,1:end-1); % Assuming last column is not data

% Fama & French Factors
Factors = xlsread("FF_Factors.xlsx"); % Daily factors
Rm = Factors(:,1); % Market excess return
rf = Factors(:,4); % Risk-free rate

Factors_monthly = xlsread("FF_monthly.xlsx"); % Monthly factors
Rm_monthly = Factors_monthly(:,1); % Monthly market excess return
SMB = Factors_monthly(:,2);
HML = Factors_monthly(:,3);
MOM = Factors_monthly(:,5);

BAB_factor_data = xlsread("BAB_2010_2024.xlsx"); % BAB factor from F&F or similar source
SP500_monthly_returns = xlsread("SP500_monthly_returns.xlsx");
SP500_monthly_returns = SP500_monthly_returns(13:end); % Adjusting for relevant period

%% Extract year and month for grouping
years = year(dates);
months = month(dates);
monthYearCodes = years * 100 + months; % e.g., 201401 for Jan 2014

% Find unique month-year codes and their indices
[yearMonth, ~, ic] = unique(monthYearCodes, 'stable');
monthEndIndices = accumarray(ic, (1:length(dates))', [], @max);
monthEndIndices = monthEndIndices(1:192); % Adjust based on your data length

%% Construction of Beta portfolios (rebalance monthly)
% This section constructs the BAB portfolio based on estimated betas.
% The proprietary signal generation and its dynamic application to weights
% have been removed for confidentiality. The weighting logic here reflects
% a more standard, non-timed BAB implementation.

count = 0;
stocks_count = zeros(1,180);
Hist_weights_long = [];
Hist_weights_short = [];
Betas_long_leg = [];
Betas_short_leg = [];

% Start from the 12th month to ensure enough historical data for beta estimation
start_month = 12; 
BAB_return_month = zeros(1, length(monthEndIndices) - start_month);

for m = start_month : length(monthEndIndices)-1
    i = monthEndIndices(m); % End of estimation month
    next_i = monthEndIndices(m+1); % End of next month (for calculating returns)
    count = count + 1;

    Betas_estimated = zeros(size(Data,2),1); % Stores estimated Beta

    % Determine estimation window length (1-year rolling window)
    if m == 12
        estimation_window = 252; % ~1 year of daily trading days
    else
        estimation_window = monthEndIndices(m) - monthEndIndices(m-12);
    end

    X = [ones(estimation_window,1), Rm(i-estimation_window+1:i)]; % Design matrix for regression

    % Estimate Betas for each stock
    for j = 1:size(Data,2)
        data_window = Data(i-estimation_window+1:i, j);
        % Ensure sufficient non-NaN data points for regression
        if sum(~isnan(data_window)) == estimation_window
            [b, ~, ~, ~, ~] = regress(data_window - rf(i-estimation_window+1:i), X);
            Betas_estimated(j) = b(2); % Store only the estimated beta
        else
            Betas_estimated(j) = NaN;
        end
    end

    % Remove NaNs (stocks with insufficient data)
    index = (1:size(Betas_estimated,1))';
    newMatrix = [index, Betas_estimated];
    nanMask = isnan(newMatrix(:, 2)); % Check for NaNs in the beta column
    filteredMatrix = newMatrix(~nanMask, :);
    
    finalMatrix = filteredMatrix; % No filtering based on confidence intervals (original BAB try)

    % Sort stocks by Beta to form long and short legs
    sortedMatrix = sortrows(finalMatrix, 2);
    stocks_count(count) = size(sortedMatrix,1);

    % Select stocks for long and short legs (equal halves)
    Long_leg_shares = sortedMatrix(1 : fix(stocks_count(count)/2),1); % Lowest beta stocks
    Short_leg_shares = sortedMatrix(end-fix(stocks_count(count)/2) + 1 : end,1); % Highest beta stocks
    
    % Calculate average betas for the long and short legs
    Beta_long = mean(sortedMatrix(1:fix(stocks_count(count)/2),2));
    Beta_short = mean(sortedMatrix(end-fix(stocks_count(count)/2) + 1 : end,2));
    Betas_long_leg(count) = Beta_long;
    Betas_short_leg(count) = Beta_short;

    % --- Proprietary Signal Logic Removed ---
    % The original script contained logic here for calculating and forecasting
    % a proprietary signal used for the last 4 years of the strategy.
    % --- Portfolio Weighting ---
    % Weights are constructed based on the inverse of beta for beta-neutrality,
    % as per the core BAB strategy. The dynamic scaling factor from the
    % proprietary signal has been removed.
    Weights_long = zeros(1,size(Data,2));
    Weights_short = zeros(1,size(Data,2));

    % Calculate weights for long and short positions
    % Long leg: inverse of Beta_long for leverage, equal weight per stock
    Weights_long(1,Long_leg_shares) = (1 / size(Long_leg_shares,1)) * (1 / Beta_long);
    % Short leg: inverse of Beta_short for de-leverage, equal weight per stock
    Weights_short(1,Short_leg_shares) = (-1 / size(Short_leg_shares,1)) * (1 / Beta_short);
    
    Hist_weights_long(:,count) = Weights_long';
    Hist_weights_short(:,count) = Weights_short';
    weights_check(:,count) = [sum(Weights_long)*Beta_long sum(Weights_short)*Beta_short];

    % --- Transaction costs ---
    if m == start_month
        TC_long = sum(abs(Weights_long)) * 0.0002; % 2 bp for long
        TC_short = sum(abs(Weights_short)) * 0.0003; % 3 bp for short
    else
        % Calculate transaction costs based on change in positions
        TC_long = sum(abs(Weights_long - Weights_long_TC)) * 0.0002;
        TC_short = sum(abs(Weights_short - Weights_short_TC)) * 0.0003;
    end
    Weights_long_TC = Weights_long; % Store current weights for next period's TC calculation
    Weights_short_TC = Weights_short;

    % --- Calculate Returns for next month ---
    % Data for the next month's returns (from i+1 to next_i)
    Data_clean = Data(i+1:next_i, :);
    Data_clean(isnan(Data_clean)) = 0; % Treat NaNs as zero returns (no investment in those stocks)
    rf_period = rf(i+1:next_i); % Risk-free rate for the period

    % Total return for the BAB portfolio
    BAB_returns_help = Data_clean * Weights_long' + Data_clean * Weights_short' - rf_period * (sum(Weights_long) - abs(sum(Weights_short)));
    BAB_returns_help_log = log(1 + BAB_returns_help); % Convert to log returns for summation

    % Aggregate monthly log return, adjusted for transaction costs
    BAB_return_month(1,count) = sum(BAB_returns_help_log) - log(1 + TC_short) - log(1 + TC_long);
end

% --- Wealth Calculation ---
Wealth = [100]; % Starting wealth
for i = 1:size(BAB_return_month,2)
    Wealth(i+1) = Wealth(i) * exp(BAB_return_month(i)); % Compound wealth
end

% --- Market Wealth (for comparison) ---
MKT_wealth = [100];
for i = 1:size(Rm_monthly,1)
    MKT_wealth(i+1) = MKT_wealth(i) * (1 + Rm_monthly(i));
end

% --- Plotting Wealth Progression ---
figure;
plot(Wealth);
hold on;
plot(MKT_wealth); % Plot market wealth for comparison
xlabel('Month');
ylabel('Wealth');
title('Base BAB Strategy Wealth (Monthly Rebalance) vs. Market');
legend('BAB Strategy', 'Market');
grid on;

% Convert BAB returns to simple returns for certain calculations
BAB_return_month_simple = exp(BAB_return_month)-1;

% --- Performance Metrics and Regressions ---
% Standard Deviation (Annualized)
fprintf('BAB Strategy Annualized Std Dev: %.4f\n', std(BAB_return_month_simple) * sqrt(12));
fprintf('Market Annualized Std Dev: %.4f\n', std(Rm_monthly) * sqrt(12));

% Annualized Returns (from log returns)
fprintf('BAB Strategy Annualized Return: %.4f\n', (exp(mean(BAB_return_month)) - 1) * 12);
fprintf('Market Annualized Return: %.4f\n', (exp(mean(log(1+Rm_monthly))) - 1) * 12);

% Sharpe Ratio (Annualized)
fprintf('BAB Strategy Annualized Sharpe Ratio: %.4f\n', ((exp(mean(BAB_return_month)) - 1)*12) / (std(BAB_return_month_simple) * sqrt(12)));
fprintf('Market Annualized Sharpe Ratio: %.4f\n', ((exp(mean(log(1+Rm_monthly))) - 1)*12) / (std(Rm_monthly) * sqrt(12)));

% Determine the common length for regression analysis
N_BAB_returns = length(BAB_return_month_simple);
% Adjust factor data to match the length of BAB_return_month_simple
% It's assumed that the loaded monthly factor data (Rm_monthly, SMB, etc.)
% has at least 'start_month + N_BAB_returns - 1' elements.
start_idx_for_factors = start_month; % Assuming factor data aligns from 'start_month'
end_idx_for_factors = start_month + N_BAB_returns - 1;

% Treynor Ratio (requires beta from regression)
% Ensure Rm_monthly is sliced to match the period of BAB_return_month_simple
[b_mkt, ~, ~, ~, ~] = regress(BAB_return_month_simple', [ones(length(BAB_return_month_simple),1) Rm_monthly]);
if size(b_mkt, 1) > 1 % Check if beta was estimated
    Treynor_ratio = ((exp(mean(BAB_return_month)) - 1)*12) / b_mkt(2);
    fprintf('BAB Strategy Treynor Ratio: %.4f\n', Treynor_ratio);
end

% Multi-factor regression (e.g., Fama-French + Momentum + BAB factor)
% The factor data is directly sliced to match the length of BAB_return_month_simple.
% This assumes that Rm_monthly, SMB, HML, MOM, BAB_factor_data loaded from Excel
% are long enough and that the segment from 'start_idx_for_factors' to 'end_idx_for_factors'
% corresponds to the period of BAB_return_month_simple.

X_factors_full = [ones(length(BAB_return_month_simple),1), Rm_monthly, SMB, HML, MOM, BAB_factor_data];
[b_full, ~, ~, ~, stats_full] = regress(BAB_return_month_simple', X_factors_full);

fprintf('\nRegression on Rm, SMB, HML, MOM, BAB:\n');
fprintf('Alpha (annualized): %.4f\n', b_full(1) * 12);
fprintf('MKT Coefficient: %.4f\n', b_full(2));
fprintf('SMB Coefficient: %.4f\n', b_full(3));
fprintf('HML Coefficient: %.4f\n', b_full(4));
fprintf('Momentum Coefficient: %.4f\n', b_full(5));
fprintf('BAB Coefficient: %.4f\n', b_full(6));
fprintf('R-squared: %.4f\n', stats_full(1));

% Regression on FF 3-Factor + Momentum (without BAB factor)
X_factors_no_bab = [ones(length(BAB_return_month_simple),1), Rm_monthly, SMB, HML, MOM];
[b_no_bab, ~, ~, ~, stats_no_bab] = regress(BAB_return_month_simple', X_factors_no_bab);

fprintf('\nRegression on Rm, SMB, HML, MOM:\n');
fprintf('Alpha (annualized): %.4f\n', b_no_bab(1) * 12);
fprintf('MKT Coefficient: %.4f\n', b_no_bab(2));
fprintf('SMB Coefficient: %.4f\n', b_no_bab(3));
fprintf('HML Coefficient: %.4f\n', b_no_bab(4));
fprintf('Momentum Coefficient: %.4f\n', b_no_bab(5));
fprintf('R-squared: %.4f\n', stats_no_bab(1));


% Maximum Drawdown
Maximum_Drawdown = 0;
for i = 1 : size( Wealth, 2 )
    High_Water_Mark = max( Wealth( 1 ,1:i ) );
    Drawdown = ( Wealth( 1, i ) - High_Water_Mark ) / High_Water_Mark;
    Maximum_Drawdown = min( Maximum_Drawdown, Drawdown );
end
fprintf('Maximum Drawdown: %.4f\n', Maximum_Drawdown);

% --- Risk Metrics: VaR and Expected Shortfall ---
% Sort returns for VaR and ES calculation
sorted_returns = sort(BAB_return_month_simple);
N_returns = length(sorted_returns);

% Historical VaR at 5% (1-month)
VaR_5pct = sorted_returns(ceil(N_returns * 0.05));
fprintf('\nHistorical VaR (5%%, Monthly): %.4f\n', VaR_5pct);

% Historical VaR at 1% (1-month)
VaR_1pct = sorted_returns(ceil(N_returns * 0.01));
fprintf('Historical VaR (1%%, Monthly): %.4f\n', VaR_1pct);

% Expected Shortfall at 5% (1-month)
% Average of returns worse than or equal to the 5% VaR
ES_5pct_indices = find(BAB_return_month_simple <= VaR_5pct);
ES_5pct = mean(BAB_return_month_simple(ES_5pct_indices));
fprintf('Expected Shortfall (5%%, Monthly): %.4f\n', ES_5pct);

% Expected Shortfall at 1% (1-month)
% Average of returns worse than or equal to the 1% VaR
ES_1pct_indices = find(BAB_return_month_simple <= VaR_1pct);
ES_1pct = mean(BAB_return_month_simple(ES_1pct_indices));
fprintf('Expected Shortfall (1%%, Monthly): %.4f\n', ES_1pct);


% --- Plots of ACF/PACF of returns ---
% Useful for analyzing strategy returns, not the proprietary signal
figure;
subplot(2,1,1);
autocorr(BAB_return_month_simple, 'NumLags', 20);
title('ACF of BAB Strategy Returns');

subplot(2,1,2);
parcorr(BAB_return_month_simple, 'NumLags', 20);
title('PACF of BAB Strategy Returns');

% Ljung-Box Q-test on returns (for serial correlation)
[h_lbq, p_lbq] = lbqtest(BAB_return_month_simple, 'Lags', [5, 10, 20]);
fprintf('\nLjung-Box Q-Test p-values for BAB Strategy Returns:\nLag 5: %.4f\nLag 10: %.4f\nLag 20: %.4f\n', p_lbq(1), p_lbq(2), p_lbq(3));

% Jarque-Bera test for normality of returns
[h_jb, p_jb] = jbtest(BAB_return_month_simple);
fprintf('Jarque-Bera Test for Normality of Returns: p-value = %.4f (H0: Normal Distribution)\n', p_jb);

% Histograms and QQ plots of returns
figure;
subplot(1,2,1);
histogram(BAB_return_month_simple, 50);
title('Histogram of BAB Strategy Returns');
subplot(1,2,2);
qqplot(BAB_return_month_simple);
title('QQ Plot of BAB Strategy Returns');