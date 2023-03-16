#! /bin/bash

WP_VERSION_FILE_PATH="./wp-includes/version.php"
WP_ZIP_NAME="wordpress.zip"

INF_WP_PLUGINS_PATH="./wp-content/plugins"
INF_WP_THEME_PATH="./wp-content/themes"

URL_PLUGINS="https://downloads.wordpress.org/plugin"
URL_THEMES="https://downloads.wordpress.org/theme"

NEW_WP_CONTENT_PATH="./wordpress/wp-content"

SEARCH_FOR_CODE="(mail|fsockopen|pfsockopen|stream\_socket\_client|exec|system|passthru|eval|base64_decode|goto|base64|eval)"
SEARCH_FOR_FILE="*.{php|txt|png|jpeg|jgp|gif|webp|html|css}"
REGEX_VERSION='[:alpha:][:space:][$_=*:;\47]'

# verifica se arquivo wp_version.php existe
if [ -f "$WP_VERSION_FILE_PATH" ]; then

    # pega a versão do wp
    WP_VERSION=`grep -i '$wp_version =' "$WP_VERSION_FILE_PATH" | tr -d "$REGEX_VERSION"`
    printf "Wordpress version: $WP_VERSION\n"
    
    # baixa e descomprime o novo wordpress, na mesma versão do antigo
    printf "Downloading WordPress from: https://wordpress.org/wordpress-$WP_VERSION.zip\n"
    wget --quiet -O "$WP_ZIP_NAME" "https://wordpress.org/wordpress-$WP_VERSION.zip" \
        && unzip -qq "$WP_ZIP_NAME" \
        && rm -rf "./$WP_ZIP_NAME";
    printf "Download completed\n"

    # copia tudo da wp-content, menos os plugins e os themas
    printf "Copying files from wp-content, except plugins and themes:\n"
    rsync -r --stats --exclude="plugins" --exclude="themes" ./wp-content ./wordpress

    # copia o wp-config.php
    if [ -f "./wp-config.php" ]; then
        cp ./wp-config.php ./wordpress
        printf "Copied wp-config.php\n"
    fi

    printf "Downloading plugins:\n"
    # loop para verificar todos os plugins, verifica se é diretório, depois encontra a versão e baixa o plugin novamente
    for f in ./wp-content/plugins/*; do
        if [ -d "$f" ]; then
            WP_PLUGIN_NAME="${f##*/}"
            WP_PLUGIN_VERSION=`find $f -type f -name '*php' | xargs egrep -h 'Version: ' | tr -d "$REGEX_VERSION"`
            printf "Downloading $WP_PLUGIN_NAME from: $URL_PLUGINS/$WP_PLUGIN_NAME.$WP_PLUGIN_VERSION.zip\n"
            wget --quiet -O "$NEW_WP_CONTENT_PATH/plugins/$WP_PLUGIN_NAME.zip" "$URL_PLUGINS/$WP_PLUGIN_NAME.$WP_PLUGIN_VERSION.zip" \
                && unzip -qq $NEW_WP_CONTENT_PATH/plugins/$WP_PLUGIN_NAME.zip \
                && rm -rf "$NEW_WP_CONTENT_PATH/plugins/$WP_PLUGIN_NAME.zip";
        fi
    done
    printf "\n"

    printf "Downloading themes:\n"
    # loop para verificar todos os temas, verifica se é diretório, depois encontra a versão e baixa o tema novamente
    for f in ./wp-content/themes/*; do
        if [ -d "$f" ]; then
            WP_THEME_NAME="${f##*/}"
            WP_THEME_VERSION=`grep 'Version: ' $f/style.css | tr -d "$REGEX_VERSION"`
            printf "Downloading $WP_THEME_NAME from: $URL_THEMES/$WP_THEME_NAME.$WP_THEME_VERSION.zip\n"
            wget --quiet -O "$NEW_WP_CONTENT_PATH/themes/$WP_THEME_NAME.zip" "$URL_THEMES/$WP_THEME_NAME.$WP_THEME_VERSION.zip" \
                && unzip -qq $NEW_WP_CONTENT_PATH/themes/$WP_THEME_NAME.zip \
                && rm -rf "$NEW_WP_CONTENT_PATH/themes/$WP_THEME_NAME.zip";
        fi
    done
    printf "\n"

    # encontra e remove arquivos com funções php dentro da wp-content/uploads
    printf "Removing infected files: \n"
    rm -rf $(find $NEW_WP_CONTENT_PATH/uploads -type f -name '*' |\
        xargs egrep -i "$SEARCH_FOR_CODE")

    rm -rf $(find $NEW_WP_CONTENT_PATH -type f -name "$SEARCH_FOR_FILE" ! -path "$NEW_WP_CONTENT_PATH/plugins" ! -path "$NEW_WP_CONTENT_PATH/themes" |\
        xargs egrep -i "$SEARCH_FOR_CODE") 
else 
    echo "$WP_VERSION_FILE_PATH does not exist."
fi

