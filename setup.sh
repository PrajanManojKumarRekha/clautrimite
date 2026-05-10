#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR=""
SKILLS_DIR=""
PLUGINS_DIR=""
GSTACK_DIR=""
CLAUTRIMITE_DIR=""
CONTEXT_SAVER_DIR=""
WORKFLOW_DIR=""
CLAUDE_ROOT_CANDIDATES=()

CHECK_ONLY=0
REINSTALL=0

print_usage() {
  cat <<'EOF'
Usage: ./setup.sh [--check] [--reinstall]

  --check      Print dependency status only. Do not install anything.
  --reinstall  Force overwrite ~/.claude/skills/clautrimite/
EOF
}

add_candidate_dir() {
  local candidate="$1"
  [[ -z "${candidate}" ]] && return 0

  local existing
  for existing in "${CLAUDE_ROOT_CANDIDATES[@]:-}"; do
    [[ "${existing}" == "${candidate}" ]] && return 0
  done

  CLAUDE_ROOT_CANDIDATES+=("${candidate}")
}

normalize_windows_path() {
  local candidate="$1"
  [[ -z "${candidate}" ]] && return 0

  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "${candidate}"
    return 0
  fi

  candidate="$(printf '%s\n' "${candidate}" | sed 's#\\#/#g')"
  if [[ "${candidate}" =~ ^([A-Za-z]):/(.*)$ ]]; then
    local drive="${BASH_REMATCH[1],,}"
    local rest="${BASH_REMATCH[2]}"
    printf '/%s/%s\n' "${drive}" "${rest}"
    return 0
  fi

  printf '%s\n' "${candidate}"
}

detect_windows_userprofile() {
  if [[ -n "${USERPROFILE:-}" ]]; then
    printf '%s\n' "${USERPROFILE}"
    return 0
  fi

  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command '[Environment]::GetFolderPath("UserProfile")' 2>/dev/null | tr -d '\r'
    return 0
  fi

  return 1
}

candidate_priority() {
  local candidate="$1"

  if [[ "${candidate}" == /c/Users/*/.claude || "${candidate}" == /mnt/c/Users/*/.claude ]]; then
    printf '0\n'
  elif [[ "${candidate}" =~ ^[A-Za-z]:/.+/.claude$ ]]; then
    printf '1\n'
  elif [[ "${candidate}" == "${HOME}/.claude" ]]; then
    printf '3\n'
  else
    printf '2\n'
  fi
}

to_windows_native_path() {
  local candidate="$1"

  if [[ "${candidate}" =~ ^/mnt/([A-Za-z])/(.*)$ ]]; then
    local drive="${BASH_REMATCH[1]^}"
    local rest="${BASH_REMATCH[2]//\//\\}"
    printf '%s:\\%s\n' "${drive}" "${rest}"
    return 0
  fi

  if [[ "${candidate}" =~ ^/([A-Za-z])/(.*)$ ]]; then
    local drive="${BASH_REMATCH[1]^}"
    local rest="${BASH_REMATCH[2]//\//\\}"
    printf '%s:\\%s\n' "${drive}" "${rest}"
    return 0
  fi

  if [[ "${candidate}" =~ ^([A-Za-z]):/(.*)$ ]]; then
    local drive="${BASH_REMATCH[1]}"
    local rest="${BASH_REMATCH[2]//\//\\}"
    printf '%s:\\%s\n' "${drive}" "${rest}"
    return 0
  fi

  printf '%s\n' "${candidate}"
}

windows_path_exists() {
  local candidate="$1"
  local native_path
  native_path="$(to_windows_native_path "${candidate}")"

  powershell.exe -NoProfile -Command "Test-Path -LiteralPath '${native_path}'" 2>/dev/null | tr -d '\r' | grep -qi '^true$'
}

windows_glob_has_match() {
  local pattern="$1"
  local native_pattern
  native_pattern="$(to_windows_native_path "${pattern}")"

  powershell.exe -NoProfile -Command "\$items = Get-ChildItem -Path '${native_pattern}' -ErrorAction SilentlyContinue; if (\$items) { 'true' } else { 'false' }" 2>/dev/null | tr -d '\r' | grep -qi '^true$'
}

dir_exists_anyhow() {
  local candidate="$1"
  [[ -d "${candidate}" ]] && return 0
  windows_path_exists "${candidate}"
}

