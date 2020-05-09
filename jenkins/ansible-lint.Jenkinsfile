pipeline {
   agent any

   stages {
      stage('Clone') {
         steps {
            git 'https://github.com/progmaticltd/homebox.git'
         }
      }
      stage('Installation playbooks') {
         steps {
            sh 'ansible-lint install/playbooks/main.yml'
         }
      }
      stage('Testing playbooks') {
         steps {
            sh 'ansible-lint tests/playbooks/main.yml'
         }
      }
      stage('Uninstall playbooks') {
         steps {
            sh 'ansible-lint uninstall/playbooks/*.ml'
         }
      }
   }
}
