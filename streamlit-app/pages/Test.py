from time import sleep

import numpy as np
import streamlit as st

from seldon_core.seldon_client import SeldonClient


def send_client_request(seldon_client):
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
    gateway_endpoint="ambassador.ambassador.svc",
    namespace="seldon",
)

st.sidebar.image("./resources/logo.png", use_column_width=True)
st.title("Practical guide to A/B Testing for ML applications")
st.markdown("***")
st.markdown(
    """ 
    ### Sending a test request
    """
)
st.text("\n")
test_text = st.text_input("Input Message", value="This is a good message.")
st.text("\n")

if st.button("Predict"):
    with st.spinner(text='In progress'):
        sleep(0.5)
        prediction = send_client_request(sc)

        data = prediction.response.get("data")
        meta = prediction.response.get("meta")
        st.json(prediction.response)
        result = data.get("ndarray")
        tag = meta.get("tags")
        metrics = meta.get("metrics")
        version = tag.get("version")
        response_time = int(metrics[0].get("value"))

        st.success(
            f"""
                Prediction: {result}. \n\n  
                Model Version: {version}. \n\n 
                Response time: {response_time} ms.
            """
        )

