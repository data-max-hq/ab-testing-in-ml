import logging
from time import sleep

import numpy as np
import pandas as pd
import streamlit as st

from Constants import Constants

from sklearn.model_selection import train_test_split
from seldon_core.seldon_client import SeldonClient

st.sidebar.image(Constants.LOGO_IMAGE, use_column_width=True)
st.title("Practical guide to A/B Testing for ML applications")
st.markdown("***")

st.markdown(
    """ 
    ### Sending many requests.
    """
)
st.text("\n")


def update_metrics_a():
    placeholder_model_a_count.metric("Model A responses", st.session_state.model_a_count)
    placeholder_model_a_latest.metric("Latest response time", f"{st.session_state.model_a_latest} ms")


def update_metrics_b():
    placeholder_model_b_count.metric("Model B responses", st.session_state.model_b_count)
    placeholder_model_b_latest.metric("Latest response time", f"{st.session_state.model_b_latest} ms")


def init_session_state():
    st.session_state.model_a_count = 0
    st.session_state.model_a_latest = 0
    st.session_state.model_b_count = 0
    st.session_state.model_b_latest = 0


def update_state_and_ui(prediction):
    meta = prediction.response.get("meta")
    tag = meta.get("tags")
    metrics = meta.get("metrics")
    version = tag.get("version")
    response_time = int(metrics[0].get("value"))

    if version == "A":
        st.session_state.model_a_count = st.session_state.model_a_count + 1
        st.session_state.model_a_latest = response_time
        update_metrics_a()

    else:
        st.session_state.model_b_count = st.session_state.model_b_count + 1
        st.session_state.model_b_latest = response_time
        update_metrics_b()


init_session_state()
load_predict_button = st.button("Predict")
st.text("\n")

placeholder_sending = st.empty()

progress_bar = st.progress(0)
st.text("\n")


model_a, model_b = st.columns(2)

with model_a:
    placeholder_model_a_count = st.empty()
    placeholder_model_a_latest = st.empty()

with model_b:
    placeholder_model_b_count = st.empty()
    placeholder_model_b_latest = st.empty()

update_metrics_a()
update_metrics_b()


@st.cache_data
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
    dataset_size = len(x_test)
    for i in range(dataset_size):
        progress_bar.progress(int(((i+1)/dataset_size)*100))
        to_classify_text = x_test[i]

        prediction = send_client_request(sc, to_classify_text)
        logging.info(prediction)
        update_state_and_ui(prediction)

        sleep(0.5)


sc = SeldonClient(
    gateway="ambassador",
    transport="rest",
    gateway_endpoint="emissary-ingress.emissary.svc",
    namespace="seldon",
)

if load_predict_button:
    placeholder_sending.warning("🧘‍ Reaching Nirvana...")
    init_session_state()

    test_data = get_test_data()
    send_predictions(test_data[:200])

    placeholder_sending.text("")
    st.success(f"🧘‍ Finished.")
