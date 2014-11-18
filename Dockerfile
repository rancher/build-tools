FROM ubuntu:14.04.1
COPY ./scripts/bootstrap /scripts/bootstrap
RUN ./scripts/bootstrap
