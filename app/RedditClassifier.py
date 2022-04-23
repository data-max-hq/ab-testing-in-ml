import datetime
import os
from time import sleep
import random

import dill

from ml_utils import CleanTextTransformer, SpacyTokenTransformer
import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - [%(filename)s:%(lineno)d] - %(levelname)s - %(message)s'
)


class RedditClassifier(object):
    def __init__(self, models_dir="/models"):

        self._clean_text_transformer = CleanTextTransformer()
        self._spacy_tokenizer = SpacyTokenTransformer()
        self._version = os.getenv("VERSION", "A")
        self._models_dir = models_dir

        logging.info(f"Loading version {self._version}.")
        with open(f"{self._models_dir}/tfidf_vectorizer.model", "rb") as model_file:
            self._tfidf_vectorizer = dill.load(model_file)

        with open(f"{self._models_dir}/lr.model", "rb") as model_file:
            self._lr_model = dill.load(model_file)

    def predict(self, X, feature_names):
        logging.info("Got request.")
        start_time = datetime.datetime.now()
        clean_text = self._clean_text_transformer.transform(X)
        spacy_tokens = self._spacy_tokenizer.transform(clean_text)
        tfidf_features = self._tfidf_vectorizer.transform(spacy_tokens)
        predictions = self._lr_model.predict_proba(tfidf_features)
        if self._version == "B":
            sleep_time = random.uniform(0.1, 1.0)
            logging.info(f"Version {self._version} waiting for {sleep_time} sec.")
            sleep(sleep_time)
        end_time = datetime.datetime.now()
        time_diff = (end_time - start_time)
        # Get run time in ms
        self._run_time = time_diff.total_seconds() * 1000

        return predictions

    def metrics(self):
        # https://github.com/SeldonIO/seldon-core/blob/master/examples/models/custom_metrics/ModelWithMetrics.py
        print("metrics called")
        return [
            {"type": "COUNTER", "key": "mycounter", "value": 1},  # a counter which will increase by the given value
            {"type": "GAUGE", "key": "gauge_runtime", "value": self._run_time},   # a gauge which will be set to given value
            {"type": "TIMER", "key": "runtime", "value": self._run_time},  # a timer which will add sum and count metrics - assumed millisecs
        ]

    def tags(self):
        return {"version": self._version}
