# Bash completion for remove-kernel
# Caches installed kernel versions, refreshes only when RPM db changes

_remove_kernel_versions_cache=""
_remove_kernel_versions_mtime=""

_remove_kernel() {
    local cur prev commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    commands="latest version list"

    case "$COMP_CWORD" in
        1)
            COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
            ;;
        2)
            if [[ "$prev" == "version" ]]; then
                # Check if RPM db has changed since last cache
                local db_mtime
                db_mtime=$(stat -c %Y /var/lib/rpm/ 2>/dev/null)

                if [[ "$db_mtime" != "$_remove_kernel_versions_mtime" || -z "$_remove_kernel_versions_cache" ]]; then
                    _remove_kernel_versions_cache=$(rpm -qa kernel-core --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' 2>/dev/null | sort -V)
                    _remove_kernel_versions_mtime="$db_mtime"
                fi

                COMPREPLY=( $(compgen -W "$_remove_kernel_versions_cache" -- "$cur") )
            fi
            ;;
    esac
}

complete -F _remove_kernel remove-kernel
