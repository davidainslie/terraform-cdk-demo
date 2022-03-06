# Terraform Not CDK Demo

1. Create VPC

2. Create Internet Gateway

3. Create Custom Route Table

4. Create Subnet

5. Associate subnet with Route Table

6. Create Security Group to allow ports 22, 80, 443

7. Create a network interface with an IP in the subnet that was created in step 4

8. Assign an elastic IP to the network interface created in step 7

9. Create Ubuntu server and install/enable apache2
 
10. Outputs

```shell
terraform apply -var-file="secrets.tfvars"
```

where in our `secrets` we set e.g.
```terraform
aws-profile = "<profile name>"
s3-bucket = "<bucket name>"
```

When you are done, don't forget:
```shell
terraform destroy -var-file="secrets.tfvars"
```