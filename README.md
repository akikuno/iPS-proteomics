# iPS Proteomics

a code repository to reproduce Fig. 2B

## Requirements

- Unix OS (Linux, WSL, macOS)
- R language (> version 3.5)

## Execute

```r
Rscript --vanilla --slave scripts/script.R
```

The command produces a `reports` directory, which contains the followings:

- `dotplot_log2fc.png`: Fig. 2B
- `expression_log2fc.csv`: Gene expression data to generate Fig. 2B