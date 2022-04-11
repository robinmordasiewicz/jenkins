pipeline {
  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: ubuntu
            image: robinhoodis/ubuntu:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            imagePullPolicy: IfNotPresent
            command:
            - /busybox/cat
            tty: true
            volumeMounts:
              - name: kaniko-secret
                mountPath: /kaniko/.docker
          restartPolicy: Never
          volumes:
            - name: kaniko-secret
              secret:
                secretName: regcred
                items:
                  - key: .dockerconfigjson
                    path: config.json
        '''
    }
  }
  stages {
    stage('INIT') {
      steps {
        def upstream_project = "${currentBuild.getBuildCauses()[0].upstreamProject}"
        echo "Build Caused by ${upstream_project}"
        cleanWs()
        checkout scm
      }
    }
    stage('Increment VERSION') {
      when {
        beforeAgent true
        anyOf {
          changeset "Dockerfile"
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'BuildUpstreamCause'
          triggeredBy cause: 'BuildUpstreamCause'
          triggeredBy cause: 'UpstreamCause'
          triggeredBy cause: 'upstreamBuilds'
        }
      }
      steps {
        sh 'echo "----------------------------------"'
        container('ubuntu') {
          sh 'sh increment-version.sh'
        }
      }
    }
    stage('Check repo for container') {
      when {
        beforeAgent true
        anyOf {
          changeset "VERSION"
          changeset "Dockerfile"
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'BuildUpstreamCause'
        }
      }
      steps {
        container('ubuntu') {
          sh 'skopeo inspect docker://docker.io/robinhoodis/ubuntu:`cat VERSION` > /dev/null || echo "create new container: `cat VERSION`" > BUILDNEWCONTAINER.txt'
        }
      }
    }
    stage('Build/Push Container') {
      when {
        beforeAgent true
        anyOf {
          changeset "VERSION"
          changeset "Dockerfile"
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'BuildUpstreamCause'
        }
      }
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh ''' 
            [ ! -f BUILDNEWCONTAINER.txt ] || \
            /kaniko/executor --dockerfile=Dockerfile \
                             --context=git://github.com/robinmordasiewicz/jenkins.git \
                             --destination=robinhoodis/jenkins:`cat VERSION` \
                             --destination=robinhoodis/jenkins:latest \
                             --cache=true
            '''
          }
        }
      }
    }
    stage('Commit new VERSION') {
      when {
        beforeAgent true
        anyOf {
          changeset "Dockerfile"
          triggeredBy cause: 'UserIdCause'
          triggeredBy 'BuildUpstreamCause'
        }
      }
      steps {
        sh 'git config user.email "robin@mordasiewicz.com"'
        sh 'git config user.name "Robin Mordasiewicz"'
        // sh 'git add -u'
        // sh 'git diff --quiet && git diff --staged --quiet || git commit -m "`cat VERSION`"'
        sh 'git add . && git diff --staged --quiet || git commit -m "`cat VERSION`"'
        withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
          // sh 'git diff --quiet && git diff --staged --quiet || git push origin HEAD:main'
          // sh 'git diff --quiet HEAD || git push origin HEAD:main'
          sh 'git push origin HEAD:main'
        }
      }
    }
  }
  post {
    always {
      cleanWs(cleanWhenNotBuilt: false,
            deleteDirs: true,
            disableDeferredWipeout: true,
            notFailBuild: true,
            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                       [pattern: '.propsfile', type: 'EXCLUDE']])
    }
  }
}
