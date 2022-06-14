from k8_modules import nodeStatus, podStatus

def main():
    # Configs can be set in Configuration class directly or using helper
    # utility. If no argument provided, the config will be loaded from
    # default location.
    print("CHECKING NODE STATUS: ")
    nodeStatus.node_status()
    print("CHECKING POD STATUS: ")
    podStatus.pod_usage("interview")
main()