declare -a dates # array
declare -A todos # dictionary

function generateTodos() {
    for file_name in $(git ls-files); do
        IFS=$'\n' todo_lines=($(git blame ${file_name} | grep -i "TODO" | tr -s " "))
        if ((${#todo_lines[@]} > 0)); then
            for line in "${todo_lines[@]}"; do
                i=0
                line_content="${line#*)}"
                tmp="${line#*(}"
                tmp="${tmp%%)*}"
                line_number=$(echo "${tmp}" | rev | cut -d' ' -f 1 | rev)
                update_date=$(echo "${tmp}" | rev | cut -d' ' -f 4 | rev)
                user_name=$(echo "${tmp}" | rev | cut -d ' ' -f5- | rev)
                if [[ -z "${todos[${update_date}${i}]}" ]]; then
                    dates+=("${update_date}")
                    todos[${update_date}${i}]="${file_name##*/}[SEPARATOR]${line_number}[SEPARATOR]${user_name}[SEPARATOR]${line_content}"
                else
                    while ((i >= 0)); do
                        i=$((i + 1))
                        if [[ -z "${todos[${update_date}${i}]}" ]]; then
                            todos["${update_date}${i}"]="${file_name##*/}[SEPARATOR]${line_number}[SEPARATOR]${user_name}[SEPARATOR]${line_content}"
                            i=-1
                        fi
                    done
                fi
            done
        fi
    done
}

function displayTodos() {
    ordered_dates=($(sort -n < <(printf '%s\n' "${dates[@]}")))
    printf "\n"
    printf '%-10s | %-50s | %-5s | %-20s | %s\n' "Date" "File" "Line" "User" "Content"
    printf '=%.0s' {1..130}
    printf "\n"
    for date in "${ordered_dates[@]}"; do
        i=0
        while true; do
            if [[ -z "${todos[${date}${i}]}" ]]; then
                break
            else
                todo=$(echo "${todos[${date}${i}]}" | sed 's/\[SEPARATOR\]/\n/g')
                readarray -t todo <<<"${todo}"
                printf '%-10s | %-50s | %-5s | %-20s | %s\n' "${date}" "${todo[0]}" "${todo[1]}" "${todo[2]}" "${todo[3]}"
            fi
            i=$((i + 1))
        done
    done
}

repository=$1
if [[ -z "${repository}" ]]; then
    printf "[WARNING] No path given, using default: '.'\n"
    repository="."
fi
cd "${repository}"
generateTodos
displayTodos
