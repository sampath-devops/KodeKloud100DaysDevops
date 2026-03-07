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
# Task 42: Create a Docker Network
  # Requirement:
        The Nautilus DevOps team needs to set up several docker environments for different applications. One of the team members has been assigned a ticket where he has been asked to create some docker networks to be used later. Complete the task based on the following ticket description:
            a. Create a docker network named as official on App Server 3 in Stratos DC.
            b. Configure it to use bridge drivers.
            c. Set it to use subnet 172.28.0.0/24 and iprange 172.28.0.0/24.
  # Solution: 
        [banner@stapp03 ~]$ docker network create --driver bridge --subnet 172.28.0.0/24 --ip-range 172.28.0.0/24 official
        713f3a55ac107a1bf5b44fe7d83c4bd4f5a20baf6ee4be82b501bad4e598e38d
        [banner@stapp03 ~]$ docker network ls
        NETWORK ID     NAME       DRIVER    SCOPE
        16ec4b7db435   bridge     bridge    local
        c6e26e05af64   host       host      local
        febf30c5081e   none       null      local
        713f3a55ac10   official   bridge    local
        [banner@stapp03 ~]$ 
# Task 43: Docker Ports Mapping
  # Requirement:
        The Nautilus DevOps team is planning to host an application on a nginx-based container. There are number of tickets already been created for similar tasks. One of the tickets has been assigned to set up a nginx container on Application Server 1 in Stratos Datacenter. Please perform the task as per details mentioned below:
            a. Pull nginx:stable docker image on Application Server 1.
            b. Create a container named blog using the image you pulled.
            c. Map host port 6000 to container port 80. Please keep the container in running state.
  # Solution: 
        [tony@stapp01 ~]$ docker images
        REPOSITORY   TAG       IMAGE ID   CREATED   SIZE
        [tony@stapp01 ~]$ docker pull nginx:stable
        stable: Pulling from library/nginx
        02d7611c4eae: Pull complete 
        11696ed710ce: Pull complete 
        02acfc0013ce: Pull complete 
        cad526308e1f: Pull complete 
        0a728426e5c1: Pull complete 
        67bac657aeb9: Pull complete 
        4e60406108e5: Pull complete 
        Digest: sha256:e7e2c41c74775ccfe88d07fa3d9ebc9e0d6ae5c755244bc525153b37e308f699
        Status: Downloaded newer image for nginx:stable
        docker.io/library/nginx:stable
        [tony@stapp01 ~]$ docker images
        REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
        nginx        stable    880187ad005d   10 days ago   152MB
        [tony@stapp01 ~]$ docker run -d -p 6000:80 --name blog
        "docker run" requires at least 1 argument.
        See 'docker run --help'.

        Usage:  docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

        Create and run a new container from an image
        [tony@stapp01 ~]$ docker run -d -p 6000:80 --name blog nginx:stable
        dba16ed401a969cb52db3b033a39ae8ae0778e7e4f3c81d870d826674e6a0e6f
        [tony@stapp01 ~]$ docker ps
        CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
        dba16ed401a9   nginx:stable   "/docker-entrypoint.…"   7 seconds ago   Up 5 seconds   0.0.0.0:6000->80/tcp   blog
        [tony@stapp01 ~]$ curl http:\\localhost:6000
        curl: (3) URL using bad/illegal format or missing URL
        [tony@stapp01 ~]$ curl http://localhost:6000
        <!DOCTYPE html>
        <html>
        <head>
        <title>Welcome to nginx!</title>
        <style>
        html { color-scheme: light dark; }
        body { width: 35em; margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif; }
        </style>
        </head>
        <body>
        <h1>Welcome to nginx!</h1>
        <p>If you see this page, the nginx web server is successfully installed and
        working. Further configuration is required.</p>

        <p>For online documentation and support please refer to
        <a href="http://nginx.org/">nginx.org</a>.<br/>
        Commercial support is available at
        <a href="http://nginx.com/">nginx.com</a>.</p>

        <p><em>Thank you for using nginx.</em></p>
        </body>
        </html>
        [tony@stapp01 ~]$ 
# Task 44: Write a Docker Compose File
  # Requirement:
        The Nautilus application development team shared static website content that needs to be hosted on the httpd web server using a containerised platform. The team has shared details with the DevOps team, and we need to set up an environment according to those guidelines. Below are the details:
            a. On App Server 2 in Stratos DC create a container named httpd using a docker compose file /opt/docker/docker-compose.yml (please use the exact name for file).
            b. Use httpd (preferably latest tag) image for container and make sure container is named as httpd; you can use any name for service.
            c. Map 80 number port of container with port 8089 of docker host.
            d. Map container's /usr/local/apache2/htdocs volume with /opt/dba volume of docker host which is already there. (please do not modify any data within these locations).
  # Solution:
        [steve@stapp02 docker]$ cat docker-compose.yml 
            version: '3.8'
            services:
                webserver:
                image: httpd:latest
                container_name: httpd
                ports: 
                    - "8089:80"
                volumes:
                    - /opt/dba/:/usr/local/apache2/htdocs

        [steve@stapp02 docker]$ docker compose up -d
        yaml: line 4: mapping values are not allowed in this context
        [steve@stapp02 docker]$ sudo vi docker-compose.yml
        [steve@stapp02 docker]$ docker compose up -d
        yaml: line 4: mapping values are not allowed in this context
        [steve@stapp02 docker]$ sudo vi docker-compose.yml
        [steve@stapp02 docker]$ docker compose up -d
        validating /opt/docker/docker-compose.yml: services.webserver additional properties 'container_ name' not allowed
        [steve@stapp02 docker]$ sudo vi docker-compose.yml
        [steve@stapp02 docker]$ docker compose up -d
        validating /opt/docker/docker-compose.yml: services.webserver additional properties 'container_ name' not allowed
        [steve@stapp02 docker]$ docker compose up -d
        validating /opt/docker/docker-compose.yml: services.webserver additional properties 'container_ name' not allowed
        [steve@stapp02 docker]$ sudo vi docker-compose.yml
        [steve@stapp02 docker]$ docker compose up -d
        WARN[0000] /opt/docker/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion 
        [+] Running 7/7
        ✔ webserver Pulled                                                                 5.8s 
        ✔ 02d7611c4eae Pull complete                                                     2.7s 
        ✔ 5a84161993ab Pull complete                                                     3.1s 
        ✔ 4f4fb700ef54 Pull complete                                                     3.3s 
        ✔ 8eb44842f200 Pull complete                                                     3.9s 
        ✔ b5be9d562803 Pull complete                                                     5.1s 
        ✔ af0709a53cc2 Pull complete                                                     5.6s 
        [+] Running 2/2
        ✔ Network docker_default  Created                                                  0.1s 
        ✔ Container httpd         Started                                                  1.5s 
        [steve@stapp02 docker]$ 
        [steve@stapp02 docker]$ docker ps
        CONTAINER ID   IMAGE          COMMAND              CREATED              STATUS              PORTS                  NAMES
        8542a4bca6b0   httpd:latest   "httpd-foreground"   About a minute ago   Up About a minute   0.0.0.0:8089->80/tcp   httpd
