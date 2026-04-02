---
slug: "cie-colors-python"
aliases: ["/blog/cie-colors-python/"]
author: "Tobia Cavalli"
title: "Calculating the CIE color of Chlorophyll A and B using Python"
date: "2024-09-14"
lastmod: "2026-04-02"
summary: "A UV-Vis spectrum tells you what light a molecule absorbs, but not
    what color it looks. This guide uses the CIE 1931 colorimetry system and
    Python to calculate the perceived color of Chlorophyll A and B from their
    absorption spectra."
description: "Calculating CIE colors from UV-Vis spectra of Chlorophyll A
    and B using Python and the colour-science library."
tags: ["python","colorimetry"]
toc: true
math: true
---

A UV-Vis spectrum records how much light a molecule absorbs at each wavelength,
but it says nothing about what the molecule actually looks like. Chlorophyll A
has absorption peaks near 430 nm and 670 nm — but what color does a solution of
it appear to the eye?

Answering that question requires crossing from physics into perception. Color is
a sensation produced by the brain's processing of signals from the retina, not a
property of light itself. The same spectral power distribution can look
different under different illuminants; different distributions can look
identical. This is metamerism: two lights with different spectral compositions
produce the same cone responses and appear identical to a normal observer under
standard conditions.[^1] [^2]

**Psychophysics** quantifies this relationship between physical stimuli and
perceived sensations. Guy Brindley formalized the distinction in 1970 by
categorizing perceptual observations into two types:

1. **Class A observations:** Two physically different stimuli are perceived as
   identical --- the observer cannot distinguish them.
2. **Class B observations:** All other cases where stimuli are distinguishable.

Color matching is the canonical Class A case. It is also the experimental
foundation of the CIE colorimetry system.

## The CIE colorimetry system

The **CIE colorimetry system**, developed by the Commission Internationale
d'Éclairage, translates spectral power distributions into standardized color
coordinates using **color matching** experiments.[^3] [^4]

In these experiments, observers view a split field: one half shows a test color,
the other a mixture of three primary lights. The observer adjusts the primaries
until both halves match. Repeating this across the visible spectrum and
averaging over many observers produces a statistical model of human color
vision.

