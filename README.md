# BAB Strategy Market-Neutral Backtest

A streamlined implementation of the classic **Betting-Against-Beta (BAB)** market-neutral equity strategy applied on the historical constituents of the SP500 equity index. This version uses a standard, non-timed BAB approach—proprietary timing logic has been removed for confidentiality.

---

## Core Workflow

1. **Data Loading**
   Daily simple returns and Fama–French factors are read from CSV or Excel files in `data/`.

2. **Beta Estimation**

   * Rolling 12‑month window of daily returns
   * OLS regression on market excess returns to estimate each stock’s beta
   * Skip stocks with insufficient data

3. **Portfolio Construction**

   * Rank stocks by beta each month
   * **Long** bottom 50%; **Short** top 50%
   * Scale weights inversely by leg-average beta to achieve beta ≈ 0
   * Apply transaction costs (2 bps long, 3 bps short)

4. **Monthly Rebalance & Return Calculation**

   * Compute monthly net log returns (including transaction costs and funding at the risk-free rate)
   * Aggregate to cumulative wealth

5. **Performance & Risk Metrics**

   * Annualized return, volatility, Sharpe ratio, max drawdown
   * Treynor and multi-factor regressions
   * **VaR** and **Expected Shortfall** at 5% and 1% monthly levels

6. **Diagnostics**

   * ACF/PACF plots
   * Ljung–Box and Jarque–Bera tests
   * Histograms and QQ plots of returns

---

## Performance & Risk Summary (2010–2024)

| Metric                             | Base BAB | With Signal |
| ---------------------------------- | -------- | ----------- |
| Annual Return                      | 3.7%     | 4.5%        |
| Annual Volatility                  | 10.4%    | 7.4%        |
| Sharpe Ratio                       | 0.35     | 0.62        |
| Max Drawdown                       | –19.5%   | –15.4%      |
| Beta vs Market                     | 0.09     | 0.00        |
| Jensen's Alpha (Fama-French + Mom) | 0.36%    | 4.8%        |
| Historical VaR (5%, Monthly)       | –4.58%   | –3.21%      |
| Historical VaR (1%, Monthly)       | –7.46%   | –5.22%      |
| Expected Shortfall (5%, Monthly)   | –6.60%   | –4.22%      |
| Expected Shortfall (1%, Monthly)   | –9.94%   | –5.42%      |

\---------------------------------------|----------------|
\| Annual Return                         | 3.7%           |
\| Annual Volatility                     | 10.4%          |
\| Sharpe Ratio                          | 0.35           |
\| Max Drawdown                          | –19.5%         |
\| Beta vs Market                        | 0.09           |
\| Jensen's Alpha (Fama-French + Mom)    | 0.36%          |
\| Historical VaR (5%, Monthly)          | –4.58%         |
\| Historical VaR (1%, Monthly)          | –7.46%         |
\| Expected Shortfall (5%, Monthly)      | –6.60%         |
\| Expected Shortfall (1%, Monthly)      | –9.94%         |

---

## Repository Structure

```
BAB-Timing-Strategy/
├── BAB_main_github_4.m          # Main MATLAB script
├── Data.zip                   # Input files: returns and factors
│   ├── Filtered_SP500_Returns_Corrected_3.csv
│   └── FF_factors.xls
│   └── ...
├── BAB_no_signal_wealth.jpg      #plot of wealth with base strategy
├── BAB_signal_wealth.jpg      #plot of wealth with trading signal last 4 years
├── README.md               # This file
└── .gitignore
```

---

## Quickstart Guide

1. **Clone the repo**

   ```bash
   git clone https://github.com/YOUR_USERNAME/BAB-Timing-Strategy.git
   cd BAB-Timing-Strategy
   ```

2. **Prepare data**

   * Place your returns and factor files in `Data.zip/`
   * Ensure filenames match those in `BAB_main_github_4.m` or update the paths within the script

3. **Run the backtest**

   * Open MATLAB and run:

     ```matlab
     run('BAB_main_github_4.m');
     ```

4. **View results**

   * Check the console for performance metrics and risk statistics
   * Inspect plots saved in `figs/`

---

## Contact

**Emanuele Gobbato**
[LinkedIn](https://www.linkedin.com/in/emanuele-gobbato/)
Email: emanuelegobbato@outlook.com


