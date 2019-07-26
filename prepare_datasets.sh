#!/usr/bin/env bash


DEST=${CONTAINER_DATA}/${DATASETS_FOLDER}
touch ${DEST}/.nobackup

SRC=/data/original_datasets

LN="ln -sf"
MKDIR="mkdir -p"

for DATA_DIR in $SRC/*; do

	DATA_NAME=$(basename ${DATA_DIR})
	$MKDIR ${DEST}/${DATA_NAME}/features

	for subset in GLOBAL GT L1_full L1_pred; do

		DIR=${DEST}/${DATA_NAME}/${subset}/

		$MKDIR $DIR

		$LN $(realpath ${DATA_DIR}/*.txt) $DIR
		$LN $(realpath ${DATA_DIR}/images) $DIR
		$LN ../features ${DIR}/features

		if [[ -d  ${DATA_DIR}/parts && ($subset == "GT" || $subset == "GLOBAL") ]]; then
			$LN $(realpath ${DATA_DIR}/parts) $DIR

		else
			$MKDIR $DIR/parts

			if [[ ! -f $DIR/parts/parts.txt ]]; then
				for (( i = 0; i < $N_PARTS; i++ )); do
					echo "${i} Part_${i}" >> $DIR/parts/parts.txt
				done
			fi
		fi
	done

done
