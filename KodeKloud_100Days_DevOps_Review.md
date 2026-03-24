# KodeKloud 100 Days DevOps Challenge Review

This document reviews the 84 tasks completed in the KodeKloud 100 Days DevOps Challenge. Tasks are segregated by tool/concept, with individual details for each task including achievements, enterprise-level benefits, best practices, and potential interview questions.

## Task Index (1–84)
- 1, 2, 3, 4, 5, 6, 7
- 11, 12, 13, 16, 17, 18, 19, 20, 21
- 23, 24, 25, 26, 27, 28
- 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
- 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67
- 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78
- 79, 80, 81, 82, 83, 84

> Note: Source task numbering in the provided file includes gaps (8-10, 14-15, 22, 29, 79-81), and “Day X” notation for 76-81 in source; this index maps all actual generated tasks from the review.

## 1. Linux System Administration Basics

### Task 1: Linux User Setup with Non-Interactive Shell
**What Was Achieved:** Configured user accounts to use non-interactive shells for security purposes.

**How It Helps in Enterprise Work Level:** Prevents unauthorized interactive access, enhancing server security in production environments.

**Best Practices:**
- Use non-interactive shells like /bin/false or /sbin/nologin for service accounts.
- Regularly audit user accounts and remove unused ones.
- Implement password policies and account expiry.

**Interview Questions:**
1. Why would you set a user's shell to /sbin/nologin?

### Task 2: Temporary User Setup with Expiry
**What Was Achieved:** Created user accounts with automatic expiry dates.

**How It Helps in Enterprise Work Level:** Ensures temporary access is automatically revoked, reducing security risks from forgotten accounts.

**Best Practices:**
- Set appropriate expiry dates based on access needs.
- Use useradd with --expiredate option.
- Monitor for expired accounts and clean them up.

**Interview Questions:**
1. How do you create a user account that expires after a certain date?

### Task 3: Secure Root SSH Access
**What Was Achieved:** Configured SSH to prevent direct root login.

**How It Helps in Enterprise Work Level:** Reduces attack surface by requiring users to login as regular users first, then escalate privileges.

**Best Practices:**
- Disable PermitRootLogin in sshd_config.
- Use sudo for privilege escalation.
- Implement multi-factor authentication.

**Interview Questions:**
1. Why is it a security risk to allow root SSH login?

### Task 4: Script Execution Permissions
**What Was Achieved:** Managed file permissions to allow script execution.

**How It Helps in Enterprise Work Level:** Enables automated script deployment and execution in CI/CD pipelines.

**Best Practices:**
- Use chmod +x only when necessary.
- Prefer user/group permissions over world permissions.
- Validate scripts before granting execute permissions.

**Interview Questions:**
1. What does chmod +x do to a file?

### Task 5: SElinux Installation and Configuration
**What Was Achieved:** Installed and configured SELinux for enhanced security.

**How It Helps in Enterprise Work Level:** Provides mandatory access control, protecting against privilege escalation attacks.

**Best Practices:**
- Start with permissive mode to audit before enforcing.
- Use semanage for custom policies.
- Regularly check SELinux logs for violations.

**Interview Questions:**
1. Explain the three modes of SELinux.

### Task 6: Create a Cron Job
**What Was Achieved:** Set up automated task scheduling using cron.

**How It Helps in Enterprise Work Level:** Automates routine maintenance, backups, and monitoring tasks.

**Best Practices:**
- Use absolute paths in cron commands.
- Redirect output to log files.
- Test cron jobs manually before scheduling.
- Use crontab -e for editing.

**Interview Questions:**
1. How would you schedule a script to run every 5 minutes?

### Task 7: Linux SSH Authentication
**What Was Achieved:** Set up SSH key-based passwordless authentication.

**How It Helps in Enterprise Work Level:** Improves security and automates remote operations.

**Best Practices:**
- Use ssh-keygen to generate keys with strong algorithms.
- Distribute public keys with ssh-copy-id.
- Disable passwordAuth after key setup for production.

**Interview Questions:**
1. How do you configure SSH key-based authentication?

## 2. Networking and Security

### Task 12: Linux Network Services
**What Was Achieved:** Troubleshot and fixed Apache service issues using network tools.

**How It Helps in Enterprise Work Level:** Develops skills for diagnosing network-related problems in production systems.

**Best Practices:**
- Use ss or netstat to check listening ports.
- Check service status with systemctl.
- Verify firewall rules with iptables.
- Use telnet or nc for connectivity testing.

**Interview Questions:**
1. How do you check if a port is open on a Linux server?

### Task 13: IPtables Installation And Configuration
**What Was Achieved:** Installed iptables and configured rules to restrict access.

**How It Helps in Enterprise Work Level:** Implements network-level security controls for server protection.

**Best Practices:**
- Save rules with iptables-save.
- Use iptables-restore for persistence.
- Implement default DROP policy.
- Document all rules with comments.

**Interview Questions:**
1. How do you allow traffic from a specific IP address in iptables?

## 3. Web Servers and Application Deployment

### Task 11: Install and Configure Tomcat Server
**What Was Achieved:** Deployed Tomcat server and configured it to run on port 6000.

**How It Helps in Enterprise Work Level:** Enables Java application deployment in enterprise environments.

