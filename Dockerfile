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

LABEL Autor='Alexander Dolgosheev'

WORKDIR /opt/app

ENTRYPOINT ["yarn", "react-start"]

COPY --from=builder /opt/build/ ./

ARG BUILD_ENV=production
ENV NODE_ENV $BUILD_ENV

ARG GIT_COMMIT
LABEL git-commit=$GIT_COMMIT
ENV GIT_COMMIT=$GIT_COMMIT

ARG BUILD_TAG
ENV BUILD_TAG=$BUILD_TAG
