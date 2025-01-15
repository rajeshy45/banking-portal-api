# Stage 1: Build the JAR file
FROM maven:latest AS build

# Set the working directory
WORKDIR /app

# Copy the pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port the application runs on
EXPOSE 8080

# Set environment variables
ENV SERVER_PORT=8080
ENV SPRING_DATASOURCE_URL=jdbc:h2:mem:bankingapp;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
ENV SPRING_DATASOURCE_USERNAME=sa
ENV SPRING_DATASOURCE_PASSWORD=password
ENV SPRING_DATASOURCE_DRIVER_CLASS_NAME=org.h2.Driver
ENV SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.H2Dialect
ENV SPRING_JPA_GENERATE_DDL=true
ENV SPRING_JPA_SHOW_SQL=false
ENV SPRING_JPA_HIBERNATE_DDL_AUTO=update
ENV SPRING_MAIN_ALLOW_CIRCULAR_REFERENCES=true
ENV SERVER_ERROR_INCLUDE_MESSAGE=always

# JWT
ENV JWT_SECRET=your-secret-key
ENV JWT_EXPIRATION=86400000
ENV JWT_HEADER=Authorization
ENV JWT_PREFIX=Bearer

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]