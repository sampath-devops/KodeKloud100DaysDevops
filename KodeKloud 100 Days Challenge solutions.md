Linux Commands
## System Admin tasks

-- Day to day Tasks as a Linux sys Admin

## Task 1: Linux User Setup with Non-Interactive Shell
   - How to permit the root SSH login 
        --> Navigate to sshd_config file under /etc/ssh directory and  mark "permitRootlogin No" 
        --> restart the SSHd services to reflect the changes
## Task 2: Temporary User Setup with Expiry
## Task 3: Secure Root SSH Access
## Task 4: Script Execution Permissions
    - Providing the execution permission to the file 
      - chmod U+X filename --> This will give execute permission to the owner
      - chmod +rx filename --> this will give read execute permissions to all users (Owner, Group,users)- chmod +rwx/777 filename --> this will give whole read, write & execute permissions
## Task 5: SElinux Installation and Configuration
## Task 6: Create a Cron Job
    - Corn tab creation --> 
        - crontab -e --> it will give us the editor to enter the timings and script details
          Crontab format (5 fields + command):
            ```bash
            * * * * * command
            | | | | |
            | | | | +-- Day of week (0-7, 0 and 7 = Sunday)
            | | | +---- Month (1-12)
            | | +------ Day of month (1-31)
            | +-------- Hour (0-23)
            +---------- Minute (0-59)
            ```
            Example: run every 5 minutes and write "hello" to `/tmp/cron_text`:
            ```bash
            */5 * * * * echo hello > /tmp/cron_text
            ```
            Always use absolute paths in cron commands.

## Task 7: Linux SSH Authentication
    -- SSH Key generation for password less authentication
       - ssh-keygen -t rsa -->This will generate the ssh key and get saves in .ssh directory	     
       - ssh-copy-id <remote user \& servername> --> this will copy the ssh key to remote server to   establish the password less SSH connection between the server

## Task 11: Install and Configure Tomcat Server
   # Requirement: 
        The Nautilus application development team recently finished the beta version of one of their Java-based applications, 

        which they are planning to deploy on one of the app servers in Stratos DC. After an internal team meeting, they have decided to use the tomcat application server. 

         Based on the requirements mentioned below complete the task:

        a. Install tomcat server on App Server 3.
        b. Configure it to run on port 6000.
        c. There is a ROOT.war file on Jump host at location /tmp.

         Deploy it on this tomcat server and make sure the webpage works directly on base URL i.e curl http://stapp03:6000
   # Solution : Followed the below link to install the tomcat and added tomcat as a demon service https://cloudinfrastructureservices.co.uk/how-to-install-apache-tomcat-server-on-centos-stream-9-tutorial/ --- Changed the default http port value 8080 in server.xml to 6000 and restarted the services --- Copied the ROOT.war file from jumpbox using SCP command to stapp03 under /opt/tomcat/tomcat10/webapps folder

## Task 12 --> Linux Network Services 
   # Requirement: 
        Our monitoring tool has reported an issue in Stratos Datacenter. One of our app servers has an issue, as its Apache service is not reachable on port 6200 (which is the Apache port). The service itself could be down, the firewall could be at fault, or something else could be causing the issue. 
        Use tools like telnet, netstat, etc. to find and fix the issue. Also make sure Apache is reachable from the jump host without compromising any security settings.

        Once fixed, you can test the same using command curl http://stapp01:6200 command from jump host.
        Note: Please do not try to alter the existing index.html code, as it will lead to task failure.
   # Solution: 
        Observed HTTPD service is not running due to below error as already one sendmail serice is running on 6200 port due to that http service not able to start on 6200 port
            Error: - got this while using the command "systemctl status httpd.service -l --no-pager" / "journalctl -u httpd.service "
            Address already in use: A H00072: make_sock: could not bind to address 0.0.0.0:6200
        - Stopped the sendmail service / we kill the process as well using pid
        - started the httpd service 
        - tried curling to http://stapp01:6200 -- got the sucussfull response
        - now checked the ip table config file whether we have rules to allow the traffic through 6200 port 
            added the below line to allow traffic through 6200 port
            "-A INPUT -p tcp -m state --state NEW -m tcp --dport 8093 -j ACCEPT "
            "vi /etc/sysconfig/iptables"
            Reload the tptables configs
            systemctl reload iptables
        - Then tried curl to the http://stapp01:6200 from jumpbox and it worked

## Task 13: IPtables Installation And Configuration
   # Requirement :
        We have one of our websites up and running on our Nautilus infrastructure in Stratos DC. Our security team has raised a concern that right now Apache’s port i.e 6200 is open for all since there is no firewall installed on these hosts. So we have decided to add some security layer for these hosts and after discussions and recommendations we have come up with the following requirements:
        1. Install iptables and all its dependencies on each app host.
        2. Block incoming port 6200 on all apps for everyone except for LBR host.
        3. Make sure the rules remain, even after system reboot.
   # Solution:
        - Install the Iptables in the server using below command and make sure to enable the service and start it
            yum install iptables iptables-services -y - For installation
            systemctl enable iptables - creates the symlink in system level and enable the service to start while boot time
            sudo systemctl start iptables - to start the service 
            iptables -V - to know the installed version
            iptables -L - to know the existing firewall rules
        - follow the below steps to block the all incomming calls and allow only Load Balancer calls
            Navigate to the file iptables under /etc/sysconfig
            # file will be displayed as per below and add "-A INPUT -p tcp -s 172.16.238.14 --dport 6200 -j ACCEPT" with load balancer ip addredd & port number which need to communicate, and save the file
                [root@stapp01 sysconfig]# vi iptables
                # sample configuration for iptables service
                # you can edit this manually or use system-config-firewall
                # please do not ask us to add additional ports/services to this default configuration
                *filter
                :INPUT ACCEPT [0:0]
                :FORWARD ACCEPT [0:0]
                :OUTPUT ACCEPT [0:0]
                -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
                -A INPUT -p icmp -j ACCEPT
                -A INPUT -i lo -j ACCEPT
                -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
                -A INPUT -p tcp -s 172.16.238.14 --dport 6200 -j ACCEPT
                -A INPUT -j REJECT --reject-with icmp-host-prohibited
                -A FORWARD -j REJECT --reject-with icmp-host-prohibited
                COMMIT
            # run the below command to Set the default policy to DROP all other incoming traffic
                [root@stapp01 sysconfig]# iptables -P INPUT DROP
                [root@stapp01 sysconfig]# systemctl reload iptables
                [root@stapp01 sysconfig]# cat iptables -- This will display the updated iptables config file 
                # sample configuration for iptables service
                # you can edit this manually or use system-config-firewall
                # please do not ask us to add additional ports/services to this default configuration
                *filter
                :INPUT ACCEPT [0:0]
                :FORWARD ACCEPT [0:0]
                :OUTPUT ACCEPT [0:0]
                -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
                -A INPUT -p icmp -j ACCEPT
                -A INPUT -i lo -j ACCEPT
                -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
                -A INPUT -p tcp -s 172.16.238.14 --dport 6200 -j ACCEPT
                -A INPUT -j REJECT --reject-with icmp-host-prohibited
                -A FORWARD -j REJECT --reject-with icmp-host-prohibited
                COMMIT
            # Run the below command to make sure updated rules remain even after server reboot
                [root@stapp01 sysconfig]# service iptables save
                iptables: Saving firewall rules to /etc/sysconfig/iptables: [  OK  ]
                [root@stapp01 sysconfig]# 

