# -----------------------------------------------------------------------------
# Function:    SHWriteJson
# Purpose:     Emit structured JSON log entry to journald using systemd-cat.
#
# Synopsis:
#   SHWriteJson [server] [action] [result] [message] [service] [tag] [event_type]
#
# Description:
#   Logs a JSON-formatted event with timestamp, server, action, result, and
#   message context to the system journal. Intended for use in automation,
#   monitoring and operational scripts where structured logs are required.
#
# Parameters:
#   server        - (Optional) Hostname or source identifier        [default: hostname]
#   action        - (Optional) Name of action being performed       [default: "unspecified"]
#   result        - (Optional) Result of the action                 [default: "undefined"]
#   message       - (Optional) Human-readable message               [default: "generic event"]
#   service       - (Optional) Service or script name               [default: "generic-service"]
#   tag           - (Optional) systemd-cat log tag                  [default: "generic-logger"]
#   event_type    - (Optional) Event type/category label            [default: "generic-event"]
#
# Environment:
#   SCRIPT_VERSION - Optional variable used to tag script version in the log
#
# Output:
#   Logs JSON to journald, viewable via:
#     journalctl -t <tag> -o json-pretty
#
# Example:
#   SHWriteJson "$(hostname)" "rotate" "success" "Backup rotated" "backup-job" "log-backup" "maintenance"
# -----------------------------------------------------------------------------

SHWriteJson() {
    local timestamp
    timestamp=$(date --iso-8601=seconds)

    local server="${1:-$(hostname)}"
    local action="${2:-unspecified}"
    local result="${3:-undefined}"
    local message="${4:-generic event}"
    local service="${5:-generic-service}"
    local scriptversion="${SCRIPT_VERSION:-v0.0.1}"
    local tag="${6:-generic-logger}"
    local event_type="${7:-generic-event}"

    echo "{\"timestamp\":\"$timestamp\",\"event_type\":\"$event_type\",\"service\":\"$service\",\"server\":\"$server\",\"action\":\"$action\",\"result\":\"$result\",\"message\":\"$message\",\"script_version\":\"$scriptversion\"}" \
    | systemd-cat -t "$tag"
}
