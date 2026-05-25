# Submission — DevOps Engineer Assignment 
  
**Candidate name: Vaibhav J. Chaudhari**  
**Email: vaibhav.chaudhari33v@gmail.com**  
**Date submitted: 25-05-2026**  
**Hours spent (approximate): 9-10**  
  
## Deliverables checklist 
- [ ] Part A: Terraform code under /terraform applies cleanly on LocalStack 
- [ ] Part A: `terraform validate` and `terraform fmt -check` both pass 
- [ ] Part B: Janitor script runs in --dry-run mode and produces report.json 
- [ ] Part B: GitHub Actions workflow runs green on a fresh PR 
- [ ] Part B: --delete mode respects Protected=true tag 
- [ ] Part C: DESIGN.md is present and within 2 pages 
- [ ] Walkthrough video link below is accessible (unlisted is fine) 
  
## Walkthrough video 
Link (Loom / YouTube unlisted / Google Drive):  
Length: max 5 minutes 
  
## Sample report 
Path to a sample report.json produced by your script: /janitor/report.json

## Known limitations 
- LocalStack does not fully behave like real AWS services, so some infrastructure behaviour may differ from an actual AWS environment.

- EC2 AMIs are manually registered in LocalStack because LocalStack does not provide default AMIs like AWS.

- The Cost Janitor script currently uses static cost estimates instead of real AWS pricing APIs.

- The orphan detection logic is intentionally simplified and currently checks only the required resource types mentioned in the assignment.

- Terraform remote state management is not implemented; the project currently uses local state files.

- Security configurations are minimal because the assignment focuses mainly on infrastructure provisioning and automation workflows.
  
## AI usage disclosure 
During this assignment, I used both ChatGPT and Claude as learning and debugging assistants.

I mainly used **Claude** to plan the project structure and break the assignment into smaller, manageable tasks so I could stay organized and avoid missing requirements.

I used **ChatGPT** mostly for debugging, understanding LocalStack behaviour, structuring Markdown files, fixing grammatical mistakes, and creating helper scripts such as `janitor.sh` and the GitHub Actions workflow (`cost-janitor.yml`).

**One thing AI got wrong:** Initially, it suggested using a real AWS AMI ID directly inside LocalStack. LocalStack does not support real AWS AMIs by default, which caused Terraform to fail with an `InvalidAMIID.NotFound` error. After debugging and checking the LocalStack documentation, I manually registered a dummy AMI before running Terraform.

**What I wrote manually:** I intentionally wrote the Terraform networking structure and EC2 module configuration myself without relying heavily on AI-generated code. I wanted to properly understand Terraform modules, variable passing, outputs, and infrastructure organisation rather than just copying generated code. I also preferred referencing official Terraform documentation directly, since provider syntax and versions change frequently and AI-generated Terraform can introduce version compatibility issues.

While AI helped speed up debugging and scripting, I made sure to understand each command and script section before including it in the final solution.