from kubernetes import client, config, watch
from model import Nodes

def main():
    # Configs can be set in Configuration class directly or using helper
    # utility. If no argument provided, the config will be loaded from
    # default location.
    print("CHECKING NODE STATUS: ")
    node_status()
    print("CHECKING POD STATUS: ")
    pod_usage()

        
    #print(v1.list_pod_for_all_namespaces())
def node_status():
    config.load_kube_config()
    v1 = client.CoreV1Api()
    node_details = v1.list_node()
    node_name = []
    for item in node_details.items:
        node_name.append(item.metadata.name)
    
    for node in node_name:
        nodes_resp = v1.read_node_status(node)
        for item in nodes_resp.status.conditions:
            print(f"message: {item.message}")
            print(f"reason: {item.reason}")
            print(f"status: {item.status}")
            print(f"type: {item.type}")

def pod_usage():
    config.load_kube_config()
    api = client.CustomObjectsApi()
    resource = api.list_namespaced_custom_object(group="metrics.k8s.io",version="v1beta1", namespace="interview", plural="pods")
    for item in resource['items']:
        print(f"pod name: {item['metadata']['name']}")
        for container in item['containers']:
            print(f"container name: {container['name']}")
            print(f"CPU Usage: {container['usage']['cpu']}")
            print(f"Memory Usage: {container['usage']['memory']}")
main()