import logging
from time import sleep

import numpy as np
import pandas as pd
import streamlit as st

from sklearn.model_selection import train_test_split
from seldon_core.seldon_client import SeldonClient


@st.experimental_memo
def get_test_data():
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

    return x_test


def send_client_request(seldon_client, test_text):

    client_prediction = seldon_client.predict(
        data=np.array([test_text]),
        deployment_name="abtest",
        names=["text"],
        payload_type="ndarray",
    )

    print(client_prediction)
    return client_prediction


def send_predictions(x_test):
    for i in range(len(x_test)):
        to_classify_text = x_test[i]

        prediction = send_client_request(sc, to_classify_text)
        logging.info(prediction)
        sleep(0.5)


sc = SeldonClient(
    gateway="ambassador",
    transport="rest",
    gateway_endpoint="localhost:8080",
    namespace="seldon",
)


def main():
    st.title("Practical guide to A/B Testing for ML applications")

    st.markdown(
        """ 
    #### Problem Statement 
    Compare prediction time for two ML models in an A/B testing set up.

    """
    )

    if st.button("Predict"):
        test_data = get_test_data()
        send_predictions(test_data)

        st.success(f"Given the customer's historical data, model says:- ?")


if __name__ == "__main__":
    main()
