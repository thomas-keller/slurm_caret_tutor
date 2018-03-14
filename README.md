# slurm_caret_tutor
How to get started on the USF cluster and do a basic analysis of some twitter data using caret
Starts simple with glmnet (sky is the limit).

Steps:
Copy this folder to your home directory on circe (or whatever cluster)

On circe:
initial package installation
load R as follows:

```console
module add apps/R
```
start R, then source the starter_rpackages.R file
```R
source('starter_rpackages.R')
```
it will ask to install a personal library, at one point, say yes. Installing these packages takes quite awhile,
(30+ minutes). I think I have gotten it to the point where it shouldn't be making errors anymore, at least.

Once the packages are installed, you can submit jobs
with sbatch
ie
```console
sbatch ex_date.sh
sbatch example_caret_ml.sh
```
