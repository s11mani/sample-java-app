FROM openjdk:17-alpine
EXPOSE 8080
WORKDIR /app
COPY ./target/spring-framework-petclinic-0.0.1-SNAPSHOT.jar app.jar
CMD [ "java", "-jar", "app.jar" ]