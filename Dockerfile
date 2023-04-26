# Use the official Node.js base image
FROM node:14-alpine

# Set environment variables
ENV GHOST_VERSION 4.32.0
ENV GHOST_INSTALL /var/lib/ghost/install
ENV GHOST_CONTENT /var/lib/ghost/content

# Create a new user and set ownership
RUN addgroup -g 1001 -S ghostgroup && \
    adduser -u 1001 -D -S -G ghostgroup ghostuser && \
    mkdir -p $GHOST_CONTENT $GHOST_INSTALL && \
    chown -R ghostuser:ghostgroup /var/lib/ghost

# Install global dependencies, Ghost-CLI, and su-exec
RUN apk add --no-cache --virtual .build-deps \
    python3 \
    make \
    gcc \
    g++ \
    && npm install -g ghost-cli@1.17.3 \
    && apk del .build-deps \
    && apk add --no-cache su-exec

# Set the working directory
WORKDIR $GHOST_INSTALL

# Install Ghost and set proper permissions
RUN su-exec ghostuser ghost install $GHOST_VERSION --db sqlite3 --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL" \
    && chown -R ghostuser:ghostgroup /var/lib/ghost

# Expose the Ghost blog port
EXPOSE 2368

# Switch to the new user
USER ghostuser

# Start Ghost
CMD ["node", "current/index.js"]
