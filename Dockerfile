FROM openjdk:17-alpine
EXPOSE 8094
WORKDIR /app
COPY ./target/java-17-maven-project-1.0-SNAPSHOT.jar app.jar
CMD [ "java", "-jar", "app.jar" ]
