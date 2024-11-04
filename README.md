
# Sentinel-1 Data Processing Pipeline with ISCE2

This repository provides an automated pipeline (`stack_proc.sh`) to download and process Sentinel-1 SAR data using **ISCE2**.

## Overview

This pipeline downloads Sentinel-1 data for a specified region and date range, prepares a DEM, downloads orbit files, and runs ISCE2 to generate interferograms. The `stack_proc.sh` script handles all processing steps.

## Prerequisites

- **Python 3.6+**
- **ISCE2** installed
- **sentineleof** tool for orbit files: install from [GitHub](https://github.com/scottstanie/sentineleof)
- **asf_search** tool for Sentinel-1 data : install from [GitHub](https://github.com/asfadmin/Discovery-asf_search/tree/master)


## Usage

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/Sen_stack_auto.git
   cd Sen_stack_auto
   ```

2. **Run the pipeline**:
   ```bash
   chmod +x stack_proc.sh
   ./stack_proc.sh
   ```

### Script Parameters

Key parameters in `stack_proc.sh`:

- **Bounding Box**: `MIN_LON`, `MIN_LAT`, `MAX_LON`, `MAX_LAT`
- **Date Range**: `START_DATE`, `END_DATE`
- **Orbit Direction**: `TRACK` (ASCENDING or DESCENDING)
- **Directories**: `DOWNLOAD_DIR`, `DEM_DIR`, `ORBIT_DIR`

