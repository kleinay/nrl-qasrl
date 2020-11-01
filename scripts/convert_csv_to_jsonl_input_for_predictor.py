import pandas as pd, json, sys, os
inp_fn = sys.argv[-1]
df = pd.read_csv(inp_fn)
df = df[df['is_verbal']].copy()
df = df[['qasrl_id', 'target_idx', 'verb_form', 'sentence']].drop_duplicates()
df.rename(columns={'target_idx': 'predicate_indices', 'verb_form': 'verb_forms'}, inplace=True)
df = df.groupby(['qasrl_id', 'sentence']).agg({'predicate_indices': list, 'verb_forms': list}).reset_index()
inputs = df.to_dict(orient='records')
out_path = os.path.splitext(inp_fn)[0] + ".jsonl"
with open(out_path, "w", encoding="utf-8") as fout:
    for input in inputs:
        inp_s = json.dumps(input)
        fout.write(inp_s)
        fout.write("\n")