# Task 45: Resolve Dockerfile Issues
  # Requirement:
        The Nautilus DevOps team is working to create new images per requirements shared by the development team. One of the team members is working to create a Dockerfile on App Server 2 in Stratos DC. While working on it she ran into issues in which the docker build is failing and displaying errors. Look into the issue and fix it to build an image as per details mentioned below:
            a. The Dockerfile is placed on App Server 2 under /opt/docker directory.
            b. Fix the issues with this file and make sure it is able to build the image.
            c. Do not change base image, any other valid configuration within Dockerfile, or any of the data been used — for example, index.html.
            Note: Please note that once you click on FINISH button all the existing containers will be destroyed and new image will be built from your Dockerfile.
  # Solution:
            ## Issued Docker file
        [steve@stapp02 docker]$ cat Dockerfile 
        FROM httpd:2.4.43

        RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/httpd.conf

        RUN sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g' conf/httpd.conf

        RUN sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socache_shmcb.so/s/^#//g' conf/httpd.conf

        RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' conf/httpd.conf

        RUN cp certs/server.crt /usr/local/apache2/conf/server.crt

        RUN cp certs/server.key /usr/local/apache2/conf/server.key

        RUN cp html/index.html /usr/local/apache2/htdocs/[steve@stapp02 docker]$ 
          ## Error when we build the image from Docker file
        [steve@stapp02 docker]$ docker build -t apache2:test .
        [+] Building 194.7s (9/11)                                                docker:default
        => [internal] load build definition from Dockerfile                                0.0s
        => => transferring dockerfile: 562B                                                0.0s
        => [internal] load metadata for docker.io/library/httpd:2.4.43                   120.9s
        => [internal] load .dockerignore                                                   0.0s
        => => transferring context: 2B                                                     0.0s
        => [1/8] FROM docker.io/library/httpd:2.4.43@sha256:cd88fee4eab37f0d8cd04b06ef97  64.3s
        => => resolve docker.io/library/httpd:2.4.43@sha256:cd88fee4eab37f0d8cd04b06ef972  0.0s
        => => sha256:cd88fee4eab37f0d8cd04b06ef97285ca981c27b4d685f0321e6 1.86kB / 1.86kB  0.0s
        => => sha256:53729354a74c9c146aa8726a8906e833755066ada1a478782f4d 1.37kB / 1.37kB  0.0s
        => => sha256:f1455599cc2e008a4555f14451e590f071371d371a3b87790651 7.35kB / 7.35kB  0.0s
        => => sha256:bf59529304463f62efa7179fa1a32718a611528cc4ce9f30c 27.09MB / 27.09MB  30.5s
        => => sha256:3d3fecf6569b94e406086a2b68a7c8930254490b45c0de4911f497e 146B / 146B  30.6s
        => => sha256:b5fc3125d9129e4cdd43f496195cc8f39d43e9bad171044ec 10.37MB / 10.37MB  30.8s
        => => extracting sha256:bf59529304463f62efa7179fa1a32718a611528cc4ce9f30c0d1bbc67  2.8s
        => => sha256:3c61041685c0f65e0b375bae6ae6bdeab9b6c20960dbef5e3 24.47MB / 24.47MB  61.0s
        => => sha256:34b7e9053f76ca3c9dc574c5034679769256a596008efbfbff1d1b1 298B / 298B  61.1s
        => => extracting sha256:3d3fecf6569b94e406086a2b68a7c8930254490b45c0de4911f497ea9  0.4s
        => => extracting sha256:b5fc3125d9129e4cdd43f496195cc8f39d43e9bad171044ecb5b8f82b  1.2s
        => => extracting sha256:3c61041685c0f65e0b375bae6ae6bdeab9b6c20960dbef5e30201db18  1.6s
        => => extracting sha256:34b7e9053f76ca3c9dc574c5034679769256a596008efbfbff1d1b154  0.8s
        => [2/8] RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/httpd.con  1.9s
        => [3/8] RUN sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g' conf/ht  2.1s
        => [4/8] RUN sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socache_shmcb  1.8s
        => [5/8] RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' conf/httpd.co  1.7s
        => ERROR [6/8] RUN cp certs/server.crt /usr/local/apache2/conf/server.crt          2.0s
        ------                                                                                   
        > [6/8] RUN cp certs/server.crt /usr/local/apache2/conf/server.crt:
        1.957 cp: cannot stat 'certs/server.crt': No such file or directory
        ------
        Dockerfile:11
        --------------------
        9 |     RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' conf/httpd.conf
        10 |     
        11 | >>> RUN cp certs/server.crt /usr/local/apache2/conf/server.crt
        12 |     
        13 |     RUN cp certs/server.key /usr/local/apache2/conf/server.key
        --------------------
        ERROR: failed to build: failed to solve: process "/bin/sh -c cp certs/server.crt /usr/local/apache2/conf/server.crt" did not complete successfully: exit code: 1
        [steve@stapp02 docker]$ ls -ltr
        total 12
        drwxr-xr-x 2 root root 4096 Jan  9 11:14 html
        drwxr-xr-x 2 root root 4096 Jan  9 11:14 certs
        -rw-r--r-- 1 root root  523 Jan  9 11:22 Dockerfile
        [steve@stapp02 docker]$ cd certs/
        [steve@stapp02 certs]$ ls
        server.crt  server.key
        [steve@stapp02 certs]$ cdv ..
        -bash: cdv: command not found
        [steve@stapp02 certs]$ cd ..
        [steve@stapp02 docker]$ sudo vi Dockerfile 

        We trust you have received the usual lecture from the local System
        Administrator. It usually boils down to these three things:

            #1) Respect the privacy of others.
            #2) Think before you type.
            #3) With great power comes great responsibility.

        [sudo] password for steve: 
        [steve@stapp02 docker]$ docker build -t apache2:test .
        [+] Building 36.9s (9/11)                                                 docker:default
        => [internal] load build definition from Dockerfile                                0.0s
        => => transferring dockerfile: 620B                                                0.0s
        => [internal] load metadata for docker.io/library/httpd:2.4.43                    30.9s
        => [internal] load .dockerignore                                                   0.0s
        => => transferring context: 2B                                                     0.0s
        => [1/8] FROM docker.io/library/httpd:2.4.43@sha256:cd88fee4eab37f0d8cd04b06ef972  0.0s
        => CACHED [2/8] RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/ht  0.0s
        => [3/8] RUN sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g' /usr/lo  2.2s
        => [4/8] RUN sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socache_shmcb  1.1s
        => [5/8] RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' /usr/local/ap  1.3s
        => ERROR [6/8] RUN cp certs/server.crt /usr/local/apache2/conf/server.crt          1.3s
        ------                                                                                   
        > [6/8] RUN cp certs/server.crt /usr/local/apache2/conf/server.crt:
        1.276 cp: cannot stat 'certs/server.crt': No such file or directory
        ------
        Dockerfile:11
        --------------------
        9 |     RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' /usr/local/apache2/conf/httpd.conf
        10 |     
        11 | >>> RUN cp certs/server.crt /usr/local/apache2/conf/server.crt
        12 |     
        13 |     RUN cp certs/server.key /usr/local/apache2/conf/server.key
        --------------------
        ERROR: failed to build: failed to solve: process "/bin/sh -c cp certs/server.crt /usr/local/apache2/conf/server.crt" did not complete successfully: exit code: 1
        [steve@stapp02 docker]$ sudo vi Dockerfile 
        [steve@stapp02 docker]$ docker build -t apache2:test .
        [+] Building 34.8s (13/13) FINISHED                                       docker:default
        => [internal] load build definition from Dockerfile                                0.0s
        => => transferring dockerfile: 614B                                                0.0s
        => [internal] load metadata for docker.io/library/httpd:2.4.43                    30.2s
        => [internal] load .dockerignore                                                   0.0s
        => => transferring context: 2B                                                     0.0s
        => [1/8] FROM docker.io/library/httpd:2.4.43@sha256:cd88fee4eab37f0d8cd04b06ef972  0.0s
        => [internal] load build context                                                   0.0s
        => => transferring context: 3.19kB                                                 0.0s
        => CACHED [2/8] RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/ht  0.0s
        => CACHED [3/8] RUN sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g'   0.0s
        => CACHED [4/8] RUN sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socach  0.0s
        => CACHED [5/8] RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' /usr/l  0.0s
        => [6/8] COPY certs/server.crt /usr/local/apache2/conf/server.crt                  0.6s
        => [7/8] COPY certs/server.key /usr/local/apache2/conf/server.key                  0.9s
        => [8/8] COPY html/index.html /usr/local/apache2/htdocs/                           0.8s
        => exporting to image                                                              2.2s
        => => exporting layers                                                             2.2s
        => => writing image sha256:12b4c002fed28bf06e7c0349969a28798a28cf9a5e3bf22086d0b1  0.0s
        => => naming to docker.io/library/apache2:test                                     0.0s
        [steve@stapp02 docker]$ 
                ## Issue occured while replacing # while enabling the ssl config in httpd.conf file complete file path not provided
                ## And used RUN CP command in docker file for copying the cets and html files which is not recornized so we need to COPY command in file to copy the file 
        
                ## After updating/correcting the Docker file
        [steve@stapp02 docker]$ cat Dockerfile 
            FROM httpd:2.4.43

            RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/httpd.conf

            RUN sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g' /usr/local/apache2/conf/httpd.conf

            RUN sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socache_shmcb.so/s/^#//g' /usr/local/apache2/conf/httpd.conf

            RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' /usr/local/apache2/conf/httpd.conf

            COPY certs/server.crt /usr/local/apache2/conf/server.crt

            COPY certs/server.key /usr/local/apache2/conf/server.key

            COPY html/index.html /usr/local/apache2/htdocs/
            [steve@stapp02 docker]$ 

            [steve@stapp02 docker]$ sudo vi Dockerfile 
            [steve@stapp02 docker]$ docker build -t apache2:test .
            [+] Building 34.8s (13/13) FINISHED                                       docker:default
            => [internal] load build definition from Dockerfile                                0.0s
            => => transferring dockerfile: 614B                                                0.0s
            => [internal] load metadata for docker.io/library/httpd:2.4.43                    30.2s
            => [internal] load .dockerignore                                                   0.0s
            => => transferring context: 2B                                                     0.0s
            => [1/8] FROM docker.io/library/httpd:2.4.43@sha256:cd88fee4eab37f0d8cd04b06ef972  0.0s
            => [internal] load build context                                                   0.0s
            => => transferring context: 3.19kB                                                 0.0s
            => CACHED [2/8] RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/ht  0.0s
            => CACHED [3/8] RUN sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g'   0.0s
            => CACHED [4/8] RUN sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socach  0.0s
            => CACHED [5/8] RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' /usr/l  0.0s
            => [6/8] COPY certs/server.crt /usr/local/apache2/conf/server.crt                  0.6s
            => [7/8] COPY certs/server.key /usr/local/apache2/conf/server.key                  0.9s
            => [8/8] COPY html/index.html /usr/local/apache2/htdocs/                           0.8s
            => exporting to image                                                              2.2s
            => => exporting layers                                                             2.2s
            => => writing image sha256:12b4c002fed28bf06e7c0349969a28798a28cf9a5e3bf22086d0b1  0.0s
            => => naming to docker.io/library/apache2:test                                     0.0s
            [steve@stapp02 docker]$ 
            [steve@stapp02 docker]$ docker images
            REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
            apache2      test      12b4c002fed2   6 minutes ago   166MB
            [steve@stapp02 docker]$ docker ps
            CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
            [steve@stapp02 docker]$ docker run -d -p 8080:80 --name apache apache2:test
            bd30c3199b2a1c559b0b32e4954b70493e129075a12b5805255fcdde09a3fa8b
            [steve@stapp02 docker]$ docker ps
            CONTAINER ID   IMAGE          COMMAND              CREATED         STATUS         PORTS                  NAMES
            bd30c3199b2a   apache2:test   "httpd-foreground"   6 seconds ago   Up 2 seconds   0.0.0.0:8080->80/tcp   apache
            [steve@stapp02 docker]$ 
# Task 46: Deploy an App on Docker Containers
  # Requirement:
        The Nautilus Application development team recently finished development of one of the apps that they want to deploy on a containerized platform. The Nautilus Application development and DevOps teams met to discuss some of the basic pre-requisites and requirements to complete the deployment. The team wants to test the deployment on one of the app servers before going live and set up a complete containerized stack using a docker compose fie. Below are the details of the task:
            On App Server 2 in Stratos Datacenter create a docker compose file /opt/devops/docker-compose.yml (should be named exactly).
            The compose should deploy two services (web and DB), and each service should deploy a container as per details below:
            For web service:
                a. Container name must be php_host.
                b. Use image php with any apache tag. Check here for more details.
                c. Map php_host container's port 80 with host port 5002
                d. Map php_host container's /var/www/html volume with host volume /var/www/html.
            For DB service:
                a. Container name must be mysql_host.
                b. Use image mariadb with any tag (preferably latest). Check here for more details.
                c. Map mysql_host container's port 3306 with host port 3306
                d. Map mysql_host container's /var/lib/mysql volume with host volume /var/lib/mysql.
                e. Set MYSQL_DATABASE=database_host and use any custom user ( except root ) with some complex password for DB connections.
            After running docker-compose up you can access the app with curl command curl <server-ip or hostname>:5002/
            For more details check here.
            Note: Once you click on FINISH button, all currently running/stopped containers will be destroyed and stack will be deployed again using your compose file.
  # Solution:
        [root@stapp02 devops]# cat docker-compose.yml 
         services:
            web:
            image: php:apache
            container_name: php_host
            ports:
                - 5002:80
            volumes:
                - /var/www/html:/var/www/html
            depends_on:
                - db
            db:
            image: mariadb:latest
            container_name: mysql_host
            ports:
                - 3306:3306
            volumes:
                - /var/lib/mysql:/var/lib/mysql
            environment:
                MYSQL_DATABASE: database_host
                MYSQL_USER: nautuser
                MYSQL_PASSWORD: N@ut1lusP@ssw0rd
                MYSQL_ROOT_PASSWORD: RootTempPass123
        [root@stapp02 devops]# 
        [root@stapp02 devops]# docker compose up -d
        yaml: line 6: found character that cannot start any token
        [root@stapp02 devops]# vi docker-compose.yml 
        [root@stapp02 devops]# docker compose up -d
        yaml: line 8: found character that cannot start any token  # Got this error as used Tabs instead of spaces while writing the file so yaml not identified the tabs so removed those tabs
        [root@stapp02 devops]# vi docker-compose.yml 
        [root@stapp02 devops]# docker compose up -d
        [+] Running 24/24
        ✔ db Pulled                                                                       24.8s 
        ✔ 20043066d3d5 Pull complete                                                     6.2s 
        ✔ 75e5c9f5eeb0 Pull complete                                                     6.8s 
        ✔ ee5b64c3e2f5 Pull complete                                                     8.6s 
        ✔ ba2d27f4ceca Pull complete                                                     9.3s 
        ✔ 4be15142d46e Pull complete                                                    10.2s 
        ✔ 9047f410cb7d Pull complete                                                    20.7s 
        ✔ be922ac1f9ed Pull complete                                                    22.8s 
        ✔ eca7ec75082e Pull complete                                                    24.4s 
        ✔ web Pulled                                                                      51.3s 
        ✔ 02d7611c4eae Pull complete                                                     6.3s 
        ✔ c366543af204 Pull complete                                                     6.8s 
        ✔ fceab7a457f4 Pull complete                                                    23.2s 
        ✔ 630ea4d355f4 Pull complete                                                    27.3s 
        ✔ 4022d3740cf9 Pull complete                                                    29.4s 
        ✔ 40aa6e9de285 Pull complete                                                    30.8s 
        ✔ 6cbbbdd5b16b Pull complete                                                    32.1s 
        ✔ 925b7797c032 Pull complete                                                    33.5s 
        ✔ 15b07802af7d Pull complete                                                    34.8s 
        ✔ 2496601b992d Pull complete                                                    37.3s 
        ✔ f3d9aa297f51 Pull complete                                                    39.4s 
        ✔ e397fb01def5 Pull complete                                                    43.3s 
        ✔ 531601cb5511 Pull complete                                                    47.2s 
        ✔ 4f4fb700ef54 Pull complete                                                    51.0s 
        [+] Running 3/3
        ✔ Network devops_default  Created                                                  0.1s 
        ✔ Container mysql_host    Started                                                 13.6s 
        ✔ Container php_host      Started                                                  9.7s 
        [root@stapp02 devops]# docker ps
        CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS         PORTS                    NAMES
        92b3b092e58e   php:apache       "docker-php-entrypoi…"   15 seconds ago   Up 5 seconds   0.0.0.0:5002->80/tcp     php_host
        0eed9f8b88d9   mariadb:latest   "docker-entrypoint.s…"   20 seconds ago   Up 6 seconds   0.0.0.0:3306->3306/tcp   mysql_host
        [root@stapp02 devops]# curl http://localhost:5002
        <html>
            <head>
                <title>Welcome to xFusionCorp Industries!</title>
            </head>

            <body>
                Welcome to xFusionCorp Industries!    </body>
        </html>[root@stapp02 devops]# ipconfig
        -bash: ipconfig: command not found
        [root@stapp02 devops]# ifconfig
        -bash: ifconfig: command not found
        [root@stapp02 devops]# curl http://stapp02:5002
        <html>
            <head>
                <title>Welcome to xFusionCorp Industries!</title>
            </head>

            <body>
                Welcome to xFusionCorp Industries!    </body>
        </html>[root@stapp02 devops]# 
