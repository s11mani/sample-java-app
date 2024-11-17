# FROM openjdk:17-alpine
# EXPOSE 8080
# WORKDIR /app
# COPY ./target/petclinic.war petclinic.war
# CMD [ "java", "-jar", "petclinic.war" ]

FROM tomcat:9.0.80-jdk8-temurin
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN rm -rf /usr/local/tomcat/webapps/*
COPY ./target/petclinic.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]