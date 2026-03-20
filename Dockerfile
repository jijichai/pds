FROM ghcr.io/bluesky-social/pds:0.4 AS base

FROM node:20-alpine AS identity-build
RUN apk add --no-cache git
WORKDIR /tmp
RUN git clone https://github.com/jijichai/atproto-identity.git identity \
    && cd identity \
    && npm install \
    && npx tsc --build tsconfig.build.json

FROM base
COPY --from=identity-build /tmp/identity/ /tmp/identity-overlay/
RUN rm -rf /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/@atproto/identity/dist \
    && cp -r /tmp/identity-overlay/dist /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/@atproto/identity/dist \
    && cp -r /tmp/identity-overlay/node_modules/ethers /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/ethers \
    && cp -r /tmp/identity-overlay/node_modules/@adraffy /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/@adraffy \
    && cp -r /tmp/identity-overlay/node_modules/@noble /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/@noble \
    && cp -r /tmp/identity-overlay/node_modules/@types /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/@types \
    && cp -r /tmp/identity-overlay/node_modules/aes-js /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/aes-js \
    && cp -r /tmp/identity-overlay/node_modules/tslib /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/tslib \
    && cp -r /tmp/identity-overlay/node_modules/ws /app/node_modules/.pnpm/@atproto+identity@0.4.10/node_modules/ws \
    && rm -rf /tmp/identity-overlay
RUN sed -i 's|if (ctx.bskyAppView) {|if (ctx.bskyAppView \&\& !handle.endsWith(".eth")) {|' \
    /app/node_modules/.pnpm/@atproto+pds@0.4.204/node_modules/@atproto/pds/dist/api/com/atproto/identity/resolveHandle.js
