---
slug: "getting-started-mixture-experiments"
aliases: ["/blog/getting-started-mixture-experiments/"]
title: "Getting started with mixture experiments"
date: "2025-08-05"
lastmod: "2026-04-02"
summary: "An introduction to mixture experimental design through a polymer
    yarn formulation example: simplex lattice design, Scheffé polynomials,
    response surface interpretation, and software recommendations."
description: "Mixture experiments handle formulations where component
    proportions must sum to 1. A worked polymer yarn example covers
    simplex lattice design, Scheffé polynomials, and response surface
    modeling, followed by software recommendations for R, Python, and
    commercial tools."
tags: ["materials-science","design-of-experiments"]
math: true
---

## What are mixture experiments?

Design of experiments (DOE) provides many tools for studying physical
systems. All share the goal of efficiently identifying how specific
variables (*factors*) control the properties (*responses*) of a system.
**Factorial designs** and **fractional factorial designs** are two
well-known approaches, but they assume that factors can be varied
independently. In many chemical systems, this assumption fails.

**Mixtures** are one such case. The response depends on the relative
proportions of the ingredients, not on their absolute quantities. This
constraint applies to pharmaceutical formulations, glass development,
polymer blends, food products --- any system where the components'
proportions must sum to 1. **Mixture designs** are built specifically
for these systems.

## A simplex example

The following example, adapted from John Cornell's "A Primer on
Experiments with Mixtures," shows what a simple mixture design and
analysis looks like. Suppose you produce a polymer-based yarn used
for draperies and want to improve its toughness.

Your current formulation is a blend of polyethylene (PE) and
polypropylene (PP). A colleague suggests that substituting
polypropylene with polystyrene (PS) might help. You want to know if
and how this substitution affects the yarn's mechanical properties, and
you want an efficient way to find out.

### Planning and designing the experiments

First, you need to choose a property that you can measure --- your response
variable \(y\). You decide to take a closer look at the elongation of fibers
produced with different polymer blends, which measures how much you can
lengthen your fibers before they break.[^1]

[^1]: This is where domain knowledge matters. Measuring the fibers' color
    would tell you nothing about toughness. The choice looks obvious here,
    but picking the right response becomes non-trivial for more complex or
    completely new systems.

Next, you need to plan your experiments (in DOE terminology: you need to plan
your *experimental runs*). How are you going to vary the proportions of PE, PP,
and PS? You need to ensure that you cover the experimental region while
minimizing the number of experiments that you'll run.

Mixture designs are built for situations where the components must sum
to a constant --- typically 100% or 1. The experimental space is
represented using simplex-based geometries (triangular for 3
components, tetrahedral for 4, etc.) and each experimental run is
optimally placed inside the simplex, ensuring that the compositional
space is properly explored.

The simplest mixture design is the **Simplex Lattice Design (SLD)**. In this
type of design, each *factor* (in this case, PE, PP, and PS) can take \(m+1\)
values (\(0, 1/m, 2/m, \dots, m/m\)) where \(m\) represents the number of
levels. A level is the specific value that a factor takes in a given
run. The value of \(m\) is also important for later
modeling, because it defines the order of the polynomial that can be fitted to
the data: \(m=1\) means you'll only be able to fit first order polynomials,
\(m=2\) second order, \(m=3\) third order, and so on.

You decide to keep it simple and explore only pure or binary blend
compositions, meaning that each factor is going to take two levels (\(m=2\)).
This setup includes three points for each component: 1 for a single-component,
0.5 for the binary blend, and 0 for blends that do not include that component.
This allows you to fit a second-order polynomial and see how pairs of
components interact.

Calculating the proportions and plotting them, the design looks like
this:

