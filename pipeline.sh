#!/usr/bin/env bash

_home=$(dirname $0)

$_home/prepare_datasets.sh

function check_return {
	ret_code=$?

	msg=$1
	if [[ $ret_code -ne 0 ]]; then
		echo "[$ret_code] Error occured during ${msg}!"
		exit $ret_code
	fi
}

function check_dir {
	if [[ ! -d $1 ]]; then
		echo "Creating \"${1}\""
		mkdir -p $1
	fi
}

export OMP_NUM_THREADS=2

# export RESULTS=${PIPELINE_OUTPUT}/results_C${C}/$(date +%Y-%m-%d-%H.%M.%S)
export RESULTS=${PIPELINE_OUTPUT}/results_C${C}
echo "Trained SVMs and features are saved under ${RESULTS}"

check_dir "${RESULTS}"


export DATA=${CODE_ROOT}/data.yaml

# echo "Pipeline starts in 5s, time for last checks ..."
# sleep 5s

for NAME in $DATASETS ; do
	CNN_ARCH=inception
	INPUT_SIZE=427
	OPTS=""

	if [[ ${NAME} == "CUB200" ]]; then
		label_shift=1

	elif [[ ${NAME} == "NAB" ]]; then
		label_shift=0

	elif [[ ${NAME} == "CARS" ]]; then
		label_shift=1
		CNN_ARCH=resnet
		INPUT_SIZE=448

	elif [[ ${NAME} == "FLOWERS" ]]; then
		label_shift=1
	else
		echo "Unknown dataset: $NAME"
		exit 1
	fi

	export DATASET=$NAME
	export WEIGHTS=${CONTAINER_DATA}/models/ft_${NAME}_${CNN_ARCH}.npz

	DATASET_FOLDER=${CONTAINER_DATA}/${DATASETS_FOLDER}/${NAME}
	OPTS=""

	if [[ ! -d $DATASET_FOLDER ]]; then
		echo "Could not find dataset folder \"$DATASET_FOLDER\""
		continue
	fi

	echo "Running pipeline for \"${NAME}\" with label_shift=${label_shift} and data folder: \"${DATASET_FOLDER}\"..."

	LOGDIR=${RESULTS}/logs/${NAME}
	check_dir $LOGDIR

	FEAT_DIR=${DATASET_FOLDER}/features/
	check_dir $FEAT_DIR

	# OPTS="${OPTS} --no_center_crop_on_val"
	# OPTS="${OPTS} --swap_channels"
	OPTS="${OPTS} --input_size $INPUT_SIZE"
	OPTS="${OPTS} --label_shift ${label_shift}"
	OPTS="${OPTS} --prepare_type model"

	export MODEL_TYPE=$CNN_ARCH

	###############################################
	# extract global features
	###############################################
	if [[ $SKIP_GLOBAL_FEATURE_EXTRACTION != "1" ]]; then

		export N_JOBS=3
		export OUTPUT=${FEAT_DIR}
		export PARTS=GLOBAL

		cd ${REPOS_ROOT}/${EXTRACTOR_FOLDER}/scripts
		./extract.sh \
			--logfile ${LOGDIR}/00_global_extraction.log \
			${OPTS}

		check_return "Global Feature Extraction"
	else
		echo "Skipping Global Feature Extraction"
	fi

	###############################################
	# Baseline SVM
	###############################################
	if [[ $SKIP_BASELINE_SVM != "1" ]]; then

		export OUTPUT=${RESULTS}
		export PARTS=GLOBAL

		cd ${REPOS_ROOT}/${SVM_FOLDER}/scripts
		./train.sh \
			--C $C \
			--logfile ${LOGDIR}/01_Baseline_SVM.log

		check_return "Baseline SVM Training"
	else
		echo "Skipping Baseline SVM Training"
	fi

	###############################################
	# Train L1 SVM
	###############################################
	if [[ $SKIP_SPARSE_SVM_TRAINING != "1" ]]; then

		export OUTPUT=${RESULTS}
		export PARTS=GLOBAL

		cd ${REPOS_ROOT}/${SVM_FOLDER}/scripts
		./train.sh \
			--sparse \
			--C $C \
			--logfile ${LOGDIR}/02_L1_training.log

		check_return "L1 Training"
	else
		echo "Skipping L1 Training"
	fi


	###############################################
	# estimate L1-SVM parts
	###############################################
	if [[ $SKIP_PARTS_ESTIMATION != "1" ]]; then
		export N_JOBS=0
		export SVM_OUTPUT=${RESULTS}

		cd ${REPOS_ROOT}/${SVM_FOLDER}/scripts
		./locs_from_L1_SVM.sh ${OPTS} \
			--logfile ${LOGDIR}/03_part_estimation.log \
			--weights ${WEIGHTS} \
			--topk 5 \
			--K $N_PARTS \
			--thresh_type otsu \
			--extract \
				${DATASET_FOLDER}/L1_pred/parts/part_locs.txt \
				${DATASET_FOLDER}/L1_full/parts/part_locs.txt

		check_return "Part Estimation"
	else
		echo "Skipping Part Estimation"
	fi

	for parts in L1_pred L1_full; do

		###############################################
		# extract part features
		###############################################
		if [[ $SKIP_PARTS_EXTRACTION != "1" ]]; then
			export N_JOBS=3
			export OUTPUT=${FEAT_DIR}
			export PARTS=${parts}

			cd ${REPOS_ROOT}/${EXTRACTOR_FOLDER}/scripts
			./extract.sh \
				--logfile ${LOGDIR}/04_part_extraction_${parts}.log \
				${OPTS}

			check_return "(${parts}) Part Feature Extraction"
		else
			echo "Skipping (${parts}) Part Feature Extraction"
		fi
		###############################################
		# train SVM on these parts
		###############################################
		if [[ $SKIP_PARTS_SVM_TRAINING != "1" ]]; then
			export OUTPUT=${RESULTS}
			export PARTS=${parts}

			cd ${REPOS_ROOT}/${SVM_FOLDER}/scripts
			./train.sh \
				-clf svm \
				--logfile ${LOGDIR}/05_svm_training_${parts}.log \
				# --no_dump

			check_return "(${parts}) SVM Training"
		else
			echo "Skipping (${parts}) SVM Training"
		fi

	done


done


# go back, where the script was invoked
# cd $_home
