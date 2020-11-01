import os,sys
from argparse import ArgumentParser
import json
import pandas as pd
sys.path.append("/home/nlp/kleinay/Synced/nrl-parser")
from qanom.annotations.decode_encode_answers import encode_qasrl

def load_records(path):
    with open(path, "r", encoding="utf-8") as fin:
        records = [json.loads(line) for line in fin]
        return records

def replace_underscore_with_empty_string(s: str):
    return s if s!="_" else ""

def apply_for_values(dic, func):
    return {k:func(v) for k,v in dic.items()}

def yield_roles_from_parser(records, min_score):
    for rec in records:
        qasrl_id = rec['qasrl_id']
        sentence = " ".join(rec['words'])
        for verb in rec['verbs']:
            predicate = verb['verb']
            predicate_idx = verb['index']
            for qa_pair in verb['qa_pairs']:
                question = qa_pair['question']
                slots = qa_pair['slots']
                slots = apply_for_values(slots, replace_underscore_with_empty_string)
                answer_ranges = [(span['start'], span['end']+1)
                                 for span in qa_pair['spans']
                                 if span['score'] > min_score]
                answers = [span['text'] for span in qa_pair['spans']
                           if span['score'] > min_score]
                if not answer_ranges:
                    continue
                item = {
                    'qasrl_id': qasrl_id,
                    'sentence': sentence,
                    'verb_idx': predicate_idx,
                    'verb': predicate,
                    'question': question,
                    'answer': answers,
                    'answer_range': answer_ranges,
                }
                item.update(slots)

                yield item
def main(args):
    records = load_records(args.parser_path)
    records = list(yield_roles_from_parser(records, args.min_score))
    df = pd.DataFrame(records)
    slot_headers = ['wh', 'aux', 'subj', 'obj', 'verb_slot_inflection',
                    'prep', 'obj2', 'is_passive', 'is_negated']
    cols = ['qasrl_id', 'sentence', 'verb_idx', 'verb', 'question', 'answer', 'answer_range'] +\
           slot_headers +\
            ['worker_id', 'is_verbal', 'verb_form', 'verb_prefix']
    out_path = os.path.splitext(args.parser_path)[0] + ".csv"
    # add qanom expected columns
    df['worker_id'] = "parser_predictions"
    df['is_verbal'] = True
    df['verb_form'] = "---"
    df['verb_prefix'] = ''
    df = df[cols].copy()
    df = encode_qasrl(df)
    df[cols].to_csv(out_path, index=False, encoding="utf-8")

if __name__ == "__main__":
    ap = ArgumentParser()
    ap.add_argument("parser_path")
    ap.add_argument("--min_score", default=0.0, type=float)
    main(ap.parse_args())