# Task 47: Docker Python App
  # Requirement:
        A python app needed to be Dockerized, and then it needs to be deployed on App Server 1. We have already copied a requirements.txt file (having the app dependencies) under /python_app/src/ directory on App Server 1. Further complete this task as per details mentioned below:
            Create a Dockerfile under /python_app directory:
            Use any python image as the base image.
            Install the dependencies using requirements.txt file.
            Expose the port 5003.
            Run the server.py script using CMD.
            Build an image named nautilus/python-app using this Dockerfile.
            Once image is built, create a container named pythonapp_nautilus:
            Map port 5003 of the container to the host port 8092.
            Once deployed, you can test the app using curl command on App Server 1.
            curl http://localhost:8092/
  # Solution: 
        - Dockerfile: 
            [tony@stapp01 python_app]$ cat Dockerfile 
                                        # Pyhton Base image
                                        FROM python:3.12-slim
                                        # Seting up the workdirectory
                                        WORKDIR /app
                                        # Copying the requirements file
                                        COPY /src/requirements.txt .
                                        # Installing pre requirements
                                        RUN pip install --no-cache-dir -r requirements.txt
                                        # Copying the application source files
                                        COPY src/ .
                                        # Exposing the COntainer port to 5003
                                        EXPOSE 5003
                                        # Running the application 
                                        CMD ["python", "server.py"]

            # Building docker image from Dockerfile
            [tony@stapp01 python_app]$ docker build -t nautilus/python-app .
            [+] Building 226.7s (10/10) FINISHED                                      docker:default
            => [internal] load build definition from Dockerfile                                0.0s
            => => transferring dockerfile: 422B                                                0.0s
            => [internal] load metadata for docker.io/library/python:3.12-slim               124.4s
            => [internal] load .dockerignore                                                   0.0s
            => => transferring context: 2B                                                     0.0s
            => [1/5] FROM docker.io/library/python:3.12-slim@sha256:a75662dfec8d90bd7161c910  94.9s
            => => resolve docker.io/library/python:3.12-slim@sha256:a75662dfec8d90bd7161c910  30.7s
            => => sha256:5dcd5ccefc085545c8dac26ccf4ee55a19f6e5641768565304fc 1.75kB / 1.75kB  0.0s
            => => sha256:7c5aeff4dbf98bbd70c8fa5337d3ec3a37b070ef577b3aa7954a 5.67kB / 5.67kB  0.0s
            => => sha256:02d7611c4eae219af91448a4720bdba036575d3bc0356cfe1 29.78MB / 29.78MB  33.9s
            => => sha256:fe2d526e7d41df5bda23740a00f6b254c44f67ce9bfc9507b36 1.29MB / 1.29MB  33.6s
            => => sha256:61a9f733534e478a7570aaf3a154be5b9302dcf474e1fe0a8 12.11MB / 12.11MB  34.3s
            => => sha256:a75662dfec8d90bd7161c91050be2e0a9b21d284f3b7a7253d 10.37kB / 10.37kB  0.0s
            => => sha256:d7c2baa095fbf75d83cd43b216be2d72bef124518338e23288648ad 250B / 250B  63.7s
            => => extracting sha256:02d7611c4eae219af91448a4720bdba036575d3bc0356cfe12774af85  2.3s
            => => extracting sha256:fe2d526e7d41df5bda23740a00f6b254c44f67ce9bfc9507b36fb77c3  0.6s
            => => extracting sha256:61a9f733534e478a7570aaf3a154be5b9302dcf474e1fe0a827d4b146  1.1s
            => => extracting sha256:d7c2baa095fbf75d83cd43b216be2d72bef124518338e23288648adda  0.5s
            => [internal] load build context                                                   0.0s
            => => transferring context: 401B                                                   0.0s
            => [2/5] WORKDIR /app                                                              0.5s
            => [3/5] COPY /src/requirements.txt .                                              0.5s
            => [4/5] RUN pip install --no-cache-dir -r requirements.txt                        4.1s
            => [5/5] COPY src/ .                                                               1.0s 
            => exporting to image                                                              1.2s 
            => => exporting layers                                                             1.1s 
            => => writing image sha256:f8aa025f567b17fec8362810b611608b8a14c3548d6df8fa29ccba  0.0s 
            => => naming to docker.io/nautilus/python-app                                      0.0s 
            [tony@stapp01 python_app]$ docker images                                                 
            REPOSITORY            TAG       IMAGE ID       CREATED         SIZE
            nautilus/python-app   latest    f8aa025f567b   7 seconds ago   132MB
            [tony@stapp01 python_app]$ 
            [tony@stapp01 python_app]$ docker run --name pythonapp_nautilus -d -p 8092:5003 nautilus/python-app
            dea0707fbc3f47aa7b9ddba73f893d9b8d9027552ce3cf4702e4fc62fd12b8b2
            [tony@stapp01 python_app]$ dcoker ps
            -bash: dcoker: command not found
            [tony@stapp01 python_app]$ docker ps
            CONTAINER ID   IMAGE                 COMMAND              CREATED          STATUS         PORTS                    NAMES
            dea0707fbc3f   nautilus/python-app   "python server.py"   12 seconds ago   Up 8 seconds   0.0.0.0:8092->5003/tcp   pythonapp_nautilus
            [tony@stapp01 python_app]$ 
            [tony@stapp01 python_app]$ curl http://localhost:8092
            Welcome to xFusionCorp Industries![tony@stapp01 python_app]$ 
# Task 48: Deploy Pods in Kubernetes Cluster
  # Requirement:
        The Nautilus DevOps team is diving into Kubernetes for application management. One team member has a task to create a pod according to the details below:
                Create a pod named pod-nginx using the nginx image with the latest tag. Ensure to specify the tag as nginx:latest.
                Set the app label to nginx_app, and name the container as nginx-container.
                Note: The kubectl utility on jump_host is configured to operate with the Kubernetes cluster.

  # Solution:
        thor@jumphost ~$ vi nginx-pod.yaml
        apiVersion: v1         # The version of the Kubernetes API we are using
        kind: Pod              # We are creating a Pod resource
        metadata:
        name: pod-nginx      # Name of the pod
        labels:
            app: nginx_app     # Adds a label "app=nginx_app" to the pod
        spec:
        containers:
            - name: nginx-container   # The container name inside the pod
            image: nginx:latest     # The image the container will use

        thor@jumphost ~$ kubectl get pods
        NAME        READY   STATUS              RESTARTS   AGE
        pod-nginx   0/1     ContainerCreating   0          8s
        thor@jumphost ~$ kubectl get pods
        NAME        READY   STATUS    RESTARTS   AGE
        pod-nginx   1/1     Running   0          12s
        thor@jumphost ~$ kubectl get pods
        NAME        READY   STATUS    RESTARTS   AGE
        pod-nginx   1/1     Running   0          13s
        thor@jumphost ~$ kubectl get pods
        NAME        READY   STATUS    RESTARTS   AGE
        pod-nginx   1/1     Running   0          14s
        thor@jumphost ~$ kubectl describe pod pod-nginx
        Name:             pod-nginx
        Namespace:        default
        Priority:         0
        Service Account:  default
        Node:             kodekloud-control-plane/172.17.0.2
        Start Time:       Fri, 23 Jan 2026 09:09:43 +0000
        Labels:           app=nginx_app
        Annotations:      <none>
        Status:           Running
        IP:               10.244.0.5
        IPs:
        IP:  10.244.0.5
        Containers:
        nginx-container:
            Container ID:   containerd://f9b3d8de81d51b4555dc86d4fd58be3de004af68fe67e1034d8b4fef74ca6125
            Image:          nginx:latest
            Image ID:       docker.io/library/nginx@sha256:c881927c4077710ac4b1da63b83aa163937fb47457950c267d92f7e4dedf4aec
            Port:           <none>
            Host Port:      <none>
            State:          Running
            Started:      Fri, 23 Jan 2026 09:09:52 +0000
            Ready:          True
            Restart Count:  0
            Environment:    <none>
            Mounts:
            /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-w88r4 (ro)
        Conditions:
        Type              Status
        Initialized       True 
        Ready             True 
        ContainersReady   True 
        PodScheduled      True 
        Volumes:
        kube-api-access-w88r4:
            Type:                    Projected (a volume that contains injected data from multiple sources)
            TokenExpirationSeconds:  3607
            ConfigMapName:           kube-root-ca.crt
            ConfigMapOptional:       <nil>
            DownwardAPI:             true
        QoS Class:                   BestEffort
        Node-Selectors:              <none>
        Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                                    node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
        Events:
        Type    Reason     Age   From               Message
        ----    ------     ----  ----               -------
        Normal  Scheduled  57s   default-scheduler  Successfully assigned default/pod-nginx to kodekloud-control-plane
        Normal  Pulling    56s   kubelet            Pulling image "nginx:latest"
        Normal  Pulled     49s   kubelet            Successfully pulled image "nginx:latest" in 7.090664154s (7.090686269s including waiting)
        Normal  Created    49s   kubelet            Created container nginx-container
        Normal  Started    48s   kubelet            Started container nginx-container

# Task 49: Deploy Applications with Kubernetes Deployments
  # Requirement:
        The Nautilus DevOps team is delving into Kubernetes for app management. One team member needs to create a deployment following these details:
            Create a deployment named httpd to deploy the application httpd using the image httpd:latest (ensure to specify the tag)Note: The kubectl utility on jump_host is set up to interact with the Kubernetes cluster.
  # Solution: 
            ## Deploymemt yaml file ##
            thor@jumphost ~$ vi httpd.yaml
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                    name: httpd-deployment
                    labels: # Labels for the Deployment object itself
                        app: httpd
                        environment: production
                    spec:
                    replicas: 1
                    selector:
                        matchLabels: # Selector to find pods managed by this deployment
                        app: httpd
                    template:
                        metadata:
                        labels: # Labels for the Pods created by this deployment
                            app: httpd
                            tier: frontend
                        spec:
                        containers:
                        - name: httpd
                            image: httpd:latest # The container image and tag
                            ports:
                            - containerPort: 80
            ==================================================================================================                            
            thor@jumphost ~$ kubectl get namespaces
            NAME                 STATUS   AGE
            default              Active   37m
            kube-node-lease      Active   37m
            kube-public          Active   37m
            kube-system          Active   37m
            local-path-storage   Active   36m
            thor@jumphost ~$ kubectl apply -f httpd.yaml 
            deployment.apps/httpd-deployment created
            thor@jumphost ~$ kubectl get deployment
            NAME               READY   UP-TO-DATE   AVAILABLE   AGE
            httpd-deployment   1/1     1            1           10s
            thor@jumphost ~$ kubectl get pods
            NAME                                READY   STATUS    RESTARTS   AGE
            httpd-deployment-5c4ff7578f-fqqtj   1/1     Running   0          20s
            thor@jumphost ~$ 
        
# Task 50: Set Resource Limits in Kubernetes Pods
  # Requirement: 
        The Nautilus DevOps team has noticed performance issues in some Kubernetes-hosted applications due to resource constraints. To address this, they plan to set limits on resource utilization. Here are the details:
            Create a pod named httpd-pod with a container named httpd-container. Use the httpd image with the latest tag (specify as httpd:latest). Set the following resource limits:

            Requests: Memory: 15Mi, CPU: 100m
            Limits: Memory: 20Mi, CPU: 100m
            Note: The kubectl utility on jump_host is configured to operate with the Kubernetes cluster.
  # Solution:
        Below yaml manifest file will help us in creating the pod with specified resource limits
        apiVersion: v1
        kind: Pod
        metadata:
        name: httpd-pod
        spec:
        containers:
        - name: httpd-container
            image: httpd:latest
            resources:
            requests:
                memory: "15Mi"
                cpu: "100m"
            limits:
                memory: "20Mi"
                cpu: "100m"
        thor@jumphost ~$ kubectl apply -f resource-limit.yaml 

# Task 51: Execute Rolling Updates in Kubernetes
 # Requirement:
        An application currently running on the Kubernetes cluster employs the nginx web server. The Nautilus application development team has introduced some recent changes that need deployment. They've crafted an image nginx:1.17 with the latest updates.
            Execute a rolling update for this application, integrating the nginx:1.17 image. The deployment is named nginx-deployment.
            Ensure all pods are operational post-update.
            Note: The kubectl utility on jump_host is set up to operate with the Kubernetes cluster
 # Solution: 
        thor@jumphost ~$ kubectl get deployment
        NAME               READY   UP-TO-DATE   AVAILABLE   AGE
        nginx-deployment   3/3     3            3           5m45s
        thor@jumphost ~$ kubectl get rs
        NAME                         DESIRED   CURRENT   READY   AGE
        nginx-deployment-989f57c54   3         3         3       5m50s
        thor@jumphost ~$ kubectl get pods
        NAME                               READY   STATUS    RESTARTS   AGE
        nginx-deployment-989f57c54-c5dtr   1/1     Running   0          5m55s
        nginx-deployment-989f57c54-f5n26   1/1     Running   0          5m55s
        nginx-deployment-989f57c54-wcfdg   1/1     Running   0          5m55s
        thor@jumphost ~$ 
        thor@jumphost ~$ kubectl edit deployment nginx-deployment ## Edit the deployment using this command and update the image name to nginx:1.17
        deployment.apps/nginx-deployment edited
        thor@jumphost ~$ kubectl get pods
        NAME                                READY   STATUS    RESTARTS   AGE
        nginx-deployment-5dd558cf95-lb7zv   1/1     Running   0          44s
        nginx-deployment-5dd558cf95-w6hzc   1/1     Running   0          46s
        nginx-deployment-5dd558cf95-xsl2g   1/1     Running   0          52s
        thor@jumphost ~$ kubectl get rs  # This was fetched two replica set Kubernetes will recreate a NEW ReplicaSet when you perform a rolling update and                                                    change the image in a Deployment.
        A Deployment always creates a new ReplicaSet when:
           -  container image changes
           - environment variables change
           - container command/args change
           - config/secret mounts change
           - labels change
           - annotations change
           - ports change
           - readiness/liveness probe changes

        Basically ANYTHING inside spec.template triggers a new ReplicaSet.
        NAME                          DESIRED   CURRENT   READY   AGE
        nginx-deployment-5dd558cf95   3         3         3       71s
        nginx-deployment-989f57c54    0         0         0       8m26s
        thor@jumphost ~$ kubectl get deployment
        NAME               READY   UP-TO-DATE   AVAILABLE   AGE
        nginx-deployment   3/3     3            3           9m7s
        thor@jumphost ~$ 

