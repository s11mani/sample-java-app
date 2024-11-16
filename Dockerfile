FROM openjdk:17-alpine
EXPOSE 8080
WORKDIR /app
COPY ./target/sample-java-app-1.0-SNAPSHOT.jar app.jar
CMD [ "java", "-jar", "app.jar" ]