import logging
import pandas as pd

from app.RedditClassifier import RedditClassifier
from training.train import train
from sklearn.model_selection import train_test_split


train()

logging.info("Test model prediction.")
classifier = RedditClassifier(models_dir="models")
df_cols = ["prev_idx", "parent_idx", "body", "removed"]

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

# With one sample
sample = x_test[0:1]
logging.info(sample)
logging.info(classifier.predict(sample, ["feature_name"]))
logging.info("Finished testing.")
