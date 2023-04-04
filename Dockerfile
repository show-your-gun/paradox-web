FROM node:gallium-bullseye-slim as builder

WORKDIR /opt/build

RUN apt-get update && apt-get install -y --no-install-recommends build-essential

# install dependencies
COPY package.json yarn.lock ./
RUN yarn --frozen-lockfile

# test and build app
COPY . .
RUN yarn react-build && yarn test --ci

# remove devDependencies for production builds
ARG BUILD_ENV=production
RUN if [ "$BUILD_ENV" = "production" ]; \
    then rm -rf node_modules && yarn --prod; \
    fi

FROM node:gallium-bullseye-slim

ENV PATH /opt/app/node_modules/.bin:$PATH

LABEL Author='Alexander Dolgosheev'

WORKDIR /opt/app

ENTRYPOINT ["yarn", "react-start"]

COPY --from=builder /opt/build/ ./

ARG BUILD_ENV=production
ENV NODE_ENV $BUILD_ENV

ARG SHA_COMMIT
LABEL sha-commit=$SHA_COMMIT
ENV SHA_COMMIT=$SHA_COMMIT

ARG VERSION_TAG
LABEL version-tag=$VERSION_TAG
ENV VERSION_TAG=$VERSION_TAG

ARG BRANCH_NAME
LABEL branch-name=$BRANCH_NAME
ENV BRANCH_NAME=$BRANCH_NAME
