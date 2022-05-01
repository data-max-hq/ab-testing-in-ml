import logging
from time import sleep

import pandas as pd
from sklearn.model_selection import train_test_split
from seldon_core.seldon_client import SeldonClient

import numpy as np

sc = SeldonClient(
    gateway="ambassador",
    transport="rest",
    gateway_endpoint="localhost:8080",  # Make sure you use the port above
    namespace="seldon",
)
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
_, x_test, _, _ = train_test_split(
    x, y, stratify=y, random_state=42, test_size=0.1, shuffle=True
)

for i in range(len(x_test)):
    test_text = x_test[i]

    client_prediction = sc.predict(
        data=np.array([test_text]),
        deployment_name="abtest",
        names=["text"],
        payload_type="ndarray",
    )

    print(client_prediction)
    sleep(0.5)

