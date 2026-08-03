#!/usr/bin/env bash
#
# Verify a built BridgeDb image: inspect what was baked into it, then start it
# and run the HTTP smoke tests against it.
#
# Usage: tests/verify-image.sh <image-ref> [expected-webservice-version]
#   e.g. tests/verify-image.sh bigcatum/bridgedb:3.0.31-2.1.9 2.1.9
#
# With no expected version, the version is taken from the image tag, which is of
# the form <bridgedb-version>-<webservice-version>.

set -uo pipefail

IMAGE="${1:?usage: verify-image.sh <image-ref> [expected-webservice-version]}"
EXPECTED_VERSION="${2:-}"

if [ -z "$EXPECTED_VERSION" ]; then
	tag="${IMAGE##*:}"
	# Tag is <bdb>-<ws>; the webservice version is the part after the last dash.
	case "$tag" in
	*-*) EXPECTED_VERSION="${tag##*-}" ;;
	*) EXPECTED_VERSION="" ;;
	esac
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER="bridgedb-verify-$$"
PORT="${PORT:-18183}"
FAILED=0

cleanup() {
	docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Verifying image ${IMAGE} (expecting webservice ${EXPECTED_VERSION:-<unknown>})"

# --- static checks, before starting anything ---------------------------------
# setup.sh is copied into the image, so the version it pins is the version of
# the JAR that was downloaded at build time. If this disagrees with the tag, the
# image is mislabelled and there is no point starting it.
if [ -n "$EXPECTED_VERSION" ]; then
	baked=$(docker run --rm --entrypoint /bin/sh "$IMAGE" -c \
		'grep -m1 -E "^export BRIDGEDBWSVERSION=" /setup.sh' 2>/dev/null |
		sed -e 's/.*="//' -e 's/".*//')
	if [ "$baked" = "$EXPECTED_VERSION" ]; then
		printf '  ok    setup.sh in image pins %s\n' "$baked"
	else
		printf '  FAIL  setup.sh in image pins "%s" but the tag says "%s"\n' "$baked" "$EXPECTED_VERSION"
		printf '        the image was built from a stale setup.sh and contains the wrong JAR\n'
		FAILED=$((FAILED + 1))
	fi
fi

if docker run --rm --entrypoint /bin/sh "$IMAGE" -c \
	'[ -s /opt/bridgedb/bridgedb/BridgeDb-Webservice.jar ] && [ "$(head -c 2 /opt/bridgedb/bridgedb/BridgeDb-Webservice.jar)" = "PK" ]' 2>/dev/null; then
	printf '  ok    webservice JAR is present and is a valid archive\n'
else
	printf '  FAIL  webservice JAR is missing, empty, or not a JAR\n'
	FAILED=$((FAILED + 1))
fi

if docker run --rm --entrypoint /bin/sh "$IMAGE" -c \
	'[ -s /opt/bridgedb-databases/gdb.config ]' 2>/dev/null; then
	printf '  ok    gdb.config is present\n'
else
	printf '  FAIL  gdb.config is missing or empty\n'
	FAILED=$((FAILED + 1))
fi

# --- runtime checks ----------------------------------------------------------
echo "Starting container on port ${PORT}..."
if ! docker run -d --name "$CONTAINER" -p "${PORT}:8183" "$IMAGE" >/dev/null; then
	echo "  FAIL  container failed to start" >&2
	exit 1
fi

if ! "${SCRIPT_DIR}/smoke-test.sh" "http://localhost:${PORT}" "$EXPECTED_VERSION"; then
	FAILED=$((FAILED + 1))
	echo
	echo "--- last 40 lines of the service log ---"
	docker exec "$CONTAINER" sh -c 'tail -40 /opt/bridgedb/bridgedb/bridgedb.log' 2>/dev/null ||
		docker logs --tail 40 "$CONTAINER" 2>&1
fi

echo
if [ "$FAILED" -gt 0 ]; then
	echo "Image verification FAILED for ${IMAGE}."
	exit 1
fi
echo "Image verification passed for ${IMAGE}."
