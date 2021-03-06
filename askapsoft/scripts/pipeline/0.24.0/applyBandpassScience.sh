#!/bin/bash -l
#
# Launches a job to apply the bandpass solution to the science measurement set 
#
# @copyright (c) 2017 CSIRO
# Australia Telescope National Facility (ATNF)
# Commonwealth Scientific and Industrial Research Organisation (CSIRO)
# PO Box 76, Epping NSW 1710, Australia
# atnf-enquiries@csiro.au
#
# This file is part of the ASKAP software distribution.
#
# The ASKAP software distribution is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# @author Matthew Whiting <Matthew.Whiting@csiro.au>
#

ID_CCALAPPLY_SCI=""

DO_IT=$DO_APPLY_BANDPASS
if [ "$DO_IT" == "true" ] && [ -e "$BANDPASS_CHECK_FILE" ]; then
    echo "Bandpass has already been applied to beam $BEAM of the science observation - not re-doing"
    DO_IT=false
fi

if [ "$DO_IT" == "true" ]; then

    setJob apply_bandpass applyBP
    cat > "$sbatchfile" <<EOFOUTER
#!/bin/bash -l
${SLURM_CONFIG}
#SBATCH --time=${JOB_TIME_APPLY_BANDPASS}
#SBATCH --ntasks=${NUM_CORES_CAL_APPLY}
#SBATCH --ntasks-per-node=${NPPN_CAL_APPLY}
#SBATCH --job-name=${jobname}
${exportDirective}
#SBATCH --output="$slurmOut/slurm-applyBandpass-%j.out"

${askapsoftModuleCommands}

BASEDIR=${BASEDIR}
cd $OUTPUT
. ${PIPELINEDIR}/utils.sh	

# Make a copy of this sbatch file for posterity
sedstr="s/sbatch/\${SLURM_JOB_ID}\.sbatch/g"
thisfile="$sbatchfile"
cp "\$thisfile" "\$(echo "\$thisfile" | sed -e "\$sedstr")"

RAW_TABLE=${TABLE_BANDPASS}
SMOOTH_TABLE=${TABLE_BANDPASS}.smooth
DO_SMOOTH=${DO_BANDPASS_SMOOTH}
if [ \${DO_SMOOTH} ] && [ -e \${SMOOTH_TABLE} ]; then
    TABLE=\${SMOOTH_TABLE}
else
    TABLE=\${RAW_TABLE}
fi

# Determine the number of channels from the MS metadata file (generated by mslist)
msMetadata="${MS_METADATA}"
#nChan=\$(python "${PIPELINEDIR}/parseMSlistOutput.py" --file="\${msMetadata}" --val=nChan)
nChan=${NUM_CHAN_SCIENCE}

parset=${parsets}/ccalapply_bp_${FIELDBEAM}_\${SLURM_JOB_ID}.in
cat > "\$parset" << EOFINNER
Ccalapply.dataset                         = ${msSci}
#
# Allow flagging of vis if inversion of Mueller matrix fails
Ccalapply.calibrate.allowflag             = true
Ccalapply.calibrate.scalenoise            = ${BANDPASS_SCALENOISE}
# Ignore the leakage
Ccalapply.calibrate.ignoreleakage         = true
#
Ccalapply.calibaccess                     = table
Ccalapply.calibaccess.table.maxant        = ${NUM_ANT}
Ccalapply.calibaccess.table.maxbeam       = ${maxbeam}
Ccalapply.calibaccess.table.maxchan       = \${nChan}
Ccalapply.calibaccess.table               = \${TABLE}

EOFINNER
log=${logs}/ccalapply_bp_${FIELDBEAM}_\${SLURM_JOB_ID}.log
#log=${logs}/ccalapply_bp_b${BEAM}_\${SLURM_JOB_ID}.log

NCORES=${NUM_CORES_CAL_APPLY}
NPPN=${NPPN_CAL_APPLY}
srun --export=ALL --ntasks=\${NCORES} --ntasks-per-node=\${NPPN} ${ccalapply} -c "\$parset" > "\$log"
err=\$?
rejuvenate ${msSci}
rejuvenate \${TABLE}
extractStats "\${log}" \${NCORES} "\${SLURM_JOB_ID}" \${err} ${jobname} "txt,csv"
if [ \$err != 0 ]; then
    exit \$err
else
    touch "$BANDPASS_CHECK_FILE"
fi

EOFOUTER

    if [ "${SUBMIT_JOBS}" == "true" ]; then
	DEP=""
        DEP=$(addDep "$DEP" "$DEP_START")
        DEP=$(addDep "$DEP" "$ID_SPLIT_SCI")
        DEP=$(addDep "$DEP" "$ID_CBPCAL")
	ID_CCALAPPLY_SCI=$(sbatch $DEP "$sbatchfile" | awk '{print $4}')
	recordJob "${ID_CCALAPPLY_SCI}" "Applying bandpass calibration to science observation, with flags \"$DEP\""
	ID_CCALAPPLY_SCI_LIST=$(addDep "$ID_CCALAPPLY_SCI" "$ID_CCALAPPLY_SCI_LIST")
    else
	echo "Would apply bandpass calibration to science observation with slurm file $sbatchfile"
    fi

    echo " "

fi
