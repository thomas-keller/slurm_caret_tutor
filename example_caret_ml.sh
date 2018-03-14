#!/bin/bash
#SBATCH --job-name=tw_car_ex
#SBATCH --time=02:00:00
#SBATCH --ntasks-per-cpu=8
#SBATCH --nodes=1

#SBATCH --mem=12G


# stage 1 add modules (R, cuda if gpu, ???)
module add apps/R

# stage 2 change to work directory
# DONT RUN STUFF IN HOME or SHARES

cd /work/t/tekeller
mkdir make_bettername
cd make_bettername
cp /shares/si_twitter/trump_dat0318/* .
cp ~/myfirst_caret.R .
Rscript myfirst_caret.R
cp myfirst_glm.csv ~/results

# stage 3 clean up
cd ..
rm -rf ./make_bettername
