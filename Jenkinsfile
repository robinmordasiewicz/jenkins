pipeline {
  options {
    disableConcurrentBuilds()
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
    stage('build container') {
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh '''
            /kaniko/executor --dockerfile `pwd`/Dockerfile \
                             --context `pwd` \
                             --destination=robinhoodis/jenkins:`cat VERSION` \
                             --destination=robinhoodis/jenkins:latest \
                             --cache=true
            '''
          }
        }
      }
    }
    stage('commit chart') {
      steps {
        sh 'mkdir -p helm-charts'
        dir ( 'helm-charts' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/helm-charts.git'
        }
        sh 'cp VERSION helm-charts/VERSION.container'
        dir ( 'helm-charts' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git add .'
          sh 'git diff --quiet && git diff --staged --quiet || git commit -am "Jenkins Container: `VERSION.container`"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
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
