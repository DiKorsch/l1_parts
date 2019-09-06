#!/usr/bin/env python
if __name__ != '__main__': raise Exception("Do not import me!")

import re
import numpy as np

from argparse import ArgumentParser
from glob import glob
from os.path import join, isdir, isfile

from prettytable import PrettyTable

# encodes the filename and the line, where the accuracy is located
BASELINE = ("01_Baseline_SVM.log", "Accuracy glob_only:")

L1_PRED = ("05_svm_training_L1_pred.log", "Accuracy all_parts:")
L1_FULL = ("05_svm_training_L1_full.log", "Accuracy all_parts:")

DATASETS = ["CUB200", "FLOWERS", "NAB", "CARS"]

def read_accuracy(log_dir, info):
	fpath = join(log_dir, info[0])

	if not isfile(fpath):
		return np.nan

	regex = re.compile(f"{info[1]} " + r"(\d{2}.\d{2,4})%")

	with open(fpath) as f:
		for line in f:
			match = regex.search(line)
			if match is not None:
				return float(match.group(1))
	return np.nan

def main(args):
	for dataset in args.datasets:
		path_pattern = join(args.results_dir, "*", "logs", dataset)
		tab = PrettyTable(
			field_names=["Baseline", "L1 Pred", "L1 Full"],
			title=f"Accuracies for {dataset}:",

		)

		accs = []
		for log_dir in glob(path_pattern):
			if not isdir(log_dir): continue

			baseline_acc = read_accuracy(log_dir, BASELINE)
			l1_pred_acc = read_accuracy(log_dir, L1_PRED)
			l1_full_acc = read_accuracy(log_dir, L1_FULL)

			row = [baseline_acc, l1_pred_acc, l1_full_acc]
			tab.add_row(row)
			accs.append(row)

		accs = np.array(accs)
		means, stds = np.nanmean(accs, axis=0), np.nanstd(accs, axis=0)

		final_row = [f"{m:.4f} +/- {s:.2f}" for m,s in zip(means, stds)]
		tab.add_row(final_row)

		print(tab)



parser = ArgumentParser()

parser.add_argument("results_dir")
parser.add_argument("--datasets", "-d", nargs="+", choices=DATASETS, default=DATASETS)


main(parser.parse_args())
