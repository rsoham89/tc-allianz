# import the modules for node status and pod status
from k8_modules import nodeStatus, podStatus

def main():
    print("CHECKING NODE STATUS: ")
    nodeStatus.node_status()
    print("CHECKING POD STATUS: ")
    podStatus.pod_usage("interview")
main()