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

    # st.markdown(
    #     """
    # #### Description of Features
    # This app is designed to predict whether customer will churn the company or not. You can input the features of the product listed below and get the prediction.
    # - Customers who left within the last month:- the column is called Churn
    # - Services that each customer has signed up for:-  phone, multiple lines, internet, online security, online backup, device protection, tech support, and streaming TV and movies
    # - Customer account information:- how long they have been a customer, contract, payment method, paperless billing, monthly charges, and total charges
    # - Demographic info about customers:- gender, age range, and if they have partners and dependents
    #
    # """
    # )
    # customer_id = st.number_input("Customer ID")
    # gender = st.number_input("Gender")
    # SeniorCitizen = st.number_input("Senior Citizen")
    # Partner = st.number_input("Partner")
    # Dependents = st.number_input("Dependents")
    # tenure = st.number_input("tenure")
    # PhoneService = st.number_input("PhoneService")
    # MultipleLines = st.number_input("MultipleLines")
    # InternetService = st.number_input("InternetService")
    # OnlineSecurity = st.number_input("OnlineSecurity")
    # OnlineBackup = st.number_input("OnlineBackup")
    # DeviceProtection = st.number_input("DeviceProtection")
    # TechSupport = st.number_input("TechSupport")
    # StreamingTV = st.number_input("StreamingTV")
    # StreamingMovies = st.number_input("StreamingMovies")
    # Contract = st.number_input("Contract")
    # PaperlessBilling = st.number_input("PaperlessBilling")
    # PaymentMethod = st.number_input("PaymentMethod")
    # MonthlyCharges = st.number_input("MonthlyCharges")
    # TotalCharges = st.number_input("TotalCharges")

    if st.button("Predict"):
        test_data = get_test_data()
        send_predictions(test_data)

        # pred = [
        #     [
        #         customer_id,
        #         gender,
        #         SeniorCitizen,
        #         Partner,
        #         Dependents,
        #         tenure,
        #         PhoneService,
        #         MultipleLines,
        #         InternetService,
        #         OnlineSecurity,
        #         OnlineBackup,
        #         DeviceProtection,
        #         TechSupport,
        #         StreamingTV,
        #         StreamingMovies,
        #         Contract,
        #         PaperlessBilling,
        #         PaymentMethod,
        #         MonthlyCharges,
        #         TotalCharges,
        #     ]
        # ]
        # data = np.array(pred)
        # pred = service.predict(data)
        # st.success(f"Given the customer's historical data, model says:- {pred}")
        st.success(f"Given the customer's historical data, model says:- ?")


if __name__ == "__main__":
    main()