# Task 52: Revert Deployment to Previous Version in Kubernetes
 # Requirement:
        Earlier today, the Nautilus DevOps team deployed a new release for an application. However, a customer has reported a bug related to this recent release. Consequently, the team aims to revert to the previous version.
            There exists a deployment named nginx-deployment; initiate a rollback to the previous revision.
            Note: The kubectl utility on jump_host is configured to interact with the Kubernetes cluster.
 # Solution:
        thor@jumphost ~$ kubectl get deployment
        NAME               READY   UP-TO-DATE   AVAILABLE   AGE
        nginx-deployment   3/3     3            3           104s
        thor@jumphost ~$ kubectl describe deployment nginx-deployment
        Name:                   nginx-deployment
        Namespace:              default
        CreationTimestamp:      Sun, 15 Feb 2026 16:33:11 +0000
        Labels:                 app=nginx-app
                                type=front-end
        Annotations:            deployment.kubernetes.io/revision: 2
                                kubernetes.io/change-cause:
                                kubectl set image deployment nginx-deployment nginx-container=nginx:alpine-perl --kubeconfig=/root/.kube/config --record=true
        Selector:               app=nginx-app
        Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
        StrategyType:           RollingUpdate
        MinReadySeconds:        0
        RollingUpdateStrategy:  25% max unavailable, 25% max surge
        Pod Template:
        Labels:  app=nginx-app
        Containers:
        nginx-container:
            Image:         nginx:alpine-perl
            Port:          <none>
            Host Port:     <none>
            Environment:   <none>
            Mounts:        <none>
        Volumes:         <none>
        Node-Selectors:  <none>
        Tolerations:     <none>
        Conditions:
        Type           Status  Reason
        ----           ------  ------
        Available      True    MinimumReplicasAvailable
        Progressing    True    NewReplicaSetAvailable
        OldReplicaSets:  nginx-deployment-989f57c54 (0/0 replicas created)
        NewReplicaSet:   nginx-deployment-5d44db985c (3/3 replicas created)
        Events:
        Type    Reason             Age    From                   Message
        ----    ------             ----   ----                   -------
        Normal  ScalingReplicaSet  2m11s  deployment-controller  Scaled up replica set nginx-deployment-989f57c54 to 3
        Normal  ScalingReplicaSet  2m1s   deployment-controller  Scaled up replica set nginx-deployment-5d44db985c to 1
        Normal  ScalingReplicaSet  115s   deployment-controller  Scaled down replica set nginx-deployment-989f57c54 to 2 from 3
        Normal  ScalingReplicaSet  115s   deployment-controller  Scaled up replica set nginx-deployment-5d44db985c to 2 from 1
        Normal  ScalingReplicaSet  113s   deployment-controller  Scaled down replica set nginx-deployment-989f57c54 to 1 from 2
        Normal  ScalingReplicaSet  113s   deployment-controller  Scaled up replica set nginx-deployment-5d44db985c to 3 from 2
        Normal  ScalingReplicaSet  111s   deployment-controller  Scaled down replica set nginx-deployment-989f57c54 to 0 from 1
        thor@jumphost ~$ 
        thor@jumphost ~$ 
        thor@jumphost ~$ kubectl rollout history deployment nginx-deployment
        deployment.apps/nginx-deployment 
        REVISION  CHANGE-CAUSE
        1         <none>
        2         kubectl set image deployment nginx-deployment nginx-container=nginx:alpine-perl --kubeconfig=/root/.kube/config --record=true

        thor@jumphost ~$ kubectl rollout history deployment/nginx-deployment
        deployment.apps/nginx-deployment 
        REVISION  CHANGE-CAUSE
        1         <none>
        2         kubectl set image deployment nginx-deployment nginx-container=nginx:alpine-perl --kubeconfig=/root/.kube/config --record=true

        thor@jumphost ~$ kubectl rollout undo deployment nginx-deployment
        deployment.apps/nginx-deployment rolled back
        thor@jumphost ~$ kubectl get deployment
        NAME               READY   UP-TO-DATE   AVAILABLE   AGE
        nginx-deployment   3/3     3            3           6m59s
        thor@jumphost ~$ kubectl get rs
        NAME                          DESIRED   CURRENT   READY   AGE
        nginx-deployment-5d44db985c   0         0         0       6m54s
        nginx-deployment-989f57c54    3         3         3       7m4s
        thor@jumphost ~$ kubectl get pods
        NAME                               READY   STATUS    RESTARTS   AGE
        nginx-deployment-989f57c54-9wpnd   1/1     Running   0          39s
        nginx-deployment-989f57c54-fbkhz   1/1     Running   0          40s
        nginx-deployment-989f57c54-qskkr   1/1     Running   0          37s
        thor@jumphost ~$ kubectl history deployment nginx-deployment
        error: unknown command "history" for "kubectl"
        thor@jumphost ~$ kubectl rollout history deployment nginx-deployment
        deployment.apps/nginx-deployment 
        REVISION  CHANGE-CAUSE
        2         kubectl set image deployment nginx-deployment nginx-container=nginx:alpine-perl --kubeconfig=/root/.kube/config --record=true
        3         <none>

        thor@jumphost ~$ 
        ###########################################################################
       # Roll Back to a Specific Revision
       # If you need to roll back to a specific version that is not the immediately preceding one (for example, to revision 2), use #   the --to-revision flag.
       # bash kubectl rollout undo deployment/<deployment-name> --to-revision=<revision-number>
       # Monitor the Rollback Status
       # After initiating the rollback, monitor its progress to ensure it completes successfully. The rollback is performed as a #      rolling update, so there             should be no downtime.
       # bash kubectl rollout status deployment/<deployment-name>
       #############################################################################

# Task 53: Resolve VolumeMounts Issue in Kubernetes
 # Requirement:
        We encountered an issue with our Nginx and PHP-FPM setup on the Kubernetes cluster this morning, which halted its functionality. Investigate and rectify the issue:
            The pod name is nginx-phpfpm and configmap name is nginx-config. Identify and fix the problem.
            Once resolved, copy /home/thor/index.php file from the jump host to the nginx-container within the nginx document root. After this, you should be able to access the website using Website button on the top bar.
            Note: The kubectl utility on jump_host is configured to operate with the Kubernetes cluster.
 # Solution:
        thor@jumphost ~$ kubectl describe configmap nginx-config
        Name:         nginx-config
        Namespace:    default
        Labels:       <none>
        Annotations:  <none>

        Data
        ====
        nginx.conf:
        ----
        events {
        }
        http {
        server {
            listen 8099 default_server;
            listen [::]:8099 default_server;

            # Set nginx to serve files from the shared volume!
            root /var/www/html;
            index  index.html index.htm index.php;
            server_name _;
            location / {
            try_files $uri $uri/ =404;
            }
            location ~ \.php$ {
            include fastcgi_params;
            fastcgi_param REQUEST_METHOD $request_method;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass 127.0.0.1:9000;
            }
        }
        }


        BinaryData
        ====

        Events:  <none>
        thor@jumphost ~$ 
        thor@jumphost ~$ 
        thor@jumphost ~$ kubectl get pod nginx-phpfpm -o yaml
        apiVersion: v1
        kind: Pod
        metadata:
        annotations:
            kubectl.kubernetes.io/last-applied-configuration: |
            {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"labels":{"app":"php-app"},"name":"nginx-phpfpm","namespace":"default"},"spec":{"containers":[{"image":"php:7.2-fpm-alpine","name":"php-fpm-container","volumeMounts":[{"mountPath":"/var/www/html","name":"shared-files"}]},{"image":"nginx:latest","name":"nginx-container","volumeMounts":[{"mountPath":"/usr/share/nginx/html","name":"shared-files"},{"mountPath":"/etc/nginx/nginx.conf","name":"nginx-config-volume","subPath":"nginx.conf"}]}],"volumes":[{"emptyDir":{},"name":"shared-files"},{"configMap":{"name":"nginx-config"},"name":"nginx-config-volume"}]}}
        creationTimestamp: "2026-02-16T13:05:10Z"
        labels:
            app: php-app
        name: nginx-phpfpm
        namespace: default
        resourceVersion: "2094"
        uid: 6dccd890-843a-4c19-bc86-2241609e651e
        spec:
        containers:
        - image: php:7.2-fpm-alpine
            imagePullPolicy: IfNotPresent
            name: php-fpm-container
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
            volumeMounts:
            - mountPath: /var/www/html
            name: shared-files
            - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
            name: kube-api-access-gzlfl
            readOnly: true
        - image: nginx:latest
            imagePullPolicy: Always
            name: nginx-container
            resources: {}
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
            volumeMounts:
            - mountPath: /usr/share/nginx/html
            name: shared-files
            - mountPath: /etc/nginx/nginx.conf
            name: nginx-config-volume
            subPath: nginx.conf
            - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
            name: kube-api-access-gzlfl
            readOnly: true
        dnsPolicy: ClusterFirst
        enableServiceLinks: true
        nodeName: kodekloud-control-plane
        preemptionPolicy: PreemptLowerPriority
        priority: 0
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        serviceAccount: default
        serviceAccountName: default
        terminationGracePeriodSeconds: 30
        tolerations:
        - effect: NoExecute
            key: node.kubernetes.io/not-ready
            operator: Exists
            tolerationSeconds: 300
        - effect: NoExecute
            key: node.kubernetes.io/unreachable
            operator: Exists
            tolerationSeconds: 300
        volumes:
        - emptyDir: {}
            name: shared-files
        - configMap:
            defaultMode: 420
            name: nginx-config
            name: nginx-config-volume
        - name: kube-api-access-gzlfl
            projected:
            defaultMode: 420
            sources:
            - serviceAccountToken:
                expirationSeconds: 3607
                path: token
            - configMap:
                items:
                - key: ca.crt
                    path: ca.crt
                name: kube-root-ca.crt
            - downwardAPI:
                items:
                - fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.namespace
                    path: namespace
        status:
        conditions:
        - lastProbeTime: null
            lastTransitionTime: "2026-02-16T13:05:10Z"
            status: "True"
            type: Initialized
        - lastProbeTime: null
            lastTransitionTime: "2026-02-16T13:05:21Z"
            status: "True"
            type: Ready
        - lastProbeTime: null
            lastTransitionTime: "2026-02-16T13:05:21Z"
            status: "True"
            type: ContainersReady
        - lastProbeTime: null
            lastTransitionTime: "2026-02-16T13:05:10Z"
            status: "True"
            type: PodScheduled
        containerStatuses:
        - containerID: containerd://e120ba7fd3c3ccbb04e8abbe9daa6e116e53c39f6fc171ed714993cd96166b16
            image: docker.io/library/nginx:latest
            imageID: docker.io/library/nginx@sha256:341bf0f3ce6c5277d6002cf6e1fb0319fa4252add24ab6a0e262e0056d313208
            lastState: {}
            name: nginx-container
            ready: true
            restartCount: 0
            started: true
            state:
            running:
                startedAt: "2026-02-16T13:05:21Z"
        - containerID: containerd://b202f154a8016f69f4f71c6f340d5b0ff5a518ceae04af6aaf8c19700122fa59
            image: docker.io/library/php:7.2-fpm-alpine
            imageID: docker.io/library/php@sha256:2e2d92415f3fc552e9a62548d1235f852c864fcdc94bcf2905805d92baefc87f
            lastState: {}
            name: php-fpm-container
            ready: true
            restartCount: 0
            started: true
            state:
            running:
                startedAt: "2026-02-16T13:05:14Z"
        hostIP: 172.17.0.2
        phase: Running
        podIP: 10.244.0.5
        podIPs:
        - ip: 10.244.0.5
        qosClass: BestEffort
        startTime: "2026-02-16T13:05:10Z"
        thor@jumphost ~$ kubectl get pod nginx-phpfpm -o yaml > nginx-phpfpm.yml
        thor@jumphost ~$ ls
        index.php  nginx-phpfpm.yml
        thor@jumphost ~$ vi nginx-phpfpm.yml 
        thor@jumphost ~$ kubectl delete pod nginx-phpfpm
        pod "nginx-phpfpm" deleted
        thor@jumphost ~$ kubectl apply -f nginx-phpfpm.yml
        pod/nginx-phpfpm created
        thor@jumphost ~$ kubectl get pods
        NAME           READY   STATUS    RESTARTS   AGE
        nginx-phpfpm   2/2     Running   0          8s
        thor@jumphost ~$ kubectl cp index.php nginx-phpfpm:/var/www/html/index.php -c nginx-container
        thor@jumphost ~$ 

