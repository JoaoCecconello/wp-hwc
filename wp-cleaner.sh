#! /bin/bash
NEW_WP_CONTENT_PATH="./wordpress/wp-content"

SEARCH_FOR_CODE="(mail|fsockopen|pfsockopen|stream\_socket\_client|exec|system|passthru|eval|base64_decode|goto|eval)"
REGEX_VERSION='[:alpha:][:space:][$_=*:;\47]'

function downloadAndUnzipAll {
    local type=$1
    for f in ./wp-content/"$type"s/*; do
        if [ -d "$f" ]; then
            local version=$(find "$f" -type f -name '*.php' -exec grep -hE 'Version: ' {} \; | tr -d "$REGEX_VERSION")
            if [ -n "$version" ]; then
                local name="${f##*/}"
                local zip_path="$NEW_WP_CONTENT_PATH/${type}s/$name.zip"
                local url="https://downloads.wordpress.org/$type/$name.$version.zip"
                
                printf "Downloading %s from: %s\n" "$name" "$url"
                if wget --quiet -O "$zip_path" "$url"; then
                    unzip -qqf "$zip_path" && rm -rf "$zip_path"
                else
                    printf "Failed to download from %s\n" "$url"
                fi
            else
                printf "Failed to find %s version, skiping!\n" "$name"
            fi
        fi
    done
    printf "\n" 
}

function downloadWordpress {
    local version=$(grep -i '$wp_version =' "$WP_VERSION_FILE_PATH" | tr -d "$REGEX_VERSION")
    if [ -n "$version" ]; then
        local url="https://wordpress.org/wordpress-$version.zip"
        printf "Downloading WordPress from: %s\n" "url"

        if wget --quiet -O "wordpress.zip" "$url"; then
            unzip -qqf "wordpress.zip" && rm -rf "./wordpress.zip"
            printf "Download completed\n"
            return 0
        else
            printf "Failed to download Wordpress from: %s\n" "$url"
            return 1
        fi
    else
        printf "Failed to find Wordpress version, aborting!"
        return 1
    fi
}

if [ -f "./wp-includes/version.php" ]; then
    downloadWordpress
    if [ $? ]; then
        [ -f "./wp-config.php" ] && cp -p "./wp-config.php" "./wordpress" && printf "Copied wp-config.php\n"

        printf "Copying files from wp-content, except plugins and themes:\n"
        rsync -r --stats --exclude="plugins" --exclude="themes" ./wp-content ./wordpress

        printf "Removing malicious files: \n"
        rm -rf `$(find "$NEW_WP_CONTENT_PATH"/uploads -type f name "*" -exec grep -iE "$SEARCH_FOR_CODE" {} \;)`
        rm -rf `$(find "$NEW_WP_CONTENT_PATH" -type f -name "*.{php|txt|png|jpeg|jgp|gif|webp|html|css}" -exec grep -iE "$SEARCH_FOR_CODE" {} \;)`

        printf "Downloading plugins:\n"
        downloadAndUnzipAll "plugin"

        printf "Downloading themes:\n"
        downloadAndUnzipAll "theme"
    fi
else 
    echo "File version.php does not exist, aborting!"
fi