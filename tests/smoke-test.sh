#!/usr/bin/env bash
#
# Smoke-test a running BridgeDb webservice over HTTP.
#
# Usage: tests/smoke-test.sh <base-url> [expected-webservice-version]
#   e.g. tests/smoke-test.sh http://localhost:8183 2.1.9
#
# When the expected version is given, the version reported by /swagger.yaml must
# match it. That is the only signal that ties the running JAR to a release
# number, so it is what catches an image built from a stale setup.sh.
#
# NOTE: the webservice answers HTTP 200 for unknown paths, returning an
# "Unrecognized query" HTML page instead of a 404. Every check here therefore
# asserts on the response body; asserting on the status code alone would pass
# against a server that resolves nothing at all.

set -uo pipefail

BASE_URL="${1:?usage: smoke-test.sh <base-url> [expected-webservice-version]}"
EXPECTED_VERSION="${2:-}"
BASE_URL="${BASE_URL%/}"

CURL="curl -sS -m 60"
FAILED=0

pass() { printf '  ok    %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; printf '        %s\n' "$2"; FAILED=$((FAILED + 1)); }

# Fetch a path and fail if the body is the catch-all "Unrecognized query" page.
#
# Note: grep reads from a here-string rather than a pipe throughout this script.
# With `pipefail`, a `grep -q` that exits on its first match leaves the upstream
# writer with SIGPIPE, and the pipeline then reports failure even though the
# match succeeded -- intermittently, only once a body exceeds the pipe buffer.
get() {
	local path="$1" body
	body=$($CURL "${BASE_URL}${path}" 2>/dev/null)
	if [ -z "$body" ] || grep -q "Unrecognized query" <<<"$body"; then
		return 1
	fi
	printf '%s' "$body"
}

check_contains() {
	local label="$1" path="$2" needle="$3" body
	if ! body=$(get "$path"); then
		fail "$label" "no usable response from ${path} (empty or 'Unrecognized query')"
		return
	fi
	if grep -q -- "$needle" <<<"$body"; then
		pass "$label"
	else
		fail "$label" "expected '${needle}' in response from ${path}; got: $(head -c 200 <<<"$body")"
	fi
}

echo "Smoke-testing ${BASE_URL}"

# Wait for the server to accept requests. Cold start loads every .bridge file
# listed in gdb.config, which takes appreciably longer than the JVM itself.
echo "Waiting for the service to become ready..."
ready=0
for _ in $(seq 1 60); do
	if get /contents >/dev/null 2>&1; then
		ready=1
		break
	fi
	sleep 5
done
if [ "$ready" -ne 1 ]; then
	echo "  FAIL  service did not become ready within 300s" >&2
	exit 1
fi
pass "service is up and answering /contents"

# --- version -----------------------------------------------------------------
# /swagger.yaml carries the webservice version of the JAR that is actually
# running, so it is the check that detects a version/content mismatch.
if [ -n "$EXPECTED_VERSION" ]; then
	served_version=""
	if swagger=$(get /swagger.yaml); then
		served_version=$(grep -m1 -oP '(?<=^  version: ).*' <<<"$swagger" | tr -d '[:space:]')
	fi
	if [ -z "$served_version" ]; then
		fail "served version matches the image tag" "could not read a version from /swagger.yaml"
	elif [ "$served_version" = "$EXPECTED_VERSION" ]; then
		pass "served version is ${EXPECTED_VERSION}"
	else
		fail "served version matches the image tag" \
			"/swagger.yaml reports '${served_version}' but the image is tagged for '${EXPECTED_VERSION}' -- the image contains the wrong JAR"
	fi
fi

# --- catalogue ---------------------------------------------------------------
check_contains "organism list includes Homo sapiens" /contents "Homo sapiens"
check_contains "source datasources are listed" "/Homo%20sapiens/sourceDataSources" "supportedSourceDatasources"

# --- mappings ----------------------------------------------------------------
# A Derby-backed lookup. This is the check that fails outright when the JDBC
# driver is not registered and no .bridge file can be opened.
check_contains "human gene mapping (BRCA2 -> Entrez)" \
	"/Homo%20sapiens/xrefs/En/ENSG00000139618" "ncbigene:675"
check_contains "human gene mapping (BRCA2 -> HGNC symbol)" \
	"/Homo%20sapiens/xrefs/En/ENSG00000139618" "hgnc.symbol:BRCA2"
check_contains "target-restricted mapping (BRCA2 -> Wikidata)" \
	"/Homo%20sapiens/xrefs/En/ENSG00000139618/Wd" "wikidata:Q17853272"
check_contains "mouse gene mapping (Brca1)" \
	"/Mus%20musculus/xrefs/En/ENSMUSG00000017146" "mgi:Brca1"
check_contains "attributes endpoint" \
	"/Homo%20sapiens/attributes/En/ENSG00000139618" "Symbol"

# --- negative check ----------------------------------------------------------
# Documents the 200-for-everything behaviour: a nonsense path must come back as
# the "Unrecognized query" page. If this ever starts returning real content, the
# body-based checks above would silently pass against anything.
if body=$($CURL "${BASE_URL}/definitely-not-a-real-endpoint-xyz" 2>/dev/null) &&
	grep -q "Unrecognized query" <<<"$body"; then
	pass "unknown paths return the 'Unrecognized query' page"
else
	fail "unknown paths return the 'Unrecognized query' page" \
		"unexpected response for a nonsense path; body-based assertions may no longer be meaningful"
fi

echo
if [ "$FAILED" -gt 0 ]; then
	echo "${FAILED} check(s) failed."
	exit 1
fi
echo "All checks passed."
