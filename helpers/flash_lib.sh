function check_arguments() {
    if [ -z "$1" ]; then
	echo "please pass image path as first argument"
	exit 1
fi
IMAGE="$1"

if [ -z "$2" ]; then
	echo "please pass storage device as second argument"
	exit 1
fi
DEVICE="$2"

if [ -z "$3" ]; then
	echo "please pass usbsdmux device as third argument"
	exit 1
fi
MUX="$3"
}