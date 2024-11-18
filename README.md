# Code for a manuscript "Ship and ground-based lidar and radiosonde evaluation of Southern Ocean clouds in the storm-resolving general circulation model ICON and the ERA5 and MERRA-2 reanalyses"

**This repository is currently in preparation.**

This repository contains code for a manuscript "Ship and ground-based lidar and
radiosonde evaluation of Southern Ocean clouds in the storm-resolving general
circulation model ICON and the ERA5 and MERRA-2 reanalyses".

Due to space requirements, accompanying data for this code must be downloaded
from other sources. [TODO]

The code in this repository is for running all of the data processing steps and
plotting, in addition to downloading reanalysis data and extracting ICON data
on the Levante supercomputer (not needed if you download the full accompanying
data, which contain the reanalysis and ICON data).

## Requirements

The code should work on any standard Linux distribution. It has been developed
and tested on Devuan GNU/Linux 5 (daedalus). Running the code on other Windows
or macOS might be possible, but has not been tested. On Windows, it might be
possible to run it most easily under the Windows Subsystem for Linux.

The commands are to be run in the terminal, such as GNU Bash. Specifically,
some of the command-line syntax is not compatible with `zsh` (the default shell
on macOS). The use the commands on macOS (untested), it is recommended to start
the `bash` shell first.

The version numbers are advisory, and the code might work with earlier versions
as well.

- Python >= 3.11
- R >= 4.2.2
- cdo >= 2.1.1

Python packages:

- alcf >= 2.0.1
- aquarius_time >= 0.4.0
- cartopy >= 0.21.1
- ds_format >= 4.1.0
- matplotlib >= 3.7.2
- numpy >= 1.24.2
- pst-format >= 2.0.0
- pyproj >= 3.4.1
- rstool >= 1.1.0
- scipy >= 1.10.1
- shapely >= 1.8.5

In addition, running code for extracting ICON data on the Levante supercomputer
on DKRZ requires the following Python packages:

- healpy >= 1.16.6
- intake >= 0.6.8

If you download the full accompanying data, running the data extraction on
Levante is not needed, because the ICON data at the voyage tracks and stations
are already contained in the full data.

R packages:

- rgdal >= 1.6
- sp >= 1.6

To install the required packages on Debian-based Linux distributions:

```sh
apt install python3 r-base r-cran-gdal r-cran-sp cdo
```

To avoid compatibility issues, it is recommended to install the specific
versions of the required Python packages (listed in the file
`requirements.txt`) in a Python virtual environment:

```sh
python3 -m venv venv
. venv/bin/activate
pip3 install -r requirements.txt
```

This also activates the environment for the current session. After finishing
working with the code, the environment can be deactivated with `deactivate`.

To run the cyclone tracking commands, download and upack version 1.0.1 of
CyTRACK:

```sh
wget -O CyTRACK-1.0.1.tar.gz https://github.com/apalarcon/CyTRACK/archive/refs/tags/v1.0.1.tar.gz
tar xf CyTRACK-1.0.1.tar.gz
mv CyTRACK-1.0.1 cytrack
```

## Commands

The following command are run as `./run` *cmd*, where *cmd* is the command
name. "Model" below means ICON, and *model* is `icon_cy3`.

### plot_map

Plot map of voyages and stations (Figure 1). The output is saved in
`plot/map.pdf`. Requires NetCDF tracks under `data/obs/track_hourly_40S+`.
Configuration of the plotting is directly in the file `bin/plot_map`.

### cytrack_model

Calculate cyclone trajectories for ICON (2021-2024).

### cytrack_era5

Calculate cyclone trajectories for ERA5 (2010-2021).

### calc_cyc_dist_model

Requires: `cytrack_model`

Calculate the distribution of cyclonic conditions in ICON (2021-2024).

### calc_cyc_dist_era5

Requires: `cytrack_era5`

The same as `calc_cyc_dist_model`, but for ERA5 (2010-2013).

### remap_lts_era5

Remap ERA5 LTS input data to a 1x1 degree grid.

### calc_lts_dist_model

Calculate LTS distribution in ICON (2021-2024).

### calc_lts_dist_era5

Requires: `remap_lts_era5`

The same as `calc_lts_dist_model`, but for ERA5 (2010-2013).

### plot_cyc_dist_model

Requires: `calc_cyc_dist_model`

Plot the distribution of cyclonic conditions in ICON (Figure 5b).

### plot_cyc_dist_era5

Requires: `calc_cyc_dist_era5`

The same as `plot_cyc_dist_model`, but for ERA5 (Figure 5a).

### plot_stab_dist_model

Requires: `calc_lts_dist_model`

Plot stability distribution in ICON (Figure 5d).

### plot_stab_dist_era5

Requires: `calc_lts_dist_era5`

The same as `plot_stab_dist_model`, but for ERA5 (Figure 5c).

### download_era5

Download ERA5 data for the voyage tracks and stations
(`data/obs/track_hourly_40S+`). The results are stored in `input/era5`.  This
step is not needed if you have downloaded the full accompanying data.  This
command requires `alcf download era5 --login` to be run first to log in to the
data distribution service.

### download_merra2

Download MERRA-2 data for the voyage tracks and stations
(`data/obs/track_hourly_40S+`). The results are stored in `input/merra2`.  This
step is not needed if you have downloaded the full accompanying data.  This
command requires `alcf download merra2 --login` to be run first to log in to
the data distribution service.

### alcf_merra2

