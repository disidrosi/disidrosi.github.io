---
slug: "getting-started-mixture-experiments"
author: "Tobia Cavalli"
title: "Getting started with mixture experiments"
date: "2025-08-05"
lastmod: "2025-08-07"
summary: "Learn mixture experimental design through a complete polymer yarn
    formulation example covering planning, Scheffé polynomial analysis, and
    practical software recommendations for R, Python, and commercial tools."
description: "Learn the basics of mixture experimental design. Includes
    step-by-step polymer formulation example, Scheffé polynomials, response
    surface modeling, and software recommendations for R, Python, and
    commercial tools."
tags: [
    "design-of-experiments",
    "mixture-experiments",
    "materials-science",
    "response-surface-methodology"
]
categories: [
    "DOE",
    "materials science",
    "data analysis"
    
]
showTableOfContents: true
showDateUpdated: true
thumbnail: "*rsm_contour*"
---

{{< katex >}}

{{< lead >}}
This post is an introduction to mixture experimental design. I'll walk you
through a complete polymer yarn example, showing how to plan, analyze, and
interpret the results of a simple mixture design.

The second half covers practical resources including books, commercial
software solutions and open-source alternatives, helping you choose the right
tools for your projects.
{{< /lead >}}

## What are mixture experiments?

Design of experiments (DOE) gives us many tools to study physical systems. All
these tools share the goal of efficiently identifying and characterizing how
specific variables (also known as *factors*) control the properties (also known
as *responses*) of a system. **Factorial designs** and **fractional factorial
designs** are two well-known examples of experimental approaches, but many
chemical systems don't play well with these strategies.

**Mixtures** present one such situation. In these systems, the response depends
on the relative proportions of the ingredients, not on their absolute
quantities. This constraint applies to many scenarios from pharmaceutical
formulations to glass development --- basically any system where the
components' proportions must sum to 1.

For these systems, we can use **mixture designs**. These designs are less
discussed than conventional factorial methods, but they can be very effective
for studying many chemical systems.

## A simplex example

The following example from "A Primer on Experiments with Mixtures" by John
Cornell shows what a simple mixture design and analysis looks like. Suppose
you're in the textile business and one of your products is a polymer-based
yarn. This type of yarn is used to make draperies, and you want to develop a
new formulation that improves their toughness.

So far, you have always produced your yarns using only one type of polymer
blend. The blend is a mixture of polyethylene (PE) and polypropylene (PP), but
one of your colleagues suggests that substituting polypropylene with
polystyrene (PS) might improve toughness. Clearly, you want to know if and how
this substitution affects the yarn's mechanical properties, but what would be
an efficient way to get a clear understanding of this effect?

### Planning and designing the experiments

First, you need to choose a property that you can measure --- your response
variable \\(y\\). You decide to take a closer look at the elongation of fibers
produced with different polymer blends, which measures how much you can
lengthen your fibers before they break.[^1]

[^1]: This is where domain knowledge becomes crucial. It would make very little
    sense to measure the fibers' color, when all you really care about is how
    tough they are. The choice might look obvious in this example, but picking
    the right response quickly becomes non-trivial when you need to study more
    complex (or completely new) systems.

Next, you need to plan your experiments (in DOE terminology: you need to plan
your *experimental runs*). How are you going to vary the proportions of PE, PP,
and PS? You need to ensure that you cover the experimental region while
minimizing the number of experiments that you'll run.

Here's where mixture designs come into play. These designs are specifically
developed for situations where the components must sum to a constant ---
typically 100% or 1. The experimental space is represented using simplex-based
geometries (triangular for 3 components, tetrahedral for 4, etc.) and each
experimental run is optimally placed inside the simplex, ensuring that the
compositional space is properly explored.

The simplest mixture design is the **Simplex Lattice Design (SLD)**. In this
type of design, each *factor* (in this case, PE, PP, and PS) can take \\(m+1\\)
values (\\(0, 1/m, 2/m, \dots, m/m\\)) where \\(m\\) represents the number of
levels. A level is nothing more than the specific value that a factor is going
to take in a given run. The value of \\(m\\) is also important for later
modeling, because it defines the order of the polynomial that can be fitted to
the data: \\(m=1\\) means you'll only be able to fit first order polynomials,
\\(m=2\\) second order, \\(m=3\\) third order, and so on.

