#!/bin/bash -l
#SBATCH --export=ALL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --mail-user=batool@liverpool.ac.uk
#SBATCH --mail-type=ALL
#SBATCH -t 3-00:00:00
export OMP_NUM_THREADS=$SLURM_NTASKS

module load apps/anaconda3/5.2.0
module load apps/gromacs/5.1.4/gcc-5.5.0+openmpi-1.10.7+fftw3_float-3.3.4+fftw3_double-3.3.4

echo 0 | gmx trjconv -f md_fit.xtc -s md_200ns.tpr -b 380000 -e 400000 -o md_fit1.xtc
echo 23 22| ./g_mmpbsa -f md_fit1.xtc -s md_200ns.tpr -n index.ndx -pdie 2 -decomp
echo 23 22| ./g_mmpbsa -f md_fit1.xtc -s md_200ns.tpr -n index.ndx -i apolar_sasa.mdp -nomme -pbsa -decomp -apol sasa.xvg -apcon sasa_contrib.dat
echo 23 22| ./g_mmpbsa -f md_fit1.xtc -s md_200ns.tpr -n index.ndx -i apolar_sav.mdp -nomme -pbsa -decomp -apol sav.xvg -apcon sav_contrib.dat
echo 23 22| ./g_mmpbsa -f md_fit1.xtc -s md_200ns.tpr -n index.ndx -i polar.mdp -nomme -pbsa -decomp

python3 MmPbSaStat.py -m energy_MM.xvg -p polar.xvg -a sasa.xvg
