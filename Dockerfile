FROM igormaka/swift-libpostal
RUN apt-get install libsqlite3-dev
CMD [ "bash" ]