import logging

import numpy as np
import pandas as pd
import streamlit as st

from sklearn.model_selection import train_test_split
from seldon_core.seldon_client import SeldonClient


def send_client_request(seldon_client, test_text):

    client_prediction = seldon_client.predict(
        data=np.array([test_text]),
        deployment_name="abtest",
        names=["text"],
        payload_type="ndarray",
    )

    print(client_prediction)
    return client_prediction


sc = SeldonClient(
    gateway="ambassador",
    transport="rest",
    gateway_endpoint="localhost:8080",
    namespace="seldon",
)


st.title("Practical guide to A/B Testing for ML applications")
st.markdown(
    """ 
#### Send a test request

"""
)

test_text = st.text_input("Input Message", value="This is a good message.")

if st.button("Predict"):

    prediction = send_client_request(sc, test_text=test_text)
    logging.info(prediction)

    st.success(prediction)
