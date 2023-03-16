#! /bin/bash

WP_VERSION_FILE_PATH="./wp-includes/version.php"
WP_ZIP_NAME="wordpress.zip"

INF_WP_PLUGINS_PATH="./wp-content/plugins"
INF_WP_THEME_PATH="./wp-content/themes"

# verifica se arquivo wp_version.php existe
if [ -f "$WP_VERSION_FILE_PATH" ]; then

    # pega a versão do wp
    WP_VERSION=`grep -i '$wp_version =' "$WP_VERSION_FILE_PATH" | tr -d '[:alpha:][:space:][$_=:;\47]'`
    printf "Wordpress version: $WP_VERSION\n"
    
    # baixa e descomprime o novo wordpress, na mesma versão do antigo
    printf "Downloading from: https://wordpress.org/wordpress-$WP_VERSION.zip\n"
    wget --quiet -O wordpress.zip "https://wordpress.org/wordpress-$WP_VERSION.zip" \
        && unzip -qq wordpress.zip \
        && rm -rf './wordpress.zip';
    printf "Download completed\n"

    # copia tudo da wp-content, menos os plugins e os themas
    printf "Copying files from wp-content, except plugins and themes:\n"
    rsync -r --stats --exclude="$INF_WP_PLUGINS_PATH" --exclude="$INF_WP_THEME_PATH" ./wp-content ./wordpress

    # copia o wp-config.php
    cp ./wp-config.php ./wordpress
    printf "Copied wp-config.php\n"

    printf "Downloading plugins:\n"
    # loop para verificar todos os plugins, verifica se é diretório, depois encontra a versão e baixa o plugin novamente
    for f in ./wp-content/plugins/*; do
        if [ -d "$f" ]; then
            WP_PLUGIN_VERSION=`grep --include=\*.php 'Version: ' "./wp-content/plugins/$f" | tr -d '[:alpha:][:space:][$_=:;\47]'`
            printf "Downloading from: https://downloads.wordpress.org/plugin/$f.$WP_PLUGIN_VERSION.zip\n"
            wget -O "./wordpress/wp-content/plugins/$f.zip" "https://downloads.wordpress.org/plugin/$f.$WP_PLUGIN_VERSION.zip" \
                && unzip -qq ./wordpress/wp-content/plugins/$f.zip \
                && rm -rf "./wordpress/wp-content/plugins/$f.zip";
        fi
    done
    printf "Done!\n"

    printf "Downloading themes:\n"
    # loop para verificar todos os temas, verifica se é diretório, depois encontra a versão e baixa o tema novamente
    for f in ./wp-content/theme/*; do
        if [ -d "$f" ]; then
            WP_THEME_VERSION=`grep 'Version: ' "./wp-content/themes/$f/style.css" | tr -d '[:alpha:][:space:][$_=:;\47]'`
            printf "Downloading from: https://downloads.wordpress.org/theme/$f.$WP_THEME_VERSION.zip\n"
            wget --quiet -O "./wordpress/wp-content/themes/$f.zip" "https://downloads.wordpress.org/theme/$f.$WP_THEME_VERSION.zip" \
                && unzip -qq ./wordpress/wp-content/themes/$f.zip \
                && rm -rf "./wordpress/wp-content/themes/$f.zip";
        fi
    done

    # encontra e remove arquivos com funções php dentro da wp-content/uploads
    # rm -rf $(find ./wordpress/wp-content/uploads -type f -name '*.{php|gif|jpg|jpeg|txt|png|webp}' | xargs egrep -i "(mail|fsockopen|pfsockopen|stream\_socket\_client|exec|system|passthru|eval|base64_decode|goto|base64|eval) *(") 
else 
    echo "$WP_VERSION_FILE_PATH does not exist."
fi

