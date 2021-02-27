usage() {
  echo ""
  echo "Copy docker images between container repositories"
  echo ""
  echo "Usage:"
  echo "  ./cp_docker_image.sh SOURCE_REPOSITORY DESTINATION_REPOSITORY [images]..."
  echo ""
}

if [ $# -lt 3 ]; then
  usage
  exit 1
fi

src_repo="$1"
dest_repo="$2"
shift 2

for image in "$@"; do
  {
  echo "Copying ${src_repo}/${image} to ${dest_repo}/${image}"
  sleep 1
  docker pull ${src_repo}/${image}

  docker tag ${src_repo}/${image} ${dest_repo}/${image}
  docker push ${dest_repo}/${image}

  docker rmi ${src_repo}/${image}
  docker rmi ${dest_repo}/${image}
} &
done

wait
