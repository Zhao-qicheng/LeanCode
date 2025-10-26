# -*- coding: utf-8 -*-
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

import os
import json
import numpy as np
from more_itertools import chunked

def format_str(string):
    for char in ['\r\n', '\r', '\n']:
        string = string.replace(char, ' ')
    return string

def preprocess_test_data_new(DATA_DIR, test_batch_size=1000):
    path = os.path.join(DATA_DIR, 'test.txt')
    print(path)
    with open(path,'r')as f:
        data=f.readlines()
    # with gzip.open(path, 'r') as pf:
    #     data = pf.readlines()

    idxs = np.arange(len(data))
    data = np.array(data, dtype=object)

    np.random.seed(0)   # set random seed so that random things are reproducible
    np.random.shuffle(idxs)
    data = data[idxs]
    batched_data = chunked(data, test_batch_size)

    print("start processing")
    for batch_idx, batch_data in enumerate(batched_data):
        if batch_idx==1:
            break
        if len(batch_data) < test_batch_size:
            break # the last batch is smaller than the others, exclude.
        examples = []
        for d_idx, d in enumerate(batch_data):
            code_a,doc_a,url_a=d.strip().split('<CODESPLIT>')
            for dd in batch_data:
                code_b, doc_b, url_b = dd.strip().split('<CODESPLIT>')
                example = (str(1), url_b, url_a, doc_b, code_a)
                example = '<CODESPLIT>'.join(example)
                examples.append(example)

        data_path = os.path.join(DATA_DIR, 'test')
        if not os.path.exists(data_path):
            os.makedirs(data_path)
        file_path = os.path.join(data_path, 'batch_{}.txt'.format(batch_idx))
        print(file_path)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines('\n'.join(examples))



# if __name__ == '__main__':
#     ratios=['10','20','30','40','50']
#     for ratio in ratios:
#         preprocess_test_data_new('./../data/codesearch/slimcode/'+ratio)
#         preprocess_test_data_new('./../data/codesearch/dietcode/' + ratio)
#         preprocess_test_data_new('./../data/codesearch/leancode_d/' + ratio)
if __name__ == '__main__':
    ratios=['10','20','30','40','50']
    for ratio in ratios:
        # slimcode 需要区分 codebert 和 codet5
        preprocess_test_data_new('./../data/codesearch/slimcode/codebert/'+ratio)
        preprocess_test_data_new('./../data/codesearch/slimcode/codet5/'+ratio)
        preprocess_test_data_new('./../data/codesearch/dietcode/' + ratio)
        preprocess_test_data_new('./../data/codesearch/leancode_d/' + ratio)