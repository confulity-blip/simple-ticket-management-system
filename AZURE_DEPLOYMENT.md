# Azure VM Deployment Guide

This guide walks you through deploying the Ticket Management System to an Azure VM using Docker.

## Prerequisites

- Azure subscription
- Azure CLI installed locally (`az` command)
- SSH key pair for authentication
- Docker knowledge (basic)

## Architecture

```
Azure VM (Ubuntu 22.04)
├── Docker & Docker Compose
├── PostgreSQL Container (port 5432)
├── Redis Container (port 6379)
├── Rails API Container (port 3000)
└── Nginx Container (ports 80, 443)
    ├── Serves Vue frontend (/)
    └── Proxies API requests (/api)
```

## Step-by-Step Deployment

### 1. Create Azure VM

#### Option A: Using Azure Portal (GUI)

1. Go to https://portal.azure.com
2. Click "Create a resource" → "Virtual Machine"
3. Configure:
   - **Subscription**: Your subscription
   - **Resource group**: Create new → `ticket-staging`
   - **VM name**: `ticket-staging-vm`
   - **Region**: Choose closest to you (e.g., East US)
   - **Image**: Ubuntu Server 22.04 LTS
   - **Size**: Standard_B2s (2 vCPU, 4GB RAM) minimum
   - **Authentication**: SSH public key
   - **Username**: `azureuser`
   - **SSH public key**: Paste your public key or generate new
4. **Networking** tab:
   - Allow ports: 22 (SSH), 80 (HTTP), 443 (HTTPS)
5. Click "Review + create" → "Create"

#### Option B: Using Azure CLI

```bash
# Login to Azure
az login

# Create resource group
az group create \
  --name ticket-staging \
  --location eastus

# Create VM
az vm create \
  --resource-group ticket-staging \
  --name ticket-staging-vm \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku Standard

# Open HTTP/HTTPS ports
az vm open-port --port 80 --resource-group ticket-staging --name ticket-staging-vm --priority 1001
az vm open-port --port 443 --resource-group ticket-staging --name ticket-staging-vm --priority 1002

# Get the public IP
az vm show -d -g ticket-staging -n ticket-staging-vm --query publicIps -o tsv
```

Save the public IP address - you'll need it!

### 2. Connect to VM and Install Docker

```bash
# SSH into your VM (replace with your VM's IP)
ssh azureuser@<YOUR_VM_IP>

# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (so you don't need sudo)
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again for group changes
exit
ssh azureuser@<YOUR_VM_IP>

# Verify installation
docker --version
docker-compose --version
```

### 3. Deploy Application (Automated)

From your **local machine**:

```bash
# Make deployment script executable (if not already)
chmod +x deploy-azure.sh

# Run deployment (replace with your VM IP)
./deploy-azure.sh <YOUR_VM_IP>
```

The script will:
1. Build the Vue frontend locally
2. Copy all files to the VM
3. Build Docker images on the VM
4. Set up the database
5. Start all services

### 4. Configure Environment Variables

On the **VM**, edit the environment file:

```bash
ssh azureuser@<YOUR_VM_IP>
cd ~/ticket-system
nano .env
```

Update these values:

```bash
# Set a strong PostgreSQL password
POSTGRES_PASSWORD=your_secure_password_here

# Generate a new secret (run: openssl rand -hex 64)
SECRET_KEY_BASE=your_generated_secret_here

# Set your VM's public IP or domain
FRONTEND_URL=http://<YOUR_VM_IP>
```

Save and exit (Ctrl+X, then Y, then Enter)

### 5. Restart Services

```bash
cd ~/ticket-system
docker-compose -f docker-compose.production.yml down
docker-compose -f docker-compose.production.yml up -d
```

### 6. Verify Deployment

Check if all containers are running:

```bash
docker-compose -f docker-compose.production.yml ps
```

You should see 4 containers:
- `ticket-postgres` (database)
- `ticket-redis` (cache)
- `ticket-api` (Rails backend)
- `ticket-nginx` (web server)

View logs:

```bash
# All services
docker-compose -f docker-compose.production.yml logs -f

# Specific service
docker-compose -f docker-compose.production.yml logs -f api
```

### 7. Access Your Application

Open your browser:

```
http://<YOUR_VM_IP>
```

Login with test credentials:
- **Email**: `admin@supportdesk.com`
- **Password**: `password123`

## Useful Commands

### On the VM

```bash
cd ~/ticket-system

# View running containers
docker-compose -f docker-compose.production.yml ps

# View logs
docker-compose -f docker-compose.production.yml logs -f

# Restart specific service
docker-compose -f docker-compose.production.yml restart api

# Stop all services
docker-compose -f docker-compose.production.yml down

# Start all services
docker-compose -f docker-compose.production.yml up -d

# Rebuild after code changes
docker-compose -f docker-compose.production.yml build
docker-compose -f docker-compose.production.yml up -d

# Run Rails console
docker-compose -f docker-compose.production.yml run --rm api bundle exec rails console

# Run database migrations
docker-compose -f docker-compose.production.yml run --rm api bundle exec rake db:migrate

# View database
docker-compose -f docker-compose.production.yml exec postgres psql -U postgres ticket_production
```

