# BAB_trading_strat

# BAB Strategy with Market-Neutral Overlay

This repository contains the implementation of a **market-neutral equity strategy** based on the classic **Betting-Against-Beta (BAB)** framework by Frazzini & Pedersen (2014), extended with a **proprietary timing overlay** that adjusts exposure dynamically based on internally estimated market signals.

The code backtests monthly-rebalanced long/short portfolios on S&P500 constituents from 2010 to 2024, with detailed metrics and visualizations of performance.

---

## 🧠 Strategy Logic

- Long low-beta stocks, short high-beta stocks.
- Position sizing scaled to neutralize portfolio beta.
- Rebalanced monthly using rolling 12-month windows.
- **Proprietary timing overlay** modulates exposure intensity based on internal signal.  
  *(Signal construction details are not disclosed in this public version.)*

---

## 📂 Repository Structure

BAB-Timing-Strategy/
├── BAB_backtest.m # Main MATLAB script
├── Investment_Proposal_Sanitized.md
├── data/ # Input data 
├── figs/ # Output plots
├── README.md

---


---

## 📈 Performance (Backtested: 2010–2024)

|                       | Base BAB | With Overlay |
|-----------------------|----------|--------------|
| Annual Return         | ~3.7%    | ~4.5%        |
| Annual Volatility     | ~10.4%   | ~7.4%        |
| Sharpe Ratio          | ~0.35    | ~0.62        |
| Max Drawdown          | ~–19.5%  | ~–15.4%      |
| Beta vs Market        | ~0.09    | ~0.00        |
| Jensen's Alpha (5F)   | ~0.36%   | ~4.8%        |

---

## 🛠️ How to Run

1. Place your cleaned factor & returns data into `/data/`.
2. Open `BAB_backtest.m` in MATLAB.
3. Run the script to generate:
   - Monthly alpha/beta estimates
   - Long/short weights
   - Portfolio returns and drawdown
   - Equity curve plots
   - (Placeholder) Signal-modulated exposure

> If you want to reproduce this in Python, porting is straightforward. Let me know and I can help set up the notebook.

---

## ❗ Disclosure

- This repo **does not include** the logic behind the proprietary signal used for exposure scaling (overlay).
- Performance shown in `/figs/` reflects out-of-sample overlays tested in rolling fashion.

---

## 📄 Investment Proposal

See [`Investment_Proposal_Sanitized.md`](./Investment_Proposal_Sanitized.md) for the theoretical foundation, design rationale, and results — redacted to protect the proprietary component.

---

## 📬 Contact

**Emanuele Gobbato**  
[LinkedIn](https://www.linkedin.com/in/emanuele-gobbato/)  
📫 Email available upon request

---

> _This repository is intended as a sample of academic-level quant research and portfolio implementation. It may serve as a conversation starter with asset managers, quant firms, or hedge funds._
