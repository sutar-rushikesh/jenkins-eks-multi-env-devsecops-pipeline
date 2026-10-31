
## Problem Statement (original)

You have been asked to set up a multi-environment declarative/yaml based deployment pipeline for a web application running on Elastic Kubernetes Service (EKS). A company controls the code for an application in source code repository. Containerized the web application using Docker and captured vulnerabilities by image scanning before pushing to registry. The application needs to be deployed automatically to multiple EKS environments (dev, qa, prod etc.) whenever changes are made to the respective branch code. Changes occur frequently every day, so the pipeline must be as responsive as possible. Prod pipeline must wait for manual approval before deployment. You are expected to integrate various DevOps/DevSecOps tools to perform given activities - build management, test coverage, code coverage etc and execute code and test coverage stages in parallel manner. Also trigger notification if coverage is less than 80% or any critical observation found and terminate the pipeline.

## Overall Purpose 

- Automates build, test, code quality checks, Docker image creation, and deployment for a Spring Boot app.
- Deploys to Dev, Test, and Prod environments on AWS EKS (Kubernetes).
- Uses SonarQube for quality gates, DockerHub for image storage.
- Requires manual approval before deploying to Prod.
- Sends email notifications on success or failure.