**Best Practices:**
- Configure custom ports to avoid conflicts.
- Use systemctl for service management.
- Implement proper logging.
- Secure Tomcat with user authentication.

**Interview Questions:**
1. How do you change the default port in Tomcat?

### Task 16: Install and Configure Nginx as an LBR
**What Was Achieved:** Set up Nginx as a load balancer for multiple app servers.

**How It Helps in Enterprise Work Level:** Provides high availability and load distribution for web applications.

**Best Practices:**
- Use upstream blocks for backend servers.
- Implement health checks.
- Configure SSL termination.
- Monitor load balancer performance.

**Interview Questions:**
1. How does Nginx load balancing work?

### Task 18: Configure LAMP server
**What Was Achieved:** Set up Linux, Apache, MySQL, PHP stack.

**How It Helps in Enterprise Work Level:** Creates foundation for PHP-based web applications.

**Best Practices:**
- Use latest stable versions.
- Configure PHP-FPM for better performance.
- Implement database connection pooling.
- Secure Apache with proper configurations.

**Interview Questions:**
1. What are the components of a LAMP stack?

### Task 19: Install and Configure Web Application
**What Was Achieved:** Deployed static websites on Apache server.

**How It Helps in Enterprise Work Level:** Demonstrates web server configuration for content delivery.

**Best Practices:**
- Use virtual hosts for multiple sites.
- Implement proper directory permissions.
- Configure logging and access controls.
- Use SCP securely for file transfers.

**Interview Questions:**
1. How do you configure Apache virtual hosts?

### Task 20: Configure Nginx + PHP-FPM Using Unix Sock
**What Was Achieved:** Integrated Nginx with PHP-FPM using Unix sockets.

**How It Helps in Enterprise Work Level:** Optimizes PHP application performance and security.

**Best Practices:**
- Use Unix sockets for better performance.
- Configure proper permissions.
- Implement caching mechanisms.
- Monitor PHP-FPM processes.

**Interview Questions:**
1. What is the advantage of using Unix sockets over TCP for PHP-FPM?

### Task 36: Deploy Nginx Container on Application Server
**What Was Achieved:** Created and ran Nginx container with port mapping.

**How It Helps in Enterprise Work Level:** Introduces containerized web server deployment.

**Best Practices:**
- Use specific image tags.
- Map ports appropriately.
- Implement container resource limits.
- Use docker logs for troubleshooting.

**Interview Questions:**
1. How do you run a Docker container in detached mode?

### Task 41: Write a Docker File
**What Was Achieved:** Created Dockerfile for Apache server with custom port.

**How It Helps in Enterprise Work Level:** Enables custom container image creation for applications.

**Best Practices:**
- Use official base images.
- Minimize image layers.
- Expose only necessary ports.
- Use COPY instead of ADD when possible.

**Interview Questions:**
1. What is the difference between COPY and ADD in Dockerfile?

### Task 43: Docker Ports Mapping
**What Was Achieved:** Mapped container ports to host ports for Nginx.

**How It Helps in Enterprise Work Level:** Enables external access to containerized applications.

**Best Practices:**
- Avoid port conflicts.
- Use standard ports when possible.
- Document port mappings.
- Implement firewall rules for exposed ports.

**Interview Questions:**
1. How do you expose a container port to the host?

### Task 44: Write a Docker Compose File
**What Was Achieved:** Created multi-container setup with httpd and volume mounting.

**How It Helps in Enterprise Work Level:** Simplifies multi-service application deployment.

**Best Practices:**
- Use version specification.
- Define networks explicitly.
- Implement health checks.
- Use environment variables for configuration.

**Interview Questions:**
1. What is the purpose of Docker Compose?

### Task 45: Resolve Dockerfile Issues
**What Was Achieved:** Fixed Dockerfile syntax and configuration issues.

**How It Helps in Enterprise Work Level:** Develops troubleshooting skills for container builds.

**Best Practices:**
- Validate Dockerfile syntax.
- Use multi-stage builds.
- Optimize for security.
- Test builds incrementally.

**Interview Questions:**
1. How do you debug a failing Docker build?

### Task 46: Deploy an App on Docker Containers
**What Was Achieved:** Deployed PHP and MySQL containers with Docker Compose.

**How It Helps in Enterprise Work Level:** Demonstrates full-stack containerized application deployment.

**Best Practices:**
- Use persistent volumes for data.
- Implement proper networking.
- Configure environment variables securely.
- Monitor container health.

**Interview Questions:**
1. How do you connect containers in Docker Compose?

### Task 47: Docker Python App
**What Was Achieved:** Containerized Python Flask application.

**How It Helps in Enterprise Work Level:** Enables deployment of Python applications in containers.

**Best Practices:**
- Use requirements.txt for dependencies.
- Expose application ports.
- Implement proper CMD.
- Use multi-stage builds for optimization.

**Interview Questions:**
1. How do you containerize a Python application?

## 4. Databases

### Task 17: Install and Configure PostgreSQL
**What Was Achieved:** Set up PostgreSQL database with user and permissions.

**How It Helps in Enterprise Work Level:** Provides relational database management skills.

**Best Practices:**
- Use strong passwords.
- Grant minimal privileges.
- Implement backup strategies.
- Monitor database performance.

**Interview Questions:**
1. How do you create a new database user in PostgreSQL?

### Task 18: Configure LAMP server (MariaDB part)
**What Was Achieved:** Installed and configured MariaDB for web applications.

