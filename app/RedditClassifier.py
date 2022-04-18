import pickle

from ml_utils import CleanTextTransformer, SpacyTokenTransformer


class RedditClassifier(object):
    def __init__(self):

        self._clean_text_transformer = CleanTextTransformer()
        self._spacy_tokenizer = SpacyTokenTransformer()

        with open("../models/tfidf_vectorizer.model", "rb") as model_file:
            self._tfidf_vectorizer = pickle.load(model_file)

        with open("../models/lr.model", "rb") as model_file:
            self._lr_model = pickle.load(model_file)

    def predict(self, X, feature_names):
        clean_text = self._clean_text_transformer.transform(X)
        spacy_tokens = self._spacy_tokenizer.transform(clean_text)
        tfidf_features = self._tfidf_vectorizer.transform(spacy_tokens)
        predictions = self._lr_model.predict_proba(tfidf_features)
        return predictions

    def metrics(self):
        # https://github.com/SeldonIO/seldon-core/blob/master/examples/models/custom_metrics/ModelWithMetrics.py
        print("metrics called")
        return [
            {"type": "COUNTER", "key": "mycounter", "value": 1}, # a counter which will increase by the given value
            {"type": "GAUGE", "key": "mygauge", "value": 100},   # a gauge which will be set to given value
            {"type": "TIMER", "key": "mytimer", "value": 20.2},  # a timer which will add sum and count metrics - assumed millisecs
        ]
