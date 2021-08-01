
target="${2:-$1}"

extraArgs=()

while(($#)) ; do
   case $1 in
     -*|--*|--)
       extraArgs+=("$1")
       ;;
     *)
       target="$1"
       ;;
   esac
   shift
done

deploy "$FLAKEROOT#${@}"