# Task 54: Kubernetes Shared Volumes
 # Requirement:
        We are working on an application that will be deployed on multiple containers within a pod on Kubernetes cluster. There is a requirement to share a volume among the containers to save some temporary data. The Nautilus DevOps team is developing a similar template to replicate the scenario. Below you can find more details about it.
            Create a pod named volume-share-datacenter.
            
            For the first container, use image debian with latest tag only and remember to mention the tag i.e debian:latest, container should be named as volume-container-datacenter-1, and run a sleep command for it so that it remains in running state. Volume volume-share should be mounted at path /tmp/beta.
            
            For the second container, use image debian with the latest tag only and remember to mention the tag i.e debian:latest, container should be named as volume-container-datacenter-2, and again run a sleep command for it so that it remains in running state. Volume volume-share should be mounted at path /tmp/cluster.
            
            Volume name should be volume-share of type emptyDir.
            
            After creating the pod, exec into the first container i.e volume-container-datacenter-1, and just for testing create a file beta.txt with any content under the mounted path of first container i.e /tmp/beta.
            
            The file beta.txt should be present under the mounted path /tmp/cluster on the second container volume-container-datacenter-2 as well, since they are using a shared volume.
            Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
 # Solution:
        Yaml manifest file for creating the shared volume with multi container in single pod
        apiVersion: v1
        kind: Pod
        metadata:
        name: volume-share-datacenter
        spec:
        volumes:
            - name: volume-share
            emptyDir: {}
        containers:
            - name: volume-container-datacenter-1
            image: debian:latest
            command: ["sh", "-c", "sleep 3600"]
            volumeMounts:
                - name: volume-share
                mountPath: /tmp/beta
            - name: volume-container-datacenter-2
            image: debian:latest
            command: ["sh", "-c", "sleep 3600"]
            volumeMounts:
                - name: volume-share
                mountPath: /tmp/cluster

        thor@jumphost ~$ kubectl apply -f volume-share.yaml 
        pod/volume-share-datacenter created
        thor@jumphost ~$ kubectl get pods
        NAME                      READY   STATUS              RESTARTS   AGE
        volume-share-datacenter   0/2     ContainerCreating   0          6s
        thor@jumphost ~$ kubectl get pods
        NAME                      READY   STATUS    RESTARTS   AGE
        volume-share-datacenter   2/2     Running   0          11s

        thor@jumphost ~$ kubectl apply -f volume-share.yaml  ## Pod created 
        pod/volume-share-datacenter created
        thor@jumphost ~$ kubectl get pods
        NAME                      READY   STATUS              RESTARTS   AGE
        volume-share-datacenter   0/2     ContainerCreating   0          6s
        thor@jumphost ~$ kubectl get pods
        NAME                      READY   STATUS    RESTARTS   AGE
        volume-share-datacenter   2/2     Running   0          11s
        thor@jumphost ~$ kubectl describe pod volume-share-datacenter ## Verify container names in side the POD
        Name:             volume-share-datacenter
        Namespace:        default
        Priority:         0
        Service Account:  default
        Node:             kodekloud-control-plane/172.17.0.2
        Start Time:       Tue, 17 Feb 2026 10:57:39 +0000
        Labels:           <none>
        Annotations:      <none>
        Status:           Running
        IP:               10.244.0.5
        IPs:
        IP:  10.244.0.5
        Containers:
        volume-container-datacenter-1:
            Container ID:  containerd://6008182ccd02cffc9012de695cc9677d6e7bfa3c32b06c8ac1dd32d0fbb474ed
            Image:         debian:latest
            Image ID:      docker.io/library/debian@sha256:2c91e484d93f0830a7e05a2b9d92a7b102be7cab562198b984a84fdbc7806d91
            Port:          <none>
            Host Port:     <none>
            Command:
            sh
            -c
            sleep 3600
            State:          Running
            Started:      Tue, 17 Feb 2026 10:57:47 +0000
            Ready:          True
            Restart Count:  0
            Environment:    <none>
            Mounts:
            /tmp/beta from volume-share (rw)
            /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hhcc9 (ro)
        volume-container-datacenter-2:
            Container ID:  containerd://22354e6b99fa21013353dd45f652c6fccdcdfa83864d02cc9058c0d60ad4ddf2
            Image:         debian:latest
            Image ID:      docker.io/library/debian@sha256:2c91e484d93f0830a7e05a2b9d92a7b102be7cab562198b984a84fdbc7806d91
            Port:          <none>
            Host Port:     <none>
            Command:
            sh
            -c
            sleep 3600
            State:          Running
            Started:      Tue, 17 Feb 2026 10:57:47 +0000
            Ready:          True
            Restart Count:  0
            Environment:    <none>
            Mounts:
            /tmp/cluster from volume-share (rw)
            /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hhcc9 (ro)
        Conditions:
        Type              Status
        Initialized       True 
        Ready             True 
        ContainersReady   True 
        PodScheduled      True 
        Volumes:
        volume-share:
            Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
            Medium:     
            SizeLimit:  <unset>
        kube-api-access-hhcc9:
            Type:                    Projected (a volume that contains injected data from multiple sources)
            TokenExpirationSeconds:  3607
            ConfigMapName:           kube-root-ca.crt
            ConfigMapOptional:       <nil>
            DownwardAPI:             true
        QoS Class:                   BestEffort
        Node-Selectors:              <none>
        Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                                    node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
        Events:
        Type    Reason     Age   From               Message
        ----    ------     ----  ----               -------
        Normal  Scheduled  79s   default-scheduler  Successfully assigned default/volume-share-datacenter to kodekloud-control-plane
        Normal  Pulling    76s   kubelet            Pulling image "debian:latest"
        Normal  Pulled     71s   kubelet            Successfully pulled image "debian:latest" in 4.526567874s (4.526588432s including waiting)
        Normal  Created    71s   kubelet            Created container volume-container-datacenter-1
        Normal  Started    71s   kubelet            Started container volume-container-datacenter-1
        Normal  Pulling    71s   kubelet            Pulling image "debian:latest"
        Normal  Pulled     71s   kubelet            Successfully pulled image "debian:latest" in 244.405638ms (244.419273ms including waiting)
        Normal  Created    71s   kubelet            Created container volume-container-datacenter-2
        Normal  Started    71s   kubelet            Started container volume-container-datacenter-2
        thor@jumphost ~$ kubectl exec -it volume-share-datacenter -c volume-container-datacenter-1 -- /bin/bash ## Connect to the container in the POD
        root@volume-share-datacenter:/# pwd
        /
        root@volume-share-datacenter:/# cd /tmp/beta/
        root@volume-share-datacenter:/tmp/beta# ls
        root@volume-share-datacenter:/tmp/beta# vi beta.txt
        bash: vi: command not found
        root@volume-share-datacenter:/tmp/beta# vim beta.txt
        bash: vim: command not found
        root@volume-share-datacenter:/tmp/beta# touch beta.txt
        root@volume-share-datacenter:/tmp/beta# echo testing shared volumes in multi container >> beta.txt ## Created the test file in container 1
        root@volume-share-datacenter:/tmp/beta# cat beta.txt 
        testing shared volumes in multi container
        root@volume-share-datacenter:/tmp/beta# 
        ## Validating in container 2 whether the test file showing in Conteiner 2

        thor@jumphost ~$ kubectl exec -it volume-share-datacenter -c volume-container-datacenter-2 -- /bin/bash ## Connecting to COntainer 2
        root@volume-share-datacenter:/# cd /tmp/cluster/
        root@volume-share-datacenter:/tmp/cluster# ls
        beta.txt
        root@volume-share-datacenter:/tmp/cluster# cat beta.txt 
        testing shared volumes in multi container
        root@volume-share-datacenter:/tmp/cluster#

# Task 55: Kubernetes Sidecar Containers 
 # Requirement:
        We have a web server container running the nginx image. The access and error logs generated by the web server are not critical enough to be placed on a persistent volume. However, Nautilus developers need access to the last 24 hours of logs so that they can trace issues and bugs. Therefore, we need to ship the access and error logs for the web server to a log-aggregation service. Following the separation of concerns principle, we implement the Sidecar pattern by deploying a second container that ships the error and access logs from nginx. Nginx does one thing, and it does it well—serving web pages. The second container also specializes in its task—shipping logs. Since containers are running on the same Pod, we can use a shared emptyDir volume to read and write logs.

        Create a pod named webserver.

        Create an emptyDir volume shared-logs.

        Create two containers from nginx and ubuntu images with latest tag only and remember to mention tag i.e nginx:latest, nginx container name should be nginx-container and ubuntu container name should be sidecar-container on webserver pod.

        Add command on sidecar-container "sh","-c","while true; do cat /var/log/nginx/access.log /var/log/nginx/error.log; sleep 30; done"

        Mount the volume shared-logs on both containers at location /var/log/nginx, all containers should be up and running.

        Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
 # Solution:
        apiVersion: v1
        kind: Pod
        metadata:
        name: webserver
        spec:
        volumes:
            - name: shared-logs
            emptyDir: {}
        containers:
            - name: nginx-container
            image: nginx:latest
            volumeMounts:
                - name: shared-logs
                mountPath: /var/log/nginx
            resources:
                requests:
                memory: "20Mi"
                cpu: "100m"
                limits:
                memory: "25Mi"
                cpu: "100m"
            - name: sidecar-container
            image: ubuntu:latest
            command: ["sh","-c","while true; do cat /var/log/nginx/access.log /var/log/nginx/error.log; sleep 30; done"]
            volumeMounts:
                - mountPath: /var/log/nginx
                name: shared-logs
            resources:
                requests:
                memory: "20Mi"
                cpu: "100m"
                limits:
                memory: "25Mi"
                cpu: "100m"
# Task 56: Deploy Nginx Web Server on Kubernetes Cluster
 # Requirement:
        Some of the Nautilus team developers are developing a static website and they want to deploy it on Kubernetes cluster. They want it to be highly available and scalable. Therefore, based on the requirements, the DevOps team has decided to create a deployment for it with multiple replicas. Below you can find more details about it:

            Create a deployment using nginx image with latest tag only and remember to mention the tag i.e nginx:latest. Name it as nginx-deployment. The container should be named as nginx-container, also make sure replica counts are 3.

            Create a NodePort type service named nginx-service. The nodePort should be 30011.

            Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.          

 # Solution: 
        # Create the Deployment and service manigfest file
            # Deployment manifest file:

            #######################################
            # Create a deployment using nginx image with latest tag only and remember to mention the tag i.e nginx:latest. Name it as nginx-deployment. 
            # The container should be named as nginx-container, also make sure replica counts are 3.
            ############################################
            apiVersion: apps/v1
            kind: Deployment
            metadata:
            name: nginx-deployment
            spec:
            replicas: 3
            selector:
                matchLabels:
                name: nginx  
            template:
                metadata:
                labels:
                    name: nginx
                spec:
                containers:
                    - name: nginx-container
                    image: nginx:latest
                    ports:
                        - containerPort: 80
        
        # Service Manifest file
            ###################################################################################
            # Create a NodePort type service named nginx-service. The nodePort should be 30011.
            ###################################################################################
            apiVersion: v1
            kind: Service
            metadata:
            name: nginx-service
            spec:
            ports:
                - port: 80
                targetPort: 80
                nodePort: 30011
            selector:
                name: nginx
            type: NodePort

