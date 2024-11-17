FROM tomcat:10.1.14-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY ./target/petclinic.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]