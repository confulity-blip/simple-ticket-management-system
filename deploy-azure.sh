#!/bin/bash

# Azure VM Deployment Script
# This script deploys the ticket management system to an Azure VM

set -e  # Exit on error

echo "================================"
echo "Azure VM Deployment Script"
echo "================================"

# Variables (customize these)
VM_USER="azureuser"
VM_IP="${1:-YOUR_VM_IP}"  # Pass as first argument or set default
APP_DIR="/home/$VM_USER/ticket-system"

if [ "$VM_IP" == "YOUR_VM_IP" ]; then
    echo "Error: Please provide VM IP address"
    echo "Usage: ./deploy-azure.sh <VM_IP>"
    exit 1
fi

echo "Deploying to: $VM_USER@$VM_IP"

# Step 1: Build frontend locally
echo ""
echo "[1/6] Building frontend..."
cd frontend
npm install
npm run build
cd ..

# Step 2: Copy files to VM
echo ""
echo "[2/6] Copying files to VM..."
ssh $VM_USER@$VM_IP "mkdir -p $APP_DIR"

rsync -avz --exclude 'node_modules' \
           --exclude 'tmp' \
           --exclude 'log' \
           --exclude '.git' \
           --exclude 'frontend/node_modules' \
           --exclude 'vendor/bundle' \
           . $VM_USER@$VM_IP:$APP_DIR/

# Step 3: Set up environment on VM
echo ""
echo "[3/6] Setting up environment on VM..."
ssh $VM_USER@$VM_IP << 'ENDSSH'
cd ~/ticket-system

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.production.azure .env
    echo ""
    echo "⚠️  IMPORTANT: Edit ~/ticket-system/.env and set your passwords!"
    echo ""
fi
ENDSSH

# Step 4: Build and start containers
echo ""
echo "[4/6] Building Docker images..."
ssh $VM_USER@$VM_IP << 'ENDSSH'
cd ~/ticket-system
docker-compose -f docker-compose.production.yml build
ENDSSH

# Step 5: Run database migrations
echo ""
echo "[5/6] Running database migrations..."
ssh $VM_USER@$VM_IP << 'ENDSSH'
cd ~/ticket-system

# Start postgres first
docker-compose -f docker-compose.production.yml up -d postgres redis

# Wait for postgres to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Run migrations and seeds
docker-compose -f docker-compose.production.yml run --rm api bundle exec rake db:create db:migrate db:seed
ENDSSH

# Step 6: Start all services
echo ""
echo "[6/6] Starting all services..."
ssh $VM_USER@$VM_IP << 'ENDSSH'
cd ~/ticket-system
docker-compose -f docker-compose.production.yml up -d

# Show running containers
echo ""
echo "Running containers:"
docker-compose -f docker-compose.production.yml ps
ENDSSH

echo ""
echo "================================"
echo "✅ Deployment Complete!"
echo "================================"
echo ""
echo "Your application is now running at:"
echo "  http://$VM_IP"
echo ""
echo "API Backend:"
echo "  http://$VM_IP/api"
echo ""
echo "Useful commands on the VM:"
echo "  cd ~/ticket-system"
echo "  docker-compose -f docker-compose.production.yml ps      # View containers"
echo "  docker-compose -f docker-compose.production.yml logs -f  # View logs"
echo "  docker-compose -f docker-compose.production.yml restart  # Restart services"
echo "  docker-compose -f docker-compose.production.yml down     # Stop services"
echo ""
