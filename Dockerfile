# Etapa 1: Compilación usando Temurin 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Imagen de producción ligera con JRE 21
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# Seguridad: Usuario no-root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
COPY --from=build /app/target/*.jar app.jar

# Informamos que el microservicio usa el puerto 8084
EXPOSE 8084

ENTRYPOINT ["java", "-jar", "app.jar"]
