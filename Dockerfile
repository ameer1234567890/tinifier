FROM alpine

ENV WORKDIR /tinifier
WORKDIR ${WORKDIR}
ADD . ${WORKDIR}/

VOLUME ${WORKDIR}/files \
       ${WORKDIR}/compressed

RUN mkdir -p ${WORKDIR}/files \
             ${WORKDIR}/compressed \
\
&& chmod +x ${WORKDIR}/tinifier.sh \
\
&& apk --update --no-cache add \
     coreutils \
     curl

CMD ["/tinifier/tinifier.sh"]
