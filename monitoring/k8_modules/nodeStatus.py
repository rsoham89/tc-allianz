"""
#--------------------------------------------------------------------------------------------
#| Module: nodeStatus.py
#| Function:   node_status()                                                               						   
#| Author: Soham Roy                                                       					           
#| Version: 1.0                                                                             						
#| Date: 14.06.2022                                                                        						   
#| Schedule run: On demand                                                                  					   
#| Dependent file: None                                                          						   
#| Purpose: This script checks the nodes of a cluster and prints its status 	   
#| Example Run: bash init.sh
#| Dependencies: kubernetes module should be installed pip3 install python-kubernetes                                                          					   
#--------------------------------------------------------------------------------------------
"""
from kubernetes import client, config

def node_status():
    # Loading config
    config.load_kube_config()
    # Call CoreV1Api extension
    v1 = client.CoreV1Api()
    # Call List Node function
    node_details = v1.list_node()
    node_name = []
    # List all the nodes
    for item in node_details.items:
        node_name.append(item.metadata.name)
    # Print Kubelet status
    for node in node_name:
        nodes_resp = v1.read_node_status(node)
        for item in nodes_resp.status.conditions:
            print(f"message: {item.message}")
            print(f"reason: {item.reason}")
            print(f"status: {item.status}")
            print(f"type: {item.type}")