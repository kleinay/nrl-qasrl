local QASRL_DATA_DIR = "data/qasrl-v2";
local QANOM_DATA_DIR = "data/qanom_annotations";
{
  "vocabulary": {
    "pretrained_files": {"tokens": "data/glove/glove.6B.100d.txt.gz"},
    "only_include_pretrained_words": true
  },
  "dataset_reader": {
      "type": "qanom",
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
  "train_data_path": QANOM_DATA_DIR + "/train_set/final/annot.train.csv",
  "validation_data_path": QANOM_DATA_DIR + "/gold_set/final/annot.final.dev.csv",
  "test_data_path": QANOM_DATA_DIR + "/gold_set/final/annot.final.test.csv",
  "model": {
    "type": "qasrl_parser",
    "span_detector": {
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
        "iou_threshold": 0.3,
      },
    "question_predictor": {
        "type": "question_predictor",
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
        "question_generator": {
            "type": "sequence",
            "slot_labels": ["WH", "AUX", "SBJ", "TRG", "OBJ1", "PP", "OBJ2"],
            "dim_slot_hidden":100,
            "dim_rnn_hidden": 200,
            "input_dim": 300,
            "rnn_layers": 4,
            "share_rnn_cell": false
        },
        "stacked_encoder": {
          "type": "alternating_lstm",
          "input_size": 1224,
          "hidden_size": 300,
          "num_layers": 4,
          "use_highway": true,
          "recurrent_dropout_probability": 0.1
        },
        "predicate_feature_dim":100,
        "hidden_dim":100
     }
  },
  "iterator": {
    "type": "bucket",
    "sorting_keys": [["text", "num_tokens"]],
    "batch_size" : 80
  },
  "trainer": {
    "num_epochs": 200,
    "grad_norm": 1.0,
    "patience": 10,
    "validation_metric": "+fscore-at-0.5",
    "cuda_device": 0,
    "optimizer": {
      "type": "adadelta",
      "rho": 0.95
    }
  },
  "prediction_threshold": 0.02,
}