**How It Helps in Enterprise Work Level:** Supports data persistence for web apps.

**Best Practices:**
- Run mysql_secure_installation.
- Use separate database users.
- Implement connection limits.
- Regular backups.

**Interview Questions:**
1. How do you secure a MySQL installation?

## 5. Git Version Control

### Task 21: Set Up Git Repository on Storage Server
**What Was Achieved:** Created bare Git repository.

**How It Helps in Enterprise Work Level:** Enables centralized version control.

**Best Practices:**
- Use git init --bare for shared repos.
- Set proper permissions.
- Implement access controls.

**Interview Questions:**
1. What is a bare Git repository?

### Task 22: Clone Git Repository on Storage Server
**What Was Achieved:** Cloned existing repository.

**How It Helps in Enterprise Work Level:** Allows distributed development.

**Best Practices:**
- Use git clone with proper URLs.
- Set up remotes correctly.
- Initialize submodules if needed.

**Interview Questions:**
1. How do you clone a Git repository?

### Task 23: Fork a Git Repository
**What Was Achieved:** Forked repository via web UI.

**How It Helps in Enterprise Work Level:** Supports collaborative workflows.

**Best Practices:**
- Use forks for contribution workflows.
- Keep forks updated with upstream.
- Create pull requests for changes.

**Interview Questions:**
1. What is the difference between fork and clone?

### Task 24: Git Create Branches
**What Was Achieved:** Created new branch from master.

**How It Helps in Enterprise Work Level:** Enables feature development isolation.

**Best Practices:**
- Use descriptive branch names.
- Create branches from appropriate base.
- Regularly merge or rebase.

**Interview Questions:**
1. How do you create a new branch in Git?

### Task 25: Git Merge Branches
**What Was Achieved:** Merged feature branch into master.

**How It Helps in Enterprise Work Level:** Integrates developed features.

**Best Practices:**
- Test before merging.
- Use merge commits for visibility.
- Resolve conflicts carefully.

**Interview Questions:**
1. How do you merge a branch into master?

### Task 26: Git Manage Remotes
**What Was Achieved:** Added and managed remote repositories.

**How It Helps in Enterprise Work Level:** Supports multi-repository workflows.

**Best Practices:**
- Use descriptive remote names.
- Regularly fetch from remotes.
- Push to appropriate remotes.

**Interview Questions:**
1. How do you add a new remote in Git?

### Task 27: Git Revert Some Changes
**What Was Achieved:** Reverted latest commit.

**How It Helps in Enterprise Work Level:** Allows undoing mistakes safely.

**Best Practices:**
- Use revert instead of reset for shared repos.
- Communicate changes to team.
- Test after revert.

**Interview Questions:**
1. What is the difference between git revert and git reset?

### Task 28: Git Cherry Pick
**What Was Achieved:** Applied specific commit to another branch.

**How It Helps in Enterprise Work Level:** Allows selective change application.

**Best Practices:**
- Use for hotfixes.
- Ensure commit compatibility.
- Test after cherry-pick.

**Interview Questions:**
1. When would you use git cherry-pick?

### Task 29: Manage Git Pull Requests
**What Was Achieved:** Created and managed PRs via web UI.

**How It Helps in Enterprise Work Level:** Facilitates code review processes.

**Best Practices:**
- Write clear PR descriptions.
- Request reviews from appropriate team members.
- Address review feedback.

**Interview Questions:**
1. What is a pull request?

### Task 30: Git hard reset
**What Was Achieved:** Reset branch to specific commit.

**How It Helps in Enterprise Work Level:** Cleans up commit history.

**Best Practices:**
- Use --hard with caution.
- Force push only for personal repos.
- Communicate with team.

**Interview Questions:**
1. What does git reset --hard do?

### Task 31: Git Stash
**What Was Achieved:** Saved and restored uncommitted changes.

**How It Helps in Enterprise Work Level:** Allows context switching.

**Best Practices:**
- Use descriptive stash messages.
- Apply stashes when ready.
- Clean up old stashes.

**Interview Questions:**
1. How do you save uncommitted changes in Git?

### Task 32: Git Rebase
**What Was Achieved:** Rebased feature branch onto master.

**How It Helps in Enterprise Work Level:** Maintains clean commit history.

**Best Practices:**
- Use interactive rebase for cleanup.
- Avoid rebasing public branches.
- Communicate with team.

**Interview Questions:**
1. What is the difference between merge and rebase?

### Task 33: Resolve Git Merge Conflicts
**What Was Achieved:** Fixed merge conflicts manually.

**How It Helps in Enterprise Work Level:** Handles concurrent development issues.

**Best Practices:**
- Understand conflict causes.
- Edit files carefully.
- Test after resolution.

**Interview Questions:**
1. How do you resolve a merge conflict?

### Task 34: Git Hook
**What Was Achieved:** Created post-update hook for tagging.

**How It Helps in Enterprise Work Level:** Automates release processes.

**Best Practices:**
- Use appropriate hook types.
- Make hooks executable.
- Test hooks thoroughly.

**Interview Questions:**
1. What are Git hooks used for?

## 6. Docker Containerization (Additional)

### Task 35: Install Docker Packages and Start Docker Service
**What Was Achieved:** Installed Docker CE and started service.

