# ---
FROM --platform=amd64 maven:3.8.4-openjdk-11 as builder

ARG PETCLINIC_REPO=https://github.com/spring-projects/spring-petclinic.git
ARG PETCLINIC_COMMIT=a7439c74ea718c4f59fe6c7c643c4afe59d7e718
ENV PETCLINIC_DIR=/petclinic

RUN git clone "${PETCLINIC_REPO}" ${PETCLINIC_DIR} && \
    git --git-dir=${PETCLINIC_DIR}/.git reset --hard "${PETCLINIC_COMMIT}"

WORKDIR ${PETCLINIC_DIR}

RUN mvn package -DskipTests -Dmaven.artifact.threads=4
RUN mvn install:install-file -Dfile=target/spring-petclinic-2.6.0-SNAPSHOT.jar -DpomFile=pom.xml

COPY petclinic-ext /${PETCLINIC_DIR}-ext

RUN for lib in ${PETCLINIC_DIR}-ext/*; \
    do \
        cd $lib; \
        mvn package -DskipTests -Dmaven.artifact.threads=4; \
    done

# ---
FROM registry.access.redhat.com/ubi8/openjdk-11-runtime as runtime

ENV PETCLINIC_FEATURES=
ENV SPRING_PROFILES_ACTIVE=postgres

COPY --from=builder /petclinic/target/spring-petclinic-*.jar /tmp/petclinic.jar
COPY --from=builder /petclinic-ext/*/target/*.jar /tmp/

WORKDIR /tmp
RUN echo -e  \
    "#!/bin/sh\n" \
    "for feature in \$PETCLINIC_FEATURES; do ADDITIONAL_JARS+=\",file:/tmp/\${feature}-lib.jar\"; done\n" \
    "java -cp /tmp/petclinic.jar" \
    "-Dloader.debug=true" \
    "-Dloader.path=file:/tmp/cloudbindings-lib.jar\$ADDITIONAL_JARS" \
    "-Dorg.springframework.cloud.bindings.boot.enable=true" \
    "-Dloader.main=org.springframework.samples.petclinic.PetClinicApplication" \
    "org.springframework.boot.loader.PropertiesLauncher" \
    > run.sh; chmod 777 run.sh;

EXPOSE 8080

ENTRYPOINT [ "/tmp/run.sh" ]