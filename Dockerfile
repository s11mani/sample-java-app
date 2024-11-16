FROM openjdk:17-alpine
EXPOSE 8080
WORKDIR /app
COPY ./target/petclinic.war petclinic.war
CMD [ "java", "-jar", "petclinic.war" ]