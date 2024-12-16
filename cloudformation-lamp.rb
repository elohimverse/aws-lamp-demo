#!/usr/bin/env ruby

# AWS CloudFormation Template
# Author: Rosen Tsaryanski
# Description: This script deploys a modernized LAMP stack using AWS best practices.
# AWS Well-Architected Framework Compliances covered up to 2024

require 'cloudformation-ruby-dsl/cfntemplate'

template do
  value :AWSTemplateFormatVersion => '2010-09-09'
  value :Description => 'Modernized LAMP Stack Deployment with AWS Best Practices'

  ## Parameters
  parameter 'VpcId',
            :Type => 'AWS::EC2::VPC::Id',
            :Description => 'VpcId of your existing Virtual Private Cloud (VPC)',
            :ConstraintDescription => 'Must be an existing VPC ID.'

  parameter 'SubnetIds',
            :Type => 'List<AWS::EC2::Subnet::Id>',
            :Description => 'List of SubnetIds for your VPC.',
            :ConstraintDescription => 'Must be a list of existing Subnet IDs.'

  parameter 'KeyPairName',
            :Type => 'AWS::EC2::KeyPair::KeyName',
            :Description => 'Name of an existing EC2 KeyPair for SSH access.'

  parameter 'DBUsername',
            :Type => 'String',
            :NoEcho => true,
            :Description => 'Database admin username.'

  parameter 'DBPassword',
            :Type => 'String',
            :NoEcho => true,
            :Description => 'Database admin password.'

  parameter 'InstanceType',
            :Type => 'String',
            :Default => 't4g.micro',
            :AllowedValues => ['t4g.micro', 't4g.small', 't4g.medium', 't4g.large'],
            :Description => 'Instance type for EC2 instances optimized for cost and performance.'

  parameter 'TrustedCIDR',
            :Type => 'String',
            :Default => '192.168.0.0/16',
            :Description => 'CIDR block for trusted network access to EC2 instances.'

  ## Resources
  resource 'WebServerInstance', :Type => 'AWS::EC2::Instance' do
    property :InstanceType, ref('InstanceType')
    property :KeyName, ref('KeyPairName')
    property :ImageId, 'ami-08c40ec9ead489470' 
    property :SubnetId, select(0, ref('SubnetIds'))
    property :SecurityGroupIds, [get_att('WebServerSG.GroupId')]

    metadata do
      property 'AWS::CloudFormation::Init', {
        configSets: {
          default: ['install']
        },
        install: {
          packages: {
            yum: {
              'httpd' => [],
              'php' => [],
              'mariadb-server' => []
            }
          },
          services: {
            sysvinit: {
              httpd: {
                enabled: true,
                ensureRunning: true
              },
              mariadb: {
                enabled: true,
                ensureRunning: true
              }
            }
          }
        }
      }
    end

    creation_policy do
      property :ResourceSignal, { Count: 1, Timeout: 'PT15M' }
    end
  end

  resource 'WebServerSG', :Type => 'AWS::EC2::SecurityGroup' do
    property :GroupDescription, 'Enable HTTP and SSH access for trusted networks only.'
    property :VpcId, ref('VpcId')
    property :SecurityGroupIngress, [
      { CidrIp: ref('TrustedCIDR'), IpProtocol: 'tcp', FromPort: 22, ToPort: 22 },
      { CidrIp: ref('TrustedCIDR'), IpProtocol: 'tcp', FromPort: 80, ToPort: 80 }
    ]
  end

  resource 'DatabaseInstance', :Type => 'AWS::RDS::DBInstance' do
    property :DBInstanceClass, 'db.t4g.micro'
    property :Engine, 'mariadb'
    property :MasterUsername, ref('DBUsername')
    property :MasterUserPassword, ref('DBPassword')
    property :AllocatedStorage, '20'
    property :DBSubnetGroupName, ref('DBSubnetGroup')
    property :MultiAZ, true
    property :PubliclyAccessible, false
    property :StorageEncrypted, true
    property :BackupRetentionPeriod, 7
  end

  resource 'DBSubnetGroup', :Type => 'AWS::RDS::DBSubnetGroup' do
    property :DBSubnetGroupDescription, 'Subnets for the RDS DB Instance.'
    property :SubnetIds, ref('SubnetIds')
  end

  ## Outputs
  output 'WebServerPublicIP',
         :Value => get_att('WebServerInstance.PublicIp'),
         :Description => 'Public IP of the Web Server instance.'

  output 'RDSInstanceEndpoint',
         :Value => get_att('DatabaseInstance.Endpoint.Address'),
         :Description => 'RDS Instance Endpoint.'
end