![CIE color matching experiment](cie_color_matching.png "CIE color matching
experiment. Adapted from literature.")

The CIE 1931 model uses additive color mixing based on **Color Matching
Functions (CMFs)**, denoted \\(\bar{x}\\), \\(\bar{y}\\), and \\(\bar{z}\\).
CMFs are not the spectral sensitivities of the cone cells directly, but linear
transformations of them, derived from standardized color matching experiments
involving foveal vision, specific field sizes, dark surroundings, and averaged
observations from multiple individuals.

By convolution of the sample spectrum \\(M(\lambda)\\) with the CMFs, we
calculate **tristimulus values** \\(X\\), \\(Y\\), and \\(Z\\). These values
represent the amounts of the three primary colors (red, green, and blue)
required to match the given color.

$$
X = \int_{380}^{780} M(\lambda) \bar{x}(\lambda)  \, d\lambda \tag{1}
$$

$$
Y = \int_{380}^{780} M(\lambda) \bar{y}(\lambda)  \, d\lambda \tag{2}
$$

$$
Z = \int_{380}^{780} M(\lambda) \bar{z}(\lambda)  \, d\lambda \tag{3}
$$

The tristimulus values define a point in a three-dimensional color space. For
visualization, this space is reduced to two dimensions using the \\(x\\) and
\\(y\\) chromaticity coordinates:

$$
x = \frac{X}{X + Y + Z} \tag{4}
$$

$$
y = \frac{Y}{X + Y + Z} \tag{5}
$$

The \\(x\\) and \\(y\\) coordinates specify a chromaticity (hue and saturation)
independently of luminance. This is what makes the diagram useful for comparing
colors across different brightness levels.

## Python code

### Dependencies

The heavy lifting is done by [`colour-science`](https://colour.readthedocs.io),
a Python library that implements most major colorimetric systems, color space
conversions, and color difference metrics. The remaining dependencies are
standard: `numpy`, `pandas`, and `matplotlib`. Install them with:

```sh
pip install numpy pandas matplotlib colour-science
```

Then import them:

```python
import colour as cl
import matplotlib.pyplot as plt
import matplotlib.ticker as tck
import numpy as np
import pandas as pd

# Disable some annoying warnings from colour library
cl.utilities.filter_warnings(colour_usage_warnings=True)
```

### Plot settings

The following settings match the blog's plot style. If you are following along
in a Jupyter notebook, you can skip this block. I use `seaborn` for its default
presets (context, ticks, colorblind palette) and the golden ratio from `scipy`
to set the figure aspect ratio.

```python {linenostart=9}
import seaborn as sns
from scipy.constants import golden_ratio

# Set seaborn defaults
sns.set_context("notebook")
sns.set_style("ticks")
sns.set_palette("colorblind", color_codes=True)

# Use white color for elements that are typically black
plt.style.use("dark_background")

# Remove background from figures and axes
plt.rcParams["figure.facecolor"] = "none"
plt.rcParams["axes.facecolor"] = "none"

# Default figure size to use throughout
figure_size = (7, 7 / golden_ratio)
```

### Plotting the CIE (2°) color space

The `colour-science` library provides a ready-made function for plotting the CIE
1931 chromaticity diagram. The diagram shows all chromaticities visible to a 2°
standard observer; the spectral locus traces the monochromatic wavelengths, and
any real color falls inside it. We will plot our chlorophyll colors on this
diagram later.

```python {hl_lines=["5-11"],linenostart=26}
# Instantiate figure and axes
fig, ax = plt.subplots(1, 1, figsize=(7, 7))

# Plot CIE color space for a 2°
cl.plotting.plot_chromaticity_diagram_CIE1931(
    cmfs="CIE 1931 2 Degree Standard Observer",
    axes=ax,
    show=False,
    title=None,
    spectral_locus_colours="white",
)

# Axes labels
ax.set_xlabel("x (2°)")
ax.set_ylabel("y (2°)")

# Axes limits
ax.set_xlim(-0.1, 0.85)
ax.set_ylim(-0.1, 0.95)

# Ticks separation
ax.xaxis.set_major_locator(tck.MultipleLocator(0.1))
ax.xaxis.set_minor_locator(tck.MultipleLocator(0.01))
ax.yaxis.set_major_locator(tck.MultipleLocator(0.1))
ax.yaxis.set_minor_locator(tck.MultipleLocator(0.01))

# Grid settings
ax.grid(which="major", axis="both", linestyle="--", color="gray", alpha=0.8)

# Padding adjustment
plt.tight_layout()

plt.show()
```

![CIE color space for a 2° observer.](CIE_2deg_color_space.png "CIE color
space for a 2° observer.")

### Importing and scaling data

The data are pre-recorded UV-Vis absorption spectra of Chlorophyll A and
Chlorophyll B in 70% and 90% acetone solutions, taken from Chazaux et al.[^6]
You can download the `.csv` file [here](include/chlorophyll_uv_vis.csv).

```python {linenostart=59}
column_names = ["lambda", "chl_a_70", "chl_a_90", "chl_b_70", "chl_b_90"]
measured_samples = pd.read_csv(
    "chlorophyll_uv_vis.csv", names=column_names, header=0, index_col="lambda"
)
measured_samples
```

|            | **chl_a_70** | **chl_a_90** | **chl_b_70** | **chl_b_90** |
|------------|--------------|--------------|--------------|--------------|
| **lambda** |              |              |              |              |
| 350.0      | 26132.0      | 25552.0      | 29529.0      | 28301.0      |
| 350.4      | 26251.0      | 25804.0      | 29574.0      | 28114.0      |
| 350.8      | 26666.0      | 26083.0      | 29350.0      | 27946.0      |
| 351.2      | 26703.0      | 26227.0      | 29084.0      | 27660.0      |
| 351.6      | 26834.0      | 26473.0      | 28991.0      | 27632.0      |
| ...        | ...          | ...          | ...          | ...          |
| 748.4      | -63.0        | -269.0       | -15.0        | -159.0       |
| 748.8      | -80.0        | -289.0       | -2.0         | -141.0       |
| 749.2      | -95.0        | -283.0       | -13.0        | -157.0       |
| 749.6      | -92.0        | -292.0       | -2.0         | -150.0       |
| 750.0      | 82.0         | -198.0       | 69.0         | -172.0       |

_1001 rows × 4 columns_

Each column records absorbance (\\(A\\)) as a function of wavelength
(\\(\lambda\\)) for one chlorophyll–solvent combination:

```python {hl_lines=["12-15"],linenostart=60}
fig, ax = plt.subplots(1, 1, figsize=figure_size)

# Define the labels for the plot's legend
chl_labels = [
    "Chlorophyll A (70 % Acetone)",
    "Chlorophyll A (90 % Acetone)",
    "Chlorophyll B (70 % Acetone)",
    "Chlorophyll B (90 % Acetone)",
]

# Iterate over dataframe and plot each spectrum
for col, sample_label in zip(measured_samples.columns, chl_labels):
    ax.plot(measured_samples.index, measured_samples[col], label=sample_label)

# Ticks separation
ax.xaxis.set_major_locator(tck.MultipleLocator(50))
ax.xaxis.set_minor_locator(tck.MultipleLocator(10))

# Axes labels
ax.set_xlabel("Wavelength [nm]")
ax.set_ylabel("Absorbance [a.u.]")

# Display legend
ax.legend()

plt.show()
```

![UV-Vis absorption spectra of Chlorophyll A and B in 70% and 90 % acetone
solutions.](chl_a_b_UV_Vis_abs.png "UV-Vis absorption spectra of Chlorophyll A
and B in 70% and 90 % acetone solutions.")

Chlorophyll A absorbs primarily in the blue (~430 nm) and red (~670 nm) regions.
Chlorophyll B shows a similar pattern with peaks near 460 nm and 650 nm, its
blue peak shifted slightly toward the green. The acetone concentration affects
peak intensities but not spectral shape.

Because the four spectra have different absolute absorbance values, we need to
normalize them before comparing colors. Normalization discards quantitative
information (concentrations), but since our goal is qualitative (what color does
each spectrum produce?), this is acceptable.

We use MinMax scaling to map each spectrum to the 0–1 range while preserving its
shape:[^7]

$$
    x_{scaled} = \frac{x - x_{min}}{x_{max} - x_{min}} \tag{6}
$$

A simple custom function avoids pulling in `scikit-learn` for a one-line
operation:

```python {linenostart=86}
def normalize(x: pd.Series | np.ndarray) -> pd.Series | np.ndarray:
    """MinMax scaling from 0 to 1

    Args:
        x (pd.Series | np.ndarray): series or array to normalize

    Returns:
        pd.Series | np.ndarray: series or array of normalized values
    """
    x_scaled = (x - x.min()) / (x.max() - x.min())
    return x_scaled
```

We apply it to the full DataFrame at once, since pandas vectorizes the operation
across all columns:

```python {linenostart=97}
abs_norm = normalize(measured_samples)
abs_norm
```

|            | **chl_a_70** | **chl_a_90** | **chl_b_70** | **chl_b_90** |
|------------|--------------|--------------|--------------|--------------|
| **lambda** |              |              |              |              |
| 350.0      | 0.324398     | 0.285405     | 0.227556     | 0.207087     |
| 350.4      | 0.325869     | 0.288188     | 0.227903     | 0.205727     |
| 350.8      | 0.331001     | 0.291269     | 0.226179     | 0.204505     |
| 351.2      | 0.331458     | 0.292859     | 0.224133     | 0.202425     |
| 351.6      | 0.333078     | 0.295576     | 0.223417     | 0.202221     |
| ...        | ...          | ...          | ...          | ...          |
| 748.4      | 0.000507     | 0.000254     | 0.000262     | 0.000095     |
| 748.8      | 0.000297     | 0.000033     | 0.000362     | 0.000225     |
| 749.2      | 0.000111     | 0.000099     | 0.000277     | 0.000109     |
| 749.6      | 0.000148     | 0.000000     | 0.000362     | 0.000160     |
| 750.0      | 0.002300     | 0.001038     | 0.000908     | 0.000000     |

_1001 rows × 4 columns_

A quick plot confirms the spectra now share the same 0–1 scale while retaining
their characteristic shapes:

```python {linenostart=99}
fig, ax = plt.subplots(1, 1, figsize=figure_size)

for col, sample_label in zip(abs_norm.columns, chl_labels):
    ax.plot(abs_norm.index, normalize(abs_norm[col]), label=f"{sample_label} norm")

# Ticks separation
ax.xaxis.set_major_locator(tck.MultipleLocator(50))
ax.xaxis.set_minor_locator(tck.MultipleLocator(10))
ax.yaxis.set_major_locator(tck.MultipleLocator(0.1))
ax.yaxis.set_minor_locator(tck.MultipleLocator(0.025))

# Axes labels
ax.set_xlabel("Wavelength [nm]")
ax.set_ylabel("Absorbance [a.u.]")

# Display legend
ax.legend()

plt.show()
```

![Normalized UV-Vis absorption spectra of Chlorophyll A and B in 70% and 90 %
acetone solutions.](chl_a_b_UV_Vis_abs_norm.png "Normalized UV-Vis absorption
spectra of Chlorophyll A and B in 70% and 90 % acetone solutions.")

### Converting absorbance to transmittance

The spectra above record **absorbed** light. The color we perceive depends on
the light that passes **through** the sample: the transmittance. The conversion
from absorbance (\\(A\\)) to percent transmittance (\\(\\%T\\)) follows the
Beer-Lambert law:

$$
    \\%T = 100 \times 10^{-A} = 10^{(2 - A)} \tag{7}
$$

Note that because we are using normalized absorbance values (0--1) rather than
actual absorbance, the resulting transmittance values do not represent true
physical transmittance. They preserve the spectral shape, which is sufficient
for a qualitative color comparison, but should not be interpreted
quantitatively.

In code:

```python {linenostart=120}
def abs_to_trans(A: pd.Series | np.ndarray) -> pd.Series | np.ndarray:
    """Convert absorbance to transmittance

    Args:
        A (pd.Series | np.ndarray): series or array of absorbance values

    Returns:
        pd.Series | np.ndarray: series or array of transmittance values
    """
    T = 10 ** (2 - A)
    return T
```

Running it on the normalized absorbance values:

```python {linenostart=131}
transm_norm = abs_to_trans(abs_norm)
transm_norm
```

|            | **chl_a_70** | **chl_a_90** | **chl_b_70** | **chl_b_90** |
|------------|--------------|--------------|--------------|--------------|
| **lambda** |              |              |              |              |
| 350.0      | 47.380775    | 51.831637    | 59.216627    | 62.074481    |
| 350.4      | 47.220520    | 51.500565    | 59.169440    | 62.269182    |
| 350.8      | 46.665880    | 51.136488    | 59.404698    | 62.444622    |
| 351.2      | 46.616747    | 50.949585    | 59.685281    | 62.744426    |
| 351.6      | 46.443207    | 50.631871    | 59.783692    | 62.773854    |
| ...        | ...          | ...          | ...          | ...          |
| 748.4      | 99.883339    | 99.941532    | 99.939788    | 99.978231    |
| 748.8      | 99.931694    | 99.992372    | 99.916775    | 99.948098    |
| 749.2      | 99.974380    | 99.977117    | 99.936247    | 99.974883    |
| 749.6      | 99.965841    | 100.000000   | 99.916775    | 99.963164    |
| 750.0      | 99.471847    | 99.761259    | 99.791184    | 100.000000   |

_1001 rows × 4 columns_

The transmittance spectra, plotted below, should mirror the absorbance spectra
inverted:

```python {hl_lines=["3-4"],linenostart=133}
fig, ax = plt.subplots(1, 1, figsize=figure_size)

for col, sample_label in zip(transm_norm.columns, chl_labels):
    ax.plot(transm_norm.index, transm_norm[col], label=f"{sample_label}")

# Ticks separation
ax.xaxis.set_major_locator(tck.MultipleLocator(50))
ax.xaxis.set_minor_locator(tck.MultipleLocator(10))
ax.yaxis.set_major_locator(tck.MultipleLocator(10))
ax.yaxis.set_minor_locator(tck.MultipleLocator(5))

# Axes labels
ax.set_xlabel("Wavelength [nm]")
ax.set_ylabel("Transmittance [%]")

# Display legend
ax.legend()

plt.show()
```

![Normalized UV-Vis transmission spectra of Chlorophyll A and B in 70% and 90 %
acetone solutions.](chl_a_b_UV_Vis_trans_norm.png "Normalized UV-Vis
transmission spectra of Chlorophyll A and B in 70% and 90 % acetone solutions.")

The inverse relationship between absorbance and transmittance is visible: peaks
in absorbance correspond to troughs in transmittance. A side-by-side comparison:

```python {hl_lines=["4-5", "8-9"],linenostart=152}
fig, ax = plt.subplots(2, 1, sharex=True, figsize=figure_size)

# Iterate over absorbance dataframe
for col, sample_label in zip(abs_norm.columns, chl_labels):
    ax[0].plot(abs_norm.index, normalize(abs_norm[col]), label=f"{sample_label}")

# Iterate over transmittance dataframe
for col, sample_label in zip(transm_norm.columns, chl_labels):
    ax[1].plot(transm_norm.index, transm_norm[col], label=f"{sample_label}")

# Axes labels
ax[0].set_ylabel("Absorbance [a.u.]")

ax[1].set_xlabel("Wavelength [nm]")
ax[1].set_ylabel("Transmittance [%]")

# Ticks separation
for axis in ax:
    axis.xaxis.set_major_locator(tck.MultipleLocator(50))
    axis.xaxis.set_minor_locator(tck.MultipleLocator(10))
    # Display legend
    axis.legend()

ax[0].yaxis.set_major_locator(tck.MultipleLocator(0.1))
ax[0].yaxis.set_minor_locator(tck.MultipleLocator(0.025))
ax[1].yaxis.set_major_locator(tck.MultipleLocator(10))
ax[1].yaxis.set_minor_locator(tck.MultipleLocator(5))

plt.show()
```

![Normalized UV-Vis absorption and transmission spectra of Chlorophyll A and B
in 70% and 90 % acetone solutions.](chl_a_b_UV_Vis_abs_trans_norm.png
"Normalized UV-Vis absorption and transmission spectra of Chlorophyll A and B in
70% and 90 % acetone solutions.")

### Calculating the CIE colors

The pipeline for each spectrum:

1. Build a `SpectralDistribution` and interpolate to 1 nm intervals (CIE
   specification).
2. Compute \\(XYZ\\) tristimulus values with `sd_to_XYZ`, using the CIE 1931 2°
   observer CMFs and the D65 daylight illuminant.
3. Convert \\(XYZ\\) to \\(xy\\) chromaticity coordinates.

The results for absorbance-based and transmittance-based colors are stored in
separate lists, then merged into a single DataFrame.

```python {linenostart=181}
# Define color matching functions
cmfs = cl.MSDS_CMFS["cie_2_1931"]

# Define illuminant
illuminant = cl.SDS_ILLUMINANTS["D65"]

chl_abs_clr = []

# Iterate over each normalized absorbance spectrum
for col in abs_norm.columns:
    # Initialize spectral distribution
    sd = cl.SpectralDistribution(data=abs_norm[col])

    # Interpolate sd to conform to the CIE specifications
    sd = sd.interpolate(cl.SpectralShape(350, 750, 1))

    # Calculate CIE XYZ coordinates from spectral distribution
    cie_XYZ = cl.sd_to_XYZ(sd, cmfs, illuminant)

    # Convert to CIE xy coordinates
    cie_xy = cl.XYZ_to_xy(cie_XYZ)

    # Append the results to the list of sample colors
    chl_abs_clr.append(
        {"sample": col, "x_A": np.round(cie_xy[0], 4), "y_A": np.round(cie_xy[1], 4)}
    )

chl_transm_clr = []

# Iterate over each normalized transmittance spectrum
for col in transm_norm.columns:
    # Initialize spectral distribution
    sd = cl.SpectralDistribution(data=transm_norm[col])
    sd = sd.interpolate(cl.SpectralShape(350, 750, 1))

    # Calculate CIE XYZ coordinates from spectral distribution
    cie_XYZ = cl.sd_to_XYZ(sd, cmfs, illuminant)

    # Convert to CIE xy coordinates
    cie_xy = cl.XYZ_to_xy(cie_XYZ)

    # Append the results to the list of sample colors
    chl_transm_clr.append(
        {"sample": col, "x_T": np.round(cie_xy[0], 4), "y_T": np.round(cie_xy[1], 4)}
    )

# Convert dictionaries to dataframes and join them together
colors = pd.merge(pd.DataFrame(chl_transm_clr), pd.DataFrame(chl_abs_clr))
colors
```

|      | **sample** | **x_T** | **y_T** | **x_A** | **y_A** |
|------|------------|---------|---------|---------|---------|
| 0    | chl_a_70   | 0.3046  | 0.3777  | 0.2966  | 0.1330  |
| 1    | chl_a_90   | 0.3063  | 0.3721  | 0.2948  | 0.1345  |
| 2    | chl_b_70   | 0.3558  | 0.4365  | 0.2036  | 0.0930  |
| 3    | chl_b_90   | 0.3538  | 0.4334  | 0.2048  | 0.0904  |

### Visualizing colors on the CIE color space

Plotting the absorbed colors on the CIE 1931 chromaticity diagram:

```python {linenostart=230}
# Instantiate figure and axes
fig, ax = plt.subplots(1, 1, figsize=figure_size)

# Plot CIE color space for a 2°
cl.plotting.plot_chromaticity_diagram_CIE1931(
    cmfs="CIE 1931 2 Degree Standard Observer",
    axes=ax,
    show=False,
    title=None,
    spectral_locus_colours="white",
)

color_list = ["r", "g", "b", "m"]

for i, c in enumerate(color_list):
    ax.scatter(
        colors["x_A"][i],
        colors["y_A"][i],
        label=chl_labels[i],
        color=c,
        edgecolors="k",
        alpha=0.8,
    )

# Axes labels
ax.set_xlabel("x (2°)")
ax.set_ylabel("y (2°)")

# Axes limits
ax.set_xlim(0.18, 0.32)
ax.set_ylim(0.06, 0.16)

# Ticks separation
ax.xaxis.set_major_locator(tck.MultipleLocator(0.01))
ax.xaxis.set_minor_locator(tck.MultipleLocator(0.005))
ax.yaxis.set_major_locator(tck.MultipleLocator(0.01))
ax.yaxis.set_minor_locator(tck.MultipleLocator(0.005))

# Grid settings
ax.grid(which="major", axis="both", linestyle="--", color="gray", alpha=0.8)

# Display legend
ax.legend()

# Adjust plot padding
plt.tight_layout()

plt.show()
```

![CIE color space for a 2° observer and calculated absorbed colors for
Chlorophyll A and B in 70 % and 90 % acetone with D65
illuminant.](CIE_chl_abs.png "CIE color space for a 2° observer and calculated
absorbed colors for Chlorophyll A and B in 70 % and 90 % acetone with D65
illuminant.")

The same plot for the transmitted colors:

```python {linenostart=278}
# Instantiate figure and axes
fig, ax = plt.subplots(1, 1, figsize=figure_size)

# Plot CIE color space for a 2°
cl.plotting.plot_chromaticity_diagram_CIE1931(
    cmfs="CIE 1931 2 Degree Standard Observer",
    axes=ax,
    show=False,
    title=None,
    spectral_locus_colours="white",
)

color_list = ["r", "g", "b", "m"]

for i, c in enumerate(color_list):
    ax.scatter(
        colors["x_T"][i],
        colors["y_T"][i],
        label=chl_labels[i],
        color=c,
        edgecolors="k",
        alpha=0.8,
    )

# Axes labels
ax.set_xlabel("x (2°)")
ax.set_ylabel("y (2°)")

# Axes limits
ax.set_xlim(0.25, 0.4)
ax.set_ylim(0.35, 0.45)

# Ticks separation
ax.xaxis.set_major_locator(tck.MultipleLocator(0.01))
ax.xaxis.set_minor_locator(tck.MultipleLocator(0.005))
ax.yaxis.set_major_locator(tck.MultipleLocator(0.01))
ax.yaxis.set_minor_locator(tck.MultipleLocator(0.005))

# Grid settings
ax.grid(which="major", axis="both", linestyle="--", color="gray", alpha=0.8)

# Display legend
ax.legend(labelcolor="k", edgecolor="k")

# Adjust plot padding
plt.tight_layout()

plt.show()
```

![CIE color space for a 2° observer and calculated transmitted colors for
Chlorophyll A and B in 70 % and 90 % acetone with D65
illuminant.](CIE_chl_transm.png "CIE color space for a 2° observer and
calculated transmitted colors for Chlorophyll A and B in 70 % and 90 % acetone
with D65 illuminant.")

The transmitted-color coordinates confirm what the spectra suggest. Both
chlorophylls absorb in the blue and red regions and transmit primarily in the
green, but the shift in Chlorophyll B's blue absorption peak toward longer
wavelengths pushes its transmitted color toward yellow-green. Chlorophyll A,
with its blue peak at shorter wavelengths, sits closer to a neutral green.

## Where to go from here

The same pipeline applies to any molecule with a UV-Vis spectrum: dyes,
pigments, optical filter glasses, fluorescent proteins. Swapping in the CIE 1976
\\( L^{\*}a^{\*}b^{\*} \\) color space (via `colour-science`'s `XYZ_to_Lab` function) would
give perceptually uniform coordinates, making it possible to compute meaningful
color differences (\\(\Delta E\\)) between samples. For quantitative work, the
normalization step should be revisited — using actual absorbance values with a
defined path length and concentration preserves the physical relationship
between Beer-Lambert transmittance and perceived color.

[^1]: Kingdom, F. A. A.; Prins, N. _Psychophysics: A Practical Introduction_,
    2nd ed.; Academic Press: Amsterdam, NL, 2016; pp. 19--20.
    [https://doi.org/10.1016/C2012-0-01278-1](https://doi.org/10.1016/C2012-0-01278-1).
[^2]: Schanda, J. _Colorimetry: Understanding the CIE System_; John Wiley &
    Sons: Hoboken, NJ, USA, 2007; pp. 56--59.
    [https://doi.org/10.1002/9780470175637](https://doi.org/10.1002/9780470175637).
[^3]: Guild, J. The Colorimetric Properties of the Spectrum. _Phil. Trans. R.
    Soc. Lond. A_ **1931**, _230_ (681-693), 149--187.
    [https://doi.org/10.1098/rsta.1932.0005](https://doi.org/10.1098/rsta.1932.0005).
[^4]: Smith, T.; Guild, J. The C.I.E. Colorimetric Standards and Their Use.
    _Trans. Opt. Soc._ **1931**, _33_ (3), 73--134.
    [https://doi.org/10.1088/1475-4878/33/3/301](https://doi.org/10.1088/1475-4878/33/3/301).
[^6]: Chazaux, M.; Schiphorst, C.; Lazzari, G.; Caffarri, S. Precise Estimation
    of Chlorophyll a , b and Carotenoid Content by Deconvolution of the
    Absorption Spectrum and New Simultaneous Equations for Chl Determination.
    _Plant J._ **2022**, _109_ (6), 1630--1648.
    [https://doi.org/10.1111/tpj.15643](https://doi.org/10.1111/tpj.15643).
[^7]: Otto, M. _Chemometrics: Statistics and Computer Application in Analytical
    Chemistry_, 4th ed.; Wiley-VCH Verlag: Weinheim, DE, 2024; pp. 137--140.
    [https://doi.org/10.1002/9783527843800](https://doi.org/10.1002/9783527843800).
