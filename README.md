[![Build Status](https://travis-ci.org/DiKorsch/l1_parts.svg?branch=master)](https://travis-ci.org/DiKorsch/l1_parts)
# L1-SVM based parts extraction

Code for the paper "[Classification-Specific Parts for Improving Fine-Grained Visual Categorization](https://arxiv.org/abs/1909.07075)"

## Installation

### Prerequisite

*tested on Ubuntu 18.04*

1. Install Docker CE:
```bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce
```
2. Install Docker-compose:
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
3. Install Nvidia-Docker:
```bash
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install nvidia-docker2
```
4. Restart Docker services or reboot your PC.



### Build the experiment image

Create the required docker image with the script:
```bash
./01_install.sh
```

## Running the experiments

### Download the datasets and models

1. Download the needed datasets. Set up the according paths in the `.env` file.
2. Download the [fine-tuned models](models) or copy your own models to the `models` folder

### Start an experiment

You could either start the whole pipeline for all set datasets (`DATASET` variable in the `.env` file):

```bash
./02_main.sh
```

or set according datasets (and GPUs) manually:

```bash
GPU=0 DATASETS=NAB ./02_main.sh
GPU=1 DATASETS="CUB200 FLOWERS" ./02_main.sh
GPU=2 BATCH_SIZE=16 DATASETS=CARS ./02_main.sh
```

All trained SVMs, logs with accuracy results, and extracted features will be stored in `output` and `datasets` folders.


## Citation
You are welcome to use our code in your research! If you do so please cite it as:

```bibtex
@inproceedings{Korsch19_CSPARTS,
  title = {Classification-Specific Parts for Improving Fine-Grained Visual Categorization},
  booktitle = {German Conference on Pattern Recognition (GCPR)},
  author = {Dimitri Korsch and Paul Bodesheim and Joachim Denzler},
  pages = {62--75},
  year = {2019},
}
```