## Task 16: Install and Configure Nginx as an LBR
   # Requirement: 
      Day by day traffic is increasing on one of the websites managed by the Nautilus production support team. Therefore, the team has observed a degradation in website performance. Following discussions about this issue, the team has decided to deploy this application on a high availability stack i.e on Nautilus infra in Stratos DC. They started the migration last month and it is almost done, as only the LBR server configuration is pending. Configure LBR server as per the information given below:
        a. Install nginx on LBR (load balancer) server.
        b. Configure load-balancing with the an http context making use of all App Servers. Ensure that you update only the main Nginx configuration file located at /etc/nginx/nginx.conf.
        c. Make sure you do not update the apache port that is already defined in the apache configuration on all app servers, also make sure apache service is up and running on all app servers.
        d. Once done, you can access the website using StaticApp button on the top bar.
   # Solution:
        -- Installed NGINX in load balancer server using below commands
            sudo dnf install nginx -y
            # Started the nginx service post installation 
              systemctl start nginx
        -- Configured the load balancing setting for 3 app servers in /etc/nginx/nginx.conf
                Updated the file by adding below block under http block

                  upstream backend {
                     server stapp01.stratos.xfusioncorp.com;
                     server stapp02.stratos.xfusioncorp.com;
                    server 172.16.238.12;  # we can give eaither server ip address or host name
                         }
                Restarted the nginx service to reload the changes
                Tested the config by running command nginx -t to validate the syntex and configs, got successfull response
                [root@stlb01 nginx]# nginx -t
                nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
                nginx: configuration file /etc/nginx/nginx.conf test is successful
        -- Validated the httpd service startus in all app servers and tried to curl the service from Loda balancer server, Able to got the response
        -- It got the "Welcome to xFusionCorp Industries!" but did not get same response while accssing thorugh browser as we did not configured the proxy settings
                      XXX Task is failed due to proxy settings are not available XXXX
        -- To fix the issue and reupdated the nginx.conf filw with below content 
                user  nginx;
                worker_processes  auto;
                error_log  /var/log/nginx/error.log warn;
                pid        /var/run/nginx.pid;

                events {
                    worker_connections  1024;
                }

                http {
                    upstream app_servers {
                        server 172.16.238.10:6000;
                        server 172.16.238.11:6000;
                        server 172.16.238.12:6000;
                    }

                    server {
                        listen 80;

                        location / {
                            proxy_pass http://app_servers;
                            proxy_set_header Host $host;
                            proxy_set_header X-Real-IP $remote_addr;
                            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                            proxy_set_header X-Forwarded-Proto $scheme;
                        }
                    }
                }
        -- Restarted the nginx service and tried the LBR url through browser got the expected response
# Task 17: Install and Configure PostgreSQL
   # Requirement:
        The Nautilus application development team has shared that they are planning to deploy one newly developed application on Nautilus infra in Stratos DC. The application uses PostgreSQL database, so as a pre-requisite we need to set up PostgreSQL database server as per requirements shared below:
            PostgreSQL database server is already installed on the Nautilus database server.
                a. Create a database user kodekloud_gem and set its password to 8FmzjvFU6S.
                b. Create a database kodekloud_db1 and grant full permissions to user kodekloud_gem on this database.
                Note: Please do not try to restart PostgreSQL server service.
   # Solution: 
        -- Connect PostgreSQL commandline using below command
                sudo -u postgres psql
        -- Create the DB user using below command
                CREATE USER your_username WITH ENCRYPTED PASSWORD 'your_password';
                CREATE USER kodekloud_gem WITH ENCRYPTED PASSWORD '8FmzjvFU6S';
                # Use the below command to list the users in PostgreSQL
                    postgres-# \du
                        # OutPut: 
                                                            List of roles
                        Role name   |                         Attributes                         | Member of 
                        ---------------+------------------------------------------------------------+-----------
                        kodekloud_gem |                                                            | {}
                        postgres      | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
        -- Create the DB using below command
                CREATE DATABASE kodekloud_db1;
                # Use the below command to list the DB in postgreSQL
                    postgres-# \l
                            #OutPut:
                                                     List of databases
                                Name      |  Owner   | Encoding  | Collate | Ctype |     Access privileges      
                            ---------------+----------+-----------+---------+-------+----------------------------
                            kodekloud_db1 | postgres | SQL_ASCII | C       | C       |                            +
                                        |          |           |           |         |                            +
                                        |          |           |           |         | 
                            postgres      | postgres | SQL_ASCII | C       | C       | 
                            template0     | postgres | SQL_ASCII | C       | C       | =c/postgres               +
                                        |          |           |           |         | postgres=CTc/postgres
                            template1     | postgres | SQL_ASCII | C       | C       | =c/postgres               +
                                        |          |           |           |         | postgres=CTc/postgres
                            (4 rows)
        -- Use the below command to grant full permissions to user
                GRANT ALL PRIVILEGES ON DATABASE kodekloud_db1 TO kodekloud_gem;
                # validate the whether permission are applied or not using "\l" command
                                                          List of databases
                            Name      |  Owner   | Encoding  | Collate | Ctype |     Access privileges      
                        ---------------+----------+-----------+---------+-------+----------------------------
                        kodekloud_db1 | postgres | SQL_ASCII | C       | C     | =Tc/postgres              +
                                      |          |           |         |       | postgres=CTc/postgres     +
                                      |          |           |         |       | kodekloud_gem=CTc/postgres
                        postgres      | postgres | SQL_ASCII | C       | C     | 
                        template0     | postgres | SQL_ASCII | C       | C     | =c/postgres               +
                                      |          |           |         |       | postgres=CTc/postgres
                        template1     | postgres | SQL_ASCII | C       | C     | =c/postgres               +
                                      |          |           |         |       | postgres=CTc/postgres
                        (4 rows)
            
# Task 18: Configure LAMP server
   # Requirement:
        xFusionCorp Industries is planning to host a WordPress website on their infra in Stratos Datacenter. They have already done infrastructure configuration—for example, on the storage server they already have a shared directory /vaw/www/html that is mounted on each app host under /var/www/html directory. Please perform the following steps to accomplish the task:
            a. Install httpd, php and its dependencies on all app hosts.
            b. Apache should serve on port 8086 within the apps.
            c. Install/Configure MariaDB server on DB Server.
            d. Create a database named kodekloud_db7 and create a database user named kodekloud_roy identified as password TmPcZjtRQx. Further make sure this newly created user is able to perform all operation on the database you created.
            e. Finally you should be able to access the website on LBR link, by clicking on the App button on the top bar. You should see a message like App is able to connect to the database using user kodekloud_roy

   # Solution:
        - Follow the below steps to install the Httpd & PHP
            # Httpd Installation
            - yum update -y # To make sure system packages are up to date
            - yum install httpd -y # Installs the HHTPD/Apache web server
            # PHP Installation
            # To install a specific version of PHP on CentOS Stream 9 (which is the basis for RHEL 9), you must use the Remi repository
            # EPEL Package repository (Mostly it will be available & upto date)
            - sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
            # Install the Remi repository
            - sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
            # List available PHP module streams
            - sudo dnf module list php
            # Enable the desired PHP version (e.g., PHP 8.5)
            - sudo dnf module enable php:remi-8.5 -y
            # This command installs the core PHP packages (php, php-cli, php-fpm) and several popular extensions (MySQL driver, GD     library, etc.)
            - sudo dnf install php php-cli php-fpm php-mysqlnd php-gd php-mbstring php-xml -y
            # To validate the version of PHP
            - php -v
            # Enabling & Starting the php as a service 
            - sudo systemctl enable php-fpm
            - sudo systemctl start php-fpm
            - sudo systemctl status php-fpm
        - Steps to update the apache port to 8086
            - Navigate to /etc/httpd/conf directory and open the httpd.conf file modify the text "Listen 80" to "Listen 8089"
            - Restart the https service and validate whether https running on 8089 port or not
               * systemctl restart httpd  # Restart the Httpd service
               * ss -tunlp | grep "8089" # this command will show which services are running on 8089 port along pid

        - Steps to install/configure the Maria Db

            - sudo dnf update -y  # To update the repo system
            - sudo dnf install mariadb-server -y  # To install the mariadb-server
            - sudo systemctl start mariadb
            - sudo systemctl enable mariadb
            - sudo systemctl status mariadb
            # Configuration & Security
                - sudo mysql_secure_installation # This command will prompt the below settings
                   Set a strong root password.
                   Remove anonymous users.
                   Disallow remote root login.
                   Remove the test database.
        - Steps to create the data base and DB user
            # In CLI enter "mysql" it will take you to the mariadb console then the run the below commands
              CREATE DATABASE mydatabase;
              CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypassword';
              GRANT ALL PRIVILEGES ON mydatabase.* TO 'myuser'@'localhost';
              FLUSH PRIVILEGES;

            - SHOW DATABASES; # Displays the available databases in server
            - SELECT User, Host FROM mysql.user; # Shows the list of users
            - SELECT User, Host FROM mysql.global_priv; # it will shows the list users with respective previliges

