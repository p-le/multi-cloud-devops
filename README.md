# AWS

```
make awscli ARG="help config-vars"
make awscli ARG="configure list-profiles"
make awscli ARG="ec2 describe-instances"
make awscli ARG="ec2 describe-availability-zones --query 'AvailabilityZones[*].[ZoneName, ZoneId]' --output text"
```

