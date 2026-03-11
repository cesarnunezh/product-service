@Library('devops-shared-lib@main') _

ciPipeline(
  serviceName: 'products-api',
  enableDeploy: true,
  dockerRepo: 'cesarnunezh/products-api',
  localImageName: 'products-api:ci-local',
  imageBuildCmd: 'make build',
  buildCmd: 'make setup',
  lintCmd: 'make lint',
  testCmd: 'make test',
  securityCmd: 'make scan',
  deployRepo: 'https://github.com/cesarnunezh/DevOpsProject.git'
)
