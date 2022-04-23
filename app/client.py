from time import sleep

from seldon_core.seldon_client import SeldonClient

import numpy as np

sc = SeldonClient(
    gateway="ambassador",
    transport="rest",
    gateway_endpoint="localhost:8080",  # Make sure you use the port above
    namespace="seldon",
)

for i in range(1000):

    client_prediction = sc.predict(
        data=np.array(["Hello world this is a test"]),
        deployment_name="abtest",
        names=["text"],
        payload_type="ndarray",
    )

    if client_prediction.success:
        print(client_prediction)
    else:
        print(client_prediction)
    sleep(0.5)

