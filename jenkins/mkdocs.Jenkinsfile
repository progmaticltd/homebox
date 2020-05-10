pipeline {
   agent any

   stages {
      stage('Clone') {
         steps {
            // Get some code from a GitHub repository
            git 'https://github.com/progmaticltd/homebox.git'
         }
      }
      stage('Docs') {
         steps {
            sh 'mkdocs build'
         }
      }
   }
}
