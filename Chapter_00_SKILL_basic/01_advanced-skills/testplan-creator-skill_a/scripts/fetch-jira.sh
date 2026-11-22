#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s ISSUE-KEY\n' "${0##*/}" >&2
  printf 'Required environment: JIRA_BASE_URL, JIRA_EMAIL, and JIRA_API_TOKEN (or JIRA_TOKEN)\n' >&2
  printf 'Example: JIRA_BASE_URL=https://your-company.atlassian.net %s PROJ-123\n' "${0##*/}" >&2
}

if [[ $# -eq 1 && ( $1 == '-h' || $1 == '--help' ) ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

issue_key=$1
if [[ ! $issue_key =~ ^[A-Za-z][A-Za-z0-9_]*-[0-9]+$ ]]; then
  printf 'Error: invalid Jira issue key: %s\n' "$issue_key" >&2
  usage
  exit 2
fi

: "${JIRA_BASE_URL:?Error: set JIRA_BASE_URL to your company Jira URL (for example https://your-company.atlassian.net)}"
: "${JIRA_EMAIL:?Error: set JIRA_EMAIL to your Atlassian account email}"
JIRA_API_TOKEN=${JIRA_API_TOKEN:-${JIRA_TOKEN:-}}
: "${JIRA_API_TOKEN:?Error: set JIRA_API_TOKEN or JIRA_TOKEN to your Atlassian API token}"

base_url=${JIRA_BASE_URL%/}
case "$base_url" in
  https://*) jira_host=${base_url#https://} ;;
  *)
    printf 'Error: JIRA_BASE_URL must use HTTPS.\n' >&2
    exit 2
    ;;
esac

case "$jira_host" in
  ''|*/*|*@*|*[[:space:]]*)
    printf 'Error: JIRA_BASE_URL must contain only the Jira host, with no path or credentials.\n' >&2
    exit 2
    ;;
esac

if [[ ! $jira_host =~ ^[A-Za-z0-9.-]+(:[0-9]+)?$ ]]; then
  printf 'Error: JIRA_BASE_URL must contain a valid Jira hostname.\n' >&2
  exit 2
fi

case "$JIRA_EMAIL$JIRA_API_TOKEN" in
  *[[:space:]]*)
    printf 'Error: JIRA_EMAIL and JIRA_API_TOKEN must not contain whitespace.\n' >&2
    exit 2
    ;;
esac

if ! command -v curl >/dev/null 2>&1; then
  printf 'Error: curl is required but was not found on PATH.\n' >&2
  exit 127
fi

umask 077
auth_file=$(mktemp "${TMPDIR:-/tmp}/jira-netrc.XXXXXX")
trap 'rm -f "$auth_file"' EXIT
trap 'exit 1' HUP INT TERM
printf 'machine %s login %s password %s\n' "$jira_host" "$JIRA_EMAIL" "$JIRA_API_TOKEN" > "$auth_file"

curl \
  --request GET \
  --url "${base_url}/rest/api/3/issue/${issue_key}" \
  --get \
  --data-urlencode 'fields=*all' \
  --netrc-file "$auth_file" \
  --header 'Accept: application/json' \
  --silent \
  --show-error \
  --fail-with-body
