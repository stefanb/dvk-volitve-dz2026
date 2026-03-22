#!/bin/bash
set -euo pipefail

WebPageURL="https://www.dvk-rs.si/volitve-in-referendumi/drzavni-zbor-rs/volitve-drzavnega-zbora-rs/volitve-v-drzavni-zbor/"
AttachmentPrefixes=(
        "https://www.dvk-rs.si/fileadmin/user_upload/"
        "/fileadmin/user_upload/"
        # "https://arhiv.mm.gov.si/dvk/"
    )

    # Download all documents linked from WebPageURL that match AttachmentPrefixes
    download_dokumenti() {
        mkdir -p ./dokumenti

        # Build a regex pattern for wget --accept-regex from AttachmentPrefixes
        # Escape dots and join with pipe for regex alternation
        local accept_pattern
        accept_pattern=$(printf '%s\n' "${AttachmentPrefixes[@]}" | sed 's/\./\\./g' | tr '\n' '|' | sed 's/|$//')

        echo "Downloading documents from $WebPageURL"
        echo "Accepting URLs matching: $accept_pattern"

        wget \
            --no-verbose \
            --show-progress \
            --span-hosts \
            --level=1 \
            --recursive \
            --no-directories \
            --directory-prefix=./dokumenti \
            --accept-regex="$accept_pattern" \
            --no-clobber \
            --convert-links \
            --page-requisites \
            "$WebPageURL"
    }

    download_dokumenti

# # Resolve relative URL to absolute
# resolve_url() {
#     local url="$1"
#     local base="$2"
    
#     if [[ "$url" =~ ^https?:// ]]; then
#     echo "$url"
#     elif [[ "$url" =~ ^/ ]]; then
#     echo "${base%/*}${url}"
#     else
#     echo "${base%/}/${url}"
#     fi
# }

# pattern=$(IFS='|'; echo "${AttachmentPrefixes[*]}" | sed 's/\./\\./g')
# echo "Using pattern: $pattern"

# # Fetches content from WebPageURL and extracts unique URLs matching the specified pattern
# # -o: outputs only the matching parts (not the entire line)
# # -P: enables Perl-Compatible Regular Expressions (PCRE) for more powerful pattern matching
# # The grep command extracts href attribute values, filters them by the pattern variable,
# # and sort -u removes duplicates before processing each URL in the while loop
# # Uses curl with progress bar to download the page, pipes to grep for pattern matching,
# # sorts results uniquely, and iterates through each matched URL for processing
# curl --progress-bar --fail "$WebPageURL" | grep -oE "href=['\"]?(${pattern})[^'\">\s]+" | sed 's/^href=['\''"]*//' | sort -u | while read -r url; do
#     filename=$(basename "$url")
#     echo "Downloading ./dokumenti/$filename from $url..."
#     # $CURL "./dokumenti/$filename" "$url"
# done


