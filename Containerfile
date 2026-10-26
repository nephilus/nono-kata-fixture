# Disposable amd64 qualification image, not an agent production image.
# Use a verified local nono binary as the build context's only supplied artifact.
FROM docker.io/library/busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662
COPY nono /usr/local/bin/nono
RUN mkdir -p /fixtures /state /work /tmp \
    && printf 'allowed fixture\n' > /fixtures/allowed \
    && printf 'restricted fixture\n' > /fixtures/restricted \
    && printf 'unrelated fixture\n' > /fixtures/unrelated \
    && chmod 0555 /usr/local/bin/nono \
    && chown 10001:10001 /state /work /tmp
USER 10001:10001
ENV HOME=/state XDG_STATE_HOME=/state XDG_CONFIG_HOME=/state
WORKDIR /work
ENTRYPOINT ["/usr/local/bin/nono"]
