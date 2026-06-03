#!/usr/bin/env bash
#
# validate-manifest.sh
# Validates a CDPCore release manifest.json against the schema documented
# in scripts/public-repo/manifest.schema.json (H4).
#
# Uses jq exclusively — no Node, npm, or Python required. Source-of-truth
# lives in cdp-swift-internal/scripts/; publish-release.sh syncs it into
# the public cdp-swift repo so both workflows share one validator.
#
# Usage:  ./scripts/validate-manifest.sh <manifest.json>
# Exits:  0 on success, 1 on validation error(s), 2 on misuse.
# Errors are accumulated and printed to stderr in a single run.

set -euo pipefail

MANIFEST="${1:-}"
if [[ -z "${MANIFEST}" ]]; then
    echo "usage: $0 <manifest.json>" >&2
    exit 2
fi
if [[ ! -f "${MANIFEST}" ]]; then
    echo "ERROR: file not found: ${MANIFEST}" >&2
    exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq is required but not installed" >&2
    exit 2
fi
if ! jq -e . "${MANIFEST}" >/dev/null 2>&1; then
    echo "ERROR: ${MANIFEST} is not valid JSON" >&2
    exit 1
fi

errors=0
err() {
    printf 'ERROR: %s\n' "$1" >&2
    errors=$((errors + 1))
}
q() { jq -r "$1" "${MANIFEST}"; }

# Canonical patterns kept in sync with:
#   cdp-swift-internal/.github/workflows/release.yml  (Validate semver)
#   cdp-swift-internal/scripts/publish-release.sh     (input validation)
#   cdp-swift/.github/workflows/release.yml           (Determine version)
#   cdp-swift-internal/scripts/public-repo/manifest.schema.json
SEMVER_RE='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z][0-9A-Za-z.-]*)?$'
SHA256_RE='^[0-9a-f]{64}$'
SHA1_RE='^[0-9a-f]{40}$'
URL_RE='^https://github\.com/coinbase/cdp-swift/releases/download/[^/]+/CDPCore\.xcframework\.zip$'
KNOWN_ROLES='xcframework xcframework-cosign-bundle sbom sbom-cosign-bundle dsyms'

# ── Top-level shape ───────────────────────────────────────────────────
TOP_TYPE=$(q 'type')
if [[ "${TOP_TYPE}" != "object" ]]; then
    err "root must be an object (got ${TOP_TYPE})"
    echo "FAILED: ${errors} validation error(s) in ${MANIFEST}" >&2
    exit 1
fi

EXTRA_TOP=$(q '. | (keys_unsorted - ["schemaVersion","version","tag","binaryTarget","assets","source"]) | .[]')
if [[ -n "${EXTRA_TOP}" ]]; then
    while IFS= read -r k; do
        [[ -z "${k}" ]] || err "unknown top-level key: ${k}"
    done <<< "${EXTRA_TOP}"
fi

for k in schemaVersion version tag binaryTarget assets source; do
    HAS=$(q "has(\"${k}\")")
    [[ "${HAS}" == "true" ]] || err "missing required key: ${k}"
done

# ── schemaVersion ─────────────────────────────────────────────────────
SCHEMA_VERSION=$(q '.schemaVersion // empty')
if [[ "${SCHEMA_VERSION}" != "1" ]]; then
    err "schemaVersion must be 1 (got '${SCHEMA_VERSION}')"
fi

# ── version / tag ─────────────────────────────────────────────────────
VERSION=$(q '.version // ""')
TAG=$(q '.tag // ""')
[[ "${VERSION}" =~ ${SEMVER_RE} ]] || err "version '${VERSION}' is not bare semver"
[[ "${TAG}"     =~ ${SEMVER_RE} ]] || err "tag '${TAG}' is not bare semver"

# ── binaryTarget ──────────────────────────────────────────────────────
BT_TYPE=$(q '.binaryTarget | type')
if [[ "${BT_TYPE}" == "object" ]]; then
    EXTRA_BT=$(q '.binaryTarget | (keys_unsorted - ["name","url","checksum"]) | .[]')
    if [[ -n "${EXTRA_BT}" ]]; then
        while IFS= read -r k; do
            [[ -z "${k}" ]] || err "unknown binaryTarget key: ${k}"
        done <<< "${EXTRA_BT}"
    fi

    BT_NAME=$(q '.binaryTarget.name // ""')
    BT_URL=$(q '.binaryTarget.url // ""')
    BT_CHECKSUM=$(q '.binaryTarget.checksum // ""')

    [[ "${BT_NAME}" == "CDPCore" ]] || err "binaryTarget.name must be 'CDPCore' (got '${BT_NAME}')"
    [[ "${BT_URL}" =~ ${URL_RE} ]] || err "binaryTarget.url does not match expected pattern: ${BT_URL}"
    [[ "${BT_CHECKSUM}" =~ ${SHA256_RE} ]] || err "binaryTarget.checksum must be 64-char lowercase hex (got '${BT_CHECKSUM}')"