# Task 57: Print Environment Variables
  # Requirement:
        The Nautilus DevOps team is working on to setup some pre-requisites for an application that will send the greetings to different users. There is a sample deployment, that needs to be tested. Below is a scenario which needs to be configured on Kubernetes cluster. Please find below more details about it.

            Create a pod named print-envars-greeting.

            Configure spec as, the container name should be print-env-container and use bash image.

            Create three environment variables:

            a. GREETING and its value should be Welcome to

            b. COMPANY and its value should be Stratos

            c. GROUP and its value should be Industries

            Use command ["/bin/sh", "-c", 'echo "$(GREETING) $(COMPANY) $(GROUP)"'] (please use this exact command), also set its restartPolicy policy to Never to avoid crash loop back.

            You can check the output using kubectl logs -f print-envars-greeting command.


            Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
  # Solution: 
        Pod Manifest file created using Conifg maps concept
            apiVersion: v1
            kind: Pod
            metadata: 
            name: print-envars-greeting
            spec:
            containers:
                - name: print-env-container
                image: bash
                command: ["/bin/sh", "-c", 'echo "$(GREETING) $(COMPANY) $(GROUP)"'] 
                env:
                    - name: GREETING 
                    value: "Welcome to"
                    - name: COMPANY
                    value: "Stratos"
                    - name: GROUP
                    value: "Industries"
            restartPolicy: Never
    
        thor@jumphost ~$ kubectl apply -f print-env.yaml 
        pod/print-envars-greeting created
        thor@jumphost ~$ kubectl get pods
        NAME                    READY   STATUS      RESTARTS   AGE
        print-envars-greeting   0/1     Completed   0          13s
        thor@jumphost ~$ kubectl get pods
        NAME                    READY   STATUS      RESTARTS   AGE
        print-envars-greeting   0/1     Completed   0          16s
        thor@jumphost ~$ kubectl get pods
        NAME                    READY   STATUS      RESTARTS   AGE
        print-envars-greeting   0/1     Completed   0          17s
        thor@jumphost ~$ kubectl get pods
        NAME                    READY   STATUS      RESTARTS   AGE
        print-envars-greeting   0/1     Completed   0          19s
        thor@jumphost ~$ kubectl describe pod print-envars-greeting
        Name:             print-envars-greeting
        Namespace:        default
        Priority:         0
        Service Account:  default
        Node:             kodekloud-control-plane/172.17.0.2
        Start Time:       Fri, 20 Feb 2026 09:44:21 +0000
        Labels:           <none>
        Annotations:      <none>
        Status:           Succeeded
        IP:               10.244.0.5
        IPs:
        IP:  10.244.0.5
        Containers:
        print-env-container:
            Container ID:  containerd://82bd9706bda7eb61fdfd8457c4bdb3d3f8a879f8b4ebab2627b18a75436509a8
            Image:         bash
            Image ID:      docker.io/library/bash@sha256:e320b40b14abc61f053286705070342c46034a549a276b798e64541457c4af92
            Port:          <none>
            Host Port:     <none>
            Command:
            /bin/sh
            -c
            echo "$(GREETING) $(COMPANY) $(GROUP)"
            State:          Terminated
            Reason:       Completed
            Exit Code:    0
            Started:      Fri, 20 Feb 2026 09:44:23 +0000
            Finished:     Fri, 20 Feb 2026 09:44:23 +0000
            Ready:          False
            Restart Count:  0
            Environment:
            GREETING:  Welcome to
            COMPANY:   Stratos
            GROUP:     Industries
            Mounts:
            /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-59dsm (ro)
        Conditions:
        Type              Status
        Initialized       True 
        Ready             False 
        ContainersReady   False 
        PodScheduled      True 
        Volumes:
        kube-api-access-59dsm:
            Type:                    Projected (a volume that contains injected data from multiple sources)
            TokenExpirationSeconds:  3607
            ConfigMapName:           kube-root-ca.crt
            ConfigMapOptional:       <nil>
            DownwardAPI:             true
        QoS Class:                   BestEffort
        Node-Selectors:              <none>
        Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                                    node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
        Events:
        Type    Reason     Age   From               Message
        ----    ------     ----  ----               -------
        Normal  Scheduled  48s   default-scheduler  Successfully assigned default/print-envars-greeting to kodekloud-control-plane
        Normal  Pulling    47s   kubelet            Pulling image "bash"
        Normal  Pulled     46s   kubelet            Successfully pulled image "bash" in 849.100688ms (849.115945ms including waiting)
        Normal  Created    46s   kubelet            Created container print-env-container
        Normal  Started    46s   kubelet            Started container print-env-container
        thor@jumphost ~$ kubectl logs -f print-envars-greeting
        Welcome to Stratos Industries
        thor@jumphost ~$

# Task 58: Deploy Grafana on Kubernetes Cluster
  # Requirement:
        The Nautilus DevOps teams is planning to set up a Grafana tool to collect and analyze analytics from some applications. They are planning to deploy it on Kubernetes cluster. Below you can find more details.
            1.) Create a deployment named grafana-deployment-datacenter using any grafana image for Grafana app. Set other parameters as per your choice.

            2.) Create NodePort type service with nodePort 32000 to expose the app.

        You need not to make any configuration changes inside the Grafana app once deployed, just make sure you are able to access the Grafana login page.
        Note: The kubectl on jump_host has been configured to work with kubernetes cluster.
  # Solution:
        ###############################################################################
        # The Nautilus DevOps teams is planning to set up a Grafana tool to collect and analyze analytics from some applications. 
        # They are planning to deploy it on Kubernetes cluster. Below you can find more details.
        #    1.) Create a deployment named grafana-deployment-datacenter using any grafana image for Grafana app. Set other parameters as per your choice.
        #    2.) Create NodePort type service with nodePort 32000 to expose the app.
        #    You need not to make any configuration changes inside the Grafana app once deployed, just make sure you are able to access the Grafana login page.
        #    Note: The kubectl on jump_host has been configured to work with kubernetes cluster.
        ################################################################################

        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: grafana-deployment-datacenter
        spec:
        replicas: 2
        selector:
            matchLabels:
            name: grafana-deployment   
        template:
            metadata:
            labels:
                name: grafana-deployment
            spec:
            containers:
                - name: grafana
                  image: grafana/grafana:latest 
                  ports:
                    - containerPort: 3000
                    
        ---
        ####################
        # Creating the node port service
        apiVersion: v1
        kind: Service
        metadata:
        name: grafana-port-node
        spec:
        type: NodePort
        selector:
            name: grafana-deployment
        ports:
            - port: 3000
              targetPort: 3000
              nodePort: 32000  

        thor@jumphost ~$ kubectl apply -f grafana-deployment.yaml 
        deployment.apps/grafana-deployment-datacenter created
        service/grafana-port-node created
        thor@jumphost ~$ kubectl get svc
        NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
        grafana-port-node   NodePort    10.96.235.11   <none>        3000:32000/TCP   9s
        kubernetes          ClusterIP   10.96.0.1      <none>        443/TCP          25m
        thor@jumphost ~$ kubectl get pods
        NAME                                            READY   STATUS              RESTARTS   AGE
        grafana-deployment-datacenter-6b99f6657-5lw9w   0/1     ContainerCreating   0          23s
        grafana-deployment-datacenter-6b99f6657-79p5z   0/1     ContainerCreating   0          23s
        thor@jumphost ~$ kubectl get pods
        NAME                                            READY   STATUS    RESTARTS   AGE
        grafana-deployment-datacenter-6b99f6657-5lw9w   1/1     Running   0          27s
        grafana-deployment-datacenter-6b99f6657-79p5z   1/1     Running   0          27s
        thor@jumphost ~$ kubectl get pods
        NAME                                            READY   STATUS    RESTARTS   AGE
        grafana-deployment-datacenter-6b99f6657-5lw9w   1/1     Running   0          29s
        grafana-deployment-datacenter-6b99f6657-79p5z   1/1     Running   0          29s
        thor@jumphost ~$ kubectl get rs
        NAME                                      DESIRED   CURRENT   READY   AGE
        grafana-deployment-datacenter-6b99f6657   2         2         2       33s
        thor@jumphost ~$ kubectl get deployment
        NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
        grafana-deployment-datacenter   2/2     2            2           41s
        thor@jumphost ~$ 

# Task 59: Troubleshoot Deployment issues in Kubernetes
  # Requirement:
        Last week, the Nautilus DevOps team deployed a redis app on Kubernetes cluster, which was working fine so far. This morning one of the team members was making some changes in this existing setup, but he made some mistakes and the app went down. We need to fix this as soon as possible. Please take a look.
            The deployment name is redis-deployment. The pods are not in running state right now, so please look into the issue and fix the same.
            Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
  # Solution:
        Deployment having issues with Image name & Configmap names so edited deployment accrordingly
# Task 60: Persistent Volumes in Kubernetes
 # Requirement:
        The Nautilus DevOps team is working on a Kubernetes template to deploy a web application on the cluster. There are some requirements to create/use persistent volumes to store the application code, and the template needs to be designed accordingly. Please find more details below:
            Create a PersistentVolume named as pv-devops. Configure the spec as storage class should be manual, set capacity to 4Gi, set access mode to ReadWriteOnce, volume type should be hostPath and set path to /mnt/dba (this directory is already created, you might not be able to access it directly, so you need not to worry about it).

            Create a PersistentVolumeClaim named as pvc-devops. Configure the spec as storage class should be manual, request 2Gi of the storage, set access mode to ReadWriteOnce.

            Create a pod named as pod-devops, mount the persistent volume you created with claim name pvc-devops at document root of the web server, the container within the pod should be named as container-devops using image nginx with latest tag only (remember to mention the tag i.e nginx:latest).

            Create a node port type service named web-devops using node port 30008 to expose the web server running within the pod.

            Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
 # Solution:
        # Manifest for persistent volume in cluster
        apiVersion: v1
        kind: PersistentVolume
        metadata:
        name: pv-datacenter
        spec:
        storageClassName: manual
        capacity:
            storage: 3Gi
        accessModes: 
            - ReadWriteOnce
        hostPath:
            path: /mnt/devops

        --- # Manifest for Persistent volume claim
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
        name: pvc-datacenter
        spec:
        storageClassName: manual
        accessModes:
            - ReadWriteOnce
        resources: 
            requests:
            storage: 3Gi

        --- # Manifest for creating the POD
        apiVersion: v1
        kind: Pod
        metadata:
        name: pod-datacenter
        labels:
            name: pod-datacenter
        spec:
            volumes: 
                - name: volume-persistent
                persistentVolumeClaim:
                    claimName: pvc-datacenter
            containers:
                - name: container-datacenter
                image: httpd:latest
                volumeMounts:
                    - name: volume-persistent
                    mountPath: /var/www/html/
                ports:
                    - containerPort: 80

        --- # Manifest to create the node port servie
        apiVersion: v1
        kind: Service
        metadata:
        name: web-datacenter
        spec:
        type: NodePort
        selector:
            name: pod-datacenter
        ports:
            - protocol: TCP
            port: 80
            targetPort: 80
            nodePort: 30008
# Task 61: Init Containers in Kubernetes
  # Requirement:
        There are some applications that need to be deployed on Kubernetes cluster and these apps have some pre-requisites where some configurations need to be changed before deploying the app container. Some of these changes cannot be made inside the images so the DevOps team has come up with a solution to use init containers to perform these tasks during deployment. Below is a sample scenario that the team is going to test first.
            Create a Deployment named as ic-deploy-xfusion.
            Configure spec as replicas should be 1, labels app should be ic-xfusion, template's metadata lables app should be the same ic-xfusion.
            The initContainers should be named as ic-msg-xfusion, use image debian with latest tag and use command '/bin/bash', '-c' and 'echo Init Done - Welcome to xFusionCorp Industries > /ic/media'. The volume mount should be named as ic-volume-xfusion and mount path should be /ic.
            Main container should be named as ic-main-xfusion, use image debian with latest tag and use command '/bin/bash', '-c' and 'while true; do cat /ic/media; sleep 5; done'. The volume mount should be named as ic-volume-xfusion and mount path should be /ic.
            Volume to be named as ic-volume-xfusion and it should be an emptyDir type.
            Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
 # Solution:
        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: ic-deploy-xfusion
        spec:
        replicas: 1
        selector:
            matchLabels:
            app: ic-xfusion
        template:
            metadata:
            labels:
                app: ic-xfusion
            spec:
            initContainers:
                - name: ic-msg-xfusion
                  image: debian:latest
                  command: ["/bin/bash", "-c", "echo Init Done - Welcome to xFusionCorp Industries > /ic/media"]
                  volumeMounts:
                    - mountPath: /ic
                      name: ic-volume-xfusion
            containers:
                - name: ic-main-xfusion
                  image: debian:latest
                  command: ["/bin/bash", "-c", "while true; do cat /ic/media; sleep 5; done"]
                  volumeMounts:
                    - mountPath: /ic
                      name: ic-volume-xfusion
            volumes:
                - name: ic-volume-xfusion
                  emptyDir: {}

          
    