**How It Helps in Enterprise Work Level:** Prepares for containerized deployments.

**Best Practices:**
- Install from official repositories.
- Enable and start service.
- Configure Docker daemon.

**Interview Questions:**
1. How do you install Docker on CentOS?

### Task 37: Copy File to Docker Container
**What Was Achieved:** Copied file from host to running container.

**How It Helps in Enterprise Work Level:** Enables data injection into containers.

**Best Practices:**
- Use docker cp for running containers.
- Prefer volumes for persistent data.
- Validate file integrity.

**Interview Questions:**
1. How do you copy files to a running Docker container?

### Task 38: Pull Docker Image
**What Was Achieved:** Downloaded and tagged Docker image.

**How It Helps in Enterprise Work Level:** Manages container images.

**Best Practices:**
- Use specific tags.
- Clean up unused images.
- Verify image sources.

**Interview Questions:**
1. How do you pull a Docker image?

### Task 39: Create a Docker Image From Container
**What Was Achieved:** Committed container changes to new image.

**How It Helps in Enterprise Work Level:** Creates custom images from modifications.

**Best Practices:**
- Use descriptive commit messages.
- Prefer Dockerfiles for reproducibility.
- Tag images appropriately.

**Interview Questions:**
1. When would you use docker commit?

### Task 40: Docker EXEC Operations
**What Was Achieved:** Executed commands in running container.

**How It Helps in Enterprise Work Level:** Enables container debugging and management.

**Best Practices:**
- Use -it for interactive sessions.
- Prefer docker exec over attaching.
- Limit command execution.

**Interview Questions:**
1. How do you run a command in a running container?

### Task 42: Create a Docker Network
**What Was Achieved:** Created custom bridge network.

**How It Helps in Enterprise Work Level:** Enables secure container communication.

**Best Practices:**
- Use bridge driver for isolation.
- Specify subnets carefully.
- Clean up unused networks.

**Interview Questions:**
1. What are Docker networks used for?

## 7. Kubernetes Orchestration

### Task 48: Deploy Pods in Kubernetes Cluster
**What Was Achieved:** Created pod with nginx container.

**How It Helps in Enterprise Work Level:** Introduces Kubernetes pod management.

**Best Practices:**
- Use labels for organization.
- Specify resource limits.
- Use appropriate image tags.

**Interview Questions:**
1. What is a Kubernetes pod?

### Task 49: Deploy Applications with Kubernetes Deployments
**What Was Achieved:** Created deployment for httpd.

**How It Helps in Enterprise Work Level:** Enables scalable application deployment.

**Best Practices:**
- Define replicas appropriately.
- Use selectors correctly.
- Implement rolling updates.

**Interview Questions:**
1. What is a Kubernetes deployment?

### Task 50: Set Resource Limits in Kubernetes Pods
**What Was Achieved:** Configured CPU and memory limits.

**How It Helps in Enterprise Work Level:** Prevents resource exhaustion.

**Best Practices:**
- Set realistic limits.
- Monitor resource usage.
- Adjust based on application needs.

**Interview Questions:**
1. Why are resource limits important in Kubernetes?

### Task 51: Execute Rolling Updates in Kubernetes
**What Was Achieved:** Updated deployment image with rolling update.

**How It Helps in Enterprise Work Level:** Enables zero-downtime deployments.

**Best Practices:**
- Test updates in staging.
- Monitor rollout progress.
- Have rollback plan ready.

**Interview Questions:**
1. How do rolling updates work in Kubernetes?

### Task 52: Revert Deployment to Previous Version in Kubernetes
**What Was Achieved:** Rolled back deployment to previous revision.

**How It Helps in Enterprise Work Level:** Allows quick recovery from issues.

**Best Practices:**
- Use rollout history.
- Test before promoting.
- Document rollback procedures.

**Interview Questions:**
1. How do you rollback a deployment in Kubernetes?

### Task 53: Resolve VolumeMounts Issue in Kubernetes
**What Was Achieved:** Fixed volume mounting in multi-container pod.

**How It Helps in Enterprise Work Level:** Enables data sharing between containers.

**Best Practices:**
- Use appropriate volume types.
- Set correct mount paths.
- Ensure permission compatibility.

**Interview Questions:**
1. How do volumes work in Kubernetes?

### Task 54: Kubernetes Shared Volumes
**What Was Achieved:** Created pod with shared emptyDir volume.

**How It Helps in Enterprise Work Level:** Allows inter-container communication.

**Best Practices:**
- Choose volume type based on needs.
- Set appropriate access modes.
- Clean up when done.

**Interview Questions:**
1. What is an emptyDir volume in Kubernetes?

### Task 55: Kubernetes Sidecar Containers
**What Was Achieved:** Deployed sidecar for log shipping.

**How It Helps in Enterprise Work Level:** Implements separation of concerns.

**Best Practices:**
- Use for cross-cutting concerns.
- Ensure resource allocation.
- Monitor sidecar health.

**Interview Questions:**
1. What is a sidecar container pattern?

### Task 56: Deploy Nginx Web Server on Kubernetes Cluster
**What Was Achieved:** Created deployment and NodePort service.

**How It Helps in Enterprise Work Level:** Exposes applications externally.

**Best Practices:**
- Use appropriate service types.
- Configure selectors correctly.
- Implement load balancing.