elif [[ "${BT_TYPE}" != "null" ]]; then
    err "binaryTarget must be an object (got ${BT_TYPE})"
fi

# ── assets[] ──────────────────────────────────────────────────────────
ASSETS_TYPE=$(q '.assets | type')
if [[ "${ASSETS_TYPE}" == "array" ]]; then
    ASSET_COUNT=$(q '.assets | length')
    if (( ASSET_COUNT < 1 )); then
        err "assets must contain at least one entry"
    fi

    HAS_REQUIRED_XCFRAMEWORK=$(q '
        [.assets[]?
         | select(.role == "xcframework" and .required == true)]
        | length > 0
    ')
    if [[ "${HAS_REQUIRED_XCFRAMEWORK}" != "true" ]]; then
        err 'assets must contain an entry with role="xcframework", required=true'
    fi

    for ((i = 0; i < ASSET_COUNT; i++)); do
        prefix=".assets[${i}]"

        EXTRA_ASSET=$(q "${prefix} | (keys_unsorted - [\"role\",\"name\",\"sha256\",\"required\"]) | .[]")
        if [[ -n "${EXTRA_ASSET}" ]]; then
            while IFS= read -r k; do
                [[ -z "${k}" ]] || err "unknown key in assets[${i}]: ${k}"
            done <<< "${EXTRA_ASSET}"
        fi

        for k in role name sha256 required; do
            HAS=$(q "${prefix} | has(\"${k}\")")
            [[ "${HAS}" == "true" ]] || err "assets[${i}] missing required key: ${k}"
        done

        ROLE=$(q "${prefix}.role // \"\"")
        NAME=$(q "${prefix}.name // \"\"")
        SHA=$(q "${prefix}.sha256 // \"\"")

        case " ${KNOWN_ROLES} " in
            *" ${ROLE} "*) ;;
            "") ;;
            *) err "assets[${i}].role '${ROLE}' is not in {${KNOWN_ROLES// /, }}" ;;
        esac
        [[ -n "${NAME}" ]] || err "assets[${i}].name must be non-empty"
        [[ "${SHA}" =~ ${SHA256_RE} ]] || err "assets[${i}].sha256 must be 64-char lowercase hex (got '${SHA}')"
        REQ_TYPE=$(q "${prefix}.required | type")
        [[ "${REQ_TYPE}" == "boolean" ]] || err "assets[${i}].required must be boolean (got ${REQ_TYPE})"
    done
elif [[ "${ASSETS_TYPE}" != "null" ]]; then
    err "assets must be an array (got ${ASSETS_TYPE})"
fi

# ── source ────────────────────────────────────────────────────────────
SRC_TYPE=$(q '.source | type')
if [[ "${SRC_TYPE}" == "object" ]]; then
    EXTRA_SRC=$(q '.source | (keys_unsorted - ["repository","sha","workflowRunId"]) | .[]')
    if [[ -n "${EXTRA_SRC}" ]]; then
        while IFS= read -r k; do
            [[ -z "${k}" ]] || err "unknown source key: ${k}"
        done <<< "${EXTRA_SRC}"
    fi

    SRC_REPO=$(q '.source.repository // ""')
    SRC_SHA=$(q '.source.sha // ""')
    SRC_RUN=$(q '.source.workflowRunId // ""')

    [[ "${SRC_REPO}" == "coinbase/cdp-swift-internal" ]] || err "source.repository must be 'coinbase/cdp-swift-internal' (got '${SRC_REPO}')"
    [[ "${SRC_SHA}" =~ ${SHA1_RE} ]] || err "source.sha must be 40-char lowercase hex (got '${SRC_SHA}')"
    [[ -n "${SRC_RUN}" ]] || err "source.workflowRunId must be non-empty"
elif [[ "${SRC_TYPE}" != "null" ]]; then
    err "source must be an object (got ${SRC_TYPE})"
fi

if (( errors > 0 )); then
    echo "FAILED: ${errors} validation error(s) in ${MANIFEST}" >&2
    exit 1
fi

echo "OK: ${MANIFEST} is valid"