# Task 19: Install and Configure Web Application
  # Requirement:
    xFusionCorp Industries is planning to host two static websites on their infra in Stratos Datacenter. The development of these websites is still in-progress, but we want to get the servers ready. Please perform the following steps to accomplish the task:
        a. Install httpd package and dependencies on app server 3.
        b. Apache should serve on port 8088.
        c. There are two website's backups /home/thor/news and /home/thor/cluster on jump_host. Set them up on Apache in a way that news should work on the link http://localhost:8088/news/ and cluster should work on link http://localhost:8088/cluster/ on the mentioned app server.
        d. Once configured you should be able to access the website using curl command on the respective app server, i.e curl http://localhost:8088/news/ and curl http://localhost:8088/cluster/
   # Solution:
       - sudo yum install httpd -y # this command will install the apache/httpd
       - sudo systemctl enable http # this will enable the service in system/boot level
       - Navigate to the http.conf file under /etc/httpd/conf/ location 
       - open the httpd.conf file using VI editior and modity the "Listen 80" to "Listen 8088"
       - Restart the httpd service if already stared or else start the service "systemctl restart httpd"
       - ss -tunlp | grep "8088" # validate whether httpd service running on 8088 port
       - Create the "news" & cluster directories under /var/www/html location using "MKDIR" command
       - SCP /thor/news/index.html banner@stapp02:/tmp ## This command will copy the index.html file from jumpbox to app server 3
       - mv /tmp/index.html /var/www/html/news ## this command will move the file from /tmp to /var/www/html/news directory
       - SCP /thor/cluster/index.html banner@stapp02:/tmp ## This command will copy the index.html file from jumpbox to app server 3
       - mv /tmp/index.html /var/www/html/cluster ## this command will move the file from /tmp to /var/www/html/cluster directory
       - now we can try curl operations and able to view the content of deployed files in httpd
       
# Task 20: Configure Nginx + PHP-FPM Using Unix Sock
  # Requirement: 
        The Nautilus application development team is planning to launch a new PHP-based application, which they want to deploy on Nautilus infra in Stratos DC. The development team had a meeting with the production support team and they have shared some requirements regarding the infrastructure. Below are the requirements they shared:
         a. Install nginx on app server 1 , configure it to use port 8095 and its document root should be /var/www/html.
         b. Install php-fpm version 8.1 on app server 1, it must use the unix socket /var/run/php-fpm/default.sock (create the parent directories if don't exist).
         c. Configure php-fpm and nginx to work together.
         d. Once configured correctly, you can test the website using curl http://stapp01:8095/index.php command from jump host.
         NOTE: We have copied two files, index.php and info.php, under /var/www/html as part of the PHP-based application setup. Please do not modify these files.
  # Solution: 
        - yum install nginx ## Installs the nginx 
        - systemctl enable nginx ## enable the service in boot/system level
        - Navigate to /etc/nginx directory edit the nginx.conf file with content Listen 80 to Listen 8095 and update the root directory as /var/www/html
        # Installing PHP-fpm
        # EPEL Package repository (Mostly it will be available & upto date)
            - sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
            # Install the Remi repository
            - sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
            # List available PHP module streams
            - sudo dnf module list php
            # Enable the desired PHP version (e.g., PHP 8.5)
            - sudo dnf module enable php:remi-8.5 -y
            # This command installs the core PHP packages (php, php-cli, php-fpm) and several popular extensions (MySQL driver, GD     library, etc.)
            - sudo dnf install php php-cli php-fpm php-mysqlnd php-gd php-mbstring php-xml -y
            # To validate the version of PHP
            - php -v
            # Enabling & Starting the php as a service 
            - sudo systemctl enable php-fpm
            - sudo systemctl start php-fpm
            - sudo systemctl status php-fpm
        
        - After sucussfull PHP-FPM installation update listen = /var/run/php-fpm/default.sock in /etc/php-fpm.d/www.conf file
        - update the below content in nginx.conf file for php and nginx configuration
            'server {
                listen 8099;
                root /var/www/html;
                index index.php index.html;

                location ~ \.php$ {
                    include fastcgi_params;
                    fastcgi_pass unix:/var/run/php-fpm/default.sock;
                    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                }
            }'
        - # restart the both nginx and php-fpm services
#########################################################################################################
##########################                    GIT          ##############################################
#########################################################################################################
# Task 21: Set Up Git Repository on Storage Server
  # Requirement:
  # Solution: 
        - yum install git # installs the git in server
        - git init --bare <<folder.git>> # it create the bare repository 
# Day 22: Clone Git Repository on Storage Server
  # Requirement: Clone the git repo
  # Solution: git clone -l /opt/games.git 

# Task 23: Fork a Git Repository
  # Requirement: 
        There is a Git server utilized by the Nautilus project teams. Recently, a new developer named Jon joined the team and needs to begin working on a project. To begin, he must fork an existing Git repository. Follow the steps below:
            Click on the Gitea UI button located on the top bar to access the Gitea page.
            Login to Gitea server using username jon and password Jon_pass123.
            Once logged in, locate the Git repository named sarah/story-blog and fork it under the jon user.
            Note: For tasks requiring web UI changes, screenshots are necessary for review purposes. Additionally, consider utilizing screen recording software such as loom.com to record and share your task completion process.
# Task 24: Git Create Branches
   # Requirement: 
        Nautilus developers are actively working on one of the project repositories, /usr/src/kodekloudrepos/media. Recently, they decided to implement some new features in the application, and they want to maintain those new changes in a separate branch. Below are the requirements that have been shared with the DevOps team:
         On Storage server in Stratos DC create a new branch xfusioncorp_media from master branch in /usr/src/kodekloudrepos/media git repo.
         Please do not try to make any changes in the code.
   # Solution: 
        [root@ststor01 media]# git branch
        * kodekloud_media
        master
        [root@ststor01 media]# git checkout master
        Switched to branch 'master'
        Your branch is up to date with 'origin/master'.
        [root@ststor01 media]# git branch
        kodekloud_media
        * master
        [root@ststor01 media]# git checkout -b xfusioncorp_media
        Switched to a new branch 'xfusioncorp_media'
        [root@ststor01 media]# git branch
        kodekloud_media
        master
        * xfusioncorp_media
        [root@ststor01 media]# 