# Task 62: Manage Secrets in Kubernetes
  # Requirement:
        The Nautilus DevOps team is working to deploy some tools in Kubernetes cluster. Some of the tools are licence based so that licence information needs to be stored securely within Kubernetes cluster. Therefore, the team wants to utilize Kubernetes secrets to store those secrets. Below you can find more details about the requirements:

            We already have a secret key file blog.txt under /opt location on jump host. Create a generic secret named blog, it should contain the password/license-number present in blog.txt file.
            Also create a pod named secret-nautilus.
            Configure pod's spec as container name should be secret-container-nautilus, image should be fedora with latest tag (remember to mention the tag with image). Use sleep command for container so that it remains in running state. Consume the created secret and mount it under /opt/apps within the container.
            To verify you can exec into the container secret-container-nautilus, to check the secret key under the mounted path /opt/apps. Before hitting the Check button please make sure pod/pods are in running state, also validation can take some time to complete so keep patience.
            Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.
  # Solution:
        thor@jumphost ~$ kubectl create secret generic secret-nautilus --from-file=/opt/blog.txt
        # Seceret Manifest file
        apiVersion: v1
        kind: Pod
        metadata:
        name: secret-nautilus
        spec:
        containers:
            - name: secret-container-nautilus
            image: fedora:latest
            command: ["/bin/sh", "-c", "env; sleep 3600"]
            volumeMounts:
                - name: secret-volume
                mountPath: /opt/apps
        volumes:
            - name: secret-volume
            secret:
            secretName: secret-nautilus

        thor@jumphost ~$ kubectl apply -f seceret.yaml 
        pod/secret-nautilus created
        thor@jumphost ~$ kubectl get pods
        NAME              READY   STATUS              RESTARTS   AGE
        secret-nautilus   0/1     ContainerCreating   0          8s
        thor@jumphost ~$ kubectl get pods
        NAME              READY   STATUS    RESTARTS   AGE
        secret-nautilus   1/1     Running   0          11s
        thor@jumphost ~$ kubectl exec  -it secret-nautilus -c secret-container-nautilus -- /bin/bash
        [root@secret-nautilus /]# cat /opt/apps/blog.txt 
        5ecur3
        [root@secret-nautilus /]# cat /opt/apps/blog.txt 

# Task 63: Deploy Iron Gallery App on Kubernetes
  # Requirement:
        There is an iron gallery app that the Nautilus DevOps team was developing. They have recently customized the app and are going to deploy the same on the Kubernetes cluster. Below you can find more details:

            Create a namespace iron-namespace-devops

            Create a deployment iron-gallery-deployment-devops for iron gallery under the same namespace you created.

            :- Labels run should be iron-gallery.

            :- Replicas count should be 1.

            :- Selector's matchLabels run should be iron-gallery.

            :- Template labels run should be iron-gallery under metadata.

            :- The container should be named as iron-gallery-container-devops, use kodekloud/irongallery:2.0 image ( use exact image name / tag ).

            :- Resources limits for memory should be 100Mi and for CPU should be 50m.

            :- First volumeMount name should be config, its mountPath should be /usr/share/nginx/html/data.

            :- Second volumeMount name should be images, its mountPath should be /usr/share/nginx/html/uploads.

            :- First volume name should be config and give it emptyDir and second volume name should be images, also give it emptyDir.

            Create a deployment iron-db-deployment-devops for iron db under the same namespace.

            :- Labels db should be mariadb.

            :- Replicas count should be 1.

            :- Selector's matchLabels db should be mariadb.

            :- Template labels db should be mariadb under metadata.

            :- The container name should be iron-db-container-devops, use kodekloud/irondb:2.0 image ( use exact image name / tag ).

            :- Define environment, set MYSQL_DATABASE its value should be database_apache, set MYSQL_ROOT_PASSWORD and MYSQL_PASSWORD value should be with some complex passwords for DB connections, and MYSQL_USER value should be any custom user ( except root ).

            :- Volume mount name should be db and its mountPath should be /var/lib/mysql. Volume name should be db and give it an emptyDir.

            Create a service for iron db which should be named iron-db-service-devops under the same namespace. Configure spec as selector's db should be mariadb. Protocol should be TCP, port and targetPort should be 3306 and its type should be ClusterIP.

            Create a service for iron gallery which should be named iron-gallery-service-devops under the same namespace. Configure spec as selector's run should be iron-gallery. Protocol should be TCP, port and targetPort should be 80, nodePort should be 32678 and its type should be NodePort.


            Note:


            We don't need to make connection b/w database and front-end now, if the installation page is coming up it should be enough for now.

            The kubectl on jump_host has been configured to work with the kubernetes cluster.

  # Solution:
        Manifest file Deployment and service

        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: iron-gallery-deployment-devops
        namespace: iron-namespace-devops
        labels:
            run: iron-gallery
        spec:
        replicas: 1
        selector:
            matchLabels:
            run: iron-gallery
        template:
            metadata:
            labels:
                run: iron-gallery
            spec:
            containers:
            - name: iron-gallery-container-devops
                image: kodekloud/irongallery:2.0
                resources:
                limits:
                    memory: "100Mi"
                    cpu: "50m"
                volumeMounts:
                - name: config
                    mountPath: /usr/share/nginx/html/data
                - name: images
                    mountPath: /usr/share/nginx/html/uploads 
            volumes:
                - name: config
                emptyDir: {}
                - name: images
                emptyDir: {}

        ---
        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: iron-db-deployment-devops
        namespace: iron-namespace-devops
        labels:
            db: mariadb
        spec: 
        replicas: 1
        selector:
            matchLabels:
            db: mariadb
        template:
            metadata:
            labels:
                db: mariadb
            spec:
            containers:
                - name: iron-db-container-devops
                image: kodekloud/irondb:2.0
                env:
                    - name: MYSQL_DATABASE
                    value: database_host
                    - name: MYSQL_ROOT_PASSWORD
                    value: "RootP@ssw0rd!"
                    - name: MYSQL_USER
                    value: "ironuser"
                    - name: MYSQL_PASSWORD
                    value: "IronP@ss123"
                volumeMounts:
                    - mountPath: /var/lib/mysql
                    name: db
            volumes:
                - name: db
                emptyDir: {}

        ---
        apiVersion: v1
        kind: Service
        metadata:
        name: iron-db-service-devops
        namespace: iron-namespace-devops
        spec:
        selector:
            db: mariadb
        ports:
            - protocol: TCP
            port: 3306
            targetPort: 3306
        type: ClusterIP

        ---

        apiVersion: v1
        kind: Service
        metadata:
        name: iron-gallery-service-devops
        namespace: iron-namespace-devops
        spec:
        selector:
            run: iron-gallery
        ports:
            - protocol: TCP
            port: 80
            targetPort: 80
            nodePort: 32678
        type: NodePort

# Task 64: Fix Python App Deployed on Kubernetes Cluster
  # Requirement:
        One of the DevOps engineers was trying to deploy a python app on Kubernetes cluster. Unfortunately, due to some mis-configuration, the application is not coming up. Please take a look into it and fix the issues. Application should be accessible on the specified nodePort.

            The deployment name is python-deployment-xfusion, its using poroko/flask-demo-appimage. The deployment and service of this app is already deployed.

            nodePort should be 32345 and targetPort should be python flask app's default port.

            Note: The kubectl on jump_host has been configured to work with the kubernetes cluster.

  # Solution:

        Issue- 1 : We can see POD creation is failed with below error and found that in deployment image name wrongly updated
        thor@jumphost ~$ kubectl get deployment
        NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
        python-deployment-xfusion   0/1     1            0           5m43s
        thor@jumphost ~$ kubectl edit python-deployment-xfusion
        error: the server doesn't have a resource type "python-deployment-xfusion"
        thor@jumphost ~$ kubectl edit deployment python-deployment-xfusion
        Edit cancelled, no changes made.
        thor@jumphost ~$ kubectl get pods
        NAME                                         READY   STATUS             RESTARTS   AGE
        python-deployment-xfusion-5dcd4fff84-vhptx   0/1     ImagePullBackOff   0          13m
        thor@jumphost ~$ kubectl logs python-deployment-xfusion-5dcd4fff84-vhptx 
        Error from server (BadRequest): container "python-container-xfusion" in pod "python-deployment-xfusion-5dcd4fff84-vhptx" is waiting to start: trying and failing to pull image
        thor@jumphost ~$ 
        # So updated the correct image name in deployment file and deployement deployed the POD as expected

        thor@jumphost ~$ kubectl edit deployment python-deployment-xfusion
        deployment.apps/python-deployment-xfusion edited
        thor@jumphost ~$ kubectl get deployment
        NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
        python-deployment-xfusion   0/1     1            0           14m
        thor@jumphost ~$ kubectl get deployment
        NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
        python-deployment-xfusion   0/1     1            0           14m
        thor@jumphost ~$ kubectl get pods
        NAME                                         READY   STATUS    RESTARTS   AGE
        python-deployment-xfusion-74f98d699b-vm7r9   1/1     Running   0          17s
        thor@jumphost ~$ kubectl get deployment
        NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
        python-deployment-xfusion   1/1     1            1           14m
        thor@jumphost ~$ kubectl get pods
        NAME                                         READY   STATUS    RESTARTS   AGE
        python-deployment-xfusion-74f98d699b-vm7r9   1/1     Running   0          23s
        thor@jumphost ~$ 
        
        Issue -2: Having issue in service port and target port is not configured with python flask default port
        thor@jumphost ~$ kubectl get svc
        NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
        kubernetes               ClusterIP   10.96.0.1      <none>        443/TCP          5m24s
        python-service-xfusion   NodePort    10.96.172.67   <none>        8080:32345/TCP   75s
         # So updated the port and target port to 5000 in service 

        thor@jumphost ~$ kubectl edit svc python-service-xfusion
        service/python-service-xfusion edited
        thor@jumphost ~$ kubectl get svc
        NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
        kubernetes               ClusterIP   10.96.0.1      <none>        443/TCP          11m
        python-service-xfusion   NodePort    10.96.172.67   <none>        5000:32345/TCP   7m18s

# Task 65: Deploy Redis Deployment on Kubernetes
 # Requirement:
        The Nautilus application development team observed some performance issues with one of the application that is deployed in Kubernetes cluster. After looking into number of factors, the team has suggested to use some in-memory caching utility for DB service. After number of discussions, they have decided to use Redis. Initially they would like to deploy Redis on kubernetes cluster for testing and later they will move it to production. Please find below more details about the task:
        Create a redis deployment with following parameters:

        Create a config map called my-redis-config having maxmemory 2mb in redis-config.

        Name of the deployment should be redis-deployment, it should use
        redis:alpine image and container name should be redis-container. Also make sure it has only 1 replica.

        The container should request for 1 CPU.
        Mount 2 volumes:
        a. An Empty directory volume called data at path /redis-master-data.

        b. A configmap volume called redis-config at path /redis-master.

        c. The container should expose the port 6379.

        Finally, redis-deployment should be in an up and running state.
        Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.


  # Solution:

        # Manifest file for ConfigMap creation
            apiVersion: v1
            kind: ConfigMap
            metadata:
            name: my-redis-config
            data:
            redis.conf: |
                maxmemory 2mb


        # Manifest file for redis deployment

            apiVersion: apps/v1
            kind: Deployment
            metadata:
            name: redis-deployment
            labels:
                app: redis
            spec:
            replicas: 1
            selector:
                matchLabels:
                app: redis
            template:
                metadata:
                labels:
                    app: redis
                spec:
                containers:
                    - name: redis-container
                    image: redis:alpine
                    ports:
                        - containerPort: 6379
                    resources:
                        requests:
                            cpu: "1"                
                    volumeMounts:
                        - name: data
                        mountPath: /redis-master-data
                        - name: redis-config
                        mountPath: /redis-master
                volumes:
                    - name: data
                    emptyDir: {}
                    - name: redis-config
                    configMap:
                        name: my-redis-config
       

        # applying the Manifest file and outcome are below 

        thor@jumphost ~$ kubectl apply -f redis-configmap.yaml 
        configmap/my-redis-config created
        thor@jumphost ~$ kubectl get configmaps
        NAME               DATA   AGE
        kube-root-ca.crt   1      12m
        my-redis-config    1      8s
        thor@jumphost ~$ kubectl describe configmap my-redis-config
        Name:         my-redis-config
        Namespace:    default
        Labels:       <none>
        Annotations:  <none>

        Data
        ====
        redis.conf:
        ----
        maxmemory 2mb


        BinaryData
        ====

        Events:  <none>
        thor@jumphost ~$ vi redis-deployment.yaml
        thor@jumphost ~$ kubectl apply -f redis-deployment.yaml 
        deployment.apps/redis-deployment created
        thor@jumphost ~$ kubectl get deployment
        NAME               READY   UP-TO-DATE   AVAILABLE   AGE
        redis-deployment   1/1     1            1           6s
        thor@jumphost ~$ kubectl get pods -A
        NAMESPACE            NAME                                              READY   STATUS    RESTARTS   AGE
        default              redis-deployment-68fbd4467-mj485                  1/1     Running   0          13s
        kube-system          coredns-5d78c9869d-brb62                          1/1     Running   0          13m
        kube-system          coredns-5d78c9869d-dnn5n                          1/1     Running   0          13m
        kube-system          etcd-kodekloud-control-plane                      1/1     Running   0          14m
        kube-system          kindnet-66dnn                                     1/1     Running   0          13m
        kube-system          kube-apiserver-kodekloud-control-plane            1/1     Running   0          14m
        kube-system          kube-controller-manager-kodekloud-control-plane   1/1     Running   0          14m
        kube-system          kube-proxy-k7x74                                  1/1     Running   0          13m
        kube-system          kube-scheduler-kodekloud-control-plane            1/1     Running   0          14m
        local-path-storage   local-path-provisioner-6bc4bddd6b-chzll           1/1     Running   0          13m
        thor@jumphost ~$ kubectl describe pod redis-deployment-68fbd4467-mj485
        Name:             redis-deployment-68fbd4467-mj485
        Namespace:        default
        Priority:         0
        Service Account:  default
        Node:             kodekloud-control-plane/172.17.0.2
        Start Time:       Wed, 04 Mar 2026 10:36:21 +0000
        Labels:           app=redis
                        pod-template-hash=68fbd4467
        Annotations:      <none>
        Status:           Running
        IP:               10.244.0.5
        IPs:
        IP:           10.244.0.5
        Controlled By:  ReplicaSet/redis-deployment-68fbd4467
        Containers:
        redis-container:
            Container ID:   containerd://e72299709e14fbe7ae0875838276652adc017b17c108f59635a856b4f1570cba
            Image:          redis:alpine
            Image ID:       docker.io/library/redis@sha256:2afba59292f25f5d1af200496db41bea2c6c816b059f57ae74703a50a03a27d0
            Port:           6379/TCP
            Host Port:      0/TCP
            State:          Running
            Started:      Wed, 04 Mar 2026 10:36:26 +0000
            Ready:          True
            Restart Count:  0
            Requests:
            cpu:        1
            Environment:  <none>
            Mounts:
            /redis-master from redis-config (rw)
            /redis-master-data from data (rw)
            /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-pmntq (ro)
        Conditions:
        Type              Status
        Initialized       True 
        Ready             True 
        ContainersReady   True 
        PodScheduled      True 
        Volumes:
        data:
            Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
            Medium:     
            SizeLimit:  <unset>
        redis-config:
            Type:      ConfigMap (a volume populated by a ConfigMap)
            Name:      my-redis-config
            Optional:  false
        kube-api-access-pmntq:
            Type:                    Projected (a volume that contains injected data from multiple sources)
            TokenExpirationSeconds:  3607
            ConfigMapName:           kube-root-ca.crt
            ConfigMapOptional:       <nil>
            DownwardAPI:             true
        QoS Class:                   Burstable
        Node-Selectors:              <none>
        Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                                    node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
        Events:
        Type    Reason     Age   From               Message
        ----    ------     ----  ----               -------
        Normal  Scheduled  36s   default-scheduler  Successfully assigned default/redis-deployment-68fbd4467-mj485 to kodekloud-control-plane
        Normal  Pulling    35s   kubelet            Pulling image "redis:alpine"
        Normal  Pulled     32s   kubelet            Successfully pulled image "redis:alpine" in 3.260561214s (3.260577577s including waiting)
        Normal  Created    32s   kubelet            Created container redis-container
        Normal  Started    31s   kubelet            Started container redis-container
        thor@jumphost ~$ _
  
                    


