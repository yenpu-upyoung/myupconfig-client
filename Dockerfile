# Use the official maven/Java 11 image to create a build artifact.
# https://hub.docker.com/_/maven
FROM gradle:7.6.1-jdk17-alpine AS build-env

# Set the working directory to /app
WORKDIR /app
# Copy the pom.xml file to download dependencies
COPY build.gradle ./
# Copy local code to the container image.
COPY src ./src

# Download dependencies and build a release artifact.
RUN gradle build -x test

# Use OpenJDK for base image.
# https://hub.docker.com/_/openjdk
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM openjdk:17.0.2-slim

# Copy the jar to the production image from the builder stage.
COPY --from=build-env /app/build/libs/myupconfig-*.jar /myupconfig.jar

# Run the web service on container startup.
CMD ["java", "-jar", "/myupconfig.jar"]
