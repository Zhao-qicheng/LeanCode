# -*- coding: utf-8 -*-
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

import os
import numpy as np
from more_itertools import chunked
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--test_batch_size', type=int, default=1000)
    parser.add_argument('--input_path', type=str, required=True, help='Path to the batch result file')
    args = parser.parse_args()
    languages = ['java']
    MRR_dict = {}
    for language in languages:
        # set the file_dir to the path of 0_batch_result.txt which you want to caculate mrr
        # file_dir ='./codesearch/codet5/base/leancode/10/0_batch_result.txt'
        # file_dir ='./models/codesearch/codebert/base/0_batch_result.txt'
        file_dir = args.input_path
        ranks = []
        num_batch = 0
        with open(file_dir, encoding='utf-8') as f:
            data = [line.strip() for line in f]
            group_size = 1000
            sorted_data = []

            for doc_index in range(group_size):
                for code_index in range(group_size):
                    original_index = code_index * group_size + doc_index
                    sorted_data.append(data[original_index])
            batched_data = chunked(sorted_data, args.test_batch_size)
            for batch_idx, batch_data in enumerate(batched_data):
                num_batch += 1
                correct_score = float(batch_data[batch_idx].strip().split('<CODESPLIT>')[-1])
                scores = np.array([float(data.strip().split('<CODESPLIT>')[-1]) for data in batch_data])
                rank = np.sum(scores >= correct_score)
                ranks.append(rank)

        mean_mrr = np.mean(1.0 / np.array(ranks))
        MRR_dict[language] = mean_mrr
    
    # Write results to file
    output_dir = os.path.dirname(args.input_path)
    output_file = os.path.join(output_dir, 'mrr')
    with open(output_file, 'w', encoding='utf-8') as f:
        for language in languages:
            f.write("{} {} mrr: {}\n".format(args.input_path, language, MRR_dict[language]))
        f.write("\n")
        for key, val in MRR_dict.items():
            f.write("{} mrr: {}\n".format(key, val))
    print("Results saved to: {}".format(output_file))


if __name__ == "__main__":
    main()
