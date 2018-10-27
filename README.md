# Cloudformation LAMP stack provisioner



## This is an example of provisioning a LAMP stack on AWS Cloud

## The example implements https://github.com/bazaarvoice/cloudformation-ruby-dsl/

## The LAMP Stack design:

#####  1. Multi-AZ ELB to serve HTTP traffic to
#####  2. WebServer Autoscaling Group with minimum of 2 Apache nodes connected to a
#####  3. Multi-AZ Amazon RDS database instance for storage.
#####  4. The LAMP stack is provisioned with Datadog SaaS Monitoring  https://www.datadoghq.com/
#####  5. In case you want to verify the Datadog implementation, send me a message, providing an email address, so I can add it to access the Datadog Dashboards

## To run the stack execute the following actions on your favourite Linux distro
##### 1. Install Cloudformation-Ruby-DSL: `gem install cloudformation-ruby-dsl`
##### 2. copy the `config` and `credentials` files to `~/.aws/config` and `~/.aws/credentials`
##### 3. Run `./cloudformation-lamp.rb create --stack-name lamp`date +%Y%m%d%H%M%S` --parameters "DBPassword=dbpassword123;InstanceType=t2.small;SSHLocation=${IP-ADDRESS}/0;VpcId=vpc-d967c3a3;Subnets=subnet-f91285d7,subnet-c0cf978a;KeyName=cfn-lamp-us-east-1;DBUser=db1"`
##### 4. The command will provision the application stack for ~10 minutes, due to the Multi-A/Z of the DB Instance and Webserver
##### 5. The DNS of the last provisioned LAMP Stack is: "http://lamp2-Appli-1991DW2TDASJA-733437319.us-east-1.elb.amazonaws.com"
##### 6. To access the Webserver nodes, you can use the pem key uploaded to the repository with: `ssh -i ${PATH-TO-PEM}.pem ec2-user@lamp2-Appli-1991DW2TDASJA-733437319.us-east-1.elb.amazonaws.com` and the public DNS of the second Webserver instance `ec2-52-90-95-101.compute-1.amazonaws.com`
