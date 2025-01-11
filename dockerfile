FROM amazonlinux:2
RUN yum update -y && yum install -y java-17-amazon-corretto-devel shadow-utils tar gzip vi findutils wget curl
RUN mkdir -p /home/tomcat
RUN useradd -d /home/tomcat -s /bin/bash tomcat
WORKDIR /home/tomcat
ADD https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz /home/tomcat
RUN tar -zvxf apache-tomcat-10.1.34.tar.gz
COPY tomcat-users.xml /home/tomcat/apache-tomcat-10.1.34/conf/tomcat-users.xml
COPY context.xml /home/tomcat/apache-tomcat-10.1.34/webapps/manager/META-INF/context.xml
RUN mkdir -p /home/tomcat/apache-tomcat-10.1.34/webapps/backup
RUN if [ -f "/home/tomcat/apache-tomcat-10.1.34/webapps/SimpleWebApplication-*.war" ]; then \
      mv /home/tomcat/apache-tomcat-10.1.34/webapps/SimpleWebApplication-*.war /home/tomcat/apache-tomcat-10.1.34/webapps/backup/; \
    fi
ARG CACHEBUST=1
RUN LATEST_VERSION=$(curl -s -u admin:admin http://13.233.77.239:8081/repository/maven-snapshots/com/maven/SimpleWebApplication/1.0.0-SNAPSHOT/maven-metadata.xml \
      | grep -oPm1 "(?<=<value>)[^<]+") && \
    curl -u admin:admin -o /home/tomcat/apache-tomcat-10.1.34/webapps/SimpleWebApplication-${LATEST_VERSION}.war \
      http://13.233.77.239:8081/repository/maven-snapshots/com/maven/SimpleWebApplication/1.0.0-SNAPSHOT/SimpleWebApplication-${LATEST_VERSION}.war || echo "No new war filefound."


RUN chmod -R 777 /home/tomcat
RUN chown -R tomcat:tomcat /home/tomcat
USER tomcat
EXPOSE 8080
CMD ["/home/tomcat/apache-tomcat-10.1.34/bin/catalina.sh", "run"]