# Task 67: Deploy Guest Book App on Kubernetes
 # Requirement:
        The Nautilus Application development team has finished development of one of the applications and it is ready for deployment. It is a guestbook application that will be used to manage entries for guests/visitors. As per discussion with the DevOps team, they have finalized the infrastructure that will be deployed on Kubernetes cluster. Below you can find more details about it.


        BACK-END TIER

        Create a deployment named redis-master for Redis master.

        a.) Replicas count should be 1.

        b.) Container name should be master-redis-nautilus and it should use image redis.

        c.) Request resources as CPU should be 100m and Memory should be 100Mi.

        d.) Container port should be redis default port i.e 6379.

        Create a service named redis-master for Redis master. Port and targetPort should be Redis default port i.e 6379.

        Create another deployment named redis-slave for Redis slave.

        a.) Replicas count should be 2.

        b.) Container name should be slave-redis-nautilus and it should use gcr.io/google_samples/gb-redisslave:v3 image.

        c.) Requests resources as CPU should be 100m and Memory should be 100Mi.

        d.) Define an environment variable named GET_HOSTS_FROM and its value should be dns.

        e.) Container port should be Redis default port i.e 6379.

        Create another service named redis-slave. It should use Redis default port i.e 6379.

        FRONT END TIER

        Create a deployment named frontend.

        a.) Replicas count should be 3.

        b.) Container name should be php-redis-nautilus and it should use gcr.io/google-samples/gb-frontend@sha256:a908df8486ff66f2c4daa0d3d8a2fa09846a1fc8efd65649c0109695c7c5cbff image.

        c.) Request resources as CPU should be 100m and Memory should be 100Mi.

        d.) Define an environment variable named as GET_HOSTS_FROM and its value should be dns.

        e.) Container port should be 80.

        Create a service named frontend. Its type should be NodePort, port should be 80 and its nodePort should be 30009.

        Finally, you can check the guestbook app by clicking on App button.


        You can use any labels as per your choice.

        Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.
# Solution:
        # Manifest for the Guest Book App
        # This manifest creates the following Kubernetes resources:
        # - Deployment for the Redis master
        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: redis-master
        labels:
            app: redis
        spec:
        replicas: 1
        selector:
            matchLabels:
            app: redis
        template:
            metadata:
            labels:
                app: redis
            spec:
            containers:
                - name: master-redis-nautilus
                image: redis:alpine
                ports:
                    - containerPort: 6379
                resources:
                    requests:
                    memory: "100Mi"
                    cpu: "100m"
                    limits:
                    memory: "100Mi"
                    cpu: "100m"

        ---
        # Service for the Redis master
        apiVersion: v1
        kind: Service
        metadata:
        name: redis-master
        spec:
        selector:
            app: redis
        ports:
            - protocol: TCP 
            port: 6379
            targetPort: 6379   

        ---
        # Deployment for the Redis slave
        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: redis-slave
        labels:
            app: redis
        spec:
        replicas: 2
        selector:
            matchLabels:
            app: redis
        template:
            metadata:
            labels:
                app: redis
            spec:
            containers:
                - name: slave-redis-nautilus
                image: gcr.io/google_samples/gb-redisslave:v3
                ports:
                    - containerPort: 6379
                resources:
                    requests:
                    memory: "100Mi"
                    cpu: "100m"
                    limits:
                    memory: "100Mi"
                    cpu: "100m"     

        ---
        # Service for the Redis slave
        apiVersion: v1
        kind: Service
        metadata:
        name: redis-slave
        spec:
        selector:
            app: redis
        ports:
            - protocol: TCP 
            port: 6379
            targetPort: 6379  

        ---
        # Deployment for the Guest Book App frontend
        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: frontend
        labels:
            app: guestbook
        spec:
        replicas: 3
        selector:
            matchLabels:
            app: guestbook
        template:
            metadata:
            labels:
                app: guestbook
            spec:
            containers:
                - name: php-redis-nautilus
                image: gcr.io/google-samples/gb-frontend@sha256:a908df8486ff66f2c4daa0d3d8a2fa09846a1fc8efd65649c0109695c7c5cbff
                ports:
                    - containerPort: 80
                resources:
                    requests:
                    memory: "100Mi"
                    cpu: "100m"
                    limits:
                    memory: "100Mi"
                    cpu: "100m"
                env:
                    - name: GET_HOSTS_FROM
                    value: "dns"

        ---
        # Service for the Guest Book App frontend
        apiVersion: v1
        kind: Service
        metadata:
        name: frontend
        spec:
        selector:
            app: guestbook
        ports:
            - protocol: TCP
            port: 80
            targetPort: 80
            nodePort: 30009
        type: NodePort


        thor@jump-host ~$ vi Guestbook.yaml
        thor@jump-host ~$ vi Guestbook.yaml
        thor@jump-host ~$ kubectl apply -f Guestbook.yaml 
        service/redis-master created
        service/frontend created
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.matchesLabels", unknown field "spec.selector.app"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.matchesLabels", unknown field "spec.selector.app"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.ports", unknown field "metadata.selector"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.matchesLabels", unknown field "spec.selector.app", unknown field "spec.template.spec.containers[0].resources.env"
        thor@jump-host ~$ vi Guestbook.yaml 
        thor@jump-host ~$ kubectl apply -f Guestbook.yaml 
        service/redis-master unchanged
        service/frontend unchanged
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.matchesLabels"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.matchesLabels"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.ports", unknown field "metadata.selector"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.matchesLabels", unknown field "spec.template.spec.containers[0].resources.env"
        thor@jump-host ~$ vi Guestbook.yaml 
        thor@jump-host ~$ kubectl apply -f Guestbook.yaml 
        service/redis-master unchanged
        service/frontend unchanged
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.selector.matchesLabels"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.selector.matchesLabels"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.ports", unknown field "metadata.selector"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.selector.matchesLabels", unknown field "spec.template.spec.containers[0].resources.env"
        thor@jump-host ~$ vi Guestbook.yaml 

        [1]+  Stopped                 vim Guestbook.yaml
        thor@jump-host ~$ vi Guestbook.yaml 
        thor@jump-host ~$ kubectl apply -f Guestbook.yaml 
        service/redis-master unchanged
        service/frontend unchanged
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.selector.matchesLabels"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.selector.matchesLabels"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.ports", unknown field "metadata.selector"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.selector.matchesLabels", unknown field "spec.template.spec.containers[0].resources.env"
        thor@jump-host ~$ vi Guestbook.yaml 
        thor@jump-host ~$ kubectl apply -f Guestbook.yaml 
        deployment.apps/redis-master created
        service/redis-master unchanged
        deployment.apps/redis-slave created
        service/frontend unchanged
        Error from server (BadRequest): error when creating "Guestbook.yaml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.ports", unknown field "metadata.selector"
        Error from server (BadRequest): error when creating "Guestbook.yaml": Deployment in version "v1" cannot be handled as a Deployment: strict decoding error: unknown field "spec.template.spec.containers[0].resources.env"
        thor@jump-host ~$ vi Guestbook.yaml 
        thor@jump-host ~$ kubectl apply -f Guestbook.yaml 
        deployment.apps/redis-master unchanged
        service/redis-master unchanged
        deployment.apps/redis-slave unchanged
        deployment.apps/frontend created
        service/frontend unchanged
        Error from server (BadRequest): error when creating "Guestbook.yaml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.ports", unknown field "metadata.selector"
        thor@jump-host ~$ vi Guestbook.yaml 
        thor@jump-host ~$ kubectl apply -f Guestbook.yaml 
        deployment.apps/redis-master unchanged
        service/redis-master unchanged
        deployment.apps/redis-slave unchanged
        service/redis-slave created
        deployment.apps/frontend unchanged
        service/frontend unchanged
        thor@jump-host ~$ kubectl get deployment
        NAME           READY   UP-TO-DATE   AVAILABLE   AGE
        frontend       3/3     3            3           75s
        redis-master   1/1     1            1           5m4s
        redis-slave    2/2     2            2           5m4s
        thor@jump-host ~$ kubectl get pods
        NAME                           READY   STATUS    RESTARTS   AGE
        frontend-bb94884c7-2dbgx       1/1     Running   0          83s
        frontend-bb94884c7-8bgdp       1/1     Running   0          83s
        frontend-bb94884c7-9g8sc       1/1     Running   0          83s
        redis-master-c7bb7585c-vpcsx   1/1     Running   0          5m12s
        redis-slave-5658cf4c6-gl2dk    1/1     Running   0          5m12s
        redis-slave-5658cf4c6-hvw25    1/1     Running   0          5m12s
        thor@jump-host ~$ kubectl get rs
        NAME                     DESIRED   CURRENT   READY   AGE
        frontend-bb94884c7       3         3         3       89s
        redis-master-c7bb7585c   1         1         1       5m18s
        redis-slave-5658cf4c6    2         2         2       5m18s
        thor@jump-host ~$ kubectl get svc
        NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
        frontend       NodePort    10.43.223.76   <none>        80:30009/TCP   18m
        kubernetes     ClusterIP   10.43.0.1      <none>        443/TCP        45m
        redis-master   ClusterIP   10.43.168.4    <none>        6379/TCP       18m
        redis-slave    ClusterIP   10.43.94.145   <none>        6379/TCP       27s
        thor@jump-host ~$ 

# Task 68: Set Up Jenkins Server
  # Requirement:
        The DevOps team at xFusionCorp Industries is initiating the setup of CI/CD pipelines and has decided to utilize Jenkins as their server. Execute the task according to the provided requirements:

            1. Install Jenkins on the jenkins server using the yum utility only, and start its service.

            If you face a timeout issue while starting the Jenkins service, refer to this.
            2. Jenkin's admin user name should be theadmin, password should be Adm!n321, full name should be Kareem and email should be kareem@jenkins.stratos.xfusioncorp.com.

            Note:

            1. To access the jenkins server, connect from the jump host using the root user with the password S3curePass.

            2. After Jenkins server installation, click the Jenkins button on the top bar to access the Jenkins UI and follow on-screen instructions to create an admin user.
  # Solution:
        Setup the jenkins using the below installation guide:
            https://www.jenkins.io/doc/book/installing/linux/
            For troubleshooting guide if any issue post installtion
            https://www.jenkins.io/doc/book/system-administration/systemd-services/#starting-services