# Stage 1: Build the application
FROM maven:3.9.6-sapmachine-21 AS build

WORKDIR /home/app/


# Copy custom Maven settings
COPY settings.xml /root/.m2/settings.xml

COPY . /home/app/

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Create a lightweight runtime image
FROM openjdk:21-slim

# Copy the JAR file from the build stage
COPY --from=build /home/app/target/javaWeb-1.0-SNAPSHOT.jar /usr/local/lib/app.jar

# Expose the application port
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "/usr/local/lib/app.jar"]