## Updating the Application

When you make code changes:

```bash
# From your local machine
./deploy-azure.sh <YOUR_VM_IP>

# On the VM
cd ~/ticket-system
docker-compose -f docker-compose.production.yml build
docker-compose -f docker-compose.production.yml up -d
```

## Setting Up SSL/HTTPS (Optional)

### Using Let's Encrypt (Free SSL)

1. **Point your domain to the VM IP**
   - Create an A record pointing to your VM's public IP

2. **Install Certbot on VM**:
   ```bash
   ssh azureuser@<YOUR_VM_IP>
   sudo apt-get install certbot
   ```

3. **Get SSL certificate**:
   ```bash
   sudo certbot certonly --standalone -d your-domain.com
   ```

4. **Copy certificates**:
   ```bash
   cd ~/ticket-system
   sudo mkdir -p nginx/ssl
   sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/cert.pem
   sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/key.pem
   sudo chown -R $USER:$USER nginx/ssl
   ```

5. **Update nginx.conf**:
   - Uncomment the HTTPS server block in `nginx/nginx.conf`
   - Replace `your-domain.com` with your actual domain

6. **Restart Nginx**:
   ```bash
   docker-compose -f docker-compose.production.yml restart nginx
   ```

## Troubleshooting

### Containers won't start

```bash
# Check logs
docker-compose -f docker-compose.production.yml logs

# Check if ports are in use
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :3000
```

### Database connection errors

```bash
# Check if PostgreSQL is running
docker-compose -f docker-compose.production.yml ps postgres

# Check database logs
docker-compose -f docker-compose.production.yml logs postgres

# Recreate database
docker-compose -f docker-compose.production.yml run --rm api bundle exec rake db:drop db:create db:migrate db:seed
```

### Frontend not loading

```bash
# Check if frontend was built
ls -la frontend/dist

# Rebuild frontend locally
cd frontend
npm run build
cd ..

# Redeploy
./deploy-azure.sh <YOUR_VM_IP>
```

### Can't access from browser

```bash
# Check if Nginx is running
docker-compose -f docker-compose.production.yml ps nginx

# Check Azure NSG (Network Security Group) rules
az network nsg rule list \
  --resource-group ticket-staging \
  --nsg-name ticket-staging-vmNSG \
  --output table
```

## Monitoring & Maintenance

### View Resource Usage

```bash
# Docker stats
docker stats

# Disk usage
df -h

# Memory usage
free -h
```

### Backup Database

```bash
# Create backup
docker-compose -f docker-compose.production.yml exec postgres pg_dump -U postgres ticket_production > backup_$(date +%Y%m%d).sql

# Restore backup
cat backup_20241019.sql | docker-compose -f docker-compose.production.yml exec -T postgres psql -U postgres ticket_production
```

### View Application Logs

```bash
# Rails logs
docker-compose -f docker-compose.production.yml logs -f api

# Nginx access logs
docker-compose -f docker-compose.production.yml exec nginx tail -f /var/log/nginx/access.log

# Nginx error logs
docker-compose -f docker-compose.production.yml exec nginx tail -f /var/log/nginx/error.log
```

## Cost Optimization

**Current setup (Standard_B2s)**:
- ~$30-40/month

**To reduce costs**:
- Use smaller VM: Standard_B1s (1 vCPU, 1GB RAM) - ~$10/month
  - ⚠️ Warning: May be slow with 1GB RAM
- Shut down VM when not in use (staging only)
- Use Azure free tier credits

**To shut down VM**:
```bash
az vm deallocate --resource-group ticket-staging --name ticket-staging-vm
```

**To start VM**:
```bash
az vm start --resource-group ticket-staging --name ticket-staging-vm
```

## Security Checklist

- [ ] Change default passwords in `.env`
- [ ] Set up firewall rules (only allow 22, 80, 443)
- [ ] Set up SSL/HTTPS for production
- [ ] Regular system updates (`sudo apt-get update && sudo apt-get upgrade`)
- [ ] Regular Docker image updates
- [ ] Enable automatic security updates
- [ ] Set up SSH key-only authentication (disable password)
- [ ] Consider Azure Firewall or NSG rules

## Next Steps

- Set up automated backups
- Configure monitoring (Azure Monitor or Datadog)
- Set up CI/CD pipeline (GitHub Actions)
- Configure log aggregation
- Set up alerts for downtime

## Support

If you encounter issues:
1. Check logs: `docker-compose -f docker-compose.production.yml logs`
2. Verify all containers are running: `docker-compose -f docker-compose.production.yml ps`
3. Check Azure VM status in portal
4. Review this guide's Troubleshooting section
