FROM jenkins/jenkins:lts-jdk11
ENV JENKINS_VERSION 2.332.1-18
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
#COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
