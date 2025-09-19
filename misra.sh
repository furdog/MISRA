#!/bin/bash
function misra_setup() {
	# Go to the same folder where script is running
	cd "$(dirname "$0")" || exit 1

	# Clone cppcheck git repo (only addons/ folder)
	git clone -n --depth=1 --filter=tree:0 \
		https://github.com/danmar/cppcheck.git cppcheck &> /dev/null
	cd cppcheck
	git sparse-checkout set --no-cone addons/
	git checkout &> /dev/null

	# Download the MISRA C 2023 headlines file
	RAW_FILE_URL="https://gitlab.com/MISRA/MISRA-C/MISRA-C-2012/tools/-/raw/main/misra_c_2023__headlines_for_cppcheck.txt"
	DOWNLOAD_PATH="./addons/misra_c_2023__headlines_for_cppcheck.txt"

	# Check if the file already exists before attempting to download
	if [ -f "$DOWNLOAD_PATH" ]; then
		echo "MISRA C 2023 headlines file already exists: $DOWNLOAD_PATH (skipping download)"
	else
		echo "Downloading MISRA C 2023 headlines file..."
		if ! curl -sSL "$RAW_FILE_URL" -o "$DOWNLOAD_PATH"; then
			echo "Error: Failed to download $RAW_FILE_URL" >&2
			exit 1
		fi
		echo "Download complete: $DOWNLOAD_PATH"
	fi
}

function misra_check() {
	MISRA_PATH="$(dirname "$0")""/cppcheck/addons/"
	TARGET="$1"

	# Initialize an empty string for the arguments
	export INCLUDES=""

	# Loop through each path in the INCLUDES variable
	for path in $2; do
		# Append the -I flag and the path to the arguments string
		INCLUDES+="-I${path} "
	done

	function cleanup() {
		# Remove garbage
		rm "${TARGET}.ctu"*
		rm "${TARGET}.dump"*
	}

	# Set a trap to call the cleanup function on script exit (EXIT signal)
	trap cleanup EXIT

	# Run check
	cppcheck --dump --check-level=exhaustive --std=c89 "${TARGET}" ${INCLUDES}
	python "${MISRA_PATH}/misra.py" "${TARGET}.dump" \
	  --rule-texts="${MISRA_PATH}/misra_c_2023__headlines_for_cppcheck.txt"

	# Check if misra checks have passed
	if [ $? -eq 0 ]; then
		echo "MISRA check completed successfully for ${TARGET}."
	else
		echo "Error: MISRA check failed for ${TARGET}. Exit code: $?" >&2
		exit 1 # Exit the script with an error if the MISRA check fails
	fi
}

# --- Main Logic ---
case "$1" in
	setup)
		misra_setup
		;;
	check)
		shift
		misra_check "$@"
		;;
	*)
		echo "Usage: $0 {setup|check <target_file.*>}"
		exit 1
		;;
esac
