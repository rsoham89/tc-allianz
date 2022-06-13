from kubernetes import client, config, watch
import os

# Configs can be set in Configuration class directly or using helper utility
config.load_kube_config()

v1 = client.CoreV1Api()

w = watch.Watch()
if (os.getenv("NODE_HOSTNAME") is None):
    sys.exit("NODE_HOSTNAME is not defined")
hostName = os.getenv("NODE_HOSTNAME")
pendingPods = []
runningPods = []
failedPods = []
deletingPods = []

for event in w.stream(v1.list_namespaced_pod, namespace = "default"):
    updatedPod = event["object"]

    if updatedPod.spec.node_name != hostName:
        continue

    podId = updatedPod.metadata.name

    if podId in pendingPods: pendingPods.remove(podId)
    if podId in failedPods: failedPods.remove(podId)
    if podId in runningPods: runningPods.remove(podId)
    if podId in deletingPods: deletingPods.remove(podId)

    # If the event is a delete event, ignore it
    if event["type"] == "DELETED":
        if pod.metadata.deletion_timestamp is not None:
            deletingPods.append(podId)
        elif pod.status.phase == "Pending":
            if (pod.status.container_statuses is not None and 
                    pod.status.container_statuses[0].state is not None and 
                    pod.status.container_statuses[0].state.waiting is not None and 
                    pod.status.container_statuses[0].state.waiting.message is not None):
                failedPods.append(podId)
            else:
                pendingPods.append(podId)
        elif pod.status.phase == "Running":
            runningPods.append(podId)