# Task 25: Git Merge Branches
   # Requirement:
        The Nautilus application development team has been working on a project repository /opt/news.git. This repo is cloned at /usr/src/kodekloudrepos on storage server in Stratos DC. They recently shared the following requirements with DevOps team:
            Create a new branch datacenter in /usr/src/kodekloudrepos/news repo from master and copy the /tmp/index.html file (present on storage server itself) into the repo. Further, add/commit this file in the new branch and merge back that branch into master branch. Finally, push the changes to the origin for both of the branches.

  # Solution: 
        [sudo] password for natasha: 
        [root@ststor01 ~]# cd /usr/src/kodekloudrepos/
        [root@ststor01 kodekloudrepos]# cd news/
        [root@ststor01 news]# ls
        info.txt  welcome.txt
        [root@ststor01 news]# git branch
        * master
        [root@ststor01 news]# git checkout -b datacenter
        Switched to a new branch 'datacenter'
        [root@ststor01 news]# git branch
        * datacenter
        master
        [root@ststor01 news]# cp /tmp/index.html .
        [root@ststor01 news]# ls
        index.html  info.txt  welcome.txt
        [root@ststor01 news]# ls -ltr
        total 12
        -rw-r--r-- 1 root root 26 Jan  2 06:29 welcome.txt
        -rw-r--r-- 1 root root 34 Jan  2 06:29 info.txt
        -rw-r--r-- 1 root root 27 Jan  2 07:06 index.html
        [root@ststor01 news]# git status
        On branch datacenter
        Untracked files:
        (use "git add <file>..." to include in what will be committed)
                index.html

        nothing added to commit but untracked files present (use "git add" to track)
        [root@ststor01 news]# git add
        Nothing specified, nothing added.
        hint: Maybe you wanted to say 'git add .'?
        hint: Disable this message with "git config advice.addEmptyPathspec false"
        [root@ststor01 news]# git add index.html 
        [root@ststor01 news]# git status
        On branch datacenter
        Changes to be committed:
        (use "git restore --staged <file>..." to unstage)
                new file:   index.html

        [root@ststor01 news]# 
        [root@ststor01 news]# git commit -m "commiting the index.html file"
        [datacenter 0326e00] commiting the index.html file
        1 file changed, 1 insertion(+)
        create mode 100644 index.html
        [root@ststor01 news]# git status
        On branch datacenter
        nothing to commit, working tree clean
        [root@ststor01 news]# git checkout master
        Switched to branch 'master'
        Your branch is up to date with 'origin/master'.
        [root@ststor01 news]# git merge datacenter
        Updating 93fe246..0326e00
        Fast-forward
        index.html | 1 +
        1 file changed, 1 insertion(+)
        create mode 100644 index.html
        [root@ststor01 news]# git push origin master
        Enumerating objects: 4, done.
        Counting objects: 100% (4/4), done.
        Delta compression using up to 16 threads
        Compressing objects: 100% (2/2), done.
        Writing objects: 100% (3/3), 338 bytes | 338.00 KiB/s, done.
        Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
        To /opt/news.git
        93fe246..0326e00  master -> master
        [root@ststor01 news]# git push origin datacenter
        Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
        To /opt/news.git
        * [new branch]      datacenter -> datacenter
        [root@ststor01 news]# 

# Task 26: Git Manage Remotes
   # Requirement:
        The xFusionCorp development team added updates to the project that is maintained under /opt/beta.git repo and cloned under /usr/src/kodekloudrepos/beta. Recently some changes were made on Git server that is hosted on Storage server in Stratos DC. The DevOps team added some new Git remotes, so we need to update remote on /usr/src/kodekloudrepos/beta repository as per details mentioned below:
            a. In /usr/src/kodekloudrepos/beta repo add a new remote dev_beta and point it to /opt/xfusioncorp_beta.git repository.
            b. There is a file /tmp/index.html on same server; copy this file to the repo and add/commit to master branch.
            c. Finally push master branch to this new remote origin.
   # Solution:
            [root@ststor01 beta]# git remote
            origin
            [root@ststor01 beta]# git branch
            * master
            [root@ststor01 beta]# git repo
            git: 'repo' is not a git command. See 'git --help'.

            The most similar commands are
                    grep
                    reflog
                    refs
                    remote
                    repack
                    replay
            [root@ststor01 beta]# git repo --list
            git: 'repo' is not a git command. See 'git --help'.

            The most similar commands are
                    grep
                    reflog
                    refs
                    remote
                    repack
                    replay
            [root@ststor01 beta]# git repo list
            git: 'repo' is not a git command. See 'git --help'.

            The most similar commands are
                    grep
                    reflog
                    refs
                    remote
                    repack
                    replay
            [root@ststor01 beta]# git remote add dev_beta /opt/xfusioncorp_beta.git
            [root@ststor01 beta]# git remote
            dev_beta
            origin
            [root@ststor01 beta]# cp /tmp/index.html .
            [root@ststor01 beta]# ls
            index.html  info.txt
            [root@ststor01 beta]# git add index.html 
            [root@ststor01 beta]# git status
            On branch master
            Your branch is up to date with 'origin/master'.

            Changes to be committed:
            (use "git restore --staged <file>..." to unstage)
                    new file:   index.html

            [root@ststor01 beta]# git commint -m "commiting the index file"
            git: 'commint' is not a git command. See 'git --help'.

            The most similar command is
                    commit
            [root@ststor01 beta]# git commit -m "commiting the index file"
            [master 797826f] commiting the index file
            1 file changed, 10 insertions(+)
            create mode 100644 index.html
            [root@ststor01 beta]# git branch
            * master
            [root@ststor01 beta]# git push dev_beta master
            Enumerating objects: 6, done.
            Counting objects: 100% (6/6), done.
            Delta compression using up to 16 threads
            Compressing objects: 100% (4/4), done.
            Writing objects: 100% (6/6), 588 bytes | 147.00 KiB/s, done.
            Total 6 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
            To /opt/xfusioncorp_beta.git
            * [new branch]      master -> master
            [root@ststor01 beta]# 

# Task 27: Git Revert Some Changes    
  # Requirement:
        The Nautilus application development team was working on a git repository /usr/src/kodekloudrepos/games present on Storage server in Stratos DC. However, they reported an issue with the recent commits being pushed to this repo. They have asked the DevOps team to revert repo HEAD to last commit. Below are more details about the task:
         In /usr/src/kodekloudrepos/games git repository, revert the latest commit ( HEAD ) to the previous commit (JFYI the previous commit hash should be with initial commit message ).
         Use revert games message (please use all small letters for commit message) for the new revert commit.    
   # Solution:
            git revert HEAD

            [root@ststor01 games]# git commit --amend -m "revert games"
            [master ee56cf2] revert games
            Date: Fri Jan 2 09:35:52 2026 +0000
            1 file changed, 1 insertion(+)
            create mode 100644 info.txt
            [root@ststor01 games]# git log --oneline
            ee56cf2 (HEAD -> master) revert games
            bcf66c1 (origin/master) add data.txt file
            bf0bfc9 initial commit
            [root@ststor01 games]#     
# Task 28: Git Cherry Pick
  # Requirement: 
        The Nautilus application development team has been working on a project repository /opt/cluster.git. This repo is cloned at /usr/src/kodekloudrepos on storage server in Stratos DC. They recently shared the following requirements with the DevOps    team:      
            There are two branches in this repository, master and feature. One of the developers is working on the feature branch and their work is still in progress, however they want to merge one of the commits from the feature branch to the master branch, the message for the commit that needs to be merged into master is Update info.txt. Accomplish this task for them, also remember to push your changes eventually.
  # Solution:
        [root@ststor01 cluster]# git log --oneline
        e1e0df0 (HEAD -> feature, origin/feature) Update welcome.txt
        40554b9 Update info.txt
        bfd2cf4 (origin/master, master) Add welcome.txt
        c6aa3db initial commit
        [root@ststor01 cluster]# git checkout master
        Switched to branch 'master'
        Your branch is up to date with 'origin/master'.
        [root@ststor01 cluster]# git branch
        feature
        * master
        [root@ststor01 cluster]# git cherry-pick 40554b9
        [master f98ac9f] Update info.txt
        Date: Fri Jan 2 10:33:37 2026 +0000
        1 file changed, 1 insertion(+), 1 deletion(-)
        [root@ststor01 cluster]# git log
        commit f98ac9f2011beca2cb11ed9239dccd34b922b783 (HEAD -> master)
        Author: Admin <admin@kodekloud.com>
        Date:   Fri Jan 2 10:33:37 2026 +0000

            Update info.txt

        commit bfd2cf4c9bd06201451e06db5c4f1559a47d2201 (origin/master)
        Author: Admin <admin@kodekloud.com>
        Date:   Fri Jan 2 10:33:37 2026 +0000

            Add welcome.txt

        commit c6aa3db47721ff052ca03197176ffbf88d7cc1d1
        Author: Admin <admin@kodekloud.com>
        Date:   Fri Jan 2 10:33:37 2026 +0000

            initial commit
        [root@ststor01 cluster]# git status
        On branch master
        Your branch is ahead of 'origin/master' by 1 commit.
        (use "git push" to publish your local commits)

        nothing to commit, working tree clean
        [root@ststor01 cluster]# git push origin/master
        fatal: 'origin/master' does not appear to be a git repository
        fatal: Could not read from remote repository.

        Please make sure you have the correct access rights
        and the repository exists.
        [root@ststor01 cluster]# git push master
        fatal: 'master' does not appear to be a git repository
        fatal: Could not read from remote repository.

        Please make sure you have the correct access rights
        and the repository exists.
        [root@ststor01 cluster]# git push origin master
        Enumerating objects: 5, done.
        Counting objects: 100% (5/5), done.
        Delta compression using up to 16 threads
        Compressing objects: 100% (2/2), done.
        Writing objects: 100% (3/3), 314 bytes | 314.00 KiB/s, done.
        Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
        To /opt/cluster.git
        bfd2cf4..f98ac9f  master -> master
        [root@ststor01 cluster]# git log
        commit f98ac9f2011beca2cb11ed9239dccd34b922b783 (HEAD -> master, origin/master)
        Author: Admin <admin@kodekloud.com>
        Date:   Fri Jan 2 10:33:37 2026 +0000

            Update info.txt

        commit bfd2cf4c9bd06201451e06db5c4f1559a47d2201
        Author: Admin <admin@kodekloud.com>
        Date:   Fri Jan 2 10:33:37 2026 +0000

            Add welcome.txt

        commit c6aa3db47721ff052ca03197176ffbf88d7cc1d1
        Author: Admin <admin@kodekloud.com>
        Date:   Fri Jan 2 10:33:37 2026 +0000

            initial commit
        [root@ststor01 cluster]# 