![SLD design](design_points.svg "Simplex Lattice Design (SLD) for a
three-component system. The triangle shows the entire compositional space
defined by the three components (polyethylene, polypropylene, and polystyrene).
The red dots indicate the experimental runs required to map the entire space.")

### Analyzing the results

You prepare the 6 polymer blends, spin them into yarns, and measure
their elongation. Using shorthand notation --- \(x_{1}\) for
polyethylene, \(x_{2}\) for polystyrene, \(x_{3}\) for polypropylene
--- and averaging three replicates per run, the results are:

| Design point | \(x_{1}\) | \(x_{2}\) | \(x_{3}\) | Average elongation |
|--------------|----------:|----------:|----------:|-------------------:|
| 1            | 1         | 0         | 0         | 11.7               |
| 2            | 1/2       | 1/2       | 0         | 15.3               |
| 3            | 0         | 1         | 0         | 9.4                |
| 4            | 0         | 1/2       | 1/2       | 10.5               |
| 5            | 0         | 0         | 1         | 16.4               |
| 6            | 1/2       | 0         | 1/2       | 16.9               |

At this point, you'll want to fit this data into a model that can be used to
extrapolate the behavior of the system. There is one problem, though. Consider
a standard polynomial with an intercept \(\beta_{0}\):

$$
y = \beta_{0} + \beta_{1}x_{1} + \beta_{2}x_{2} + \beta_{3}x_{3} + \dots
$$

Where \(\beta_{1}\), \(\beta_{2}\), and \(\beta_{3}\) are the regression
coefficients of each component. In mixture space, when all components approach
zero we have \(x_{1} \rightarrow 0\), \(x_{2} \rightarrow 0\), \(x_{3}
\rightarrow 0\). However, this violates the mixture constraint, since the sum
of all components \(\sum_{i} x_{i}\) must equal 1. There is no point
in mixture space where all \(x_{i} = 0\), so the intercept
\(\beta_{0}\) has no physical meaning.[^2]

[^2]: The mixture constraint creates perfect multicollinearity. If you know the
    values of \(q-1\) components in a \(q\)-component mixture, the last
    component is completely determined: \(x_{q} = 1 - \sum_{i=1}^{q-1} x_{i}\).
    This means that the design matrix is singular, and therefore the
    coefficients cannot be estimated through standard least squares.

The solution is to use Scheffé polynomials, special polynomial forms
that respect the mixture constraint. For a ternary
mixture system, the second-order Scheffé polynomial is:

$$
y = \beta_{1}x_{1} + \beta_{2}x_{2} + \beta_{3}x_{3} + \beta_{12}x_{1}x_{2} +
\beta_{13}x_{1}x_{3} + \beta_{23}x_{2}x_{3}
$$

Here, \(\beta_{1}\), \(\beta_{2}\), and \(\beta_{3}\) represent the expected
response when component 1, 2, and 3 respectively comprise 100% of the mixture,
whereas the terms \(\beta_{12}\), \(\beta_{13}\) and \(\beta_{23}\) represent
binary interactions. These latter terms have physical meaning and represent
synergistic or antagonistic effects between components.

The fitted model becomes:

$$
y = 11.7 \cdot x_{1} + 9.4 \cdot x_{2} + 16.4 \cdot x_{3} + 19.0 \cdot
x_{1}x_{2} + 11.4 \cdot x_{1}x_{3} -9.6 \cdot x_{2}x_{3}
$$

With six experiments, you now have a model that describes the
elongation for **any binary blend** of the three polymers. Plotting the
model over the simplex shows the full picture:

![Polymer response surface](rsm_contour.svg "Response surface modeled on the
collected data")

This type of visualization is called a **response surface**. It shows
how a response (the elongation) changes across the entire
compositional space. Each point within the triangle represents a unique
three-component composition, while the distances from the three sides
correspond to the proportions of each component. The contour lines show predicted elongation values, revealing trends
that would not be obvious from the raw data alone.

The results show that your colleague's intuition was partially right.
The PE-PS combination has a strong synergistic effect: the binary blend
achieves 15.3 elongation, 45% higher than the simple average of the
pure components (10.55). But in absolute terms, the PE-PP blend still
wins. The highest elongation values (16-17 range) occur along the PE-PP
edge, with the maximum near the 50:50 PE:PP blend (16.9 from design
point 6). PS-PP combinations show antagonistic behavior, particularly
in the lower-right region of the triangle.

The model provides clear guidance for optimization. If maximum
elongation is the primary goal, aim for compositions between 40-60% PE
and 40-60% PP with minimal PS content. If other considerations require
PS, keep it below 20% while maintaining high PE content to take
advantage of the PE-PS synergy. The relatively flat response surface
around the PE-PP optimum also suggests these formulations will be
robust to minor mixing variations during production.

## Where to learn more

This example covered the simplest case. Several important topics were
left out:

- Modeling ternary interactions.
- Designing experiments with more than three mixture components.
- Restricting the experimental region by adding further constraints.
- Coupling mixture designs with process factors.

The following resources cover these and more.

> [!note]
> I am not affiliated with any of the following publishers or software companies.

### Books

- **"Experiments with Mixtures" by John Cornell**
  ([10.1002/9781118204221](https://doi.org/10.1002/9781118204221)): The most
  thorough reference on mixture designs available. Published in 2002 and
  showing its age in some aspects, but still unmatched in depth. Assumes
  strong statistical foundations; some chapters are heavily mathematical.
- **"A Primer on Experiments with Mixtures" by John Cornell**
  ([10.1002/9781118204221](https://doi.org/10.1002/9781118204221)): Cornell's
  shorter, more accessible version of the above. Covers much of the same
  content in a more direct way.
- **"Formulation Simplified" by Mark Anderson, Patrick Whitcomb, and Martin
  Bezener** ([10.4324/9781315165578](https://doi.org/10.4324/9781315165578)):
  A hands-on introduction aimed at practitioners who want to get started
  without heavy mathematical detail. Published 2018.
- **"Response Surfaces, Mixtures, and Ridge Analyses" by George Box and Norman
  Draper** ([10.1002/0470072768](https://doi.org/10.1002/0470072768)): Covers
  advanced response surface modeling topics. Not limited to mixture designs,
  but useful for complex systems.
- **"Design and Analysis of Experiments" by Douglas Montgomery** ([Link to
  publisher
  website](https://www.wiley.com/en-us/Design+and+Analysis+of+Experiments%2C+10th+Edition-p-9781119492443))
  and **"Design and Analysis of Experiments" by Angela Dean, Daniel Voss, and
  Danel Draguljić**
  ([10.1007/978-3-319-52250-0](https://doi.org/10.1007/978-3-319-52250-0)):
  Both these books provide broad and thorough introductions to DOE
  fundamentals, from planning to designing and modeling. Among the various
  approaches, they also include short chapters on the basics of mixture
  experiments.

### Software

There are two main options for running mixture analyses, each with
different tradeoffs between ease-of-use and cost:

1. A proprietary DOE program with a graphical interface.
2. R or Python with dedicated libraries.

#### Commercial solutions

Several GUI-based DOE platforms support mixture designs:

- [Minitab](https://www.minitab.com/en-us/),
- [Design-Expert](https://www.statease.com/software/design-expert/)
- [SPSS](https://www.ibm.com/products/spss)
- [JMP](https://www.jmp.com/en/home)
- [SAS](https://www.sas.com)
- [NCSS](https://www.ncss.com)

These are GUI-based statistical platforms with built-in DOE
functionality. Each has a learning curve, but they are generally
straightforward to use once set up.

I avoid this kind of software for two reasons:

1. *They're expensive*. For example, at the time of writing a single one-year
   license subscription for Design-Expert costs 1140 USD, while a single
   one-year license subscription for Minitab is priced at 1851 USD.
2. *They provide black-box solutions*. Being closed-source means you can't
   inspect what a certain function in the program actually does. This might not
   be a concern for you now, but it might be in the future when you need to
   understand exactly how a result was obtained.

#### Free coding alternatives

Everything these programs do can be replicated in code, with greater
flexibility and full reproducibility. For mixture designs, the two
main options are **R** ([R Project](https://www.r-project.org)) and
**Python** ([Python.org](https://www.python.org)).

R was built for statistics; Python is a general-purpose language that
has become a standard for data analysis. The tradeoff is
straightforward: full control over the analysis, at the cost of
learning to program. Both provide dedicated libraries that cover most
of what commercial software offers.

- R libraries: R has a
  [mature DOE ecosystem](https://cran.r-project.org/web/views/ExperimentalDesign.html).
  For mixture work specifically, the `mixexp` package
  ([documentation](https://cran.r-project.org/web/packages/mixexp/index.html),
  [JSS article](https://www.jstatsoft.org/article/view/v072c02)) handles
  design generation, analysis, and basic response surface plots. All plots
  and analyses in this post were done in R using `mixexp` and the
  `Ternary` package
  ([documentation](https://ms609.github.io/Ternary/)).
  The [R script used for this post](cornell-plot.R) is available.
- Python libraries: Python's DOE ecosystem is less developed than R's
  for mixture designs. The available options:
  - [DoEgen](https://github.com/sebhaan/DoEgen): The most complete
    Python DOE library, actively developed.
  - [dexpy](https://github.com/statease/dexpy): Based on Design-Expert,
    developed by Stat-Ease. Supports SLD, simplex-centroid designs, and
    D-optimal designs. Not updated since 2018.
  - [ExperimentsPyDesign](https://github.com/JosiahMcMillan/ExperimentsPyDesign):
    Covers various experimental designs, though mixture support is
    limited to simple SLD.

The polymer yarn example used six runs to map an entire ternary
compositional space. Traditional one-factor-at-a-time (OFAT)
approaches would need far more experiments and still miss the
interaction effects that drove the key findings.
