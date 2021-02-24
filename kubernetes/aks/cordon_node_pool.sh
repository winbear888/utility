usage() {
  echo ""
  echo "Cordon AKS nodepool"
  echo 
  echo "Usage:"
  echo "  cordon_node_pool.sh  [OPTION] rg_name=RESOURCE_GROUP_NAME cluster_name=CLUSTER_NAME node_pool_name=NODE_POOL_NAME"
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
    rg_name=*)
      rg_name="${1#*=}"
      ;;
    cluster_name=*)
      cluster_name="${1#*=}"
      ;;
    node_pool_name=*)
      node_pool_name="${1#*=}"
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

if [ -z "$rg_name" ]; then
  echo "missing rg_name"
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

az aks get-credentials -g ${rg_name} -n ${cluster_name}

if [[ "${mode}" == "cordon" ]]; then
  echo "disable cluster autoscaling for node pool"
  az aks nodepool update --cluster-name ${cluster_name} --name ${node_pool} --resource-group ${rg_name} --disable-cluster-autoscaler
  echo "cordoning node pool"
  kubectl cordon $(kubectl get nodes -l agentpool=${node_pool} -o=name | cut -d '/' -f2)
else 
  if [[ "${auto_scale}" == "true" ]]; then
    echo "enable cluster autoscaling for node pool"
    az aks nodepool update --cluster-name ${cluster_name} --name ${node_pool} --resource-group ${rg_name} --enable-cluster-autoscaler --max-count $max_node --min-count $min_node
  fi
  echo "uncordoning node pool"
  kubectl uncordon $(kubectl get nodes -l agentpool=${node_pool} -o=name | cut -d '/' -f2)
fi
