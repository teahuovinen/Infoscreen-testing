FROM python:3.11.2-slim

## ENV ##

# Set Docker workdir
ENV DockerHOME=/home/app/webapp
# Prevent Python from writing .pyc files to the file system.
ENV PYTHONDONTWRITEBYTECODE 1
# Prevent Python from buffering the standard output and error streams.
ENV PYTHONUNBUFFERED 1

RUN mkdir -p $DockerHOME

WORKDIR $DockerHOME

COPY requirements.txt requirements.txt

# Update apt-get and install nginx, libpd-dev, dos2unix and libmagic1
RUN apt-get update \
    && apt-get install nginx -y \
    && apt-get -y install libpq-dev gcc \
    && apt-get install -y dos2unix \
    && apt-get install -y libmagic1

# Update PIP
RUN python -m pip install pip --upgrade

# Copy nginx configuration to overwrite nginx defaults
COPY ./src/nginx_default.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint.sh
COPY ./src/entrypoint.sh $DockerHome

# Link nginx logs to container stdout
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# Create venv and install rest of the depencies
RUN python -m venv /opt/venv && \
    /opt/venv/bin/python -m pip install pip --upgrade && \
    /opt/venv/bin/python -m pip install -r requirements.txt

COPY ./src/webapp $DockerHOME

# Make entrypoint.sh executable
RUN dos2unix entrypoint.sh && \
    chmod +x entrypoint.sh

# Execute entrypoint.sh file
CMD ["./entrypoint.sh"]
