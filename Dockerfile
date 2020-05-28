FROM stedolan/jq AS jq
FROM alpine

RUN apk add bash openssl

COPY --from=jq /usr/local/bin/jq /usr/local/bin/jq
COPY jwt.sh .

ENTRYPOINT ["./jwt.sh"]
