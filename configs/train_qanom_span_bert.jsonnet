local QASRL_DATA_DIR = "data/qasrl-v2";
local QANOM_DATA_DIR = "data/qanom_annotations";
local bert_model = "bert-base-uncased";

{
  "vocabulary": {
    "pretrained_files": {"tokens": "data/glove/glove.6B.100d.txt.gz"},
    "only_include_pretrained_words": true
  },
  "dataset_reader": {
      "type": "qanom",
      "token_indexers": {
          "bert": {
                  "type": "pretrained_transformer",
                  "model_name": bert_model,
                  "do_lowercase": true,
                  #"use_starting_offsets": true,
          },
      },
  },

    // for debug (small data samples):
//  "train_data_path": QANOM_DATA_DIR + "/train_set/final/annot.wikinews.train.1.csv",
//  "validation_data_path": QANOM_DATA_DIR + "/gold_set/final/annot.final.wikinews.dev.5.csv",
//  "test_data_path": QANOM_DATA_DIR + "/gold_set/final/annot.final.wikinews.test.1.csv",

    // for real:
  "train_data_path": QANOM_DATA_DIR + "/train_set/final/annot.train.csv",
  "validation_data_path": QANOM_DATA_DIR + "/gold_set/final/annot.final.dev.csv",
  "test_data_path": QANOM_DATA_DIR + "/gold_set/final/annot.final.test.csv",

  "model": {
    "type": "span_detector",
    "text_field_embedder": {
        "allow_unmatched_keys": true,
        "embedder_to_indexer_map": {
            "bert": ["bert"],
        },
        "token_embedders": {
          "bert": {
            "type": "pretrained_transformer",
            "model_name": bert_model,
          }
      }
    },
    "stacked_encoder": {
      "type": "alternating_lstm",
      "use_highway": true,
      "input_size": 868,
      "hidden_size": 600,
      "num_layers": 1,
      "recurrent_dropout_probability": 0.1
    },
    "predicate_feature_dim":100,
    "thresholds": [0.05, 0.2, 0.5, 0.9],
    "iou_threshold": 0.3,
  },
  "iterator": {
    "type": "bucket",
    "sorting_keys": [["text", "num_tokens"]],
    "batch_size" : 10
  },
  "trainer": {
    "num_epochs": 200,
    "grad_norm": 1.0,
    "patience": 30,
    "validation_metric": "+fscore-at-0.5",
    "cuda_device": 1,
    "optimizer": {
      "type": "adadelta",
      "rho": 0.95
    }
  }
}
