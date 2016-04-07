# First execute by hand
#sudo apt-get update

sudo apt-get install -y nginx mysql-server php5-cli php5-fpm php5-mysql php5-gd php5-curl php5-sqlite php5-tidy php5-imagick git tig vim-gtk curl virtualbox vagrant htop

# Install drush
wget http://files.drush.org/drush.phar 
chmod +x drush.phar 
sudo mv drush.phar /usr/local/bin/drush 
drush init -y

# Install drupal
curl https://drupalconsole.com/installer -L -o drupal.phar 
sudo mv drupal.phar /usr/local/bin/drupal 
chmod +x /usr/local/bin/drupal 
drupal init --override

# Install composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Create database and user
mysqladmin -u root create drupalcamp
echo "grant all on drupalcamp.* to drupalcamp@localhost identified by 'drupalpass';" | mysql -u root drupalcamp

# Create drupalcamp dir
cd 
mkdir drupalcamp 
cd drupalcamp 

# Clone nginx configuration
git clone https://github.com/jackbravo/simple-drupal-nginx.git 

# Create drupal, settings.php and files with permissions
drupal site:new drupal 8.0.6
mkdir drupal/sites/default/files
cp drupal/sites/default/default.settings.php drupal/sites/default/settings.php
sudo chgrp www-data drupal/sites/default/files drupal/sites/default/settings.php
chmod g+w drupal/sites/default/settings.php


# Configure nginx
CONTENT_SCRIPT="server {\n
     listen       80;\n
     server_name  drupalcamp.local;\n
     root         ${HOME}/drupalcamp/drupal;\n
     include      ${HOME}/drupalcamp/simple-drupal-nginx/drupal.conf;\n
}"
touch temp.conf
echo -e ${CONTENT_SCRIPT} > temp.conf
sudo mv temp.conf /etc/nginx/sites-enabled/drupalcamp.conf
sudo -- sh -c -e "echo '127.0.0.1 drupalcamp.local' >> /etc/hosts"
sudo service nginx restart

# Configure PHP-FPM
sudo sed -i.bak 's/^memory_limit.*/memory_limit = 512M/' /etc/php5/fpm/php.ini
sudo service php5-fpm restart

# Install Drupal site
cd drupal
drupal site:install standard --langcode=en --db-type=mysql --db-host=127.0.0.1 --db-name=drupalcamp --db-user=drupalcamp --db-pass=drupalpass --db-port=3306 --site-name="Drupal Camp" --site-mail=admin@example.com --account-name=admin --account-mail=admin@example.com --account-pass=admin --no-interaction

# Done =)
firefox drupalcamp.local
