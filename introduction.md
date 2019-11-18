
## Overview

This shiny app provides interactive simulation based on the early phase trial design by Chiuzan et al. (2018). Simulation and implementation functions are implemented in Stage 1 is safety-driven dose-escalation, and Stage 2 employs efficacy-driven randomization while continuing to monitor dose safety.

The design uses a likelihood paradigm, rather than rules. e.g. In Stage 1, when the likelihood ratio for a dose is greater than a prespecified threshold, the dose is considered acceptably safe and subsequent patients are enrolled on the next dose level. Conversely, if the likelihood ratio is less than or equal to the threshold, escalation is stopped.

One hallmark of this design is its ability to identify the most effective dose in the presence of a non-monotone dose-response curve - a phenomenon common in immunotherapies. Additionally, it follows a frequentist framework, but allows for adaptive design components.

The function of this software is two-fold:

* Produce trial outcomes through simulation for an inputted scenario, and

* Implement the design in a real trial.

## Background

This design is relevant in the face of a non-monotonous dose-response relationship - a phenomenon that most often seen in immunologic therapies. Additionally, the probabilistic nature (as opposed to rule-based) provides an advantage in identifying the optimal dose to carry forward in development, by allowing more than one dose to be examined for efficacy.

## Dose-response relationship

Often, dose-finding designs rely on a monotone dose-response curve, meaning that as dose increases, we expect the drug's effectiveness to increase too. This is a convenient assumption, though not always accurate. Instead, a relationship may exist in which case some dose-escalation designs may falsely move a higher dose forward.

## How to use 

1. Start at the __Simulation__ tab to simulate a single trial and explore parameter variations.

2. After simulating one trial, use the **Repeated Simulation** tab to examine the design's operating characteristics.

3. See **Implementation** for a vignette about how to use the iAdapt package to run this trial design in practice.

## References

[Chiuzan, C., Garrett-Mayer, E., & Nishimura, M. I. (2018). An Adaptive Dose-Finding Design Based on Both Safety and Immunologic Responses in Cancer Clinical Trials. Statistics in Biopharmaceutical Research, 10(3), 185–195.](https://doi.org/10.1080/19466315.2018.1462727)


[Chiuzan, C., Garrett-Mayer, E., & Yeatts, S. D. (2015). A likelihood-based approach for computing the operating characteristics of the 3+3 phase I clinical trial design with extensions to other A+B designs. Clinical Trials, 12(1), 24–33.](https://doi.org/10.1177/1740774514555585)

[Blume, J. D. (2002). Likelihood methods for measuring statistical evidence. Statistics in Medicine, 21(17), 2563–2599.](https://doi.org/10.1002/sim.1216)
