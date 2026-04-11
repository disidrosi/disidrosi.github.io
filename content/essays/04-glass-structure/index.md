---
slug: "glass-structure-stability"
aliases: ["/blog/glass-structure-stability/"]
title: "The structure and metastability of glass"
date: "2024-10-27"
lastmod: "2026-04-11"
summary: "Glass is amorphous, metastable, and undergoes a gradual rather than
    sharp transition from liquid to solid. This post covers the structure, the
    thermodynamics, and the glass transition."
description: "What glass is, why it is metastable, and how it forms from a
    supercooled liquid. Covers the amorphous atomic structure, the
    thermodynamic state, the glass transition, and structural relaxation."
lead: "Glass is structurally disordered, thermodynamically out of equilibrium, and yet stable enough on human timescales to be a solid material in every practical sense. Its atoms occupy no lattice, and its molar volume, entropy, and free energy are all higher than those of the crystal of the same composition. Its transformation from liquid to solid happens over a range of temperatures rather than at a single point, and the temperature at which the structure stops responding to further cooling depends on how fast the cooling was."
tags: ["materials-science","glass"]
math: true
---

Glass is in windows, containers, optical fibers, lenses, and the substrates
of most electronic displays. Its atomic structure differs from that of most
solids: in crystals, atoms are arranged in a periodic lattice, but in glass
they are not.[^1] This disorder is the source of much of what is distinctive about
glass, including its gradual softening with temperature instead of a sharp
melting point and its isotropic mechanical response. Glass is also out of
thermodynamic equilibrium: its structure is slowly relaxing toward a more
stable arrangement, but the process is too slow to observe at ordinary
temperatures.

## Crystalline and amorphous solids

Solids fall into two structural categories: crystalline and amorphous. In
crystalline solids, such as diamond or metallic copper, atoms occupy a highly
ordered, repeating lattice. In amorphous solids, including glass, the atoms
are disordered, resembling a liquid frozen in place rather than a regular
lattice.[^2] [^3]

![Three drinking glasses, each containing one of the classical states of water (ice, liquid, vapor), with diagrams of atomic arrangement below.](states_of_matter.png "Three drinking glasses showing the three classical states of matter: ice (solid), water (liquid), and vapor (gas). The diagrams below show the atomic arrangement of each state: tightly packed in the solid, loosely arranged but still in contact in the liquid, and widely dispersed in the gas. Adapted from https://tinyurl.com/2svcj8dn")

The periodic arrangement gives crystalline solids two characteristic
properties. They have a sharp melting point: at the right temperature, the
entire lattice breaks down at once. They are also anisotropic, meaning their
mechanical properties depend on the direction of an applied force, because
some directions in the lattice are stronger than others.

Glass differs in both respects. Because there is no lattice to break, it does
not have a sharp melting point and softens gradually as temperature rises,
transitioning from rigid to fluid over a range. The disordered atomic
arrangement has no preferred direction, so glass is isotropic: its mechanical
properties are the same along every axis.

The contrast is sharpest in silica (\(\mathrm{SiO}_2\)). In its crystalline
form, silica is quartz, with a sharp melting point and anisotropic mechanical
properties. In its amorphous form, the same chemical composition produces a
glass with no melting point and isotropic properties.

![Side-by-side schematic of the atomic arrangement of amorphous silica (left, disordered) and crystalline silica or quartz (right, ordered).](silica_structure.png "Amorphous silica (left), the basis of most oxide glasses, contrasted with crystalline silica or quartz (right). The composition is identical, and only the atomic arrangement differs.")

Glass is not limited to silica. Many other substances, including metals and
polymers, can form amorphous structures when cooled rapidly enough to suppress
crystallization. What they all share is the absence of long-range order in the
atomic arrangement.

## Metastability

Glass is **metastable**: it sits in a local energy minimum that is not the
global minimum, but the energy barrier separating the two is too large to
cross under ordinary conditions. For almost any glass-forming substance, the
global minimum is a crystalline arrangement.[^4] [^5]

Crystallization requires atoms to settle into the periodic positions of a
lattice, and that takes time. When a melt is cooled fast enough, there is not
enough time for them to do so, and the resulting solid carries the disordered
arrangement it had in the liquid state. The faster the cooling, the more
frozen-in disorder.

