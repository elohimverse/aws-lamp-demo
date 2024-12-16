# Modernized LAMP Stack Deployment

#### Overview
This Ruby script generates an AWS CloudFormation template to deploy a modernized LAMP stack (Linux, Apache, MariaDB, PHP) adhering to AWS best practices. The deployment ensures security, reliability, and scalability using the AWS Well-Architected Framework.

#### Features
- **Secure by Design**: Limits access to trusted IP ranges.
- **Highly Available**: Multi-AZ database setup.
- **Cost Efficient**: Uses Graviton-based T4g instance types.
- **Modern OS**: Deploys on Amazon Linux 2023.
- **Automated Configuration**: Bootstraps LAMP stack at instance initialization.

#### Prerequisites
1. **VPC and Subnets**:
   - An existing VPC ID.
   - A list of subnet IDs within the VPC.
2. **Key Pair**:
   - A valid EC2 KeyPair for SSH access.
3. **Database Credentials**:
   - Secure values for `DBUsername` and `DBPassword`.
4. **Ruby Environment**:
   - Install Ruby and the `cloudformation-ruby-dsl` gem.

   ```bash
   gem install cloudformation-ruby-dsl
   ```

#### Parameters
- `VpcId`: ID of the existing Virtual Private Cloud (VPC).
- `SubnetIds`: List of subnet IDs within the VPC.
- `KeyPairName`: Name of an existing EC2 KeyPair for SSH access.
- `DBUsername`: Database admin username.
- `DBPassword`: Database admin password.
- `InstanceType`: EC2 instance type (default: `t4g.micro`).
- `TrustedCIDR`: CIDR block for trusted network access (default: `192.168.0.0/16`).

#### Outputs
- **WebServerPublicIP**: Public IP of the deployed web server.
- **RDSInstanceEndpoint**: Endpoint address of the RDS database instance.

#### Usage
1. Clone the repository and navigate to the script directory.

   ```bash
   git clone <repository_url>
   cd <repository_directory>
   ```

2. Run the Ruby script to generate the CloudFormation template:

   ```bash
   ruby modern_aws_lamp.rb > template.yaml
   ```

3. Deploy the template using AWS CLI or Console:

   **CLI Example**:
   ```bash
   aws cloudformation create-stack \
     --stack-name ModernLAMPStack \
     --template-body file://template.yaml \
     --parameters ParameterKey=VpcId,ParameterValue=<VpcId> \
                  ParameterKey=SubnetIds,ParameterValue="<SubnetId1>,<SubnetId2>" \
                  ParameterKey=KeyPairName,ParameterValue=<KeyPairName> \
                  ParameterKey=DBUsername,ParameterValue=<DBUsername> \
                  ParameterKey=DBPassword,ParameterValue=<DBPassword> \
                  ParameterKey=InstanceType,ParameterValue=t4g.micro \
                  ParameterKey=TrustedCIDR,ParameterValue=192.168.0.0/16 \
     --capabilities CAPABILITY_IAM
   ```

4. Monitor stack creation via AWS Console or CLI.

#### Notes
- Ensure the `TrustedCIDR` parameter matches your organization's network.
- Test with dummy parameters before deploying to production.