You decide to keep it simple and explore only pure or binary blend
compositions, meaning that each factor is going to take two levels (\\(m=2\\)).
This setup includes three points for each component: 1 for a single-component,
0.5 for the binary blend, and 0 for blends that do not include that component.
This approach will allow you to fit a second order polynomial and get an idea
of how two components interact with each other.

After calculating the relative proportions of each component and plotting them,
your experimental design looks like the following:

![SLD design](design_points.svg "Simplex Lattice Design (SLD) for a
three-component system. The triangle shows the entire compositional space
defined by the three components (polyethylene, polypropylene, and polystyrene).
The red dots indicate the experimental runs required to map the entire space.")

### Analyzing the results

Time to execute. You go to the lab, prepare your 6 polymer blends, spin them
into yarns and measure their elongation. Writing out the name of each component
quickly gets boring, so you introduce some notation: \\(x_{1}\\) for
polyethylene, \\(x_{2}\\) for polystyrene, and \\(x_{3}\\) for polypropylene. You
repeat each run three times and average the measured elongation, obtaining the
following results:

| Design point | \\(x_{1}\\) | \\(x_{2}\\) | \\(x_{3}\\) | Average elongation |
|--------------|----------:|----------:|----------:|-------------------:|
| 1            | 1         | 0         | 0         | 11.7               |
| 2            | 1/2       | 1/2       | 0         | 15.3               |
| 3            | 0         | 1         | 0         | 9.4                |
| 4            | 0         | 1/2       | 1/2       | 10.5               |
| 5            | 0         | 0         | 1         | 16.4               |
| 6            | 1/2       | 0         | 1/2       | 16.9               |

At this point, you'll want to fit this data into a model that can be used to
extrapolate the behavior of the system. There is one, problem though. Consider
a standard polynomial with an intercept \\(\beta_{0}\\):

$$
y = \beta_{0} + \beta_{1}x_{1} + \beta_{2}x_{2} + \beta_{3}x_{3} + \dots
$$

Where \\(\beta_{1}\\), \\(\beta_{2}\\), and \\(\beta_{3}\\) are the regression
coefficients of each component. In mixture space, when all components approach
zero we have \\(x_{1} \rightarrow 0\\), \\(x_{2} \rightarrow 0\\), \\(x_{3}
\rightarrow 0\\). However, this violates the mixture constraint, since the sum
of all components \\(\sum_{i} x_{i}\\) must equal 1. There's literally no point
in mixture space where all \\(x_{i} = 0\\), so the intercept \\(\beta_{0}\\) has no
physical meaning.[^2]

[^2]: The mixture constraint creates perfect multicollinearity. If you know the
    values of \\(q-1\\) components in a \\(q\\)-component mixture, the last
    component is completely determined: \\(x_{q} = 1 - \sum_{i=1}^{q} x_{i}\\).
    This means that the design matrix is singular, and therefore the
    coefficients cannot be estimated through standard least squares.

To solve this problem, you are going to use Scheffé polynomials. These are
special polynomial forms that respect the mixture constraint. For a ternary
mixture system, the second-order Scheffé polynomial is:

$$
y = \beta_{1}x_{1} + \beta_{2}x_{2} + \beta_{3}x_{3} + \beta_{12}x_{1}x_{2} +
\beta_{13}x_{1}x_{3} + \beta_{23}x_{2}x_{3}
$$

Here, \\(\beta_{1}\\), \\(\beta_{2}\\), and \\(\beta_{3}\\) represent the expected
response when component 1, 2, and 3 respectively comprise 100% of the mixture,
whereas the terms \\(\beta_{12}\\), \\(\beta_{13}\\) and \\(\beta_{23}\\) represent
binary interactions. These latter terms have physical meaning and represent
synergistic or antagonistic effects between components.

The linear model becomes:

$$
y = 11.7 \cdot x_{1} + 9.4 \cdot x_{2} + 16.4 \cdot x_{3} + 19.0 \cdot
x_{1}x_{2} + 11.4 \cdot x_{1}x_{3} -9.6 \cdot x_{2}x_{3}
$$

This is already a great result, because with just six experiments you obtained
a model that describes the elongation for **any binary blend** obtained by
mixing the three polymers. But there's more. You can go one step further and
plot the model over the simplex, like so:

![Polymer response surface](rsm_contour.svg "Response surface modeled on the
collected data")

This type of visualization is called **response surface**, and it allows to
easily understand how a response (the elongation) changes throughout the entire
compositional space. Each point within the triangle represents a unique
three-component composition, while the distances from the three sides
correspond to the proportions of each component. The contour lines show
predicted elongation values, highlighting trends that wouldn't be obvious from
the raw experimental data.

You can see that your colleague was absolutely correct about the benefits of
substituting polypropylene with polystyrene. However, this is true only under
specific conditions. The highest elongation values (16-17 range) occur along
the PE-PP edge, with the maximum near the 50:50 PE:PP blend (16.9 elongation
from design point 6).

The PE-PS combination also shows strong synergistic effects: the binary blend
achieves 15.3 elongation, which is 45% higher than the simple average of the
pure components (10.55). However, PS-PP combinations show antagonistic
behavior, particularly in the lower-right region of the triangle.

What's important is that this model provides clear guidance for optimizing your
yarn properties. If maximum elongation is your primary goal, aim for
compositions between 40-60% PE and 40-60% PP with minimal PS content. If other
considerations require PS incorporation, keep it below 20% while maintaining
high PE content to leverage the beneficial PE-PS interactions. The relatively
flat response surface around the PE-PP optimum also suggests these formulations
will be more robust to minor mixing variations during production.

## Where to learn more

The previous example barely scratched the surface of everything there is to
know about mixture designs and models. For example, some very important topics
that I haven't considered here are:

- Modeling ternary interactions.
- Designing experiments with more than three mixture components.
- Restricting the experimental region by adding further constraints.
- Coupling mixture designs with process factors.

If you're interested in learning more about this topic and designing your own
mixture experiments, below you'll find some resources to get you started.

{{< alert >}}
I am not affiliated with any of the following publishers or software companies.
{{< /alert >}}

### Books

- **"Experiments with Mixtures" by John Cornell**
  ([10.1002/9781118204221](https://doi.org/10.1002/9781118204221)): If you are
  looking for a comprehensive reference on mixture designs and their analysis,
  this is what you need. This book was published in 2002 and starts to show its
  age in some aspects, but it's still by far the most thorough resource
  available on the topic. It covers everything you need to know to start
  designing and analyzing mixture experiments on your own, but be warned: this
  is not a book for the faint-hearted. It assumes you have a very good grasp of
  fundamental statistics, and some chapters can be quite math-heavy.
- **"A Primer on Experiments with Mixtures" by John Cornell**
  ([10.1002/9781118204221](https://doi.org/10.1002/9781118204221)): Cornell
  published a second book, which provides a gentler introduction. This book
  presents much of the same content from "Experiments with Mixtures", just in a
  shorter and more direct way.
- **"Formulation Simplified" by Mark Anderson, Patrick Whitcomb, and Martin
  Bezener** ([10.4324/9781315165578](https://doi.org/10.4324/9781315165578)):
  This book is a hands-on introduction to mixture experiments. It is aimed at
  an audience that is interested in quickly getting started without dwelling
  too much on the mathematical details. The book is also relatively recent, as
  it was published in 2018.
- **"Response Surfaces, Mixtures, and Ridge Analyses" by George Box and Norman
  Draper** ([10.1002/0470072768](https://doi.org/10.1002/0470072768)): This
  book covers many advanced topics related to response surface modeling.
  Although not limited to mixture designs, it can be very useful when dealing
  with complex systems.
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

Let's say you are ready to crunch some numbers. Where do you start? You have
two main options, each with different tradeoffs between ease-of-use and cost:

1. Buy a license for a proprietary DOE program.
2. Use R or Python and do some programming.

#### Commercial solutions

If you're looking for an all-in-one solution with a graphical interface, you
have several options:

- [Minitab](https://www.minitab.com/en-us/),
- [Design-Expert](https://www.statease.com/software/design-expert/)
- [SPSS](https://www.ibm.com/products/spss)
- [JMP](https://www.jmp.com/en/home)
- [SAS](https://www.sas.com)
- [NCSS](https://www.ncss.com)

If you've never used any of these programs, think of them like Microsoft Excel
on steroids. Like with everything else, there's going to be a learning curve to
overcome with each of them. However, they are typically straightforward to use.

I am not a fan of using this kind of software for two fundamental reasons:

1. *They're expensive*. For example, at the time of writing a single one-year
   license subscription for Design-Expert costs 1140 USD, while a single
   one-year license subscription for Minitab is priced at 1851 USD.
2. *They provide black-box solutions*. Being closed-source means you can't
   inspect what a certain function in the program actually does. This might not
   be a concern for you now, but it might be in the future when you need to
   understand exactly how a result was obtained.

#### Free coding alternatives

All functionality provided by paid software can be replicated using programming
languages. Coding your own analyses gives you greater flexibility and provides
better reproducibility, since you're not locked into using proprietary
software. When it comes to mixture designs, there are two main options that I
am aware of: **R** ([see R Project](https://www.r-project.org)) and **Python**
([see Python.org](https://www.python.org)).

Both R and Python are free, open-source, and versatile programming and
scripting languages. R was developed specifically for statistics and data
analysis, while Python is a general-purpose language that has become the de
facto standard for data analysis, thanks to its ease of use and relatively
simple syntax.

The upside of using one of these languages for your experimental design and
analysis is that you are in full control over what you do and how. The downside
is that you need to learn how to program, which takes time and for many people
might not be that straightforward to do (hence why there are paid programs
available).

However, you don't actually need much to get started. Both programming
languages provide dedicated libraries that allow you to do a lot (if not more)
of what is possible in specialized software, from generating experimental
designs to analyzing results.

- R libraries: The DOE library ecosystem available in R is very mature and
  provides [anything you can think
  of](https://cran.r-project.org/web/views/ExperimentalDesign.html). Within
  this large selection, R also includes a fantastic "little" package called
  `mixexp` ([see package
  documentation](https://cran.r-project.org/web/packages/mixexp/index.html) and
  associated [article published on Journal of Statistical
  Software](https://www.jstatsoft.org/article/view/v072c02)). With it, you can
  design both simple and advanced mixture designs, analyze the results of your
  experiments, and even plot some basic response surfaces. If you're wondering:
  All the plots and analyses in this post were done in R using `mixexp` and the
  `Ternary` package ([see Ternary
  documentation](https://ms609.github.io/Ternary/)).
- Python libraries: I love Python. However, when I compare it to R in the
  context of generating experimental designs, there seems to be no game at all.
  Nonetheless, the following libraries allow doing some basic mixture designs:
  - [DoEgen](https://github.com/sebhaan/DoEgen): Probably the most complete DOE
    library out there which is also being actively developed.
  - [dexpy](https://github.com/statease/dexpy): Library based on Design-Expert,
    developed by Stat-Ease. Includes functions for generating SLD and
    simplex-centroid designs (CSD), as well as functions for producing
    D-optimal designs. However, the project has not been updated since 2018.
  - [ExperimentsPyDesign](https://github.com/JosiahMcMillan/ExperimentsPyDesign):
    Interesting project that contains various functions for generating
    experimental designs, although mixture designs are limited to simple SLD.

## Conclusions

Mixture experiments provide a powerful framework for optimizing formulations
where component proportions are the key variables. The Scheffé polynomials and
simplex designs might initially seem complex, but the practical benefits are
clear: fewer experiments, better understanding of component interactions, and
clear direction for further development.

The key is to start experimenting with these methods on your own systems. The
polymer yarn example shows that even a simple six-run design can give insights
that would be difficult to obtain through traditional one-factor-at-a-time
(OFAT) approaches.

Remember that the choice of response variables and experimental constraints
will largely determine the success of your optimization efforts. Domain
knowledge remains central for interpreting results and translating statistical
models into practical guidelines.
