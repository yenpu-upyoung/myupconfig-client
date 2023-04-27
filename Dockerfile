# Use the official maven/Java 11 image to create a build artifact.
# https://hub.docker.com/_/maven
FROM maven:3-openjdk-17-slim AS build-env

ARG PROFILE
ENV PROFILE $PROFILE

#ARG APM_SERVER
#ENV APM_SERVER $APM_SERVER

ARG APM_TOKEN
ENV APM_TOKEN $APM_TOKEN

# Set the working directory to /app
WORKDIR /app
# Copy the pom.xml file to download dependencies
COPY pom.xml ./
# Copy local code to the container image.
COPY src ./src

# Download dependencies and build a release artifact.
RUN mvn package -DskipTests

# Use OpenJDK for base image.
# https://hub.docker.com/_/openjdk
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM openjdk:17.0.2-slim

# Copy the jar to the production image from the builder stage.
COPY --from=build-env /app/target/myupconfig-*.jar /myupconfig.jar

# Copy the apm agent
COPY --from=docker.elastic.co/observability/apm-agent-java:latest /usr/agent/elastic-apm-agent.jar /elastic-apm-agent.jar

ARG APM_AGENT
ENV APM_AGENT -javaagent:/elastic-apm-agent.jar -Delastic.apm.service_name=config-client -Delastic.apm.secret_token=${APM_TOKEN} -Delastic.apm.server_url=${APM_SERVER} -Delastic.apm.environment=test -Delastic.apm.application_packages=com.example.myupconfigclient

RUN echo $APM_TOKEN
RUN echo ${APM_TOKEN}
RUN echo $PROFILE
RUN echo ${PROFILE}
RUN pwd
RUN ls -al
RUN echo $APM_AGENT

# Run the web service on container startup.
CMD ["java", "-Dspring.profiles.active=${PROFILE}", "-jar", "/myupconfig.jar"]
