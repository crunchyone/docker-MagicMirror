FROM node:12-buster

# Install system dependencies
RUN set -e; \
    apt update; \
    apt install -y gettext git; \
    rm -rf /var/lib/apt/lists/*

ARG branch=master

ENV NODE_ENV production
WORKDIR /opt/magic_mirror

# Clone MagicMirror repository
RUN git clone --depth 1 -b ${branch} https://github.com/MichMich/MagicMirror.git .

# Backup default modules and config
RUN cp -R modules /opt/default_modules
RUN cp -R config /opt/default_config

# Install MagicMirror dependencies
RUN npm install --unsafe-perm --silent

# Clone MMM-CalendarExt3 module into the modules folder
RUN git clone https://github.com/MA2cK/MMM-CalendarExt3.git /opt/magic_mirror/modules/MMM-CalendarExt3

# Install CalendarExt3 dependencies
WORKDIR /opt/magic_mirror/modules/MMM-CalendarExt3
RUN npm install --unsafe-perm --silent

# Return to the main MagicMirror directory
WORKDIR /opt/magic_mirror

# Copy the custom configuration and entrypoint script
COPY mm-docker-config.js docker-entrypoint.sh ./
RUN chmod +x ./docker-entrypoint.sh

# Expose the port MagicMirror runs on
EXPOSE 8282

# Entry point and command for the container
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["node", "serveronly"]
