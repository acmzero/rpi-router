# declares where to find the config file.

CONFIG_FILE="$(pwd)/rpi-router.conf"
FUNCTIONS_FILE="$(pwd)/functions.sh"

echo "Sourcing $CONFIG_FILE"
. "$CONFIG_FILE"
. "$FUNCTIONS_FILE"

