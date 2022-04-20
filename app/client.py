from seldon_core.seldon_client import SeldonClient

import numpy as np

# sc = SeldonClient(
#     deployment_name="abtest",
#     namespace="seldon",
#     gateway_endpoint="localhost:8003",
#     gateway="ambassador",
# )
#
# r = sc.predict(transport="rest")
# assert r.success is True
# print(r)


sc = SeldonClient(
    gateway="ambassador",
    transport="rest",
    gateway_endpoint="localhost:8003",  # Make sure you use the port above
    namespace="seldon",
)

client_prediction = sc.predict(
    data=np.array(["Hello world this is a test"]),
    deployment_name="abtest",
    names=["text"],
    payload_type="ndarray",
)

print(client_prediction)

