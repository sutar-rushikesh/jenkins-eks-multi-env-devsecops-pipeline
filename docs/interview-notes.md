# Interview Notes - Jenkins to EKS Multi-Environment Pipeline

## 60-second pitch

"I built a declarative Jenkins pipeline that takes a Spring Boot app from commit to running pods on Amazon EKS. It builds with Maven, runs SonarQube analysis, builds and pushes a Docker image to DockerHub, then deploys with kubectl to dev and test namespaces, pauses for a manual approval, and deploys to prod. Credentials sit in the Jenkins credential store, and the pipeline emails the result. Reviewing it against the original requirements, I identified what was missing - image scanning, parallel coverage stages, an 80% gate and webhook triggers - and documented how I would add each."

## Likely questions

**Why namespaces instead of separate clusters?**
Cheaper and simpler for a lab: one control plane, logical isolation, and per-namespace RBAC. In production, many teams isolate prod in its own cluster or account for blast-radius and compliance reasons.

**How does Jenkins authenticate to EKS?**
`aws eks update-kubeconfig` creates a kubeconfig that calls `aws eks get-token`; the IAM identity behind it must be authorised in the cluster (EKS access entries or the aws-auth ConfigMap). Best practice is to scope it to the three namespaces.

**How do you keep secrets out of the pipeline?**
`withCredentials` binds Jenkins credentials to environment variables for one step and masks them in logs. Docker login uses `--password-stdin`.

**How does the prod approval work, and what is the weakness in your version?**
The `input` step pauses the build. In my Jenkinsfile a separate `Proceed` build parameter also guards the stage, which means two confirmations and is easy to misuse. The cleaner design is `input` alone with a `submitter` and a `timeout`.

**What happens if the quality gate fails?**
As submitted, nothing stops the pipeline, because `mvn sonar:sonar` only uploads results. Adding `waitForQualityGate abortPipeline: true` makes a failed gate fail the build and trigger the failure email.

**How would you scan images?**
Add a Trivy stage after `docker build` and before `docker push` with `--exit-code 1 --severity CRITICAL`.

**Why is a fixed `:1` image tag a problem?**
`kubectl apply` sees an identical spec and does nothing, and rollbacks are impossible to reason about. Use `${BUILD_NUMBER}` or the Git SHA.

**How would you make it faster?**
Run unit tests and Sonar analysis in parallel, cache the Maven repository, use Docker layer caching, and trigger on webhooks rather than polling.

**How would you roll back a bad prod deploy?**
`kubectl rollout undo deployment/spring-boot-app -n prod`, which works best when each release has a unique image tag.

**How do you control cost?**
Delete the cluster after the lab (`eksctl delete cluster`), keep node counts at 1-2, use AWS Budgets alerts, and check for orphaned load balancers and volumes.
