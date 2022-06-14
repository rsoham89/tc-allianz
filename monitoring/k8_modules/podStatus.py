"""
#--------------------------------------------------------------------------------------------
#| Module: podStatus.py
#| Function: pod_status()                                                               						   
#| Author: Soham Roy                                                       					           
#| Version: 1.0                                                                             						
#| Date: 14.06.2022                                                                        						   
#| Schedule run: On demand                                                                  					   
#| Dependent file: None                                                          						   
#| Purpose: This script checks the pods in a namespace and print the usage of the containers 	   
#| Example Run: bash init.sh
#| Dependencies: kubernetes module should be installed pip3 install python-kubernetes                                                          					   
#--------------------------------------------------------------------------------------------
"""
from kubernetes import client, config, watch

def pod_usage(namespace):
    # Loading config
    config.load_kube_config()
     # Call CustomObjectsApi extension
    api = client.CustomObjectsApi()
    # List all pods for the namespace and check the usage
    resource = api.list_namespaced_custom_object(group="metrics.k8s.io",version="v1beta1", namespace=namespace, plural="pods")
    for item in resource['items']:
        print(f"pod name: {item['metadata']['name']}")
        for container in item['containers']:
            print(f"container name: {container['name']}")
            print(f"CPU Usage: {container['usage']['cpu']}")
            print(f"Memory Usage: {container['usage']['memory']}")