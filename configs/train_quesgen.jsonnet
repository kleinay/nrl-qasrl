{
  "vocabulary": {
    "pretrained_files": {"tokens": "data/glove/glove.6B.100d.txt.gz"},
    "only_include_pretrained_words": true
  },
  "dataset_reader": {
      "type": "qasrl"
 },
  "train_data_path": "${QASRL_DATA_DIR}/orig/train.jsonl.gz",
  "validation_data_path": "${QASRL_DATA_DIR}/orig/dev.jsonl.gz",
  "test_data_path": "${QASRL_DATA_DIR}/orig/test.jsonl.gz",
  "model": {
    "type": "question_predictor",
    "text_field_embedder": {
      "tokens": {
        "type": "embedding",
        "embedding_dim": 100,
        "pretrained_file": "data/glove/glove.6B.100d.txt.gz",
        "trainable": true
      }
    },
    "question_generator": {
        "type": "sequence",
        "slot_labels": ["wh", "aux", "subj", "verb", "obj", "prep", "obj2"],
        "dim_slot_hidden":100,
        "dim_rnn_hidden": 200,
        "input_dim": 300,
        "rnn_layers": 4,
        "share_rnn_cell": false
    },
    "stacked_encoder": {
      "type": "alternating_lstm",
      "use_highway": true,
      "input_size": 200,
      "hidden_size": 300,
      "num_layers": 4,
      "recurrent_dropout_probability": 0.1
    },
    "predicate_feature_dim":100
  },
  "iterator": {
    "type": "bucket",
    "sorting_keys": [["text", "num_tokens"]],
    "batch_size" : 80
  },
  "trainer": {
    "num_epochs": 200,
    "grad_norm": 1.0,
    "patience": 20,
    "validation_metric": "+question-role-accuracy",
    "cuda_device": 0,
    "optimizer": {
      "type": "adadelta",
      "rho": 0.95
    }
  }
}
