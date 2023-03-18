#! /bin/bash
SEARCH_FOR_CODE="(mail|fsockopen|pfsockopen|stream\_socket\_client|exec|system|passthru|eval|base64_decode|goto|eval)"
REGEX_VERSION='[:alpha:][:space:][$_=*:;\47]'

function downloadAndUnzipAll {
    local type=$1
    local find_name=$2
    for f in ./wp-content/"$type"s/*; do
        if [ -d "$f" ]; then
            local version=$(find "$f" -type f -name "$find_name"  -exec grep -hE 'Version: ' {} \; | tr -d "$REGEX_VERSION")
            if [ -n "$version" ]; then
                local name="${f##*/}"
                local zip_path="./wordpress/wp-content/${type}s/$name.zip"
                local url="https://downloads.wordpress.org/$type/$name.$version.zip"
                
                printf "Downloading %s from %s... " "$name" "$url"
                if wget --quiet -O "$zip_path" "$url"; then
                    unzip -qqf "$zip_path" 
                    printf "Done!\n"
                else
                    printf "Failed to download\n"
                fi
            else
                printf "Failed to find %s version, skiping!\n" "$name"
            fi
        fi
    done
    printf "\n" 
}

function downloadWordpress {
    local version=$(grep -i '$wp_version =' "./wp-includes/version.php" | tr -d "$REGEX_VERSION")
    if [ -n "$version" ]; then
        local url="https://wordpress.org/wordpress-$version.zip"
        printf "Downloading WordPress from %s... " "$url"

        if wget --quiet -O "wordpress.zip" "$url"; then
            unzip -qq "wordpress.zip" && rm -rf "./wordpress.zip"
            printf "Done!\n\n"
            return 0
        else
            printf "Failed to download \n"
            return 1
        fi
    else
        printf "Failed to find Wordpress version, aborting!\n "
        return 1
    fi
}

if [ -f "./wp-includes/version.php" ]; then
    if downloadWordpress; then
         [ -e "./wp-config.php" ] && cp -p "./wp-config.php" "./wordpress" && printf "Copied wp-config.php\n"

        printf "Copying files from wp-content, except plugins and themes:\n"
        rsync -r --stats --exclude="plugins" --exclude="themes" ./wp-content ./wordpress

        printf "Removing malicious files: \n"
        rm -rf `$(find ./wordpress/wp-content/uploads -type f -name "*" -exec grep -iE "$SEARCH_FOR_CODE" {} \;)`
        rm -rf `$(find ./wordpress/wp-content -type f -name "*.{php|txt|png|jpeg|jgp|gif|webp|html|css}" -exec grep -iE "$SEARCH_FOR_CODE" {} \;)`

        downloadAndUnzipAll "plugin" "*.php"
        downloadAndUnzipAll "theme" "style.css"

        diff --exclude=wordpress -r ./wordpress . | tee report.txt
    fi    
else 
    echo "File version.php does not exist, aborting!"
fi