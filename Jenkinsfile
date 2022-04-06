pipeline {
  options {
    // skipDefaultCheckout(true)
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
            imagePullPolicy: IfNotPresent
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
    stage('bump container version') {
      steps {
        container('ubuntu') {
          sh "sh increment-version.sh"
        }
      }
    }
    stage('build container') {
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh '''
            /kaniko/executor --dockerfile `pwd`/Dockerfile \
                             --context `pwd` \
                             --destination=robinhoodis/jenkins:`cat VERSION` \
                             --destination=robinhoodis/jenkins:latest
            '''
          }
        }
      }
    }
    stage('commit container version') {
      steps {
        dir ( 'jenkins-container' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git add .'
          sh 'git tag `cat VERSION`'
          sh 'git commit -m "`cat VERSION`"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            sh '/usr/bin/git push origin main'
            sh '/usr/bin/git push origin `cat VERSION`'
          }
        }
      }
    }
    stage('commit chart') {
      steps {
        sh 'mkdir -p helm-charts-pipeline'
        dir ( 'helm-charts-pipeline' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/helm-charts-pipeline.git'
        }
        sh 'cp jenkins-container/VERSION helm-charts-pipeline/VERSION.container'
        dir ( 'helm-charts-pipeline' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git add .'
          sh 'git commit -m "`cat VERSION.container`"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            sh '/usr/bin/git push origin main'
          }
        }
      }
    }
  }
//  post {
//    always {
//      cleanWs(cleanWhenNotBuilt: false,
//            deleteDirs: true,
//            disableDeferredWipeout: true,
//            notFailBuild: true,
//            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
//                     [pattern: '.propsfile', type: 'EXCLUDE']])
//    }
//  }
}
