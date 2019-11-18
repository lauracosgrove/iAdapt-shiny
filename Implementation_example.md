Trial implementation
================

Here we demonstrate how to use this package to implement and run an
actual trial. Only two functions are needed: one for each stage.

## Stage 1: Establish the safety profile for all initial doses.

The first stage requires only the calculation of the likelihood of
safety *for each dose*, based on observed binary toxicity (yes/no DLT).
The function takes as input the cohort size (equal number of patients
assigned at each dose, default is 3), number of DLTs observed, the
acceptable and unacceptable toxicity rates, and the likelihood threshold
value (default is 2). This function is used after enrolling each dose.

For example, suppose we have the following data for a dose. Do we
escalate to the next dose level, or declare this dose unsafe and move on
to stage 2?

``` r
library(iAdapt)
```

    ## Loading required package: shiny

    ## Loading required package: shinydashboard

    ## 
    ## Attaching package: 'shinydashboard'

    ## The following object is masked from 'package:graphics':
    ## 
    ##     box

    ## 
    ## Attaching package: 'iAdapt'

    ## The following object is masked from 'package:shiny':
    ## 
    ##     runExample

``` r
# Acceptable (p_yes) and unacceptable (p_no) DLT rates used for establishing safety
p_no <- 0.40                                     
p_yes <- 0.15    

# Likelihood-ratio (LR) threshold
K <- 2                                          

# Cohort size used in stage 1
coh.size <- 3 

# number of observed DLTs
x <- 1
```

``` r
LRtox(coh.size, x, p_no, p_yes, K)
```

    ## [1] "Safe/Escalate"

    ## $LR
    ## [1] 0.75

Based on this data, because LR=0.75 \> 1/2 (1/K) we would escalate to
the next dose. However, if we observed 2 DLTs instead of 1, we would not
because LR \< 1/2

``` r
LRtox(coh.size, x = 2, p_no, p_yes, K)
```

    ## [1] "Unsafe/Stop"

    ## $LR
    ## [1] 0.2

The program can be implemented for each dose to test its safety.

## Stage 2: Adaptive randomization based on efficacy outcomes.

Once we have determined which doses are safe, we can move on to stage 2
and begin collecting information about effectiveness. If only only one
dose was determined as safe in stage 1, then stage 2 will be omitted.
The function at stage 2 returns the updated randomization probabilities
and the dose allocation for the next enrolled patient, based on the
observed efficacies up to that point in the trial.

As input, this function requires a vector of observed efficacies (for
each patient) and a vector of the corresponding dose levels.

``` r
y.eff <- c(9, 1, 0, 34, 10, 27, 38, 42, 60, 75, 48, 62)
d.safe <- c(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4)
rand.prob(y.eff, d.safe)
```

    ## $Rand.Prob
    ## [1] 0.02037092 0.16578310 0.35098480 0.46286117
    ## 
    ## $Next.Dose
    ## [1] 4

In this example, the randomization probabilities for doses 1-4 are given
by $Rand.Prob, and the next patient will be enrolled on dose level 4.
