# CIBERSORTx Docker

A simple Docker launcher for **CIBERSORTx Fractions**, designed to make bulk RNA-seq deconvolution easier to run locally.

## Features

- Run CIBERSORTx using Docker.
- Configure credentials and parameters in `.env`.
- Provide input files through the `data/` directory.
- Retrieve results in the `results/` directory.

## Requirements

- Linux
- Docker
- A CIBERSORTx account and access token

## Installation

```bash
git clone https://github.com/PAPEIBRAH/cibersortx_docker.git
cd cibersortx_docker
cp .env.example .env
```

Edit `.env` and enter your CIBERSORTx credentials.

## Input files

Place your files in the `data/` directory:

- `mixture.txt`: bulk gene-expression matrix.
- `signature_matrix.txt`: reference cell-type signature matrix.

Update the corresponding filenames in `.env` if necessary.

## Run

```bash
chmod +x run_cibersortx.sh
./run_cibersortx.sh
```

Results will be saved in `results/`.

## Configuration

Edit `.env` to change the input filenames and parameters:

```bash
MIXTURE_FILE="mixture.txt"
SIGMATRIX_FILE="signature_matrix.txt"
PERM=100
QN=FALSE
```

Keep your `.env` file private. **Never upload your credentials to GitHub.**

## References

Steen CB et al. *Profiling Cell Type Abundance and Expression in Bulk Tissues with CIBERSORTx*. Methods in Molecular Biology, 2020. [Read the article](https://pmc.ncbi.nlm.nih.gov/articles/PMC7695353/).

**Note:** This repository simplifies execution; it does not remove CIBERSORTx access requirements or guarantee unlimited computing resources.