**Interview Questions:**
1. What is a NodePort service in Kubernetes?

### Task 57: Print Environment Variables
**What Was Achieved:** Configured pod with environment variables.

**How It Helps in Enterprise Work Level:** Enables configuration management.

**Best Practices:**
- Use ConfigMaps for non-sensitive data.
- Use Secrets for sensitive data.
- Reference variables properly.

**Interview Questions:**
1. How do you pass environment variables to a pod?

### Task 58: Deploy Grafana on Kubernetes Cluster
**What Was Achieved:** Created Grafana deployment and service.

**How It Helps in Enterprise Work Level:** Enables monitoring and visualization.

**Best Practices:**
- Use persistent volumes for data.
- Configure security properly.
- Implement resource limits.

**Interview Questions:**
1. How would you deploy a stateful application in Kubernetes?

## 7. Git Version Control

### Task 21: Set Up Git Repository on Storage Server
**What Was Achieved:** Initialized a bare Git repository on a storage server.

**How It Helps in Enterprise Work Level:** Enables centralized version control for team collaboration.

**Best Practices:**
- Use bare repositories for shared access.
- Set proper permissions.
- Implement backup strategies.

**Interview Questions:**
1. What is a bare Git repository?

### Task 23: Fork a Git Repository
**What Was Achieved:** Created a fork of an existing repository.

**How It Helps in Enterprise Work Level:** Allows independent development while maintaining upstream connection.

**Best Practices:**
- Keep forks updated with upstream.
- Use pull requests for contributions.
- Clean up unused forks.

**Interview Questions:**
1. What is the difference between fork and clone?

### Task 24: Git Create Branches
**What Was Achieved:** Created and managed Git branches.

**How It Helps in Enterprise Work Level:** Enables parallel development and feature isolation.

**Best Practices:**
- Use descriptive branch names.
- Delete merged branches.
- Implement branch protection rules.

**Interview Questions:**
1. How do you create a new branch in Git?

### Task 25: Git Merge Branches
**What Was Achieved:** Merged feature branches into main branch.

**How It Helps in Enterprise Work Level:** Integrates completed features into production code.

**Best Practices:**
- Test before merging.
- Use merge commits for visibility.
- Resolve conflicts carefully.

**Interview Questions:**
1. What is the difference between merge and rebase?

### Task 26: Git Manage Remotes
**What Was Achieved:** Configured and managed remote repositories.

**How It Helps in Enterprise Work Level:** Enables distributed collaboration across teams.

**Best Practices:**
- Use meaningful remote names.
- Regularly fetch updates.
- Verify remote URLs.

**Interview Questions:**
1. How do you add a remote repository?

### Task 27: Git Revert Some Changes
**What Was Achieved:** Reverted unwanted commits.

**How It Helps in Enterprise Work Level:** Allows undoing mistakes without losing history.

**Best Practices:**
- Use revert instead of reset for shared branches.
- Communicate changes to team.
- Test after revert.

**Interview Questions:**
1. What is the difference between revert and reset?

### Task 28: Git Cherry Pick
**What Was Achieved:** Applied specific commits to different branches.

**How It Helps in Enterprise Work Level:** Allows selective application of changes.

**Best Practices:**
- Use for hotfixes.
- Avoid on public branches.
- Check for dependencies.

**Interview Questions:**
1. When would you use git cherry-pick?

### Task 34: Git Hook
**What Was Achieved:** Implemented a post-update hook to create release tags.

**How It Helps in Enterprise Work Level:** Automates release management and tagging.

**Best Practices:**
- Test hooks before deployment.
- Use server-side hooks for consistency.
- Document hook logic.

**Interview Questions:**
1. What are Git hooks?

## 8. Docker Containerization

### Task 35: Install Docker Packages and Start Docker Service
**What Was Achieved:** Installed Docker CE and started the service.

**How It Helps in Enterprise Work Level:** Enables containerized application deployment.

**Best Practices:**
- Use official repositories.
- Configure Docker daemon properly.
- Implement security scanning.

**Interview Questions:**
1. How do you install Docker on CentOS?

### Task 36: Deploy Nginx Container on Application Server
**What Was Achieved:** Ran an Nginx container with Alpine tag.

**How It Helps in Enterprise Work Level:** Demonstrates basic container deployment.

**Best Practices:**
- Use specific image tags.
- Map ports appropriately.
- Implement health checks.

**Interview Questions:**
1. How do you run a Docker container?

### Task 37: Copy File to Docker Container
**What Was Achieved:** Copied a file from host to running container.

**How It Helps in Enterprise Work Level:** Enables data injection into containers.

**Best Practices:**
- Use volumes for persistent data.
- Avoid modifying running containers.
- Use COPY in Dockerfiles.

**Interview Questions:**
1. How do you copy files to/from Docker containers?

### Task 38: Pull Docker Image
**What Was Achieved:** Downloaded and retagged a Docker image.

**How It Helps in Enterprise Work Level:** Manages image distribution.

**Best Practices:**
- Use trusted registries.
- Implement image scanning.
- Clean up unused images.

**Interview Questions:**
1. How do you pull a Docker image?

### Task 39: Create a Docker Image From Container
**What Was Achieved:** Committed changes to create a new image.

**How It Helps in Enterprise Work Level:** Allows customization of base images.

**Best Practices:**
- Prefer Dockerfiles over commits.
- Document changes.
- Use version tags.

