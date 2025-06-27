# BAB Strategy with Market-Neutral Overlay

A concise implementation of the **Betting-Against-Beta (BAB)** market-neutral equity strategy, extended with a **proprietary timing overlay**. Monthly rebalanced long/short portfolios on S\&P500 constituents (2010–2024). Signal logic is internal and not disclosed here.

---

## Strategy Logic

1. **Beta-Based Selection**: Long bottom 50% by estimated beta; short top 50%.
2. **Beta Neutralization**: Scale weights so portfolio beta ≈ 0.
3. **Monthly Rebalance**: Rolling 12-month beta estimates, transaction costs (2 bps long, 3 bps short).
4. **Timing Overlay**: Proprietary internal signal adjusts gross exposure (placeholder in code).

---

## Repository Structure

```
BAB-Timing-Strategy/
├── BAB_backtest.m                # MATLAB script for backtest
├── Investment_Proposal_Sanitized.md
├── data/                         # Input CSVs (returns, factor data)
├── figs/                         # Generated plots
├── requirements.txt              # (Optional) Python dependencies
└── README.md
```

---

## Performance & Risk Metrics (2010–2024)

| Metric                               | Base BAB   | With Overlay |
| ------------------------------------ | ---------- | ------------ |
| Annual Return                        | 3.7%       | 4.5%         |
| Annual Volatility                    | 10.4%      | 7.4%         |
| Sharpe Ratio                         | 0.35       | 0.62         |
| Max Drawdown                         | –19.5%     | –15.4%       |
| Beta vs Market                       | 0.09       | 0.00         |
| Jensen's Alpha (Fama-French + Mom)   | 0.36%      | 4.8%         |
| Historical VaR (5%, Monthly)**     | –4.58%** | –3.21%**   |
| Historical VaR (1%, Monthly)**     | –7.46%** | –5.22%**   |
| Expected Shortfall (5%, Monthly)** | –6.60%** | –4.22%**   |
| Expected Shortfall (1%, Monthly)** | –9.94%** | –5.42%**   |

---

## Quickstart

1. **Clone & Setup**

   ```bash
   git clone https://github.com/YOUR_USERNAME/BAB-Timing-Strategy.git
   cd BAB-Timing-Strategy
   # For MATLAB: open BAB_backtest.m
   # For Python (optional):
   pip install -r requirements.txt
   ```

2. **Prepare Data**

   * Place your CSVs (e.g., `SP500_returns.csv`, `FF_factors.csv`) in `data/`.
   * Ensure the script’s `DATA_DIR` points to `./data/`.

3. **Run Backtest**

   * In MATLAB: `run('BAB_backtest.m')`.
   * Placeholder function `generate_proprietary_signal()` outputs dummy signals for overlay integration.

4. **Inspect Outputs**

   * Equity curves and risk metrics in `figs/`.
   * Detailed results in the console and exported tables.

---

## Disclosure

* **No proprietary signal details**: Exposure timing logic is stubbed in the public version.
* **Out-of-sample test**: Overlay metrics reflect rolling validation.

---

## Contact

Emanuele Gobbato
[LinkedIn](https://www.linkedin.com/in/emanuele-gobbato/)
Email: emanuelegobbato@outlook.com

