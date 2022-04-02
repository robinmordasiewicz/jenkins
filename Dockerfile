FROM jenkins/jenkins:lts-jdk11
ENV JENKINS_VERSION 2.332.1-16
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
