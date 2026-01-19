FROM eclipse-temurin:21-jdk AS build
ARG SERVICE_NAME
WORKDIR /app

COPY ${SERVICE_NAME}/gradlew .
COPY ${SERVICE_NAME}/gradle gradle
COPY ${SERVICE_NAME}/build.gradle .
COPY ${SERVICE_NAME}/settings.gradle .
COPY ${SERVICE_NAME}/src src

RUN chmod +x gradlew
RUN ./gradlew bootJar --no-daemon

FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=build /app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
