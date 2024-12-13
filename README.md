# Code for a manuscript "Ship and ground-based lidar and radiosonde evaluation of Southern Ocean clouds in the storm-resolving general circulation model ICON and the ERA5 and MERRA-2 reanalyses"

This repository contains code for the manuscript "Ship and ground-based lidar
and radiosonde evaluation of Southern Ocean clouds in the storm-resolving
general circulation model ICON and the ERA5 and MERRA-2 reanalyses" (DOI:
[10.5281/zenodo.14071808](https://doi.org/10.5281/zenodo.14071808)).

Due to space requirements (~1 TB), we do not include the source data here. They
have to be either obtained from the various original sources (see the Open
Research Section in the manuscript), or requested from the authors. The latter
might be a better option because it can take a large amount of time to download
some of the data, such as ERA5, from the original repositories.

The code in this repository is for running all of the data processing steps and
plotting, in addition to downloading the reanalysis data and extracting ICON
data on the Levante supercomputer.

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
- cdo >= 2.1.1
- GNU parallel >= 20221122
- R >= 4.2.2 (for map plotting only)

Python packages:

- alcf, a custom version available at [peterkuma/icon-so-2024-alcf](https://github.com/peterkuma/icon-so-2024-alcf)
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

R packages (for map plotting only):

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
[CyTRACK](https://github.com/apalarcon/CyTRACK):

```sh
wget -O CyTRACK-1.0.1.tar.gz https://github.com/apalarcon/CyTRACK/archive/refs/tags/v1.0.1.tar.gz
tar xf CyTRACK-1.0.1.tar.gz
mv CyTRACK-1.0.1 cytrack
```

## Input data

The directory `input` should be populated with the input data before running
the commands documented below, except for reanalysis data along the
voyage/station locations, which can be downloaded with the `download_merra2`
and `download_era5` commands.

The input data is expected to be organized in `input` in multiple directory
as follow.

### ceres

Directory with CERES `SYN1deg-Day_Terra-Aqua-MODIS_Edition4A` NetCDF files
(years 2010-2021). These can be produced by converting the CERES HDF files
to NetCDF with [h4toh5](https://www.hdfeos.org/software/h4toh5.php).

### era5

This directory should contain the following subdirectories:

- `cyc`: ERA5 surface-level 6-hourly instantaneous NetCDF files with the
  variables `latitude`, `longitude`, `msl`, `time`, `u10`, `v10` (years
  2010-2021).
- `lts/plev`: ERA5 pressure-level 6-hourly instantaneous NetCDF files with the
  variables `latitude`, `longitude`, `t`, and `time`, merged by time (with cdo
  or `ds merge`) into yearly files `2010.nc`, ..., `2013.nc`.
- `lts/surf`: The same as above, but for surface-level and the variables
  `latitude`, `longitude`, `sp`, `t2m`, and `valid_time`.

### natural_earth

This directory should contain a single subdirectory `ne_50m_land`, with data
extracted from [Natural Earth](https://www.naturalearthdata.com) (1:50m
Physical Vectors Land). This is only required for map plotting.

### obs

Observational data from the campaigns. It should contain the following
subdirectories.

#### lidar

- `chm15k`: This directory should contain one subdirectory per
  campaign (`HMNZSW16`, `NBP1704`, `TAN1702`, and `TAN1802`), containing
  NetCDF files extracted from the corresponding Lufft CHM 15k archives in the
  manuscript data repository (DOI:
  [10.5281/zenodo.14422427](https://doi.org/10.5281/zenodo.14422427)) and the
  TAN1802 repository (DOI:
  [10.5281/zenodo.4060236](https://doi.org/10.5281/zenodo.4060236)).
- `cl51/dat`: The same as above, but containing the Vaisala
  CL51 DAT files for the `AA15-16`, `TAN1502`, and the RV *Polarstern* voyages.
  The RV *Polarstern* voyages should use the `PS`*...* names, not the
  `ANT-`*...* names. See the file `ps_voyage_name_map.csv` for mapping between
  the two.
- `cl51/nc`: The same as above, but containing files converted
  from DAT to NetCDF with [cl2nc](https://github.com/peterkuma/cl2nc).
- `ct25k/nc`: This directory should contain the Vaisala CT25K
  NetCDF files for the `MARCUS` and `MICRE` campaigns, downloaded from
  [ARM](https://www.arm.gov).

#### rs

This directory should contain subdirectories for each campaign which has
radiosonde data available.

- `MARCUS`: This directory should contain NetCDF files from the corresponding
  ARM archive containing the `marsondewnpnM1.b1`*...* files.
- `NBP1704` and `TAN1702`: These directories should contain the files extracted
  from the corresponding archives for radiosondes in the manuscript data
  repository. `NBP1704` should contain NetCDF files. `TAN1702` should contain
  directories produced by the InterMet Systems software, one per radiosonde
  launch.
- `PS`*...* exept `PS111`-`PS124`: Directories for the RV *Polarstern* voyages,
  each containing a file `summary.txt` and a subdirectory `tab` with `.tab`
  files coming from the RV *Polarstern* repositories for upper air data on
  Pangaea. In addition, a file `summary_wo_header.tab` and subdirectory
  `tab_wo_header` should be created, containing the same files, but with the
  headers removed (text between `/*` and `*/`).
- `PS111`-`PS124`: The same as above, but containing files
  `PS`*...*`_radiosonde.tab` and `PS`*...*`_radiosonde_wo_header.tab`, which
  is the same as the former but with the headers removed.
- `TAN1802`: The same as `TAN1702`, but extracted from the TAN1802 data
  repository archive with the Intermet Systems radiosonde data.

#### surf

This directory should contain subdirectories for the following campaings:

- `AA15-16`: This subdirectory should contain CSV files extracted from the
  corresponding surfave archive in the manuscript data repository.
- `HMNZSW16` and `NBP1704`: The same as above, but MATLAB files for the
  corresponding campaings.
- `PS/metcont/tab`: This subdirectory should contain `.tab` files named
  `PS`*voyage`.tab` from the continuous meteorological measurement archives of
  the RV *Polarstern* voyages from Pangaea.
- `PS/metcont/tab_wo_header`: The same as above, but with `.tab` files with the
  headers removed.
- `PS/metcont_extra`: This subdirectory should contain files copied from
  the `ps_metcont_extra` directory in this repository.
- `PS/thermosalinograph/tab`: The same as `PS/metcont/tab`, but for `.tab`
  files from the voyage thermosalinograph archives on Pangaea.
- `PS/thermosalinograph/tab_wo_header`: The same as above, but with `.tab`
  files with the headers removed.

## Commands

The following command are run as `./run` *cmd* in the main directory of the
repository, where *cmd* is the command name. "Model" below means ICON, and
*model* is `icon_cy3`. The output of the commands is stored in a `data`
directory and plots are stored in a `plot` directory. The input data for the
commands come either from the `input` or `data` directories.

### surf

Convert native voyage surface navigation and observations to NetCDF.

### track

Requires: `surf`

Convert voyage and station surface data to hourly tracks south of 40°S.

### plot_map

Requires: `track`

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

Requires: `track`

Download ERA5 data for the voyage tracks and stations
(`data/obs/track_hourly_40S+`). The results are stored in `input/era5`.  This
step is not needed if you have downloaded the full accompanying data.  This
command requires `alcf download era5 --login` to be run first to log in to the
data distribution service.

### download_merra2

Requires: `track`

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

Requires: `alcf_merra2`

The same as `recalib_obs`, but for MERRA-2. The output is stored under
`data/merra2/samples`.

### recalib_era5

Requires: `alcf_era5`

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

### filter_cyc_model

Create a filter for model cyclonic activity.

### filter_cyc_era5

The same as `filter_cyc_model`, but for ERA5.

### filter_lts_model

Create a filter for model LTS.

### filter_lts_merra2

The same as `filter_lts_model`, but for MERRA-2.

### filter_lts_era5

The same as `filter_lts_model`, but for ERA5.

### stats_obs

Requires: `recalib_obs`

Calculate statistics for observations.

### stats_model

Requires: `recalib_model`, `filter_model`, `filter_cyc_model`, `filter_lts_model`

Calculate statistics for the model.

### stats_merra2

Requires: `recalib_merra2`, `filter_merra2`, `filter_cyc_era5`, `filter_lts_merra2`

Calculate statistics for MERRA-2.

### stats_era5

Requires: `recalib_era5`, `filter_era5`, `filter_cyc_era5`, `filter_lts_era5`

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

## License

All except for the `metcont_extra` directory:

Copyright © 2023–2024 Peter Kuma. This code is available under the MIT license
(see `LICENSE.md`).

The `metcont_extra` directory:

These data come from AWI and are for continous meteorological measurements
collected on the `PS124` and `PS81_8` voyages of RV *Polarstern*, missing on
Pangaea. No license is specified, but is likely the same as the corresponding
repositories on Pangaea.
