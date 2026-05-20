#!/bin/bash

protocolname="EXVIVO_SHELL5_RUN1"

echo "Finding closest protocol, getting the subsets and processing .nii files"

python get_closest_scheme.py \
    --protocol-name $protocolname \
    --ref-signal all_signals_all_substrates.npy \
    --dwi ~/Documents/SimProjects/Data_ERCExVivo/sub-01/dwi_TE28_denoised_shell5_sphmean.nii \
    --bval ~/Documents/SimProjects/Data_ERCExVivo/sub-01/dwi_TE28_shell5.bval \
    --gdur ~/Documents/SimProjects/Data_ERCExVivo/sub-01/dwi_TE28_shell5.gdur \
    --gsep ~/Documents/SimProjects/Data_ERCExVivo/sub-01/dwi_TE28_shell5.gsep \
    --bval-threshold 20 \
    --vasc-threshold 100 \
    --noise ~/Documents/SimProjects/Data_ERCExVivo/sub-01/dwi_noise.nii \

echo "Selecting parameter configuration: fin vCS_cyl D0in D0ex kappa"

python select_parameter_configuration.py --params fin vCS_cyl --output-folder $protocolname

echo "Fixing parameter array"

python fix_parameters.py --kappa 15 --D0in 0.8 --protocol-folder $protocolname

echo "Making 'fitting' folder"

mkdir -v protocols/$protocolname/fitting

echo "Running fitting script"

python mri2micro_dictml.py \
    protocols/$protocolname/dwi_normalized.nii \
    protocols/$protocolname/kappa_D0in_fixed_sig.npy \
    protocols/$protocolname/kappa_D0in_fixed_params.npy \
    --sldim 0 \
    --savg 3 \
    --ncpu 10 \
    --reg "2,0.01" \
    --noise ~/Documents/SimProjects/Data_ERCExVivo/sub-01/dwi_noise_normalized.nii \
    --mask ~/Documents/SimProjects/Data_ERCExVivo/sub-01/dwi_singleslice_mask.nii \
    protocols/$protocolname/fitting/Histo_uSim
