FROM xonsh/xonsh:alpine

RUN apk add git

ADD watch_repo.xsh /opt/
WORKDIR /root

ENTRYPOINT ["/usr/bin/xonsh", "/opt/watch_repo.xsh"]