# Day 29: Manage Git Pull Requests
   # Requirement:
        Max want to push some new changes to one of the repositories but we don't want people to push directly to master branch, since that would be the final version of the code. It should always only have content that has been reviewed and approved. We cannot just allow everyone to directly push to the master branch. So, let's do it the right way as discussed below:
            SSH into storage server using user max, password Max_pass123 . There you can find an already cloned repo under Max user's home. Max has written his story about The 🦊 Fox and Grapes 🍇
            Max has already pushed his story to remote git repository hosted on Gitea branch story/fox-and-grapes
            Check the contents of the cloned repository. Confirm that you can see Sarah's story and history of commits by running git log and validate author info, commit message etc.
            Max has pushed his story, but his story is still not in the master branch. Let's create a Pull Request(PR) to merge Max's story/fox-and-grapes branch into the master branch
            Click on the Gitea UI button on the top bar. You should be able to access the Gitea page.
            UI login info:
            - Username: max
            - Password: Max_pass123
            PR title : Added fox-and-grapes story
            PR pull from branch: story/fox-and-grapes (source)
            PR merge into branch: master (destination)
            Before we can add our story to the master branch, it has to be reviewed. So, let's ask tom to review our PR by assigning him as a reviewer
            Add tom as reviewer through the Git Portal UI
            Go to the newly created PR
            Click on Reviewers on the right
            Add tom as a reviewer to the PR
            Now let's review and approve the PR as user Tom
            Login to the portal with the user tom
            Logout of Git Portal UI if logged in as max
            UI login info:
            - Username: tom
            - Password: Tom_pass123
            PR title : Added fox-and-grapes story
            Review and merge it.
            Great stuff!! The story has been merged! 👏
            Note: For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
# Task 30: Git hard reset
  # Requirement:
        The Nautilus application development team was working on a git repository /usr/src/kodekloudrepos/blog present on Storage server in Stratos DC. This was just a test repository and one of the developers just pushed a couple of changes for testing, but now they want to clean this repository along with the commit history/work tree, so they want to point back the HEAD and the branch itself to a commit with message add data.txt file. Find below more details:
            In /usr/src/kodekloudrepos/blog git repository, reset the git commit history so that there are only two commits in the commit history i.e initial commit and add data.txt file.
            Also make sure to push your changes.
  # Solution: 
        [root@ststor01 blog]# git log --oneline
        1d78df0 (HEAD -> master, origin/master) Test Commit10
        b5a13d2 Test Commit9
        721bc2c Test Commit8
        ab0bf07 Test Commit7
        48d6eb9 Test Commit6
        d749086 Test Commit5
        8eb669b Test Commit4
        8c467e7 Test Commit3
        32e2203 Test Commit2
        0a6d07e Test Commit1
        fc2cdef add data.txt file
        9e00edc initial commit
        [root@ststor01 blog]# git branch
        * master
        [root@ststor01 blog]# git reset --hard fc2cdef
        HEAD is now at fc2cdef add data.txt file
        [root@ststor01 blog]# git log --oneline
        fc2cdef (HEAD -> master) add data.txt file
        9e00edc initial commit
        [root@ststor01 blog]# git push origin master
        To /opt/blog.git
        ! [rejected]        master -> master (non-fast-forward)
        error: failed to push some refs to '/opt/blog.git'
        hint: Updates were rejected because the tip of your current branch is behind
        hint: its remote counterpart. If you want to integrate the remote changes,
        hint: use 'git pull' before pushing again.
        hint: See the 'Note about fast-forwards' in 'git push --help' for details.
        [root@ststor01 blog]# git pull
        Updating fc2cdef..1d78df0
        Fast-forward
        info.txt | 1 +
        1 file changed, 1 insertion(+)
        create mode 100644 info.txt
        [root@ststor01 blog]# git log --oneline
        1d78df0 (HEAD -> master, origin/master) Test Commit10
        b5a13d2 Test Commit9
        721bc2c Test Commit8
        ab0bf07 Test Commit7
        48d6eb9 Test Commit6
        d749086 Test Commit5
        8eb669b Test Commit4
        8c467e7 Test Commit3
        32e2203 Test Commit2
        0a6d07e Test Commit1
        fc2cdef add data.txt file
        9e00edc initial commit
        [root@ststor01 blog]# git reset --hard fc2cdef
        HEAD is now at fc2cdef add data.txt file
        [root@ststor01 blog]# git push origin master
        To /opt/blog.git
        ! [rejected]        master -> master (non-fast-forward)
        error: failed to push some refs to '/opt/blog.git'
        hint: Updates were rejected because the tip of your current branch is behind
        hint: its remote counterpart. If you want to integrate the remote changes,
        hint: use 'git pull' before pushing again.
        hint: See the 'Note about fast-forwards' in 'git push --help' for details.
        [root@ststor01 blog]# git rebase -i --root
        Successfully rebased and updated refs/heads/master.
        [root@ststor01 blog]# git push origin master --force
        Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
        To /opt/blog.git
        + 1d78df0...fc2cdef master -> master (forced update)
        [root@ststor01 blog]# 
