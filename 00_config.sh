export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

export OUTPUT_FOLDER=output_moths
export DATASETS_FOLDER=datasets

## container config
export CODE_ROOT=/home/code
export REPOS_ROOT=/home/repos
export CONTAINER_DATA=/data
export PIPELINE_OUTPUT=${CONTAINER_DATA}/${OUTPUT_FOLDER}

if [[ ! -d $OUTPUT_FOLDER ]]; then
	mkdir $OUTPUT_FOLDER
fi
if [[ ! -d $DATASETS_FOLDER ]]; then
	mkdir $DATASETS_FOLDER
fi
