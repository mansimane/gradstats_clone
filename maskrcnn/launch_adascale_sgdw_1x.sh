#!/bin/bash
BASE_LR=0.06
MAX_ITER=45000
WARMUP_FACTOR=0.000096
WARMUP_ITERS=500
TRAIN_IMS_PER_BATCH=32
TEST_IMS_PER_BATCH=8
WEIGHT_DECAY=1e-3
NSOCKETS_PER_NODE=2
NCORES_PER_SOCKET=24
# in EKS we have 1 GPU per "worker/virtual node"
NPROC_PER_NODE=8
LR_SCHEDULE="COSINE"
WORLD_SIZE=1
RANK=0

# setup NCCL to use EFA
export FI_PROVIDER=efa
export FI_EFA_TX_MIN_CREDITS=64
export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=ens5

# Single node multi-gpu setting on P3dn.24xl - 4 images per GPU

python -m torch.distributed.launch \
 --nproc_per_node=${NPROC_PER_NODE} \
 --nnodes=${WORLD_SIZE} \
 --node_rank=${RANK} \
 /mnt/tools/train_mlperf.py --label $(date +%s) --config-file '/mnt/configs/e2e_mask_rcnn_R_50_FPN_1x_giou_sgd_ls.yaml' \
 PATHS_CATALOG '/mnt/maskrcnn_benchmark/config/paths_catalog.py' \
 DISABLE_REDUCED_LOGGING True \
 SOLVER.BASE_LR ${BASE_LR} \
 SOLVER.WEIGHT_DECAY ${WEIGHT_DECAY} \
 SOLVER.MAX_ITER ${MAX_ITER} \
 SOLVER.WARMUP_FACTOR ${WARMUP_FACTOR} \
 SOLVER.WARMUP_ITERS ${WARMUP_ITERS} \
 SOLVER.WEIGHT_DECAY_BIAS 0 \
 SOLVER.WARMUP_METHOD mlperf_linear \
 SOLVER.IMS_PER_BATCH ${TRAIN_IMS_PER_BATCH} \
 SOLVER.LR_SCHEDULE ${LR_SCHEDULE} \
 SOLVER.GRADIENT_CLIP_VAL 0.0 \
 SOLVER.LR_SCALE 1.0 \
 SOLVER.OPTIMIZER SGDW \
 TEST.IMS_PER_BATCH ${TEST_IMS_PER_BATCH} \
 NHWC True