Compared to a crystal of the same composition, a glass has a larger
**molar volume** (its atoms are not packed as tightly), higher **entropy**
(the disordered arrangement has more accessible microstates), and higher
**enthalpy** and **Gibbs free energy**. All of these reflect the same fact:
glass is in a higher-energy state, but the activation energy required to
reach the lower-energy crystalline state is too large to cross at ordinary
temperatures.

## The glass transition

The transformation from a glass-forming liquid into a glass is called the
**glass transition**, and the process of carrying it out (cooling a liquid
fast enough to bypass crystallization) is called **vitrification**. Unlike the
melting transition of a crystal, which happens at a single sharp temperature,
the glass transition is gradual: as a liquid is cooled, its viscosity rises,
and over some temperature range it becomes so viscous that, on the timescales
of observation, it stops flowing. The temperature at which this happens is
called the **glass transition temperature**, \(T_g\).[^3]

\(T_g\) is not a thermodynamic constant of the material but a quantity that
depends on the cooling rate. Faster cooling traps the atoms at a higher
temperature, before they have time to relax into lower-energy arrangements,
and produces a higher \(T_g\). Slower cooling gives them more time to relax
and produces a lower \(T_g\). The same substance can have different glass
transition temperatures depending on its thermal history.

![Phase diagram showing the four states of a glass-forming substance against temperature: liquid, supercooled liquid, glass, and crystal, with the melting temperature and glass transition temperature marked.](glass_phase_transition.png "The four states of a glass-forming substance plotted against temperature: liquid, supercooled liquid, glass, and crystal. The melting temperature \(T_m\) is the boundary between solid crystal and liquid, and the glass transition temperature \(T_g\) is the boundary between supercooled liquid and glass.")

This time-dependence is the central distinction between glass and crystalline
solids. Crystals melt at a fixed temperature (\(T_m\)), and the transition is
sharp. Glasses do not melt at all in the strict sense. They pass continuously
between rigid solid and viscous liquid, and the location of the transition
depends on time as much as on temperature.

## Supercooled liquids

A liquid cooled below its freezing point without crystallizing is a
**supercooled liquid**. As it cools further, its atomic structure continues to
rearrange through a process called **structural relaxation**, which slows as
the temperature drops. The characteristic timescale for this rearrangement is
the **relaxation time**, \(\tau_s\), which increases sharply as the liquid
approaches the glass transition.

When the cooling rate exceeds the structural relaxation rate, the atomic
arrangement is frozen in: continued cooling produces no further structural
change, and the supercooled liquid becomes a glass. The temperature at which
this happens is called the **fictive temperature**, and for many materials it
coincides with \(T_g\).

## Conclusion

Glass is structurally disordered, thermodynamically out of equilibrium, and
stable on human timescales. These features, together with the glass transition
that connects the liquid and solid states, are common to all glasses, whether
oxide, metallic, or polymeric. What varies between systems is the chemistry
that sets the relaxation timescales and the value of \(T_g\).

[^1]: Mysen, B.; Richet, P. _Silicate Glasses and Melts_, 2nd ed.; Elsevier:
    Amsterdam, NL, 2019.
    [https://doi.org/10.1016/C2018-0-00864-6](https://doi.org/10.1016/C2018-0-00864-6).
[^2]: Vogel, W. _Glass Chemistry_; Springer: Berlin, DE, 1994.
    [https://doi.org/10.1007/978-3-642-78723-2](https://doi.org/10.1007/978-3-642-78723-2).
[^3]: Schmelzer, J. W. P.; Gutzow, I. S. _Glasses and the Glass Transition_;
    John Wiley & Sons: Weinheim, DE, 2011.
    [https://doi.org/10.1002/9783527636532](https://doi.org/10.1002/9783527636532).
[^4]: Zanotto, E. D.; Mauro, J. C. The Glassy State of Matter: Its Definition
    and Ultimate Fate. _J. Non-Cryst. Solids_ **2017**, _471_, 490---495.
    [https://doi.org/10.1016/j.jnoncrysol.2017.05.019](https://doi.org/10.1016/j.jnoncrysol.2017.05.019).
[^5]: Montazerian, M.; Zanotto, E. D. The Glassy State. In _Encyclopedia of
    Materials: Technical Ceramics and Glasses_; Elsevier, 2021; Vol. 2, pp
    448---461.
    [https://doi.org/10.1016/B978-0-12-803581-8.11728-X](https://doi.org/10.1016/B978-0-12-803581-8.11728-X).
