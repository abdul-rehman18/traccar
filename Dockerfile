# Stage 1: Build the application using Gradle with JDK 17
FROM gradle:7.6.0-jdk17 AS build
WORKDIR /app
# Copy Gradle files and wrapper if available for consistency
COPY build.gradle settings.gradle gradlew gradlew.bat ./
COPY gradle ./gradle
# Copy the source code
COPY src ./src
# Build the project (skip tests if desired)
RUN ./gradlew build -x test

# Stage 2: Create the runtime image using OpenJDK 17
FROM openjdk:17-slim
WORKDIR /app
# Copy the built jar from the target directory (update the filename if needed)
COPY --from=build /app/target/tracker-server.jar ./tracker-server.jar
# Copy the dependencies folder if your jar relies on external libs
COPY --from=build /app/target/lib ./lib

COPY ./debug.xml /app/debug.xml

COPY ./schema /app/schema


# Ensure logs directory exists
RUN mkdir -p /app/logs


# Expose the port your application listens on (ensure this matches your app’s configuration)
EXPOSE 8083
# Run the application
CMD ["java", "-jar", "tracker-server.jar"]
