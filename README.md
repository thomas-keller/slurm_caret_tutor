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

# University of South Florida CIRCE cluster capabilities

For the full details, please see the documentation on the [RC web page](https://wiki.rc.usf.edu/index.php/CIRCE_Hardware). Quoting from that web page:

Advanced computing resources at the University of South Florida are administered by Research Computing (RC). RC hosts a cluster computer which currently consists of approximately 467 nodes with over 7100 processor cores running Red Hat Enterprise Linux 6. The cluster is built on the condominium model with 29TB of memory shared across the nodes in various configurations. The most recent major addition to the cluster is comprised of 110, dual 12-core 2.2GhZ Intel Broadwell nodes with 64GB RAM per node. Additionally, there are 40 NVidia Kepler K20 GPUs available.