# Task 31: Git Stash
  # Requirement:
        The Nautilus application development team was working on a git repository /usr/src/kodekloudrepos/apps present on Storage server in Stratos DC. One of the developers stashed some in-progress changes in this repository, but now they want to restore some of the stashed changes. Find below more details to accomplish this task:
          Look for the stashed changes under /usr/src/kodekloudrepos/apps git repository, and restore the stash with stash@{1} identifier. Further, commit and push your changes to the origin.
  # Solution:
        [root@ststor01 apps]# git log --oneline
        e670534 (HEAD -> master, origin/master) initial commit
        [root@ststor01 apps]# git stash show
        welcome.txt | 1 +
        1 file changed, 1 insertion(+)
        [root@ststor01 apps]# git stash list
        stash@{0}: WIP on master: e670534 initial commit
        stash@{1}: WIP on master: e670534 initial commit
        [root@ststor01 apps]# git status
        On branch master
        Your branch is up to date with 'origin/master'.

        nothing to commit, working tree clean
        [root@ststor01 apps]# git stash apply e670534
        fatal: 'e670534' is not a stash-like commit
        [root@ststor01 apps]# git stash apply stash@{1}
        On branch master
        Your branch is up to date with 'origin/master'.

        Changes to be committed:
        (use "git restore --staged <file>..." to unstage)
                new file:   welcome.txt

        [root@ststor01 apps]# git status
        On branch master
        Your branch is up to date with 'origin/master'.

        Changes to be committed:
        (use "git restore --staged <file>..." to unstage)
                new file:   welcome.txt

        [root@ststor01 apps]# git add .
        [root@ststor01 apps]# git status
        On branch master
        Your branch is up to date with 'origin/master'.

        Changes to be committed:
        (use "git restore --staged <file>..." to unstage)
                new file:   welcome.txt

        [root@ststor01 apps]# git comming -m "Commiting the stash changes"
        git: 'comming' is not a git command. See 'git --help'.

        The most similar command is
                commit
        [root@ststor01 apps]# git commit -m "Commiting the stash changes"
        [master 93f2fd9] Commiting the stash changes
        1 file changed, 1 insertion(+)
        create mode 100644 welcome.txt
        [root@ststor01 apps]# git status
        On branch master
        Your branch is ahead of 'origin/master' by 1 commit.
        (use "git push" to publish your local commits)

        nothing to commit, working tree clean
        [root@ststor01 apps]# git push origin master
        Enumerating objects: 4, done.
        Counting objects: 100% (4/4), done.
        Delta compression using up to 16 threads
        Compressing objects: 100% (2/2), done.
        Writing objects: 100% (3/3), 312 bytes | 312.00 KiB/s, done.
        Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
        To /opt/apps.git
        e670534..93f2fd9  master -> master
        [root@ststor01 apps]# git log --oneline
        93f2fd9 (HEAD -> master, origin/master) Commiting the stash changes
        e670534 initial commit
        [root@ststor01 apps]# git log 93f2fd9
        commit 93f2fd9b53fb490aafc145751b1d240205d2ceb7 (HEAD -> master, origin/master)
        Author: Admin <admin@kodekloud.com>
        Date:   Fri Jan 2 11:51:24 2026 +0000

            Commiting the stash changes

        commit e6705349596db13a6a06285e51944e3b1ab190d3
        Author: Admin <admin@kodekloud.com>
        Date:   Fri Jan 2 11:43:15 2026 +0000

            initial commit
        [root@ststor01 apps]# ls
        info.txt  welcome.txt
        [root@ststor01 apps]# 
# Task 32: Git Rebase
  # Requirement:
      The Nautilus application development team has been working on a project repository /opt/cluster.git. This repo is cloned at /usr/src/kodekloudrepos on storage server in Stratos DC. They recently shared the following requirements with DevOps team:
        One of the developers is working on feature branch and their work is still in progress, however there are some changes which have been pushed into the master branch, the developer now wants to rebase the feature branch with the master branch without loosing any data from the feature branch, also they don't want to add any merge commit by simply merging the master branch into the feature branch. Accomplish this task as per requirements mentioned.
        Also remember to push your changes once done.
  # Solution:
        [root@ststor01 news]# git branch
        * feature
        master
        [root@ststor01 news]# git status
        On branch feature
        nothing to commit, working tree clean
        [root@ststor01 news]# git rebase master
        Successfully rebased and updated refs/heads/feature.
        [root@ststor01 news]# git status
        On branch feature
        nothing to commit, working tree clean
        [root@ststor01 news]# git log --oneline
        c5a126c (HEAD -> feature) Add new feature
        78dcb02 (origin/master, master) Update info.txt
        6e24e32 initial commit
        [root@ststor01 news]# git push origin feature
        To /opt/news.git
        ! [rejected]        feature -> feature (non-fast-forward)
        error: failed to push some refs to '/opt/news.git'
        hint: Updates were rejected because the tip of your current branch is behind
        hint: its remote counterpart. If you want to integrate the remote changes,
        hint: use 'git pull' before pushing again.
        hint: See the 'Note about fast-forwards' in 'git push --help' for details.
        [root@ststor01 news]# git push origin feature --force
        Enumerating objects: 4, done.
        Counting objects: 100% (4/4), done.
        Delta compression using up to 16 threads
        Compressing objects: 100% (2/2), done.
        Writing objects: 100% (3/3), 295 bytes | 295.00 KiB/s, done.
        Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
        To /opt/news.git
        + 97af024...c5a126c feature -> feature (forced update)
        [root@ststor01 news]# git log --oneline
        c5a126c (HEAD -> feature, origin/feature) Add new feature
        78dcb02 (origin/master, master) Update info.txt
        6e24e32 initial commit
        [root@ststor01 news]# git branch
        * feature
        master
        [root@ststor01 news]# 
# Task 33: Resolve Git Merge Conflicts
  # Requirement:
        Sarah and Max were working on writting some stories which they have pushed to the repository. Max has recently added some new changes and is trying to push them to the repository but he is facing some issues. Below you can find more details:
          SSH into storage server using user max and password Max_pass123. Under /home/max you will find the story-blog repository. Try to push the changes to the origin repo and fix the issues. The story-index.txt must have titles for all 4 stories. Additionally, there is a typo in The Lion and the Mooose line where Mooose should be Mouse.
          Click on the Gitea UI button on the top bar. You should be able to access the Gitea page. You can login to Gitea server from UI using username sarah and password Sarah_pass123 or username max and password Max_pass123.
          Note: For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.
  # Solution: 
            max (master)$ git log --oneline
            0178124 Added the fox and grapes story
            3dee3e9 Merge branch 'story/frogs-and-ox'
            be18590 Fix typo in story title
            812445f Completed frogs-and-ox story
            a93a687 Added the lion and mouse story
            46c765f Add incomplete frogs-and-ox story
            max (master)$ git pull origin master
            remote: Enumerating objects: 4, done.
            remote: Counting objects: 100% (4/4), done.
            remote: Compressing objects: 100% (3/3), done.
            remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
            Unpacking objects: 100% (3/3), done.
            From http://git.stratos.xfusioncorp.com/sarah/story-blog
            * branch            master     -> FETCH_HEAD
            3dee3e9..bfb9172  master     -> origin/master
            Auto-merging story-index.txt
            CONFLICT (add/add): Merge conflict in story-index.txt
            Automatic merge failed; fix conflicts and then commit the result.
            max (master)$ ls
            fox-and-grapes.txt  frogs-and-ox.txt    lion-and-mouse.txt  story-index.txt
            max (master)$ cat fox-and-grapes.txt 
            --------------------------------------------
                THE FOX AND GRAPES
            --------------------------------------------

            A Fox one day spied a beautiful bunch of ripe grapes hanging from a vine trained along the branches of a tree.

            The grapes seemed ready to burst with juice, and the Fox's mouth watered as he gazed longingly at them.

            The bunch hung from a high branch, and the Fox had to jump for it.

            The first time he jumped he missed it by a long way.

            So he walked off a short distance and took a running leap at it, only to fall short once more.

            Again and again he tried, but in vain.

            Now he sat down and looked at the grapes in disgust.

            "What a fool I am," he said. "Here I am wearing myself out to get a bunch of sour grapes that are not worth gaping for."

            And off he walked very, very scornfully.max (master)$ cat story-index.txt 
            <<<<<<< HEAD
            1. The Lion and the Mooose
            2. The Frogs and the Ox
            3. The Fox and the Grapes
            4. The Donkey and the Dog
            =======
            1. The Lion and the Mouse
            2. The Frogs and the Ox
            3. The Fox and the Grapes
            >>>>>>> bfb9172c517c24e9b90a938414d9d220d8370fd8
            max (master)$ vi story-index.txt 
            max (master)$ git add story-index.txt 
            max (master)$ git commit -m "updated the story-index file"
            [master c5fc3c2] updated the story-index file
            Committer: Linux User <max@ststor01.stratos.xfusioncorp.com>
            Your name and email address were configured automatically based
            on your username and hostname. Please check that they are accurate.
            You can suppress this message by setting them explicitly. Run the
            following command and follow the instructions in your editor to edit
            your configuration file:

                git config --global --edit

            After doing this, you may fix the identity used for this commit with:

                git commit --amend --reset-author

            max (master)$ git log --oneline
            c5fc3c2 updated the story-index file
            0178124 Added the fox and grapes story
            bfb9172 Added Index
            3dee3e9 Merge branch 'story/frogs-and-ox'
            be18590 Fix typo in story title
            812445f Completed frogs-and-ox story
            a93a687 Added the lion and mouse story
            46c765f Add incomplete frogs-and-ox story
            max (master)$ git push origin master
            Username for 'http://git.stratos.xfusioncorp.com': max
            Password for 'http://max@git.stratos.xfusioncorp.com': 
            Counting objects: 7, done.
            Delta compression using up to 16 threads.
            Compressing objects: 100% (7/7), done.
            Writing objects: 100% (7/7), 1.17 KiB | 0 bytes/s, done.
            Total 7 (delta 1), reused 0 (delta 0)
            remote: . Processing 1 references
            remote: Processed 1 references in total
            To http://git.stratos.xfusioncorp.com/sarah/story-blog.git
            bfb9172..c5fc3c2  master -> master
            max (master)$ 
