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
