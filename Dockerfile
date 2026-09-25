# =============================================
# Etapa 1: Build con Maven
# =============================================
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Descargar dependencias primero para aprovechar la cache de capas
COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests

# =============================================
# Etapa 2: Runtime con JRE
# =============================================
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Ejecutar como usuario sin privilegios
RUN addgroup -S spring && adduser -S spring -G spring

COPY --from=build /app/target/users-management-*.jar app.jar
RUN chown spring:spring app.jar
USER spring

EXPOSE 8080

ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0"

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
