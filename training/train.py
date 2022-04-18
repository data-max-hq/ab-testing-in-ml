import logging

import dill
import pandas as pd

# This import may take a while as it will download the Spacy ENGLISH model
from training.ml_utils import CleanTextTransformer, SpacyTokenTransformer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

# Source: https://github.com/SeldonIO/seldon-core/tree/master/examples/models/sklearn_spacy_text

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - [%(filename)s:%(lineno)d] - %(levelname)s - %(message)s'
)

df_cols = ["prev_idx", "parent_idx", "body", "removed"]

TEXT_COLUMN = "body"
CLEAN_COLUMN = "clean_body"
TOKEN_COLUMN = "token_body"

# Downloading the 50k reddit dataset of moderated comments
logging.info("Read reddit training dataset.")
df = pd.read_csv(
    "https://raw.githubusercontent.com/axsauze/reddit-classification-exploration/master/data/reddit_train.csv",
    names=df_cols,
    skiprows=1,
    encoding="ISO-8859-1",
)

df.head()

x = df["body"].values
y = df["removed"].values
logging.info("Train test split.")
x_train, x_test, y_train, y_test = train_test_split(
    x, y, stratify=y, random_state=42, test_size=0.1, shuffle=True
)

# Clean the text
logging.info("Clean the text.")
clean_text_transformer = CleanTextTransformer()
x_train_clean = clean_text_transformer.transform(x_train)

# Tokenize the text and get the lemmas
logging.info("Tokenize the text and get the lemmas.")
spacy_tokenizer = SpacyTokenTransformer()
x_train_tokenized = spacy_tokenizer.transform(x_train_clean)

# Build tfidf vectorizer
logging.info("Build tfidf vectorizer.")
tfidf_vectorizer = TfidfVectorizer(
    max_features=10000,
    preprocessor=lambda x: x,
    tokenizer=lambda x: x,
    token_pattern=None,
    ngram_range=(1, 3),
)

tfidf_vectorizer.fit(x_train_tokenized)

# Transform our tokens to tfidf vectors
logging.info("Transform our tokens to tfidf vectors.")
x_train_tfidf = tfidf_vectorizer.transform(x_train_tokenized)


# Train logistic regression classifier
logging.info("Train logistic regression classifier.")
lr = LogisticRegression(C=0.1, solver="sag")
lr.fit(x_train_tfidf, y_train)

# These are the models we'll deploy
logging.info("Dump models.")
with open("../models/tfidf_vectorizer.model", "wb") as model_file:
    dill.dump(tfidf_vectorizer, model_file)
with open("../models/lr.model", "wb") as model_file:
    dill.dump(lr, model_file)

logging.info("Finished training.")