**Interview Questions:**
1. What is docker commit?

### Task 40: Docker EXEC Operations
**What Was Achieved:** Executed commands inside running containers.

**How It Helps in Enterprise Work Level:** Enables debugging and maintenance.

**Best Practices:**
- Use for troubleshooting only.
- Prefer declarative configurations.
- Document changes.

**Interview Questions:**
1. How do you execute commands in a running container?

### Task 41: Write a Docker File
**What Was Achieved:** Created a Dockerfile for Apache on Ubuntu.

**How It Helps in Enterprise Work Level:** Enables reproducible builds.

**Best Practices:**
- Use multi-stage builds.
- Minimize layer count.
- Use .dockerignore.

**Interview Questions:**
1. What is a Dockerfile?

### Task 42: Create a Docker Network
**What Was Achieved:** Created a custom bridge network.

**How It Helps in Enterprise Work Level:** Enables secure inter-container communication.

**Best Practices:**
- Use user-defined networks.
- Implement network policies.
- Monitor network traffic.

**Interview Questions:**
1. What are Docker networks?

### Task 43: Docker Ports Mapping
**What Was Achieved:** Mapped container ports to host ports.

**How It Helps in Enterprise Work Level:** Exposes services externally.

**Best Practices:**
- Use specific port ranges.
- Implement load balancers.
- Secure exposed ports.

**Interview Questions:**
1. How do you expose Docker container ports?

### Task 44: Write a Docker Compose File
**What Was Achieved:** Created a compose file for httpd with volume mount.

**How It Helps in Enterprise Work Level:** Simplifies multi-container deployments.

**Best Practices:**
- Use version 3+.
- Implement health checks.
- Use environment files.

**Interview Questions:**
1. What is Docker Compose?

### Task 45: Resolve Dockerfile Issues
**What Was Achieved:** Fixed Dockerfile syntax and path issues.

**How It Helps in Enterprise Work Level:** Improves build reliability.

**Best Practices:**
- Test builds locally.
- Use absolute paths.
- Validate syntax.

**Interview Questions:**
1. How do you debug Dockerfile build failures?

### Task 46: Deploy an App on Docker Containers
**What Was Achieved:** Deployed PHP and MariaDB with Docker Compose.

**How It Helps in Enterprise Work Level:** Demonstrates full-stack containerization.

**Best Practices:**
- Use secrets for passwords.
- Implement backups.
- Monitor resource usage.

**Interview Questions:**
1. How do you deploy a web application with Docker?

### Task 47: Docker Python App
**What Was Achieved:** Containerized a Python Flask app.

**How It Helps in Enterprise Work Level:** Enables microservices deployment.

**Best Practices:**
- Use virtual environments.
- Implement logging.
- Use multi-stage builds.

**Interview Questions:**
1. How do you containerize a Python application?

## 9. Kubernetes Orchestration

### Task 48: Deploy Pods in Kubernetes Cluster
**What Was Achieved:** Created a basic pod with nginx.

**How It Helps in Enterprise Work Level:** Introduces pod management.

**Best Practices:**
- Use labels and selectors.
- Implement resource limits.
- Use probes.

**Interview Questions:**
1. What is a Kubernetes pod?

### Task 49: Deploy Applications with Kubernetes Deployments
**What Was Achieved:** Created a deployment for httpd.

**How It Helps in Enterprise Work Level:** Enables scalable application deployment.

**Best Practices:**
- Use rolling updates.
- Implement readiness probes.
- Use anti-affinity.

**Interview Questions:**
1. What is a Kubernetes deployment?

### Task 50: Set Resource Limits in Kubernetes Pods
**What Was Achieved:** Configured CPU and memory limits.

**How It Helps in Enterprise Work Level:** Prevents resource exhaustion.

**Best Practices:**
- Set appropriate limits.
- Monitor usage.
- Use quotas.

**Interview Questions:**
1. How do you set resource limits in Kubernetes?

### Task 51: Execute Rolling Updates in Kubernetes
**What Was Achieved:** Updated deployment image with rolling update.

**How It Helps in Enterprise Work Level:** Enables zero-downtime deployments.

**Best Practices:**
- Test updates in staging.
- Use canary deployments.
- Implement rollbacks.

**Interview Questions:**
1. How do rolling updates work in Kubernetes?

### Task 52: Revert Deployment to Previous Version in Kubernetes
**What Was Achieved:** Rolled back to previous deployment revision.

**How It Helps in Enterprise Work Level:** Allows quick recovery from issues.

**Best Practices:**
- Keep revision history.
- Test rollbacks.
- Communicate changes.

**Interview Questions:**
1. How do you rollback a deployment in Kubernetes?

### Task 53: Resolve VolumeMounts Issue in Kubernetes
**What Was Achieved:** Fixed volume mounting in multi-container pod.

**How It Helps in Enterprise Work Level:** Ensures proper data sharing.

**Best Practices:**
- Use ConfigMaps for configs.
- Implement persistent volumes.
- Test volume mounts.

**Interview Questions:**
1. How do volumes work in Kubernetes?

### Task 54: Kubernetes Shared Volumes
**What Was Achieved:** Created pod with shared emptyDir volume.

**How It Helps in Enterprise Work Level:** Enables inter-container communication.

