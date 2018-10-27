#!/usr/bin/env ruby

require 'bundler/setup'
require 'cloudformation-ruby-dsl/cfntemplate'
require 'cloudformation-ruby-dsl/spotprice'
require 'cloudformation-ruby-dsl/table'

template do

  value :AWSTemplateFormatVersion => '2010-09-09'

  value :Description => 'AWS CloudFormation Sample Template LAMP_Multi_AZ: Create a highly available, scalable LAMP stack with an Amazon RDS database instance for the backend data store. This template demonstrates using the AWS CloudFormation bootstrap scripts to install the packages and files necessary to deploy the Apache web server and PHP at instance launch time. **WARNING** This template creates one or more Amazon EC2 instances, an Application Load Balancer and an Amazon RDS DB instance. You will be billed for the AWS resources used if you create a stack from this template.'

  parameter 'VpcId',
            :Type => 'AWS::EC2::VPC::Id',
            :Description => 'VpcId of your existing Virtual Private Cloud (VPC)',
            :ConstraintDescription => 'must be the VPC Id of an existing Virtual Private Cloud.'

  parameter 'Subnets',
            :Type => 'List<AWS::EC2::Subnet::Id>',
            :Description => 'The list of SubnetIds in your Virtual Private Cloud (VPC)',
            :ConstraintDescription => 'must be a list of at least two existing subnets associated with at least two different availability zones. They should be residing in the selected Virtual Private Cloud.'

  parameter 'KeyName',
            :Description => 'Name of an existing EC2 KeyPair to enable SSH access to the instances',
            :Type => 'AWS::EC2::KeyPair::KeyName',
            :ConstraintDescription => 'must be the name of an existing EC2 KeyPair.'

  parameter 'DBName',
            :Default => 'myDatabase',
            :Description => 'MySQL database name',
            :Type => 'String',
            :MinLength => '1',
            :MaxLength => '64',
            :AllowedPattern => '[a-zA-Z][a-zA-Z0-9]*',
            :ConstraintDescription => 'must begin with a letter and contain only alphanumeric characters.'

  parameter 'DBUser',
            :NoEcho => 'true',
            :Description => 'Username for MySQL database access',
            :Type => 'String',
            :MinLength => '1',
            :MaxLength => '16',
            :AllowedPattern => '[a-zA-Z][a-zA-Z0-9]*',
            :ConstraintDescription => 'must begin with a letter and contain only alphanumeric characters.'

  parameter 'DBPassword',
            :NoEcho => 'true',
            :Description => 'Password for MySQL database access',
            :Type => 'String',
            :MinLength => '8',
            :MaxLength => '41',
            :AllowedPattern => '[a-zA-Z0-9]*',
            :ConstraintDescription => 'must contain only alphanumeric characters.'

  parameter 'DBAllocatedStorage',
            :Default => '5',
            :Description => 'The size of the database (Gb)',
            :Type => 'Number',
            :MinValue => '5',
            :MaxValue => '1024',
            :ConstraintDescription => 'must be between 5 and 1024Gb.'

  parameter 'DBInstanceClass',
            :Description => 'The database instance type',
            :Type => 'String',
            :Default => 'db.t2.small',
            :AllowedValues => [
                'db.t1.micro',
                'db.m1.small',
                'db.m1.medium',
                'db.m1.large',
                'db.m1.xlarge',
                'db.m2.xlarge',
                'db.m2.2xlarge',
                'db.m2.4xlarge',
                'db.m3.medium',
                'db.m3.large',
                'db.m3.xlarge',
                'db.m3.2xlarge',
                'db.m4.large',
                'db.m4.xlarge',
                'db.m4.2xlarge',
                'db.m4.4xlarge',
                'db.m4.10xlarge',
                'db.r3.large',
                'db.r3.xlarge',
                'db.r3.2xlarge',
                'db.r3.4xlarge',
                'db.r3.8xlarge',
                'db.m2.xlarge',
                'db.m2.2xlarge',
                'db.m2.4xlarge',
                'db.cr1.8xlarge',
                'db.t2.micro',
                'db.t2.small',
                'db.t2.medium',
                'db.t2.large',
            ],
            :ConstraintDescription => 'must select a valid database instance type.'

  parameter 'MultiAZDatabase',
            :Default => 'false',
            :Description => 'Create a Multi-AZ MySQL Amazon RDS database instance',
            :Type => 'String',
            :AllowedValues => [ 'true', 'false' ],
            :ConstraintDescription => 'must be either true or false.'

  parameter 'WebServerCapacity',
            :Default => '2',
            :Description => 'The initial number of WebServer instances',
            :Type => 'Number',
            :MinValue => '1',
            :MaxValue => '5',
            :ConstraintDescription => 'must be between 1 and 5 EC2 instances.'

  parameter 'InstanceType',
            :Description => 'WebServer EC2 instance type',
            :Type => 'String',
            :Default => 't2.small',
            :AllowedValues => %w(t1.micro t2.nano t2.micro t2.small t2.medium t2.large m1.small m1.medium m1.large m1.xlarge m2.xlarge m2.2xlarge m2.4xlarge m3.medium m3.large m3.xlarge m3.2xlarge m4.large m4.xlarge m4.2xlarge m4.4xlarge m4.10xlarge c1.medium c1.xlarge c3.large c3.xlarge c3.2xlarge c3.4xlarge c3.8xlarge c4.large c4.xlarge c4.2xlarge c4.4xlarge c4.8xlarge g2.2xlarge g2.8xlarge r3.large r3.xlarge r3.2xlarge r3.4xlarge r3.8xlarge i2.xlarge i2.2xlarge i2.4xlarge i2.8xlarge d2.xlarge d2.2xlarge d2.4xlarge d2.8xlarge hi1.4xlarge hs1.8xlarge cr1.8xlarge cc2.8xlarge cg1.4xlarge),
            :ConstraintDescription => 'must be a valid EC2 instance type.'

  parameter 'SSHLocation',
            :Description => ' The IP address range that can be used to SSH to the EC2 instances',
            :Type => 'String',
            :MinLength => '9',
            :MaxLength => '18',
            :Default => '0.0.0.0/0',
            :AllowedPattern => '(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})',
            :ConstraintDescription => 'must be a valid IP CIDR range of the form x.x.x.x/x.'

  mapping 'AWSInstanceType2Arch',
          :'t1.micro' => { :Arch => 'HVM64' },
          :'t2.nano' => { :Arch => 'HVM64' },
          :'t2.micro' => { :Arch => 'HVM64' },
          :'t2.small' => { :Arch => 'HVM64' },
          :'t2.medium' => { :Arch => 'HVM64' },
          :'t2.large' => { :Arch => 'HVM64' },
          :'m1.small' => { :Arch => 'HVM64' },
          :'m1.medium' => { :Arch => 'HVM64' },
          :'m1.large' => { :Arch => 'HVM64' },
          :'m1.xlarge' => { :Arch => 'HVM64' },
          :'m2.xlarge' => { :Arch => 'HVM64' },
          :'m2.2xlarge' => { :Arch => 'HVM64' },
          :'m2.4xlarge' => { :Arch => 'HVM64' },
          :'m3.medium' => { :Arch => 'HVM64' },
          :'m3.large' => { :Arch => 'HVM64' },
          :'m3.xlarge' => { :Arch => 'HVM64' },
          :'m3.2xlarge' => { :Arch => 'HVM64' },
          :'m4.large' => { :Arch => 'HVM64' },
          :'m4.xlarge' => { :Arch => 'HVM64' },
          :'m4.2xlarge' => { :Arch => 'HVM64' },
          :'m4.4xlarge' => { :Arch => 'HVM64' },
          :'m4.10xlarge' => { :Arch => 'HVM64' },
          :'c1.medium' => { :Arch => 'HVM64' },
          :'c1.xlarge' => { :Arch => 'HVM64' },
          :'c3.large' => { :Arch => 'HVM64' },
          :'c3.xlarge' => { :Arch => 'HVM64' },
          :'c3.2xlarge' => { :Arch => 'HVM64' },
          :'c3.4xlarge' => { :Arch => 'HVM64' },
          :'c3.8xlarge' => { :Arch => 'HVM64' },
          :'c4.large' => { :Arch => 'HVM64' },
          :'c4.xlarge' => { :Arch => 'HVM64' },
          :'c4.2xlarge' => { :Arch => 'HVM64' },
          :'c4.4xlarge' => { :Arch => 'HVM64' },
          :'c4.8xlarge' => { :Arch => 'HVM64' },
          :'g2.2xlarge' => { :Arch => 'HVMG2' },
          :'g2.8xlarge' => { :Arch => 'HVMG2' },
          :'r3.large' => { :Arch => 'HVM64' },
          :'r3.xlarge' => { :Arch => 'HVM64' },
          :'r3.2xlarge' => { :Arch => 'HVM64' },
          :'r3.4xlarge' => { :Arch => 'HVM64' },
          :'r3.8xlarge' => { :Arch => 'HVM64' },
          :'i2.xlarge' => { :Arch => 'HVM64' },
          :'i2.2xlarge' => { :Arch => 'HVM64' },
          :'i2.4xlarge' => { :Arch => 'HVM64' },
          :'i2.8xlarge' => { :Arch => 'HVM64' },
          :'d2.xlarge' => { :Arch => 'HVM64' },
          :'d2.2xlarge' => { :Arch => 'HVM64' },
          :'d2.4xlarge' => { :Arch => 'HVM64' },
          :'d2.8xlarge' => { :Arch => 'HVM64' },
          :'hi1.4xlarge' => { :Arch => 'HVM64' },
          :'hs1.8xlarge' => { :Arch => 'HVM64' },
          :'cr1.8xlarge' => { :Arch => 'HVM64' },
          :'cc2.8xlarge' => { :Arch => 'HVM64' }

  mapping 'AWSInstanceType2NATArch',
          :'t1.micro' => { :Arch => 'NATHVM64' },
          :'t2.nano' => { :Arch => 'NATHVM64' },
          :'t2.micro' => { :Arch => 'NATHVM64' },
          :'t2.small' => { :Arch => 'NATHVM64' },
          :'t2.medium' => { :Arch => 'NATHVM64' },
          :'t2.large' => { :Arch => 'NATHVM64' },
          :'m1.small' => { :Arch => 'NATHVM64' },
          :'m1.medium' => { :Arch => 'NATHVM64' },
          :'m1.large' => { :Arch => 'NATHVM64' },
          :'m1.xlarge' => { :Arch => 'NATHVM64' },
          :'m2.xlarge' => { :Arch => 'NATHVM64' },
          :'m2.2xlarge' => { :Arch => 'NATHVM64' },
          :'m2.4xlarge' => { :Arch => 'NATHVM64' },
          :'m3.medium' => { :Arch => 'NATHVM64' },
          :'m3.large' => { :Arch => 'NATHVM64' },
          :'m3.xlarge' => { :Arch => 'NATHVM64' },
          :'m3.2xlarge' => { :Arch => 'NATHVM64' },
          :'m4.large' => { :Arch => 'NATHVM64' },
          :'m4.xlarge' => { :Arch => 'NATHVM64' },
          :'m4.2xlarge' => { :Arch => 'NATHVM64' },
          :'m4.4xlarge' => { :Arch => 'NATHVM64' },
          :'m4.10xlarge' => { :Arch => 'NATHVM64' },
          :'c1.medium' => { :Arch => 'NATHVM64' },
          :'c1.xlarge' => { :Arch => 'NATHVM64' },
          :'c3.large' => { :Arch => 'NATHVM64' },
          :'c3.xlarge' => { :Arch => 'NATHVM64' },
          :'c3.2xlarge' => { :Arch => 'NATHVM64' },
          :'c3.4xlarge' => { :Arch => 'NATHVM64' },
          :'c3.8xlarge' => { :Arch => 'NATHVM64' },
          :'c4.large' => { :Arch => 'NATHVM64' },
          :'c4.xlarge' => { :Arch => 'NATHVM64' },
          :'c4.2xlarge' => { :Arch => 'NATHVM64' },
          :'c4.4xlarge' => { :Arch => 'NATHVM64' },
          :'c4.8xlarge' => { :Arch => 'NATHVM64' },
          :'g2.2xlarge' => { :Arch => 'NATHVMG2' },
          :'g2.8xlarge' => { :Arch => 'NATHVMG2' },
          :'r3.large' => { :Arch => 'NATHVM64' },
          :'r3.xlarge' => { :Arch => 'NATHVM64' },
          :'r3.2xlarge' => { :Arch => 'NATHVM64' },
          :'r3.4xlarge' => { :Arch => 'NATHVM64' },
          :'r3.8xlarge' => { :Arch => 'NATHVM64' },
          :'i2.xlarge' => { :Arch => 'NATHVM64' },
          :'i2.2xlarge' => { :Arch => 'NATHVM64' },
          :'i2.4xlarge' => { :Arch => 'NATHVM64' },
          :'i2.8xlarge' => { :Arch => 'NATHVM64' },
          :'d2.xlarge' => { :Arch => 'NATHVM64' },
          :'d2.2xlarge' => { :Arch => 'NATHVM64' },
          :'d2.4xlarge' => { :Arch => 'NATHVM64' },
          :'d2.8xlarge' => { :Arch => 'NATHVM64' },
          :'hi1.4xlarge' => { :Arch => 'NATHVM64' },
          :'hs1.8xlarge' => { :Arch => 'NATHVM64' },
          :'cr1.8xlarge' => { :Arch => 'NATHVM64' },
          :'cc2.8xlarge' => { :Arch => 'NATHVM64' }

  mapping 'AWSRegionArch2AMI',
          :'us-east-1' => { :HVM64 => 'ami-0ff8a91507f77f867', :HVMG2 => 'ami-0a584ac55a7631c0c' },
          :'us-west-2' => { :HVM64 => 'ami-a0cfeed8', :HVMG2 => 'ami-0e09505bc235aa82d' },
          :'us-west-1' => { :HVM64 => 'ami-0bdb828fd58c52235', :HVMG2 => 'ami-066ee5fd4a9ef77f1' },
          :'eu-west-1' => { :HVM64 => 'ami-047bb4163c506cd98', :HVMG2 => 'ami-0a7c483d527806435' },
          :'eu-west-2' => { :HVM64 => 'ami-f976839e', :HVMG2 => 'NOT_SUPPORTED' },
          :'eu-west-3' => { :HVM64 => 'ami-0ebc281c20e89ba4b', :HVMG2 => 'NOT_SUPPORTED' },
          :'eu-central-1' => { :HVM64 => 'ami-0233214e13e500f77', :HVMG2 => 'ami-06223d46a6d0661c7' },
          :'ap-northeast-1' => { :HVM64 => 'ami-06cd52961ce9f0d85', :HVMG2 => 'ami-053cdd503598e4a9d' },
          :'ap-northeast-2' => { :HVM64 => 'ami-0a10b2721688ce9d2', :HVMG2 => 'NOT_SUPPORTED' },
          :'ap-northeast-3' => { :HVM64 => 'ami-0d98120a9fb693f07', :HVMG2 => 'NOT_SUPPORTED' },
          :'ap-southeast-1' => { :HVM64 => 'ami-08569b978cc4dfa10', :HVMG2 => 'ami-0be9df32ae9f92309' },
          :'ap-southeast-2' => { :HVM64 => 'ami-09b42976632b27e9b', :HVMG2 => 'ami-0a9ce9fecc3d1daf8' },
          :'ap-south-1' => { :HVM64 => 'ami-0912f71e06545ad88', :HVMG2 => 'ami-097b15e89dbdcfcf4' },
          :'us-east-2' => { :HVM64 => 'ami-0b59bfac6be064b78', :HVMG2 => 'NOT_SUPPORTED' },
          :'ca-central-1' => { :HVM64 => 'ami-0b18956f', :HVMG2 => 'NOT_SUPPORTED' },
          :'sa-east-1' => { :HVM64 => 'ami-07b14488da8ea02a0', :HVMG2 => 'NOT_SUPPORTED' },
          :'cn-north-1' => { :HVM64 => 'ami-0a4eaf6c4454eda75', :HVMG2 => 'NOT_SUPPORTED' },
          :'cn-northwest-1' => { :HVM64 => 'ami-6b6a7d09', :HVMG2 => 'NOT_SUPPORTED' }

  resource 'ApplicationLoadBalancer', :Type => 'AWS::ElasticLoadBalancingV2::LoadBalancer', :Properties => { :Subnets => ref('Subnets') }

  resource 'ALBListener', :Type => 'AWS::ElasticLoadBalancingV2::Listener', :Properties => {
      :DefaultActions => [
          {
              :Type => 'forward',
              :TargetGroupArn => ref('ALBTargetGroup'),
          },
      ],
      :LoadBalancerArn => ref('ApplicationLoadBalancer'),
      :Port => '80',
      :Protocol => 'HTTP',
  }

  resource 'ALBTargetGroup', :Type => 'AWS::ElasticLoadBalancingV2::TargetGroup', :Properties => {
      :HealthCheckIntervalSeconds => 10,
      :HealthCheckTimeoutSeconds => 5,
      :HealthyThresholdCount => 2,
      :Port => 80,
      :Protocol => 'HTTP',
      :UnhealthyThresholdCount => 5,
      :VpcId => ref('VpcId'),
      :TargetGroupAttributes => [
          { :Key => 'stickiness.enabled', :Value => 'true' },
          { :Key => 'stickiness.type', :Value => 'lb_cookie' },
          { :Key => 'stickiness.lb_cookie.duration_seconds', :Value => '30' },
      ],
  }

  resource 'WebServerGroup', :Type => 'AWS::AutoScaling::AutoScalingGroup', :CreationPolicy => { :ResourceSignal => { :Timeout => 'PT5M', :Count => ref('WebServerCapacity') } }, :UpdatePolicy => { :AutoScalingRollingUpdate => { :MinInstancesInService => '1', :MaxBatchSize => '1', :PauseTime => 'PT15M', :WaitOnResourceSignals => 'true' } }, :Properties => {
      :VPCZoneIdentifier => ref('Subnets'),
      :LaunchConfigurationName => ref('LaunchConfig'),
      :MinSize => '1',
      :MaxSize => '5',
      :DesiredCapacity => ref('WebServerCapacity'),
      :TargetGroupARNs => [ ref('ALBTargetGroup') ],
  }

  resource 'LaunchConfig', :Type => 'AWS::AutoScaling::LaunchConfiguration', :Metadata => { :Comment1 => 'Configure the bootstrap helpers to install the Apache Web Server and PHP', :Comment2 => 'The website content is downloaded from the CloudFormationPHPSample.zip file', :'AWS::CloudFormation::Init' => { :config => { :packages => { :yum => { :httpd => [], :php => [], :'php-mysql' => [] } }, :files => { :'/var/www/html/index.php' => { :content => join('', "<html>\n", "  <head>\n", "    <title>AWS CloudFormation PHP Sample</title>\n", "    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=ISO-8859-1\">\n", "  </head>\n", "  <body>\n", "    <h1>Welcome to the AWS CloudFormation PHP Sample</h1>\n", "    <p/>\n", "    <?php\n", "      // Print out the current data and tie\n", "      print \"The Current Date and Time is: <br/>\";\n", "      print date(\"g:i A l, F j Y.\");\n", "    ?>\n", "    <p/>\n", "    <?php\n", "      // Setup a handle for CURL\n", "      $curl_handle=curl_init();\n", "      curl_setopt($curl_handle,CURLOPT_CONNECTTIMEOUT,2);\n", "      curl_setopt($curl_handle,CURLOPT_RETURNTRANSFER,1);\n", "      // Get the hostname of the intance from the instance metadata\n", "      curl_setopt($curl_handle,CURLOPT_URL,'http://169.254.169.254/latest/meta-data/public-hostname');\n", "      $hostname = curl_exec($curl_handle);\n", "      if (empty($hostname))\n", "      {\n", "        print \"Sorry, for some reason, we got no hostname back <br />\";\n", "      }\n", "      else\n", "      {\n", "        print \"Server = \" . $hostname . \"<br />\";\n", "      }\n", "      // Get the instance-id of the intance from the instance metadata\n", "      curl_setopt($curl_handle,CURLOPT_URL,'http://169.254.169.254/latest/meta-data/instance-id');\n", "      $instanceid = curl_exec($curl_handle);\n", "      if (empty($instanceid))\n", "      {\n", "        print \"Sorry, for some reason, we got no instance id back <br />\";\n", "      }\n", "      else\n", "      {\n", "        print \"EC2 instance-id = \" . $instanceid . \"<br />\";\n", "      }\n", '      $Database   = "', get_att('MySQLDatabase', 'Endpoint.Address'), "\";\n", '      $DBUser     = "', ref('DBUser'), "\";\n", '      $DBPassword = "', ref('DBPassword'), "\";\n", "      print \"Database = \" . $Database . \"<br />\";\n", "      $dbconnection = mysql_connect($Database, $DBUser, $DBPassword)\n", "                      or die(\"Could not connect: \" . mysql_error());\n", "      print (\"Connected to $Database successfully\");\n", "      mysql_close($dbconnection);\n", "    ?>\n", "    <h2>PHP Information</h2>\n", "    <p/>\n", "    <?php\n", "      phpinfo();\n", "    ?>\n", "  </body>\n", "</html>\n"), :mode => '000600', :owner => 'apache', :group => 'apache' }, :'/etc/cfn/cfn-hup.conf' => { :content => join('', "[main]\n", 'stack=', aws_stack_id, "\n", 'region=', aws_region, "\n"), :mode => '000400', :owner => 'root', :group => 'root' }, :'/etc/cfn/hooks.d/cfn-auto-reloader.conf' => { :content => join('', "[cfn-auto-reloader-hook]\n", "triggers=post.update\n", "path=Resources.LaunchConfig.Metadata.AWS::CloudFormation::Init\n", 'action=/opt/aws/bin/cfn-init -v ', '         --stack ', aws_stack_name, '         --resource LaunchConfig ', '         --region ', aws_region, "\n", "runas=root\n"), :mode => '000400', :owner => 'root', :group => 'root' } }, :services => { :sysvinit => { :httpd => { :enabled => 'true', :ensureRunning => 'true' }, :'cfn-hup' => { :enabled => 'true', :ensureRunning => 'true', :files => [ '/etc/cfn/cfn-hup.conf', '/etc/cfn/hooks.d/cfn-auto-reloader.conf' ] } } } } } }, :Properties => {
      :ImageId => find_in_map('AWSRegionArch2AMI', aws_region, find_in_map('AWSInstanceType2Arch', ref('InstanceType'), 'Arch')),
      :InstanceType => ref('InstanceType'),
      :SecurityGroups => [ ref('WebServerSecurityGroup') ],
      :KeyName => ref('KeyName'),
      :UserData => base64(
          join('',
               "#!/bin/bash -xe\n",
               "yum update -y aws-cfn-bootstrap\n",
               "DD_API_KEY=32e627c2342195407457a533bbaea716 bash -c \"$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)\"\n",
               "# Install the files and packages from the metadata\n",
               '/opt/aws/bin/cfn-init -v ',
               '         --stack ',
               aws_stack_name,
               '         --resource LaunchConfig ',
               '         --region ',
               aws_region,
               "\n",
               "# Signal the status from cfn-init\n",
               '/opt/aws/bin/cfn-signal -e $? ',
               '         --stack ',
               aws_stack_name,
               '         --resource WebServerGroup ',
               '         --region ',
               aws_region,
               "\n",
          )
      ),
  }

  resource 'WebServerSecurityGroup', :Type => 'AWS::EC2::SecurityGroup', :Properties => {
      :GroupDescription => 'Enable HTTP access via port 80 locked down to the ELB and SSH access',
      :SecurityGroupIngress => [
          {
              :IpProtocol => 'tcp',
              :FromPort => '80',
              :ToPort => '80',
              :SourceSecurityGroupId => select(0, get_att('ApplicationLoadBalancer', 'SecurityGroups')),
          },
          {
              :IpProtocol => 'tcp',
              :FromPort => '22',
              :ToPort => '22',
              :CidrIp => ref('SSHLocation'),
          },
      ],
      :VpcId => ref('VpcId'),
  }

  resource 'DBEC2SecurityGroup', :Type => 'AWS::EC2::SecurityGroup', :Properties => {
      :GroupDescription => 'Open database for access',
      :SecurityGroupIngress => [
          {
              :IpProtocol => 'tcp',
              :FromPort => '3306',
              :ToPort => '3306',
              :SourceSecurityGroupId => ref('WebServerSecurityGroup'),
          },
      ],
      :VpcId => ref('VpcId'),
  }

  resource 'MySQLDatabase', :Type => 'AWS::RDS::DBInstance', :Properties => {
      :Engine => 'MySQL',
      :DBName => ref('DBName'),
      :MultiAZ => ref('MultiAZDatabase'),
      :MasterUsername => ref('DBUser'),
      :MasterUserPassword => ref('DBPassword'),
      :DBInstanceClass => ref('DBInstanceClass'),
      :AllocatedStorage => ref('DBAllocatedStorage'),
      :VPCSecurityGroups => [ get_att('DBEC2SecurityGroup', 'GroupId') ],
  }

  output 'WebsiteURL',
         :Description => 'URL for newly created LAMP stack',
         :Value => join('', 'http://', get_att('ApplicationLoadBalancer', 'DNSName'))

end.exec!
