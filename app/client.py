from seldon_core.seldon_client import SeldonClient

import numpy as np

sc = SeldonClient(
    deployment_name="mymodel",
    namespace="seldon",
    gateway_endpoint="localhost:8003",
    gateway="ambassador",
)

r = sc.predict(transport="rest")
assert r.success is True
print(r)


# sc = SeldonClient(
#     gateway="ambassador",
#     transport="rest",
#     gateway_endpoint="localhost:80",  # Make sure you use the port above
#     namespace="default",
# )
#
# client_prediction = sc.predict(
#     data=np.array(["Hello world this is a test"]),
#     deployment_name="reddit-classifier",
#     names=["text"],
#     payload_type="ndarray",
# )
#
# print(client_prediction)

