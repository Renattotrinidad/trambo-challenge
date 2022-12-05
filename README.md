# Challenge Trambo

The project is part of the evaluation for the acceptance of the devops middle position.

To run the project follow the steps below.

1. run the terraform init command
2. run the terraform fmt command
3. run the terraform validate command
4. verify the work being done with the terraform plan command
5. if everything is correct run the terraform apply command

A vpc was created to which an application load balancer exposed to the internet was integrated, this balancer is "balancing" the workload to 3 availability zones where the fargate tasks are located, within an ECS, a security group to be able to handle secure traffic.

