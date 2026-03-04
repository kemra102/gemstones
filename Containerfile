# Set build args
ARG BASE_CONTAINER
ARG BUILD_SCRIPT

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files/$BUILD_SCRIPT /

# Base Image
FROM $BASE_CONTAINER

# the following RUN directive does all the things required to run "tourmaline.sh" as recommended.
ARG BUILD_SCRIPT
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/$BUILD_SCRIPT && \
    ostree container commit
