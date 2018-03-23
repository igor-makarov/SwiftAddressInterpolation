FROM igormaka/swift-libpostal
RUN apt-get install libsqlite3-dev
ENV INTERPOLATION_DATA_DIR /code/Tests/AddressInterpolation.Tests/
CMD [ "bash" ]