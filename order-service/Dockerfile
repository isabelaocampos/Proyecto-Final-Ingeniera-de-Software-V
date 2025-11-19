# Usamos una imagen JRE Alpine ligera (Java 11)
FROM eclipse-temurin:11-jre-alpine

# Argumento para la versión, por defecto la del proyecto
ARG PROJECT_VERSION=0.1.0

# Crear usuario linux standard para seguridad (Best Practice)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

WORKDIR /home/app

# Copiamos el jar compilado.
# OJO: Esto asume que el nombre del jar es estándar. 
# Si falla, verifica el nombre en la carpeta target/ de cada servicio.
COPY target/*.jar app.jar

# Límites de memoria duros para que no se coma la RAM de tu compañera
ENV JAVA_OPTS="-Xmx256m -Xms256m -XX:+UseSerialGC"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -jar app.jar"]