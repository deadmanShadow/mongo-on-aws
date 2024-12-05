import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as lambda from 'aws-cdk-lib/aws-lambda';

export class TestLambdaStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc_name = process.env.VPC_NAME || 'appvpc';
    const vpc = cdk.aws_ec2.Vpc.fromLookup(this, vpc_name, {
      vpcName: vpc_name
    })

    const sg = cdk.aws_ec2.SecurityGroup.fromLookupByName(this, 'app-sg', 'test-ec2-sg', vpc);

    const lambdaPolicy = new iam.PolicyStatement({
      actions: ['es:*', 'logs:*', 's3:*', 'secretsmanager:*', 'kms:*', 'lambda:*', 'dynamodb:*', 'xray:*', 'ssm:*', 'cloudwatch:*', 'ec2:*', 'ecr:*', 'rds:*', 'sns:*'],
      resources: ['*']
    });

    const lambdaRole = new iam.Role(this, "test-lambda-role", {
      roleName: 'test-lambda-role',
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com'),
      inlinePolicies: {
        lambdaPolicy: new iam.PolicyDocument({
          statements: [lambdaPolicy]
        })
      },
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaVPCAccessExecutionRole')
      ],
    });

    const testLambda = new lambda.DockerImageFunction(this, 'test-lambda', {
      functionName: 'test-lambda',
      code: lambda.DockerImageCode.fromImageAsset('assets/lambda_code'),
      role: lambdaRole,
      memorySize: 256,
      timeout: cdk.Duration.seconds(30),
      vpc: vpc,
      vpcSubnets: {
        subnetType: cdk.aws_ec2.SubnetType.PRIVATE_WITH_EGRESS
      },
      securityGroups: [sg],
      environment: {
        'MONGO_USER': 'admin',
        'MONGO_PWD_SSM': '/mongodb/MONGO_INITDB_ROOT_PASSWORD'
      }
    });

    const docdbtestLambda = new lambda.DockerImageFunction(this, 'docdb-test-lambda', {
      functionName: 'docdb-test-lambda',
      code: lambda.DockerImageCode.fromImageAsset('assets/docdb_lambda'),
      role: lambdaRole,
      memorySize: 256,
      timeout: cdk.Duration.seconds(30),
      vpc: vpc,
      vpcSubnets: {
        subnetType: cdk.aws_ec2.SubnetType.PRIVATE_WITH_EGRESS
      },
      securityGroups: [sg],
      environment: {
        'MONGO_ENDPOINT': 'mongodb://<user>:<password>@<endpoint>:27017/testdb?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false'
      }
    });

  }
}
