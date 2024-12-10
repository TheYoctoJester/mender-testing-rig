function check_arguments() {
	if [ -z "$1" ]; then
		echo "please pass image path as first argument"
		exit 1
	fi
	IMAGE="$1"
}
