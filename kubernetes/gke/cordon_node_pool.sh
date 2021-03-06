usage() {
  echo ""
  echo "Cordon GKE nodepool"
  echo 
  echo "Usage:"
  echo "  cordon_node_pool.sh  [OPTION] project_id=PROJECT_ID cluster_name=CLUSTER_NAME node_pool_name=NODE_POOL_NAME region=REGION"
  echo "Default:"
  echo "  disables auto scaling and cordons the node pool NODE_POOL_NAME."
  echo "Options:"
  echo "  -u                  uncordon node pool NODE_POOL_NAME."
  echo "  -a                  enable auto scaling. Only used when -u is specified."
  echo "                      -min_node and -max_node must also be specified."
  echo "  -min_node=MIN_NODE  minimum node count. Only used when -e is specified."
  echo "  -max_node=MAX_NODE  maximum node count. Only used when -e is specified."
  echo "  -help               print manual"
  echo ""
}

set -e

mode="cordon"
auto_scale="false"
while [ $# -gt 0 ]; do
  case $1 in
    -u)
      mode="uncordon"
      ;;
    -a)
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
    -help)
      usage
      exit
      ;;
    *)
      echo "invalid argument: $1"
      usage
      exit 1
  esac
  shift 1
done

if [ -z "$project_id" ]; then
  echo "missing project_id"
  usage
  exit 1
fi

if [ -z "$cluster_name" ]; then
  echo "missing cluster_name"
  usage
  exit 1
fi

if [ -z "$node_pool_name" ]; then
  echo "missing node_pool_name"
  usage
  exit 1
fi

if [ -z "$region" ]; then
  echo "missing region"
  usage
  exit 1
fi

if [[ "${auto_scale}" == "true" ]]; then
  if [[ "${mode}" != "uncordon" ]]; then
    echo "auto scale can only be enabled when uncordoning node pool (-u)"
    usage
    exit 1
  fi
  if [[ -z "${min_node}" || -z "${max_node}" ]]; then
    echo "min_node and max_node must be set when enabling auto scale"
    usage
    exit 1
  fi
fi

gcloud container clusters get-credentials ${cluster_name} --region ${region} --project ${project_id}

if [[ "${mode}" == "cordon" ]]; then
  echo "disable cluster autoscaling for node pool"
  gcloud container clusters update ${cluster_name} --no-enable-autoscaling --node-pool ${node_pool_name} --region ${region} --project ${project_id}
  echo "cordoning node pool"
  kubectl cordon $(kubectl get nodes -l cloud.google.com/gke-nodepool=${node_pool_name} -o=name | cut -d '/' -f2)
else 
  if [[ "${auto_scale}" == "true" ]]; then
    echo "enable cluster autoscaling for node pool"
    gcloud container clusters update ${cluster_name} --enable-autoscaling --node-pool ${node_pool_name} --region ${region} --project ${project_id} --max-nodes ${max_node} --min-nodes ${min_node}
  fi
  echo "uncordoning node pool"
  kubectl uncordon $(kubectl get nodes -l cloud.google.com/gke-nodepool=${node_pool_name} -o=name | cut -d '/' -f2)
fi
