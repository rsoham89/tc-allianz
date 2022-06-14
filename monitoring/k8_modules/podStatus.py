from kubernetes import client, config, watch
def pod_usage(namespace):
    config.load_kube_config()
    api = client.CustomObjectsApi()
    resource = api.list_namespaced_custom_object(group="metrics.k8s.io",version="v1beta1", namespace=namespace, plural="pods")
    for item in resource['items']:
        print(f"pod name: {item['metadata']['name']}")
        for container in item['containers']:
            print(f"container name: {container['name']}")
            print(f"CPU Usage: {container['usage']['cpu']}")
            print(f"Memory Usage: {container['usage']['memory']}")