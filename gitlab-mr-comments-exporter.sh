#!/usr/bin/env bash

##########################################
# GitLab Configuration
##########################################

GITLAB_URL="https://gitlab.com"
GITLAB_TOKEN="glpat"
PROJECT_ID="242"
TARGET_BRANCH="development"

OUTPUT_FILE="Gitlab-Commit.csv"

set -euo pipefail

##########################################
# CSV Header
##########################################
sudo rm -rf FE-mr_comments-Notes.csv
echo "MR_ID,MR_Title,Source_Branch,Target_Branch,Author,Date,Comment" > "$OUTPUT_FILE"

##########################################
# Helper: Safe CSV escaping
##########################################
escape_csv() {
    local input="$1"
    input="${input//\"/\"\"}"
    printf "\"%s\"" "$input"
}

##########################################
# Fetch All Merge Requests
##########################################

echo "Fetching Merge Requests targeting '$TARGET_BRANCH'..."

MR_LIST=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
    "$GITLAB_URL/api/v4/projects/$PROJECT_ID/merge_requests?state=all&target_branch=$TARGET_BRANCH&per_page=100")

# Validate JSON
if ! echo "$MR_LIST" | jq empty 2>/dev/null; then
    echo "ERROR: GitLab returned invalid (non‑JSON) response:"
    echo "$MR_LIST"
    exit 1
fi

MR_COUNT=$(echo "$MR_LIST" | jq 'length')
echo "Found $MR_COUNT merge requests."

##########################################
# Process Each MR
##########################################

for ((i=0; i<MR_COUNT; i++)); do

    MR=$(echo "$MR_LIST" | jq ".[$i]")

    MR_ID=$(echo "$MR" | jq -r '.iid')
    MR_TITLE=$(echo "$MR" | jq -r '.title')
    SOURCE_BRANCH=$(echo "$MR" | jq -r '.source_branch')
    TARGET_BRANCH_NAME=$(echo "$MR" | jq -r '.target_branch')

    echo "Processing MR !${MR_ID} – $MR_TITLE"

    DISCUSSIONS=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "$GITLAB_URL/api/v4/projects/$PROJECT_ID/merge_requests/$MR_ID/discussions?per_page=100")

    DISC_COUNT=$(echo "$DISCUSSIONS" | jq 'length')

    COMMENT_FOUND=false

    ##########################################
    # Process All Discussions & Notes
    ##########################################

    for ((d=0; d<DISC_COUNT; d++)); do

        NOTES=$(echo "$DISCUSSIONS" | jq ".[$d].notes")
        NOTE_COUNT=$(echo "$NOTES" | jq 'length')

        for ((n=0; n<NOTE_COUNT; n++)); do

            NOTE=$(echo "$NOTES" | jq ".[$n]")

            # INCLUDE SYSTEM NOTES NOW → NO FILTER HERE

            BODY=$(echo "$NOTE" | jq -r '.body // ""')
            AUTHOR=$(echo "$NOTE" | jq -r '.author.name // ""')
            DATE=$(echo "$NOTE" | jq -r '.created_at // ""')

            # Some system notes may have empty body
            [[ -z "$BODY" ]] && continue

            COMMENT_FOUND=true

            echo "$(
                printf "%s,%s,%s,%s,%s,%s,%s" \
                "$(escape_csv "$MR_ID")" \
                "$(escape_csv "$MR_TITLE")" \
                "$(escape_csv "$SOURCE_BRANCH")" \
                "$(escape_csv "$TARGET_BRANCH_NAME")" \
                "$(escape_csv "$AUTHOR")" \
                "$(escape_csv "$DATE")" \
                "$(escape_csv "$BODY")"
            )" >> "$OUTPUT_FILE"

        done
    done

    ##########################################
    # If MR had NO comments (human or system)
    ##########################################
    if [[ "$COMMENT_FOUND" = false ]]; then
        echo "$(
            printf "%s,%s,%s,%s,%s,%s,%s" \
            "$(escape_csv "$MR_ID")" \
            "$(escape_csv "$MR_TITLE")" \
            "$(escape_csv "$SOURCE_BRANCH")" \
            "$(escape_csv "$TARGET_BRANCH_NAME")" \
            "" "" ""
        )" >> "$OUTPUT_FILE"
    fi

done

echo "Done! CSV file created: $OUTPUT_FILE"