# Task 34: Git Hook
   # Requirement:
        The Nautilus application development team was working on a git repository /opt/blog.git which is cloned under /usr/src/kodekloudrepos directory present on Storage server in Stratos DC. The team want to setup a hook on this repository, please find below more details:
            Merge the feature branch into the master branch, but before pushing your changes complete below point.
            Create a post-update hook in this git repository so that whenever any changes are pushed to the master branch, it creates a release tag with name release-2023-06-15, where 2023-06-15 is supposed to be the current date. For example if today is 20th June, 2023 then the release tag must be release-2023-06-20. Make sure you test the hook at least once and create a release tag for today's release.
            Finally remember to push your changes.
            Note: Perform this task using the natasha user, and ensure the repository or existing directory permissions are not altered.
  # Solution:
            # 0. Ssh into the storage server 
            ssh natasha@ststor01

            # 1. Navigate to the bare repository hooks directory
            cd /opt/blog.git/hooks

            # 2. Create the post-update hook from sample (or new file)
            cp post-update.sample post-update

            # 3. Replace content with this script
            cat > post-update << 'EOF'
            #!/bin/sh
            # post-update hook: always create today's release tag for master

            DATE=$(date +%F)

            # Check if master branch changed
            CHANGED_MASTER=0
            for ref in "$@"
            do
                if echo "$ref" | grep -q "refs/heads/master"; then
                    CHANGED_MASTER=1
                    break
                fi
            done

            # If master changed or stdin is empty, attempt to create tag
            if [ $CHANGED_MASTER -eq 1 ] || [ -z "$@" ]; then
                echo "Creating release tag for $DATE..."
                if ! git rev-parse "release-$DATE" >/dev/null 2>&1; then
                    git tag -a "release-$DATE" -m "Release for $DATE"
                else
                    echo "Tag release-$DATE already exists"
                fi
            fi
            EOF

            # 4. Make the hook executable
            chmod +x post-update

            # 5. In your working clone, merge feature into master
            cd /usr/src/kodekloudrepos/blog
            git checkout master
            git merge --no-ff feature -m "Merge feature into master"

            # 6. Push master to the bare repository to trigger the hook
            git push origin master

            # 7. Fetch tags in your clone and verify
            git fetch --tags
            git tag
            git show release-$(date +%F)

            # 8. Optional: make a dummy commit to force hook execution
            touch trigger_hook.txt
            git add trigger_hook.txt
            git commit -m "Trigger post-update hook"
            git push origin master
# Task 35: Install Docker Packages and Start Docker Service
  # Requirement:
        The Nautilus DevOps team aims to containerize various applications following a recent meeting with the application development team. They intend to conduct testing with the following steps:
            Install docker-ce and docker compose packages on App Server 1.
            Initiate the docker service.
  # Solution:
            1  sudo dnf update -y
            2  sudo dnf install -y dnf-plugins-core
            3  sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            4  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            5  sudo systemctl enable --now docker
            6  systemctl start docker
            7  systemctl status focker
            8  systemctl status docker
            9  docker compose version
# Task 36: Deploy Nginx Container on Application Server
  # Requirement:
        The Nautilus DevOps team is conducting application deployment tests on selected application servers. They require a nginx container deployment on Application Server 1. Complete the task with the following instructions:
            On Application Server 1 create a container named nginx_1 using the nginx image with the alpine tag. Ensure container is in a running state.
  # Solution:
        [root@stapp01 ~]# sudo docker pull nginx:alpine
        alpine: Pulling from library/nginx
        1074353eec0d: Pull complete 
        25f453064fd3: Pull complete 
        567f84da6fbd: Pull complete 
        da7c973d8b92: Pull complete 
        33f95a0f3229: Pull complete 
        085c5e5aaa8e: Pull complete 
        0abf9e567266: Pull complete 
        de54cb821236: Pull complete 
        Digest: sha256:8491795299c8e739b7fcc6285d531d9812ce2666e07bd3dd8db00020ad132295
        Status: Downloaded newer image for nginx:alpine
        docker.io/library/nginx:alpine
        [root@stapp01 ~]# docker image

        Usage:  docker image COMMAND

        Manage images

        Commands:
        build       Build an image from a Dockerfile
        history     Show the history of an image
        import      Import the contents from a tarball to create a filesystem image
        inspect     Display detailed information on one or more images
        load        Load an image from a tar archive or STDIN
        ls          List images
        prune       Remove unused images
        pull        Download an image from a registry
        push        Upload an image to a registry
        rm          Remove one or more images
        save        Save one or more images to a tar archive (streamed to STDOUT by default)
        tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

        Run 'docker image COMMAND --help' for more information on a command.
        [root@stapp01 ~]# docker images
        REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
        nginx        alpine    04da2b0513cd   2 weeks ago   53.7MB
        [root@stapp01 ~]# docker run --name nginx_1 -p 8080:80 -d nginx:alpine
        4263782aaee3904d895030e0705e201b23973021d359ebcbf1ed7d0a49f880fc
        [root@stapp01 ~]# docker ps
        CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
        4263782aaee3   nginx:alpine   "/docker-entrypoint.…"   6 seconds ago   Up 4 seconds   0.0.0.0:8080->80/tcp   nginx_1
        [root@stapp01 ~]# docker status nginx_1
        docker: 'status' is not a docker command.
        See 'docker --help'
        [root@stapp01 ~]# docker log nginx_1
        docker: 'log' is not a docker command.
        See 'docker --help'
        [root@stapp01 ~]# docker logs nginx_1
        /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
        /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
        10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
        10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
        /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
        /docker-entrypoint.sh: Configuration complete; ready for start up
        2026/01/05 10:41:42 [notice] 1#1: using the "epoll" event method
        2026/01/05 10:41:42 [notice] 1#1: nginx/1.29.4
        2026/01/05 10:41:42 [notice] 1#1: built by gcc 15.2.0 (Alpine 15.2.0) 
        2026/01/05 10:41:42 [notice] 1#1: OS: Linux 5.15.0-1083-gcp
        2026/01/05 10:41:42 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
        2026/01/05 10:41:42 [notice] 1#1: start worker processes
        2026/01/05 10:41:42 [notice] 1#1: start worker process 84
        2026/01/05 10:41:42 [notice] 1#1: start worker process 85
        2026/01/05 10:41:42 [notice] 1#1: start worker process 86
        2026/01/05 10:41:42 [notice] 1#1: start worker process 87
        2026/01/05 10:41:42 [notice] 1#1: start worker process 88
        2026/01/05 10:41:42 [notice] 1#1: start worker process 89
        2026/01/05 10:41:42 [notice] 1#1: start worker process 90
        2026/01/05 10:41:42 [notice] 1#1: start worker process 91
        2026/01/05 10:41:42 [notice] 1#1: start worker process 92
        2026/01/05 10:41:42 [notice] 1#1: start worker process 93
        2026/01/05 10:41:42 [notice] 1#1: start worker process 94
        2026/01/05 10:41:42 [notice] 1#1: start worker process 95
        2026/01/05 10:41:42 [notice] 1#1: start worker process 96
        2026/01/05 10:41:42 [notice] 1#1: start worker process 97
        2026/01/05 10:41:42 [notice] 1#1: start worker process 98
        2026/01/05 10:41:42 [notice] 1#1: start worker process 99
        [root@stapp01 ~]# 
