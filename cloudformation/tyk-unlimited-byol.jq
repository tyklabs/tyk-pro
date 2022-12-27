[
  {
    "ParameterKey": "VPC",
    "ParameterValue": .vpc
  },
  {
    "ParameterKey": "Project",
    "ParameterValue": "SingleGW"
  },
  {
    "ParameterKey": "Environment",
    "ParameterValue": "demo"
  },
  {
    "ParameterKey": "AMISelect",
    "ParameterValue": "AWSLinux"
  },
  {
    "ParameterKey": "GatewaySSHKey",
    "ParameterValue": .ssh_key
  },
  {
    "ParameterKey": "GateWayInstanceType",
    "ParameterValue": "t3.small"
  },
  {
    "ParameterKey": "TYKGatewaySubDomain",
    "ParameterValue": "tykgw"
  },
  {
    "ParameterKey": "TYKPumpSubnet",
    "ParameterValue": .private_subnet1
  },
  {
    "ParameterKey": "TYKDashboardSubnet",
    "ParameterValue": .pub_subnet1
  },
  {
    "ParameterKey": "TYKGatewaySubnet",
    "ParameterValue": (.pub_subnet1 + "," + .pub_subnet2 + "," + .pub_subnet3)
  },
  {
    "ParameterKey": "ElastiCacheSubnets",
    "ParameterValue": (.private_subnet1 + "," + .private_subnet2 + "," + .private_subnet3)
  },
  {
    "ParameterKey": "DocDBSubnets",
    "ParameterValue": (.private_subnet1 + "," + .private_subnet2 + "," + .private_subnet3)
  },
  {
    "ParameterKey": "EnableAtRestEncryptionEnabled",
    "ParameterValue": "true"
  },
  {
    "ParameterKey": "LicenseKey",
    "ParameterValue": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  },
  {
    "ParameterKey": "TYKDBAdminUserName",
    "ParameterValue": "admin"
  },
  {
    "ParameterKey": "TYKDBAdminUserName",
    "ParameterValue": "admin"
  },
  {
    "ParameterKey": "TYKDBAdminOrganization",
    "ParameterValue": "infinity"
  },
  {
    "ParameterKey": "DashboardInstanceType",
    "ParameterValue": "t3.small"
  },
  {
    "ParameterKey": "PumpInstanceType",
    "ParameterValue": "t3.small"
  },
  {
    "ParameterKey": "DashboardSSHKey",
    "ParameterValue": .ssh_key
  },
  {
    "ParameterKey": "TYKMONGOSSHKey",
    "ParameterValue": .ssh_key
  },
  {
    "ParameterKey": "PumpSSHKey",
    "ParameterValue": .ssh_key
  },
  {
    "ParameterKey": "TYKHostedZone",
    "ParameterValue": "alephnull.site"
  },
  {
    "ParameterKey": "TYKDashBoardSubDomain",
    "ParameterValue": "tykdb"
  },
  {
    "ParameterKey": "MongoAdminUsername",
    "ParameterValue": "clusteradmin"
  },
  {
    "ParameterKey": "PumpDbAdminUser",
    "ParameterValue": "admin"
  },
  {
    "ParameterKey": "DBInstanceClass",
    "ParameterValue": "db.t3.medium"
  },
  {
    "ParameterKey": "TYKGatewaySubnetAZs",
    "ParameterValue": "sa-east-1a,sa-east-1b,sa-east-1c"
  }
]
