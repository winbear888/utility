usage() {
    echo "Cordon GKE nodepool"
    echo 
    echo "Usage:"
    echo "  cordon_nodepool.sh  [OPTION] project_id=PROJECT_ID cluster_name=CLUSTER_NAME node_pool_name=NODE_POOL_NAME region=REGION"
    echo "Options:"
    echo "  -u                  uncordon node pool NODE_POOL_NAME."
    echo "  -e                  enable auto scaling. Only used when -u is specified."
    echo "                      -min_node and -max_node must also be specified."
    echo "  -min_node=MIN_NODE  minimum node count. Only used when -e is specified."
    echo "  -max_node=MAX_NODE  maximum node count. Only used when -e is specified."
}

set -e

cordon() {
# if [ $# -ne 4 ]; then
#   usage
# else
#   project_id="$1"
#   cluster_name="$2"
#   node_pool_name="$3"
#   region="$4"
#   gcloud container clusters get-credentials ${cluster_name} --region ${region} --project ${project_id}
#   echo "disable cluster autoscaling for node pool"
#   gcloud container clusters update ${cluster_name} --no-enable-autoscaling --node-pool ${node_pool_name} --region ${region} --project ${project_id}
#   echo "cordoning node pool"
#   kubectl cordon $(kubectl get nodes -l cloud.google.com/gke-nodepool=${node_pool_name} -o=name | cut -d '/' -f2)
# fi
echo TODO
}

uncordon () {
  # TODO
  echo $2
}

mode="cordon"
auto_scale="false"
while [ $# -gt 0 ]; do
  case $1 in
    -u)
      mode="uncordon"
      ;;
    -e)
      auto_scale="true"
      ;;
    -min_node=*)
      min_node="${1#*=}"
      ;;
    -max_node=*)
      max_node="${1#*=}"
      ;;
    project_id=*)
      project_id="${1#*=}"
      ;;
    cluster_name=*)
      cluster_name="${1#*=}"
      ;;
    node_pool_name=*)
      node_pool_name="${1#*=}"
      ;;
    region=*)
      region="${1#*=}"
      ;;
    *)
      echo "invalid argument: $1"
      exit 1
  esac
  shift 1
done

# TODO: check missing arguments
# check if min max specified -e is specified
# check if -e is specified -u is specified