**Best Practices:**
- Use appropriate volume types.
- Implement cleanup.
- Monitor disk usage.

**Interview Questions:**
1. What is an emptyDir volume?

### Task 55: Kubernetes Sidecar Containers
**What Was Achieved:** Deployed sidecar for log shipping.

**How It Helps in Enterprise Work Level:** Enables auxiliary services.

**Best Practices:**
- Use for cross-cutting concerns.
- Implement resource limits.
- Monitor sidecar health.

**Interview Questions:**
1. What is a sidecar container?

### Task 56: Deploy Nginx Web Server on Kubernetes Cluster
**What Was Achieved:** Created deployment and NodePort service.

**How It Helps in Enterprise Work Level:** Exposes services externally.

**Best Practices:**
- Use LoadBalancer for production.
- Implement ingress.
- Use network policies.

**Interview Questions:**
1. What is a NodePort service?

### Task 57: Print Environment Variables
**What Was Achieved:** Configured environment variables in pod.

**How It Helps in Enterprise Work Level:** Enables configuration injection.

**Best Practices:**
- Use ConfigMaps.
- Avoid hardcoding values.
- Use secrets for sensitive data.

**Interview Questions:**
1. How do you pass environment variables to pods?

### Task 59: Troubleshoot Deployment issues in Kubernetes
**What Was Achieved:** Fixed deployment configuration issues.

**How It Helps in Enterprise Work Level:** Develops debugging skills.

**Best Practices:**
- Check logs and events.
- Use describe and get commands.
- Validate YAML syntax.

**Interview Questions:**
1. How do you troubleshoot a failing pod?

### Task 60: Persistent Volumes in Kubernetes
**What Was Achieved:** Created PV, PVC, and pod with persistent storage.

**How It Helps in Enterprise Work Level:** Enables stateful applications.

**Best Practices:**
- Use appropriate storage classes.
- Implement backup strategies.
- Monitor storage usage.

**Interview Questions:**
1. What is the difference between PV and PVC?

### Task 61: Init Containers in Kubernetes
**What Was Achieved:** Used init container for setup tasks.

**How It Helps in Enterprise Work Level:** Enables pre-deployment setup.

**Best Practices:**
- Use for one-time setup.
- Keep init containers lightweight.
- Handle failures properly.

**Interview Questions:**
1. What are init containers?

### Task 62: Manage Secrets in Kubernetes
**What Was Achieved:** Created and mounted secrets.

**How It Helps in Enterprise Work Level:** Secures sensitive data.

**Best Practices:**
- Use encrypted secrets.
- Rotate regularly.
- Limit access.

**Interview Questions:**
1. How do you manage secrets in Kubernetes?

### Task 63: Deploy Iron Gallery App on Kubernetes
**What Was Achieved:** Deployed multi-tier application with services.

**How It Helps in Enterprise Work Level:** Demonstrates complex deployments.

**Best Practices:**
- Use namespaces.
- Implement health checks.
- Use ConfigMaps.

**Interview Questions:**
1. How do you deploy a database in Kubernetes?

### Task 64: Fix Python App Deployed on Kubernetes Cluster
**What Was Achieved:** Troubleshot and fixed deployment issues.

**How It Helps in Enterprise Work Level:** Improves operational skills.

**Best Practices:**
- Check service configurations.
- Validate image names.
- Use correct ports.

**Interview Questions:**
1. How do you debug service connectivity issues?

### Task 65: Deploy Redis Deployment on Kubernetes
**What Was Achieved:** Created Redis with ConfigMap and volumes.

**How It Helps in Enterprise Work Level:** Enables caching infrastructure.

**Best Practices:**
- Use ConfigMaps for configs.
- Implement persistence.
- Set resource limits.

**Interview Questions:**
1. How do you configure Redis in Kubernetes?

### Task 66: Deploy MySQL on Kubernetes
**What Was Achieved:** Deployed MySQL with secrets and persistent storage.

**How It Helps in Enterprise Work Level:** Enables database as a service.

**Best Practices:**
- Use secrets for credentials.
- Implement backups.
- Use StatefulSets for production.

**Interview Questions:**
1. How do you deploy a database in Kubernetes?

### Task 67: Deploy Guest Book App on Kubernetes
**What Was Achieved:** Deployed multi-component application.

**How It Helps in Enterprise Work Level:** Demonstrates microservices architecture.

**Best Practices:**
- Use multiple deployments.
- Implement services.
- Use labels properly.

**Interview Questions:**
1. How do you connect services in Kubernetes?

## 10. Jenkins CI/CD

### Task 68: Set Up Jenkins Server
**What Was Achieved:** Installed and configured Jenkins.

**How It Helps in Enterprise Work Level:** Enables automated pipelines.

**Best Practices:**
- Secure initial setup.
- Use latest LTS version.
- Implement backups.

**Interview Questions:**
1. How do you install Jenkins?

### Task 69: Install Jenkins Plugins
**What Was Achieved:** Installed Git and GitLab plugins.

**How It Helps in Enterprise Work Level:** Extends Jenkins functionality.

**Best Practices:**
- Install only needed plugins.
- Keep plugins updated.
- Test after installation.

**Interview Questions:**
1. How do you manage Jenkins plugins?

### Task 70: Configure Jenkins User Access
**What Was Achieved:** Set up user authentication and authorization.

