FROM jenkins/jenkins:lts-jdk11
<<<<<<< HEAD
ENV JENKINS_VERSION 2.332.1-42
=======
ENV JENKINS_VERSION 2.332.1-42
>>>>>>> 5d7fbae81470ccd9fd961df87ee40fb0989480a9
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
#COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
