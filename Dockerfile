FROM debian
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates unzip rsync \
    && rm -rf /var/lib/apt/lists/*
COPY move.sh /move.sh
RUN chmod +x move.sh
RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
RUN unzip rclone-current-linux-amd64.zip
RUN cp rclone*/rclone /usr/bin/
RUN chown root:root /usr/bin/rclone
RUN rm -r rclone*
RUN chmod 755 /usr/bin/rclone

ENV bwlimit=9M
ENV hdpath=/data
ENV rclonemount=/gcrypt
ENV useragent="rclone/v1.48"
ENV vfs_dcs="128M"

ENV maxtransfer=750G
CMD /move.sh