**How It Helps in Enterprise Work Level:** Secures CI/CD pipelines.

**Best Practices:**
- Use role-based access.
- Implement least privilege.
- Regular access reviews.

**Interview Questions:**
1. How do you secure Jenkins?

### Task 71: Configure Jenkins Job for Package Installation
**What Was Achieved:** Created parameterized job for remote package installation.

**How It Helps in Enterprise Work Level:** Enables automated deployments.

**Best Practices:**
- Use parameters for flexibility.
- Implement error handling.
- Log execution details.

**Interview Questions:**
1. How do you create a parameterized Jenkins job?

### Task 72: Jenkins Parameterized Builds
**What Was Achieved:** Created job with string and choice parameters.

**How It Helps in Enterprise Work Level:** Enables dynamic builds.

**Best Practices:**
- Validate parameter inputs.
- Use default values.
- Document parameters.

**Interview Questions:**
1. What are Jenkins parameters?

### Task 73: Jenkins Scheduled Jobs
**What Was Achieved:** Configured cron-based job scheduling.

**How It Helps in Enterprise Work Level:** Automates routine tasks.

**Best Practices:**
- Use appropriate schedules.
- Monitor job execution.
- Handle failures.

**Interview Questions:**
1. How do you schedule Jenkins jobs?

### Task 74: Jenkins Database Backup Job
**What Was Achieved:** Automated database backups via Jenkins.

**How It Helps in Enterprise Work Level:** Ensures data protection.

**Best Practices:**
- Secure credentials.
- Test restore procedures.
- Monitor backup success.

**Interview Questions:**
1. How do you automate backups with Jenkins?

### Task 75: Jenkins Slave Nodes
**What Was Achieved:** Added SSH slave nodes to Jenkins.

**How It Helps in Enterprise Work Level:** Distributes build load.

**Best Practices:**
- Use dedicated build servers.
- Implement security.
- Monitor node health.

**Interview Questions:**
1. What are Jenkins agents?

### Task 76: Jenkins Project Security
**What Was Achieved:** Configured project-based security.

**How It Helps in Enterprise Work Level:** Enables fine-grained access control.

**Best Practices:**
- Use matrix authorization.
- Implement inheritance.
- Regular permission audits.

**Interview Questions:**
1. How do you configure Jenkins security?

### Task 77: Jenkins Deploy Pipeline
**What Was Achieved:** Created pipeline for web app deployment.

**How It Helps in Enterprise Work Level:** Enables automated deployments.

**Best Practices:**
- Use declarative pipelines.
- Implement stages.
- Add error handling.

**Interview Questions:**
1. What is a Jenkins pipeline?

### Task 78: Jenkins Conditional Pipeline
**What Was Achieved:** Added conditional logic to pipeline.

**How It Helps in Enterprise Work Level:** Enables dynamic deployments.

**Best Practices:**
- Use when conditions.
- Test all branches.
- Document logic.

**Interview Questions:**
1. How do you add conditions to Jenkins pipelines?

### Task 79: Jenkins Deployment Job
**What Was Achieved:** Created job triggered by Git pushes.

**How It Helps in Enterprise Work Level:** Enables continuous deployment.

**Best Practices:**
- Use webhooks.
- Implement testing.
- Add approval gates.

**Interview Questions:**
1. How do you implement CI/CD with Jenkins?

### Task 80: Jenkins Chained Builds
**What Was Achieved:** Created upstream/downstream job relationship.

**How It Helps in Enterprise Work Level:** Enables complex workflows.

**Best Practices:**
- Use build triggers.
- Implement dependencies.
- Monitor chain execution.

**Interview Questions:**
1. What are Jenkins upstream/downstream jobs?

### Task 81: Jenkins Multistage Pipeline
**What Was Achieved:** Created pipeline with Deploy and Test stages.

**How It Helps in Enterprise Work Level:** Enables comprehensive CI/CD.

**Best Practices:**
- Separate concerns.
- Add testing stages.
- Implement notifications.

**Interview Questions:**
1. How do you structure a Jenkins pipeline?

## 11. Ansible Automation

### Task 82: Create Ansible Inventory for App Server Testing
**What Was Achieved:** Created inventory file for Ansible.

**How It Helps in Enterprise Work Level:** Enables configuration management.

**Best Practices:**
- Use groups for organization.
- Implement dynamic inventory.
- Secure credentials.

**Interview Questions:**
1. What is an Ansible inventory?

### Task 83: Troubleshoot and Create Ansible Playbook
**What Was Achieved:** Created playbook to manage files.

**How It Helps in Enterprise Work Level:** Automates system configuration.

**Best Practices:**
- Use idempotent tasks.
- Implement error handling.
- Test playbooks.

**Interview Questions:**
1. What is an Ansible playbook?

### Task 84: Copy Data to App Servers using Ansible
**What Was Achieved:** Copied files to multiple servers.

**How It Helps in Enterprise Work Level:** Enables mass configuration.

**Best Practices:**
- Use copy module.
- Implement validation.
- Use variables.

**Interview Questions:**
1. How do you copy files with Ansible?

## Conclusion

This comprehensive review covers all 84 tasks from the KodeKloud 100 Days DevOps Challenge, organized by concept with individual task details. The hands-on experience gained provides a solid foundation for enterprise DevOps practices, from basic Linux administration to advanced Kubernetes orchestration.