mkdir_p_anyhow() {
  local candidate="$1"
  if [[ "${candidate}" == /[A-Za-z]/* || "${candidate}" =~ ^[A-Za-z]:/ ]]; then
    local native_path
    native_path="$(to_windows_native_path "${candidate}")"
    powershell.exe -NoProfile -Command "New-Item -ItemType Directory -Force -Path '${native_path}' | Out-Null" >/dev/null
    return 0
  fi

  mkdir -p "${candidate}"
}

remove_dir_anyhow() {
  local candidate="$1"
  if [[ "${candidate}" == /[A-Za-z]/* || "${candidate}" =~ ^[A-Za-z]:/ ]]; then
    local native_path
    native_path="$(to_windows_native_path "${candidate}")"
    powershell.exe -NoProfile -Command "if (Test-Path -LiteralPath '${native_path}') { Remove-Item -Recurse -Force -LiteralPath '${native_path}' }" >/dev/null
    return 0
  fi

  rm -rf "${candidate}"
}

copy_file_anyhow() {
  local source="$1"
  local dest="$2"

  if [[ "${dest}" == /[A-Za-z]/* || "${dest}" =~ ^[A-Za-z]:/ ]]; then
    local native_source
    local native_dest
    native_source="$(to_windows_native_path "${source}")"
    native_dest="$(to_windows_native_path "${dest}")"
    powershell.exe -NoProfile -Command "Copy-Item -LiteralPath '${native_source}' -Destination '${native_dest}' -Force" >/dev/null
    return 0
  fi

  cp "${source}" "${dest}"
}

install_single_skill() {
  local source_dir="$1"
  local dest_dir="$2"

  mkdir_p_anyhow "${dest_dir}"
  copy_file_anyhow "${source_dir}/SKILL.md" "${dest_dir}/SKILL.md"

  if [[ -f "${source_dir}/plugin.json" ]]; then
    copy_file_anyhow "${source_dir}/plugin.json" "${dest_dir}/plugin.json"
  fi
}

resolve_claude_dirs() {
  local uname_out=""
  local windows_home=""
  uname_out="$(uname -s 2>/dev/null || true)"

  add_candidate_dir "${HOME}/.claude"

  windows_home="$(detect_windows_userprofile || true)"
  if [[ -n "${windows_home}" ]]; then
    add_candidate_dir "$(normalize_windows_path "${windows_home}")/.claude"
  fi

  if [[ "${#CLAUDE_ROOT_CANDIDATES[@]}" -eq 0 ]]; then
    echo "Unable to determine a Claude directory." >&2
    exit 1
  fi

  local candidate best_priority=999 priority
  for candidate in "${CLAUDE_ROOT_CANDIDATES[@]}"; do
    priority="$(candidate_priority "${candidate}")"
    if [[ "${priority}" -lt "${best_priority}" ]]; then
      best_priority="${priority}"
      CLAUDE_DIR="${candidate}"
    fi
  done

  SKILLS_DIR="${CLAUDE_DIR}/skills"
  PLUGINS_DIR="${CLAUDE_DIR}/plugins"
  GSTACK_DIR="${SKILLS_DIR}/gstack"
  CLAUTRIMITE_DIR="${SKILLS_DIR}/clautrimite"
  CONTEXT_SAVER_DIR="${SKILLS_DIR}/context-saver"
  WORKFLOW_DIR="${SKILLS_DIR}/clautrimite-workflow"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      CHECK_ONLY=1
      shift
      ;;
    --reinstall)
      REINSTALL=1
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage >&2
      exit 1
      ;;
  esac
done

has_gsd() {
  local path
  local root
  for root in "${CLAUDE_ROOT_CANDIDATES[@]}"; do
    for path in "${root}"/skills/gsd-*; do
      if [[ -e "${path}" ]]; then
        if [[ -n "$(find "${path}" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
          return 0
        fi
      fi
    done

    if windows_glob_has_match "${root}/skills/gsd-*"; then
      return 0
    fi
  done
  return 1
}

has_superpowers() {
  local root install_manifest
  for root in "${CLAUDE_ROOT_CANDIDATES[@]}"; do
    if dir_exists_anyhow "${root}/skills/superpowers" || dir_exists_anyhow "${root}/plugins/superpowers"; then
      return 0
    fi

    install_manifest="${root}/plugins/installed_plugins.json"
    if [[ -f "${install_manifest}" ]] && grep -Fq 'superpowers@claude-plugins-official' "${install_manifest}"; then
      return 0
    fi

    if windows_path_exists "${install_manifest}" && powershell.exe -NoProfile -Command "Select-String -Path '$(to_windows_native_path "${install_manifest}")' -Pattern 'superpowers@claude-plugins-official' -Quiet" 2>/dev/null | tr -d '\r' | grep -qi '^true$'; then
      return 0
    fi
  done
  return 1
}

print_status_line() {
  local name="$1"
  local present="$2"
  if [[ "${present}" == "1" ]]; then
    echo "found: ${name}"
  else
    echo "missing: ${name}"
  fi
}

check_prereq_commands() {
  local missing=0
  for cmd in git npx; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      echo "Missing required command: ${cmd}" >&2
      missing=1
    fi
  done
  if [[ "${missing}" -ne 0 ]]; then
    exit 1
  fi
}

print_target_dirs() {
  echo "Claude root: ${CLAUDE_DIR}"
  echo "Detected Claude directories:"
  local root
  for root in "${CLAUDE_ROOT_CANDIDATES[@]}"; do
    echo "  - ${root}"
  done
}

install_gstack_if_needed() {
  if dir_exists_anyhow "${GSTACK_DIR}"; then
    echo "✓ gstack found"
    return
  fi

  echo "Installing gstack..."
  mkdir_p_anyhow "${SKILLS_DIR}"
  git clone https://github.com/garrytan/gstack.git "${GSTACK_DIR}"
  (
    cd "${GSTACK_DIR}"
    ./setup
  )
}

install_gsd_if_needed() {
  if has_gsd; then
    echo "✓ GSD found"
    return
  fi

  echo "Installing GSD..."
  npx get-shit-done-cc --claude --global
}

require_superpowers() {
  if has_superpowers; then
    echo "✓ Superpowers found"
    return
  fi

  cat <<'EOF'
⚠️  Superpowers is not installed yet.

Clautrimite can install itself, gstack, and GSD from the shell, but Superpowers still
requires an interactive Claude Code install step in many environments.

Open Claude Code and run:
  /plugin install superpowers@claude-plugins-official

Then return here and rerun:
  ./setup.sh

Why this is manual:
- some Claude Code plugin installs only finalize correctly from inside a live session
- Clautrimite intentionally does not fake that step or silently skip it

Required manual command:
  /plugin install superpowers@claude-plugins-official
EOF
  exit 1
}

install_clautrimite_skill() {
  mkdir_p_anyhow "${SKILLS_DIR}"

  if dir_exists_anyhow "${CLAUTRIMITE_DIR}" && [[ "${REINSTALL}" -eq 1 ]]; then
    remove_dir_anyhow "${CLAUTRIMITE_DIR}"
  fi

  if dir_exists_anyhow "${CONTEXT_SAVER_DIR}" && [[ "${REINSTALL}" -eq 1 ]]; then
    remove_dir_anyhow "${CONTEXT_SAVER_DIR}"
  fi

  if dir_exists_anyhow "${WORKFLOW_DIR}" && [[ "${REINSTALL}" -eq 1 ]]; then
    remove_dir_anyhow "${WORKFLOW_DIR}"
  fi

  install_single_skill "${SCRIPT_DIR}" "${CLAUTRIMITE_DIR}"
  install_single_skill "${SCRIPT_DIR}/context-saver" "${CONTEXT_SAVER_DIR}"
  install_single_skill "${SCRIPT_DIR}/clautrimite-workflow" "${WORKFLOW_DIR}"
  cat <<'EOF'
✓ clautrimite installed.

Next step:
- open Claude Code in a real project
- let clautrimite auto-activate
- confirm the printed phase line before using framework-specific commands
- use /clautrimite-workflow if you want the operator guide
- use /context-saver before ending a meaningful session
EOF
}

if [[ "${CHECK_ONLY}" -eq 1 ]]; then
  resolve_claude_dirs
  print_target_dirs

  if dir_exists_anyhow "${GSTACK_DIR}"; then
    print_status_line "gstack" 1
  else
    print_status_line "gstack" 0
  fi

  if has_gsd; then
    print_status_line "GSD" 1
  else
    print_status_line "GSD" 0
  fi

  if has_superpowers; then
    print_status_line "Superpowers" 1
  else
    print_status_line "Superpowers" 0
  fi
  exit 0
fi

resolve_claude_dirs
check_prereq_commands
print_target_dirs
install_gstack_if_needed
install_gsd_if_needed
require_superpowers
install_clautrimite_skill