# Task 37: Copy File to Docker Container
  # Requirement:
        The Nautilus DevOps team possesses confidential data on App Server 3 in the Stratos Datacenter. A container named ubuntu_latest is running on the same server.
            Copy an encrypted file /tmp/nautilus.txt.gpg from the docker host to the ubuntu_latest container located at /tmp/. Ensure the file is not modified during this operation.
  # Solution:
        [banner@stapp03 ~]$ docker ps 
        CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
        681c5cfa3719   ubuntu    "/bin/bash"   2 minutes ago   Up 2 minutes             ubuntu_latest
        [banner@stapp03 ~]$ cd /tmp/
        [banner@stapp03 tmp]$ ls
        nautilus.txt.gpg
        systemd-private-6363bdae8c754aac9938e9db5c38ec8f-dbus-broker.service-aNVjSh
        systemd-private-6363bdae8c754aac9938e9db5c38ec8f-systemd-hostnamed.service-VsG2bs
        systemd-private-6363bdae8c754aac9938e9db5c38ec8f-systemd-logind.service-LYdf3L
        [banner@stapp03 tmp]$ docker cp ./nautilus.txt.gpg 681c5cfa3719:/tmp
        Successfully copied 2.05kB to 681c5cfa3719:/tmp
        [banner@stapp03 tmp]$ docker exec -it 681c5cfa3719 
        "docker exec" requires at least 2 arguments.
        See 'docker exec --help'.

        Usage:  docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

        Execute a command in a running container
        [banner@stapp03 tmp]$ docker exec -it 681c5cfa3719 /bin/bash
        root@681c5cfa3719:/# ls -ltr /tmp/
        total 4
        -rw-r--r-- 1 root root 105 Jan  6 12:14 nautilus.txt.gpg
        root@681c5cfa3719:/# exit
        exit
        [banner@stapp03 tmp]$ 
# Task 38: Pull Docker Image
  # Requirement: 
        Nautilus project developers are planning to start testing on a new project. As per their meeting with the DevOps team, they want to test containerized environment application features. As per details shared with DevOps team, we need to accomplish the following task:
            a. Pull busybox:musl image on App Server 3 in Stratos DC and re-tag (create new tag) this image as busybox:blog.
  # Solution: 
        docker pull busybox:musl
        docker tag busybox:musl busybox:blog

# Task 39: Create a Docker Image From Container
  # Requirement:
        One of the Nautilus developer was working to test new changes on a container. He wants to keep a backup of his changes to the container. A new request has been raised for the DevOps team to create a new image from this container. Below are more details about it:
            a. Create an image apps:devops on Application Server 1 from a container ubuntu_latest that is running on same server.
  # Solution:
        [tony@stapp01 ~]$ docker ps
        CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
        fb56e436735a   ubuntu    "/bin/bash"   3 minutes ago   Up 3 minutes             ubuntu_latest
        [tony@stapp01 ~]$ docker commit -a "tony" -m "COntainer backup" fb56e436735a apps:devops
        sha256:4cee7799f2a062d50be621074795aea224b3feea1829fb2631444f3078c69f54
        [tony@stapp01 ~]$ docker images
        REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
        apps         devops    4cee7799f2a0   4 seconds ago   135MB
        ubuntu       latest    c3a134f2ace4   2 months ago    78.1MB
        [tony@stapp01 ~]$ 
# Task 40: Docker EXEC Operations
  # Requirement:
        One of the Nautilus DevOps team members was working to configure services on a kkloud container that is running on App Server 3 in Stratos Datacenter. Due to some personal work he is on PTO for the rest of the week, but we need to finish his pending work ASAP. Please complete the remaining work as per details given below:
            a. Install apache2 in kkloud container using apt that is running on App Server 3 in Stratos Datacenter.
            b. Configure Apache to listen on port 5001 instead of default http port. Do not bind it to listen on specific IP or hostname only, i.e it should listen on localhost, 127.0.0.1, container ip, etc.
            c. Make sure Apache service is up and running inside the container. Keep the container in running state at the end.

  # Solution: 
            docker exec -it d97d86a96f1e /bin/bash
                cat /etc/os-release 
            5  apt update -y
            6  apt install apache2 -y
            7  systemctl status apache2
            8  system status apache2
            9  system status httpd
        10  system status apache
        11  cd /etc/
        12  ls
        13  cd apache2/
        14  ls
        15  cat apache2.conf 
        16  vi apache2.conf 
        17  vim apache2.conf 
        18  nano apache2.conf 
        19  apt install vim
        20  vi apache2.conf 
        21  ls -ltr
        22  vi ports.conf 
        23  systemctl enable apache2
        24  service enable apache2
        25  service apache2 enable
        26  service apache2 status
        27  service apache2 start
        28  service apache2 status
        29  cat http://localhost:5001
        30  cat http://127.0.0:5001
        31  cat http://127.0.0.1:5001
        32  ss -tulpn
        33  apt install net-tools
        34  ss
        35  netstat
        36  netstat -tunlp
        37  ipconfig
        38  ifconfig
        39  exit
        40  ls
        41  curl http://localhost:5001
        42  curl http://127.0.01:5001
        43  curl http://127.0.0.1:5001
# Task 41: Write a Docker File
  # Requirement:
        As per recent requirements shared by the Nautilus application development team, they need custom images created for one of their projects. Several of the initial testing requirements are already been shared with DevOps team. Therefore, create a docker file /opt/docker/Dockerfile (please keep D capital of Dockerfile) on App server 3 in Stratos DC and configure to build an image with the following requirements: 
            a. Use ubuntu:24.04 as the base image.
            b. Install apache2 and configure it to work on 5002 port. (do not update any other Apache configuration settings like document root etc).
  # Solution: 
        # Dockerfile
            #################
            FROM ubuntu:24.04
            WORKDIR
            RUN apt-get update -y &&\ 
                apt-get install apache2 -y

            RUN sed -i 's/80/5002/g' /etc/apache2/ports.conf && \
                sed -i 's/80/5002/g' /etc/apache2/sites-available/000-default.conf
            CMD ["apache2ctl", "-D", "FOREGROUND"]
            ##################
            ~                                                
            [banner@stapp03 docker]$ docker build -t apache2:latest_new .
            [+] Building 0.0s (1/1) FINISHED                                          docker:default
            => [internal] load build definition from Dockerfile                                0.0s
            => => transferring dockerfile: 288B                                                0.0s
            Dockerfile:2
            --------------------
            1 |     FROM ubuntu:24.04
            2 | >>> WORKDIR
            3 |     RUN apt-get update -y &&\ 
            4 |         apt-get install apache2 -y
            --------------------
            ERROR: failed to build: failed to solve: dockerfile parse error on line 2: WORKDIR requires exactly one argument
            [banner@stapp03 docker]$ vi Dockerfile 
            [banner@stapp03 docker]$ sudo vi Dockerfile 
            [banner@stapp03 docker]$ docker build -t apache2:latest_new .
            [+] Building 21.5s (7/7) FINISHED                                         docker:default
            => [internal] load build definition from Dockerfile                                0.0s
            => => transferring dockerfile: 280B                                                0.0s
            => [internal] load metadata for docker.io/library/ubuntu:24.04                     0.0s
            => [internal] load .dockerignore                                                   0.0s
            => => transferring context: 2B                                                     0.0s
            => [1/3] FROM docker.io/library/ubuntu:24.04                                       0.0s
            => [2/3] RUN apt-get update -y &&    apt-get install apache2 -y                   18.5s
            => [3/3] RUN sed -i 's/80/5002/g' /etc/apache2/ports.conf &&     sed -i 's/80/500  1.1s
            => exporting to image                                                              1.8s 
            => => exporting layers                                                             1.8s 
            => => writing image sha256:b29bdb3950c9f66096df1cb5c4069dc94fd723e9e41a4da090fcc3  0.0s 
            => => naming to docker.io/library/apache2:latest_new                               0.0s 
            [banner@stapp03 docker]$ docker images                                                   
            REPOSITORY   TAG          IMAGE ID       CREATED          SIZE
            apache2      latest_new   b29bdb3950c9   10 seconds ago   256MB
            ubuntu       24.04        602eb6fb314b   9 months ago     78.1MB
            [banner@stapp03 docker]$ docker run -d apache2:latest_new

