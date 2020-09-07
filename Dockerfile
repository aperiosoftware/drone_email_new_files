FROM xonsh/xonsh:alpine

ADD watch_repo.xsh /bin/

RUN chmod +x /bin/watch_repo.xsh

ENTRYPOINT /bin/watch_repo.xsh
