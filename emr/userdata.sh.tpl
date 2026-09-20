#!/bin/bash
set -e

# ============================================================
# MedSarv - EC2 Bootstrap Script
# Environment: ${environment}
# Domain: ${domain}
# ============================================================

# Update system
dnf update -y

# Install Node.js 20, Nginx, Git
dnf install -y nodejs20 npm git nginx

# Install PM2
npm install -g pm2

# Create app directory
mkdir -p /opt/medrecord-pro/frontend/dist
mkdir -p /opt/medrecord-pro/backend
chown -R ec2-user:ec2-user /opt/medrecord-pro

# Fetch secrets from Secrets Manager via the instance role (no plaintext
# secrets in this script or in the EC2 console's "user data" field)
DB_PASS=$(aws secretsmanager get-secret-value --region ${region} --secret-id ${db_password_arn} --query SecretString --output text)
JWT_JSON=$(aws secretsmanager get-secret-value --region ${region} --secret-id ${jwt_secret_arn} --query SecretString --output text)
JWT_SECRET=$(echo "$JWT_JSON" | node -e "process.stdin.on('data',d=>process.stdout.write(JSON.parse(d).jwt_secret))")
JWT_REFRESH_SECRET=$(echo "$JWT_JSON" | node -e "process.stdin.on('data',d=>process.stdout.write(JSON.parse(d).jwt_refresh_secret))")

# Create backend .env
cat > /opt/medrecord-pro/backend/.env << ENV
DATABASE_URL="postgresql://${db_user}:$DB_PASS@${db_host}:5432/${db_name}"
JWT_SECRET="$JWT_SECRET"
JWT_REFRESH_SECRET="$JWT_REFRESH_SECRET"
PORT=4000
NODE_ENV=${node_env}
CORS_ORIGIN=${cors_origin}
ENV
chown ec2-user:ec2-user /opt/medrecord-pro/backend/.env
chmod 600 /opt/medrecord-pro/backend/.env

# Configure Nginx
cat > /etc/nginx/conf.d/medrecord.conf << 'NGINX'
server {
    listen 80;
    server_name ${domain};

    # Frontend
    location / {
        root /opt/medrecord-pro/frontend/dist;
        try_files $uri $uri/ /index.html;

        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2?)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:4000;
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

echo "${environment} environment ready for deployment" > /opt/medrecord-pro/status.txt
