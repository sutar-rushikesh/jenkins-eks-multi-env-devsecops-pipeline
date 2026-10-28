# Closing the Gaps Against the Problem Statement

The submitted pipeline (`jenkins/Jenkinsfile`) is kept exactly as executed. This page shows how to close the gaps listed in the README requirement table. **These snippets were not executed in the original lab**; treat them as a tested-by-you starting point, not as evidence.

## 1. Trigger on every push (responsiveness)

- Add a GitHub webhook: repository Settings > Webhooks > `http://<jenkins-host>:8080/github-webhook/`, event: push.
- In the job, enable **GitHub hook trigger for GITScm polling**.
- For branch-per-environment (dev / qa / prod), use a **Multibranch Pipeline** and gate the deploy stages:

```groovy
stage('Deploy to Dev')  { when { branch 'dev' }  steps { /* kubectl apply ... --namespace=dev */ } }
stage('Deploy to Test') { when { branch 'qa' }   steps { /* kubectl apply ... --namespace=test */ } }
stage('Deploy to Prod') { when { branch 'main' } steps { /* approval, then apply to prod */ } }
```

## 2. Run tests/coverage and static analysis in parallel

```groovy
stage('Quality') {
  parallel {
    stage('Unit Tests and Coverage') {
      steps { sh 'mvn -B clean verify' }
      post  { always { junit 'target/surefire-reports/*.xml' } }
    }
    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarqube-server') {   // server name configured in Manage Jenkins > System
          sh 'mvn -B sonar:sonar'
        }
      }
    }
  }
}
```

## 3. Fail the pipeline when coverage is below 80%

Option A - enforce in Maven with JaCoCo (`pom.xml`):

```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.12</version>
  <executions>
    <execution><goals><goal>prepare-agent</goal></goals></execution>
    <execution>
      <id>report</id><phase>verify</phase><goals><goal>report</goal></goals>
    </execution>
    <execution>
      <id>check</id><phase>verify</phase><goals><goal>check</goal></goals>
      <configuration>
        <rules>
          <rule>
            <element>BUNDLE</element>
            <limits>
              <limit>
                <counter>LINE</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.80</minimum>
              </limit>
            </limits>
          </rule>
        </rules>
      </configuration>
    </execution>
  </executions>
</plugin>
```

`mvn verify` then fails below 80% line coverage, the `post { failure }` block sends the email and the pipeline stops.

Option B - enforce in SonarQube: add a quality-gate condition for coverage (80%) and critical issues, then wait for it in Jenkins:

```groovy
stage('Quality Gate') {
  steps {
    timeout(time: 5, unit: 'MINUTES') {
      waitForQualityGate abortPipeline: true
    }
  }
}
```

This needs a SonarQube webhook pointing to `http://<jenkins-host>:8080/sonarqube-webhook/`.

## 4. Scan the image for vulnerabilities before pushing

Place this between "Build a Docker Image" and "Push to DockerHub" (Trivy must be installed on the agent):

```groovy
stage('Image Vulnerability Scan') {
  steps {
    sh 'trivy image --exit-code 1 --severity CRITICAL --no-progress $IMAGE_NAME'
  }
}
```

A non-zero exit code on any CRITICAL finding fails the stage, stops the pipeline and triggers the failure email.

## 5. Use unique image tags

```groovy
environment {
  IMAGE_REPO = "nithishnithi/nithish"
  IMAGE_NAME = "${IMAGE_REPO}:${BUILD_NUMBER}"
}
// then, instead of a fixed tag in the manifest:
//   kubectl set image deployment/spring-boot-app spring-boot-app=$IMAGE_NAME --namespace=dev
```

## 6. Make the production approval unambiguous

The `input` step's parameter does not feed `params.Proceed`. Simplest fix: drop the build parameter and the `when` clause, and let the approval step be the gate.

```groovy
stage('Approval to Deploy to Prod') {
  steps {
    timeout(time: 30, unit: 'MINUTES') {
      input message: 'Approve deployment to Prod?', submitter: 'admin'
    }
  }
}
stage('Deploy to Prod') {
  steps {
    sh '''
      kubectl apply -f ${MANIFEST_PATH}/prod/deployment.yaml --namespace=prod
      kubectl rollout status deployment/spring-boot-app --namespace=prod
    '''
  }
}
```

## 7. Parameterise notifications

Replace the hard-coded address with an environment variable (`NOTIFY_TO`) or a job parameter, and include the failed stage and build URL in the body.
