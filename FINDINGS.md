# Findings (matured loans only, unless noted)

## Q1. Portfolio
- 779,025 matured loans, $10.30B funded, $11.24B received back.
- Default rate 15.19%. Defaults cost $0.57B (amount lent minus everything repaid).
- Net return over the life of the loans: +9.18% on funded amount.

## Q2. Grade pricing
| Grade | Loans | Avg rate | Default | Return (life of loan) |
|---|---|---|---|---|
| A | 167,117 | 7.15% | 5.5% | 7.14% |
| B | 252,072 | 10.79% | 11.6% | 8.99% |
| C | 207,469 | 14.02% | 18.7% | 9.79% |
| D | 100,455 | 17.34% | 24.5% | 9.86% |
| E | 37,456 | 20.24% | 30.4% | 11.96% |
| F | 11,912 | 23.40% | 35.3% | 14.64% |
| G | 2,544 | 24.81% | 38.9% | 14.25% |
- Default risk rises 7x from A to G (5.5% to 38.9%).
- The apparent rise in return with grade is a **term-mix effect**: riskier grades hold more 60-month loans, which earn 5 years of interest. See Q2b for the fair comparison.

## Q2b. Grade pricing, 36-month loans only (like-for-like)
| Grade | Loans | Avg rate | Default | Return |
|---|---|---|---|---|
| A | 165,899 | 7.14% | 5.5% | 7.09% |
| B | 242,952 | 10.75% | 11.4% | **8.60% (peak)** |
| C | 185,191 | 13.85% | 18.4% | 8.06% |
| D | 85,557 | 17.20% | 24.0% | 7.31% |
| E | 24,968 | 19.88% | 29.7% | 5.24% |
| F | 5,318 | 23.50% | 34.4% | 3.55% |
| G | 921 | 25.01% | 41.2% | **0.08%** |
- **Key finding: risk is under-priced beyond grade B.** Grade G loans charge 25% interest but break even (0.08%) because 41% default. Grade A earns 89x more per dollar than G.
- Business action: raise rates or tighten approval for grades E to G, or cap their share of new lending.

## Q3. Term
- 60-month loans default at 25.4% vs 14.2% for 36-month (1.8x).
- Holds within every grade A to F: grade A 8.3% vs 5.5% (+51%), B 15.3% vs 11.4%. Only G reverses (small sample).
- 60-month return (18.59%) isn't comparable with 36-month (7.78%) because it covers 5 years of interest, not 3.

## Q4. Loan purpose
- Debt consolidation is 57% of loans (444,697) and **62.6% of all losses ($356.8M)**. With credit card refinancing, that's 82% of losses.
- Small business loans default the most: 24.6%, 1.6x the 15.2% average. Car loans default the least (12.1%).

## Q5. Borrower profile
- Income: default falls from 19.5% (<$40K) to 10.4% ($150K+), so the lowest earners default 1.9x as often.
- FICO: 18.1% (660-699) down to 4.7% (780+), a 3.9x gap. The <660 band has only 489 loans (Lending Club's minimum was about 660), so ignore it.
- DTI: default rises from 11.7% (DTI 0-10) to 21.3% (DTI 30+), 1.8x.

## Q6. Home ownership and employment
- Mortgage holders 13.0% vs renters 17.6%.
- Years employed barely matter (14.0% to 15.5% for 0 to 10 years). But borrowers with **no employment length given default at 21.4%**, 1.4x the average. Missing data is itself a risk signal.

## Q7. Income verification paradox
- Verified borrowers default at 18.3% vs 11.8% for Not Verified (55% more).
- Reason: Lending Club verified riskier applicants (avg rate 13.86% vs 11.19%).
- **Q7b confirms it holds within every grade**, so it isn't only grade mix. Grade C: 16.7% not verified vs 19.6% verified; grade F: 29.4% vs 35.8%. Verification marks applications Lending Club already found suspicious; it doesn't make them safer.

## Q8. Geography
- Highest default (states with 5K+ loans): AR 18.5%, AL 18.2%, NV 18.1%. NV has the lowest return of the top 10 (7.18%).
- The spread is small (about 3 points above the 15.2% average), so geography is a weak driver compared with grade, term and FICO.

## Q9. Growth and cohorts
- Volume grew from 603 loans ($5M) in 2007 to 375,545 loans ($5.5B) in 2015.
- 2008 loans (financial crisis) defaulted at 20.7%. After credit tightening, the 2009 cohort fell to 13.7%. Matured default stayed in a 14% to 16% band from 2009 to 2016.
- The drop in loans for 2016 to 2018 is **not** a real decline. Most of those loans are still Current and were excluded in cleaning. Don't present it as falling volume.

## Q10. Sub-grade returns
- No sub-grade lost money over the life of its loans.
- The rising returns across sub-grades in this all-terms table are inflated by 60-month loans (see Q2b). On like-for-like 36-month loans, return peaks at grade B and falls to break-even at G.
- Interest rates flatten at about 24-25% from F3 to G5 while defaults keep climbing to about 40%, so the top of the risk scale has no room left to price risk.