Requires: `download_merra2`

Run ALCF on the MERRA-2 input data under `input/merra2` to produce simulated
backscatter. The output is stored under `data/merra2/samples`.

### alcf_era5

Requires: `download_era5`

Run ALCF on the ERA5 input data under `input/era5` to produce simulated
backscatter. The output is stored under `data/era5/samples`.

### recalib_obs

Recalibrate observations. This changes the cloud threshold and assumed
backscatter noise standard deviation. The output is stored under
`data/obs/samples/*/lidar_recalib_bsd`.

### recalib_model

The same as `recalib_obs`, but for ICON. The output is stored under
`data/`*model*`/samples`.

### recalib_merra2

The same as `recalib_obs`, but for MERRA-2. The output is stored under
`data/merra2/samples`.

### recalib_era5

The same as `recalib_obs`, but for ERA5. The output is stored under
`data/era5/samples`.

### alcf_ceres

Augment the ALCF output for observations with radiation data from CERES.

### filter_model

Create a filter for model precipitation and latitude 40°+S.

### filter_merra2

The same as `filter_model`, but for MERRA-2.

### filter_era5

The same as `filter_model`, but for ERA5.

### filter_lts_model

Create a filter for model LTS.

### filter_lts_merra2

The same as `filter_lts_model`, but for MERRA-2.

### filter_lts_era5

The same as `filter_lts_model`, but for ERA5.

### stats_obs

Calculate statistics for observations.

### stats_model

Calculate statistics for the model.

### stats_merra2

Calculate statistics for MERRA-2.

### stats_era5

Calculate statistics for ERA5.

### plot_cl_agg

Requires: `stats_obs`, `stats_model`, `stats_merra2`, `stats_era5`

Plot aggregated cloud occurrence (Figure 7). The output is stored under
`plot/cl_agg`.

### plot_clt_hist

Requires: `stats_obs`, `stats_model`, `stats_merra2`, `stats_era5`

Plot total cloud fraction histogram (Figure 8). The output is stored under
`plot/clt_hist`.

### rs_obs

Process radiosonde observations.

### rs_model

Process virtual radiosonde profiles for the model.

### rs_merra2

The same as `rs_model`, but for MERRA-2.

### rs_era5

The same as `rs_model`, but for ERA5.

### rs_stats_obs

Requires: `rs_obs`

Calculate radiosonde statistics for observations.

### rs_stats_model

Requires: `rs_model`

The same as `rs_stats_obs`, but for the model.

### rs_stats_merra2

Requires: `rs_merra2`

The same as `rs_stats_obs`, but for MERRA-2.

### rs_stats_era5

Requires: `rs_era5`

The same as `rs_stats_obs`, but for ERA5.

### plot_rs_agg

Requires: `rs_stats_obs`, `rs_stats_model`, `rs_stats_merra2`, `rs_stats_era5`

Plot aggregated radiosonde statistics. The output is stored in `plot/rs_agg`.

## Miscellaneous commands

The following commands are not strictly neccessary for the data processing and
plotting, but are included nonetheless for completeness.

### era5_is_broken

Determine if an ERA5 data file is broken. If a variable is found to be invalid,
print the file and variable name and exit with 1.

Usage: `era5_is_broken` *input*

Arguments:

- *input*: Input file (NetCDF).

### rename_ps_voyages

Rename files/directories of RV Polarstern voyage names in *dir* from ANT-* to
PS*.

Usage: `bin/rename_ps_voyages` *dir*

Arguments:

- *dir*: Directory.

## License and attribution

The code under the `bin` and `lib` directories, `run`, and `requirements.txt`
is Copyright © 2023–2024 Peter Kuma and licensed under the MIT license (see
`LICENSE.md`).

`README.md` and plots under `plot` are Copyright © 2023–2024 Peter Kuma and
licensed under the [Creative Commons Attribution 4.0 International license (CC
BY 4.0)](https://creativecommons.org/licenses/by/4.0/), (see `LICENSE_CC.txt`).

The original voyage and station data under `input` and the derived data under
`data` (available in the extended repository [TODO]) come from various sources,
with specific attribution requirements:

- AA15-16: Australian Antarctic Division and University of Canterbury.
- CERES: NASA Langley Atmospheric Science Data Center Distributed Active
  Archive Center.
- ERA5: Copernicus Climate Change Service.
- ICON: nextGEMS, Deutscher Wetterdienst, Max-Planck-Institute for Meteorology,
  Deutsches Klimarechenzentrum, Karlsruhe Institute of Technology, and Center
  for Climate Systems Modeling.
- MERRA-2: Global Modeling and Assimilation Office, NASA.
- Natural Earth: public domain dataset provided by naturalearthdata.com.
- Polarstern (PS*): Alfred Wegener Institute and Pangaea.
- HMNZSW16: Royal New Zealand Navy and University of Canterbury.
- NBP1704: National Science Foundation, Cooperative Institute for Research in
  Environmental Sciences, University of Colorado and University of Canterbury.
- TAN1502, TAN1702, and TAN1802: National Institute of Water and Atmospheric
  Research and University of Canterbury.
- MARCUS: Atmospheric Radiation Measurement and Australian Antarctic Division.
- MICRE: Atmospheric Radiation Measurement, the Australian Bureau of
  Meteorology, and Australian Antarctic Division.

Please see the Acknowledgements and Data availability sections in the
manuscript for more information, and the text of the manuscript for the
relevant publications to cite if you use these data.
