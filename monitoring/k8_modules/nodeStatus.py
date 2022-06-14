from kubernetes import client, config

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