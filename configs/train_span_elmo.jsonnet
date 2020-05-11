local QASRL_DATA_DIR = "data/qasrl-v2";

{
  "vocabulary": {
    "pretrained_files": {"tokens": "data/glove/glove.6B.100d.txt.gz"},
    "only_include_pretrained_words": true
  },
  "dataset_reader": {
      "type": "qasrl",
      "token_indexers": {
          "tokens": {
            "type": "single_id",
            "lowercase_tokens": true
          },
          "elmo": {
            "type": "elmo_characters"
          }
      }
 },
  "train_data_path": QASRL_DATA_DIR + "/orig/train.jsonl.gz",
  "validation_data_path": QASRL_DATA_DIR + "/orig/dev.jsonl.gz",
  "test_data_path": QASRL_DATA_DIR + "/orig/test.jsonl.gz",
  "model": {
    "type": "span_detector",
    "text_field_embedder": {
      "tokens": {
        "type": "embedding",
        "embedding_dim": 100,
        "pretrained_file": "data/glove/glove.6B.100d.txt.gz",
        "trainable": true
      },
      "elmo":{
        "type": "elmo_token_embedder",
        "options_file": "data/elmo/elmo_2x4096_512_2048cnn_2xhighway_options.json",
        "weight_file": "data/elmo/elmo_2x4096_512_2048cnn_2xhighway_weights.hdf5",
        "do_layer_norm": false,
        "dropout": 0.5
      }
    },
    "stacked_encoder": {
      "type": "alternating_lstm",
      "use_highway": true,
      "input_size": 1224,
      "hidden_size": 300,
      "num_layers": 8,
      "recurrent_dropout_probability": 0.1
    },
    "predicate_feature_dim":100,
    "thresholds": [0.2, 0.3, 0.5, 0.7, 0.8],
    "iou_threshold": 0.3,
  },
  "iterator": {
    "type": "bucket",
    "sorting_keys": [["text", "num_tokens"]],
    "batch_size" : 80
  },
  "trainer": {
    "num_epochs": 200,
    "grad_norm": 1.0,
    "patience": 100,
    "validation_metric": "+fscore-at-0.5",
    "cuda_device": 3,
    "optimizer": {
      "type": "adadelta",
      "rho": 0.95
    }
  }
}
