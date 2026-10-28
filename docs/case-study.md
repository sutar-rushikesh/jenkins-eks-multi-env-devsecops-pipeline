# Case Study 1 - Source Document

This page preserves the original case study so the repository stays traceable to its source.

## Problem Statement (original)

You have been asked to set up a multi-environment declarative/yaml based deployment pipeline for a web application running on Elastic Kubernetes Service (EKS). A company controls the code for an application in source code repository. Containerized the web application using Docker and captured vulnerabilities by image scanning before pushing to registry. The application needs to be deployed automatically to multiple EKS environments (dev, qa, prod etc.) whenever changes are made to the respective branch code. Changes occur frequently every day, so the pipeline must be as responsive as possible. Prod pipeline must wait for manual approval before deployment. You are expected to integrate various DevOps/DevSecOps tools to perform given activities - build management, test coverage, code coverage etc and execute code and test coverage stages in parallel manner. Also trigger notification if coverage is less than 80% or any critical observation found and terminate the pipeline.

## Overall Purpose (from the answer sheet)

- Automates build, test, code quality checks, Docker image creation, and deployment for a Spring Boot app.
- Deploys to Dev, Test, and Prod environments on AWS EKS (Kubernetes).
- Uses SonarQube for quality gates, DockerHub for image storage.
- Requires manual approval before deploying to Prod.
- Sends email notifications on success or failure.

## Differences Found Between the Source Files

The answer sheet (`case-1.txt` / `case1.docx`), the `Jenkinsfile` and the screenshots do not agree everywhere. This repository treats the **Jenkinsfile and screenshots as the executed solution** and the answer sheet as the narrative.

| Topic | Answer sheet | Jenkinsfile / screenshots | Used in this repo |
|---|---|---|---|
| Source repo URL | `.txt`: Basavaraja9164/spring-boot-app; `.docx`: Nithishkumar-Ptech/spring-boot-app (with a stray trailing `git`) | Nithishkumar-Ptech/spring-boot-app | Jenkinsfile |
| Image name | `.txt`: `dockerhub-username/spring-boot-app` (placeholder) | `nithishnithi/nithish:1` (DockerHub screenshot confirms) | Jenkinsfile |
| kubeconfig command | `eks update-kubeconfig ...` (missing `aws`) | n/a | `aws eks update-kubeconfig ...` |
| Stage order | Docker build/push before SonarQube | SonarQube before Docker build/push | Jenkinsfile |
| Email step | `emailext` | `mail` | Jenkinsfile |
| Registry password variable | `DOCKER_PASSWORD` | `DOCKER_PASS` | Jenkinsfile |
| Worker node type | `t2.medium` in the eksctl command | EC2 console shows `t3.medium` nodes | Both noted in README |
| Docker stage name | "Build Docker Image" | Stage View shows "Build and Push Docker Image"; Jenkinsfile says "Build a Docker Image" | Screenshot likely taken from an earlier revision |
