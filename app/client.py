from seldon_core.seldon_client import SeldonClient

sc = SeldonClient(
    deployment_name="mymodel",
    namespace="seldon",
    gateway_endpoint="localhost:8003",
    gateway="ambassador",
)

r = sc.predict(transport="rest")
assert r.success is True
print(r)
