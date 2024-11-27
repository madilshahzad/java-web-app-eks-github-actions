apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${node_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${master_role_arn}
      username: eks-master
      groups:
        - system:masters
  mapUsers: |
%{ for user in jsondecode(users) ~}
    - userarn: ${user.user_arn}
      username: ${user.username}
      groups:
%{ for group in user.groups ~}
        - ${group}
%{ endfor ~}
%{ endfor ~}
