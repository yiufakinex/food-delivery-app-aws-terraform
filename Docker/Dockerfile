# Use the latest version of the Amazon Linux base image
FROM amazonlinux:2 AS builder

# Set build arguments for repository information
ARG PERSONAL_ACCESS_TOKEN
ARG GITHUB_USERNAME
ARG FRONTEND_REPO
ARG BACKEND_REPO
ARG DOMAIN_NAME
ARG ENVIRONMENT

# Update packages and install development dependencies
RUN yum update -y && \
    yum install -y \
    git \
    wget \
    unzip \
    curl \
    make \
    gcc \
    openssl-devel \
    tar \
    nodejs \
    npm

# Clone repositories
WORKDIR /app
RUN git clone https://${PERSONAL_ACCESS_TOKEN}@github.com/${GITHUB_USERNAME}/${FRONTEND_REPO}.git frontend
RUN git clone https://${PERSONAL_ACCESS_TOKEN}@github.com/${GITHUB_USERNAME}/${BACKEND_REPO}.git backend

# Build frontend
WORKDIR /app/frontend
RUN npm install && \
    npm run build && \
    mkdir -p /app/dist && \
    cp -r build/* /app/dist/

# Clean up build tools to reduce image size
FROM amazonlinux:2

# Set labels for metadata
LABEL maintainer="Franklin <franklin@example.com>"
LABEL application="FoodDeliveryApp"
LABEL version="1.0"

# Set environment variables for runtime configuration
ENV APP_ENV=${ENVIRONMENT}
ENV DOMAIN_NAME=${DOMAIN_NAME}

# Update all installed packages to their latest versions
RUN yum update -y && \
    yum install -y \
    httpd \
    php \
    php-common \
    php-pear \
    php-cgi \
    php-curl \
    php-mbstring \
    php-gd \
    php-mysqlnd \
    php-gettext \
    php-json \
    php-xml \
    php-fpm \
    php-intl \
    php-zip \
    wget \
    unzip \
    mysql

# Install MySQL client
RUN wget https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm && \
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 && \
    yum localinstall mysql80-community-release-el7-3.noarch.rpm -y && \
    yum install mysql-community-client -y && \
    rm -f mysql80-community-release-el7-3.noarch.rpm

# Set up application directories
RUN mkdir -p /var/www/html/app

# Copy application files from builder stage
COPY --from=builder /app/dist /var/www/html/app/public
COPY --from=builder /app/backend /var/www/html/app

# Configure Apache
COPY apache-vhost.conf /etc/httpd/conf.d/app.conf

# Set proper ownership and permissions
RUN chmod -R 755 /var/www/html && \
    chown -R apache:apache /var/www/html

# Configure and prepare PHP application
WORKDIR /var/www/html/app

# Setup app environment file from template
COPY .env.template .env
RUN sed -i "s/APP_ENV=local/APP_ENV=${APP_ENV}/" .env && \
    sed -i "s/APP_URL=http:\/\/localhost/APP_URL=https:\/\/${DOMAIN_NAME}/" .env

# Install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Start Apache in foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]