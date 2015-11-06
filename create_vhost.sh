#!/bin/bash
clear;

YELLOW=`tput setaf 3`
GREEN=`tput setaf 2`
RED=`tput setaf 1`
BLUE=`tput setaf 4`
CYAN=`tput setaf 6`
NC=`tput sgr0`

vhost_name="mywebsite.loc";
cert_file="/home/mkatanski/.ssl/server/server.crt"
cert_key="/home/mkatanski/.ssl/server/server.key"
root_path="/home/mkatanski/www"
enableSSL="true"

echo "";
echo "";
echo "";
echo "${BLUE}";
echo " _    ____  __           __                                      __            ";
echo "| |  / / / / /___  _____/ /_   ____ ____  ____  ___  _________ _/ /_____  _____";
echo "| | / / /_/ / __ \/ ___/ __/  / __ \`/ _ \/ __ \/ _ \/ ___/ __ \`/ __/ __ \/ ___/";
echo "| |/ / __  / /_/ (__  ) /_   / /_/ /  __/ / / /  __/ /  / /_/ / /_/ /_/ / /    ";
echo "|___/_/ /_/\____/____/\__/   \__, /\___/_/ /_/\___/_/   \__,_/\__/\____/_/     ";
echo "                            /____/                                             ";

echo "";
echo "(c) Indust 2015. All Rights Reserved.";
echo "${NC}";
echo "";


read -p "${NC}Please enter virtual host name ($vhost_name):${NC} " name_answer

if [ "$name_answer" != "" ]
  then vhost_name=$name_answer;
fi

echo "${GREEN}Your new vhost name is:${CYAN} $vhost_name${NC}"
echo "";

useSSL() {
  printf "${GREEN}SSL will be enabled on port 443\nUse certificate from:${CYAN} ${cert_file}${GREEN}\nUse certificate key from:${CYAN} ${cert_key}${NC}\n";
}

disableSSL() {
  enableSSL="false"
  echo "${RED}SSL disabled${NC}";
}

read -p "Do You want to use SSL also (Y/n)?: " choice
case "$choice" in
  y|Y ) useSSL;;
  n|N ) disableSSL;;
  * ) useSSL;;
esac

echo "";

read -p "${NC}Enter website root path (${root_path}/${vhost_name}):${NC} " root_answer

if [ "$root_answer" != "" ]
  then root_path=$root_answer;
  else root_path=$root_path/$vhost_name;
fi

echo "${GREEN}Your website path is:${CYAN} $root_path${NC}"
echo "";
echo "";
echo "";

echo "Creating new virtual host...";
echo "";
echo "${YELLOW}Creating Nginx configuration file in: ${CYAN}/etc/nginx/sites-available/$vhost_name ${NC}";

if [ "$enableSSL" = "false" ]
then printf "server {\n\tlisten 80;\n\troot "$root_path";\n\tindex index.php index.html index.htm;\n\tserver_name "$vhost_name";\n\n\tlocation / {\n\t\ttry_files \$uri \$uri/ /index.html;\n\t}\n\n\terror_page 404 /404.html;\n\terror_page 500 502 503 504 /50x.html;\n\n\tlocation = /50x.html {\n\t\troot /usr/share/nginx/www;\n\t}\n\n\tlocation ~ \.php$ {\n\t\ttry_files \$uri =404;\n\t\tfastcgi_pass unix:/var/run/php5-fpm.sock;\n\t\tfastcgi_index index.php;\n\t\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n\t\tinclude fastcgi_params;\n\t}\n}" > /etc/nginx/sites-available/$vhost_name
else printf "server {\n\tlisten 80;\n\troot "$root_path";\n\tindex index.php index.html index.htm;\n\tserver_name "$vhost_name";\n\n\tlocation / {\n\t\ttry_files \$uri \$uri/ /index.html;\n\t}\n\n\terror_page 404 /404.html;\n\terror_page 500 502 503 504 /50x.html;\n\n\tlocation = /50x.html {\n\t\troot /usr/share/nginx/www;\n\t}\n\n\tlocation ~ \.php$ {\n\t\ttry_files \$uri =404;\n\t\tfastcgi_pass unix:/var/run/php5-fpm.sock;\n\t\tfastcgi_index index.php;\n\t\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n\t\tinclude fastcgi_params;\n\t}\n}\n\nserver {\n\tlisten 443;\n\troot "$root_path";\n\tindex index.php index.html index.htm;\n\tserver_name "$vhost_name";\n\n\tlocation / {\n\t\ttry_files \$uri \$uri/ /index.html;\n\t}\n\n\terror_page 404 /404.html;\n\terror_page 500 502 503 504 /50x.html;\n\n\tlocation = /50x.html {\n\t\troot /usr/share/nginx/www;\n\t}\n\n\tlocation ~ \.php$ {\n\t\ttry_files \$uri =404;\n\t\tfastcgi_pass unix:/var/run/php5-fpm.sock;\n\t\tfastcgi_index index.php;\n\t\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n\t\tinclude fastcgi_params;\n\t}\n\n\tssl on;\n\tssl_certificate "$cert_file";\n\tssl_certificate_key "$cert_key";\n}" > /etc/nginx/sites-available/$vhost_name
fi

echo "${YELLOW}Making new virtual host active${NC}";
ln -s /etc/nginx/sites-available/$vhost_name /etc/nginx/sites-enabled/

echo "${YELLOW}Creating website directory: ${CYAN}$root_path${NC}";
mkdir $root_path

echo "${YELLOW}Restarting Nginx server${NC}";
service nginx restart

echo "${YELLOW}Adding entry into ${CYAN}/etc/hosts${YELLOW} file${NC}";
sed -i '/'$vhost_name'/d' /etc/hosts
printf "\n127.0.0.1\t"$vhost_name >> /etc/hosts

echo "";
echo "";
echo "${GREEN}Everything is complete. Please visit your website url: ${NC}";
echo "${CYAN}http://"$vhost_name"${NC}";
if [ "$enableSSL" = "true" ]
  then echo "${CYAN}https://"$vhost_name"${NC}";
fi
echo "";
echo "";