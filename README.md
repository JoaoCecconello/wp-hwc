<h1 align="center">WordPress Hacked Website Cleaner</h1>
<p>
    This script was created with one intention: help people to clean their WordPress website, even if it's just a little. It actually does not clean the website, it recreates the entire WordPress structure in a new folder. This is the most simple and fast way to solve the hacking and remove malicious files as I'm concerned.
</p>
<p>
    Working in a website hosting company wich the main product is focused in WordPress for 2+ years made me realize that many people don't clean their websites as they should. The main reason is basically because they do not know how to do it and just a few percentage of developers and wordpress experts know how to solve the problems that a hacked website has.
</p>

<h3 align="center">🚧🚧 This project still in development 🚧🚧</h3>
<p>
    I'm still working on it so, if you use it and have any trouble, you can report to me or suggest any changes. I'm doing it as I can =)
</p>

<h2>How to use</h2>
<p>
    Execute the following steps to use the script. After the execution a folder called "wordpress" with the cleaned version will be available inside your wordpress folder.
</p>


```bash
# clone the repository inside your WordPress folder
$ git clone https://github.com/JoaoCecconello/wp-hwc.git

# change permissions
$ chmod 777 ./wp-hwc/wp-cleaner.sh

# execute
$ ./wp-hwc/wp-cleaner.sh
```
<h2>How does it work</h2>
<p>
    First of all we need to understand how wordpress works. It has 3 folders, just one of them your uploads and plugins and themes are stored: wp-content. The other two folder don't change if plugins and themes are modified. Inside wp-content there is 3 other folders that are essencial: plugins, themes and uploads. The uploads folder should not have executable files such as php, html and etc.
</p>
<p>
    What the script does is pretty simple: First it downloads the same version of your wordpress then copies the entire wp-content folder, except for plugins and themes directiory. After, it cleans malicious files from the entire wp-content. After removing the files, it downloads all plugins and themes from wordpress website. 
</p>
<p>
    All this process allow to recreate the entire wordpress structures and files, avoiding malicious files inside plugins, themes, wordpress core and wp-content folder. The script is not fail-proof, so it generates a report.txt file with all diferences between the hacked and cleaned wordpress.
</p>
