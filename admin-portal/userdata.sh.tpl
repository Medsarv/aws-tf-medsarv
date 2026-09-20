#!/bin/bash
set -e

# ============================================================
# MedSarv Admin Portal - EC2 Bootstrap Script
# Environment: ${environment}
# Domain: ${domain}
# ============================================================

# Update system
dnf update -y

# Install Node.js 20, Nginx
dnf install -y nodejs20 npm nginx

# Install PM2
npm install -g pm2

# Create app directory
mkdir -p /opt/admin-portal/frontend/dist
mkdir -p /opt/admin-portal/backend
chown -R ec2-user:ec2-user /opt/admin-portal

# Backend .env (no secrets today - the demo login is hardcoded in the app)
cat > /opt/admin-portal/backend/.env << ENV
PORT=5000
NODE_ENV=${node_env}
ENV
chown ec2-user:ec2-user /opt/admin-portal/backend/.env
chmod 600 /opt/admin-portal/backend/.env

# Configure Nginx
cat > /etc/nginx/conf.d/admin-portal.conf << 'NGINX'
server {
    listen 80;
    server_name ${domain};

    # Frontend
    location / {
        root /opt/admin-portal/frontend/dist;
        try_files $uri $uri/ /index.html;

        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2?)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 90;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
NGINX

# Remove default nginx page
rm -f /etc/nginx/conf.d/default.conf

# Enable services
systemctl enable nginx
systemctl start nginx

echo "${environment} admin-portal ready for deployment" > /opt/admin-portal/status.txt
