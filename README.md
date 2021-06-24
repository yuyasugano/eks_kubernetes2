# AWS EKS test deployment with eksctl and kubectl Part 2
  
## yaml file
 
1. `env-sample.yaml` has a use of environmental variable under env
2. `env-pod-sample.yaml` has a use of valueFrom from fieldRef for env
3. `env-container-sample.yaml` has a use of valueFrom from resourceFieldRef for env
4. `secret-sample.yaml` has a sample type Opaque secret for username and password
5. `secret-single-env-sample.yaml` ia a sample to refer to a single key in the secret
6. `secret-multi-env-sample.yaml` is a sample to refer to all keys in the secret
7. `secret-single-volume-sample.yaml` is a sample to refer to a single key from the volume
8. `secret-multi-volume-sample.yaml` is a sample to refer to all keys in the volume 
9. `emptydir-sample.yaml` is a sample yaml to use an empty directory
10. `hostpath-sample.yaml` is a sample yaml to use the node's host path
11. `pv-sample.yaml` is a persistent volume sample yaml file
12. `pvc-sample.yaml` is a persistent volume claim sample yaml file
13. `pvc-pod-sample.yaml` has a volumeMounts for pvc configuration
14. `storageclass-sample.yaml` is a sample to create a StorageClass
15. `pvc-provisioner-sample.yaml` is to use dynamic provisioning for a pvc
16. `pvc-provisioner-pod-sample.yaml` has a volumeMounts for dynamic pvc provisioning
17. `statefulset-volumeclaim-sample.yaml` is a sample yaml for statefulset workload
  
## a classification of secret
 
- Generic (type: Opaque)
- TLS (type: kubernetes.io/tls)
- Docker Regisry (type: kubernetes.io/dockerconfigjson)
- Service Account (type: kubernetes.io/service-account-token)
 
## volume plugins

- EmptyDir
- HostPath
- nfs
- iscisi
- cephfs
- GCPPersistentVolume
- gitRepo
 
## persistent volume types
 
- GCE Persistent Disk
- AWS Elastic Block Store
- NFS
- iSCSI
- Ceph
- OpenStack Cinder
- GlusterFS
 
## run test
 
1. Build new cluster in EKS by using `eksctl` utility and config file
```sh
create_eks_cluster.sh
eksctl get cluster
```
2. Confirm cluster status and node status
```sh
kubectl get svc
kubectl get componentstatuses
kubectl get nodes
kubectl get daemonSets --namespace=kube-system
kubectl get deployments --namespace=kube-system
kubectl get services --namespace=kube-system
```
3. Test static environmental variable configuration
```sh
kubectl apply -f env-sample.yaml
kubectl get pods -o wide
kubectl exec -it sample-env env | grep MAX_CONNECTION
``` 
4. Test dynamic environmental variable configuration
```sh
kubectl apply -f env-pod-sample.yaml
kubectl get pods -o yaml
kubectl exec -it sample-env-pod env | grep K8S_NODE
kubectl apply -f env-container-sample.yaml
kubectl get pods -o yaml
kubectl exec -it sample-env-container env | grep CPU
``` 
5. Create a secret from static plain files
```sh
echo -n "root" > ./username
echo -n "rootpassword" > ./password
kubectl create secret generic sample-db-auth --from-file=./username --from-file=./password
kubectl get secret sample-db-auth -o json | jq .data
kubectl get secret sample-db-auth -o json | jq -r .data.username | base64 -d
kubectl get secret sample-db-auth -o json | jq -r .data.password | base64 -d
kubectl get secrets -o wide
``` 
6. Create a secret from yaml file with base64 encoding
```sh
kubectl create -f secret-sample.yaml
kubectl get secrets -o wide
``` 
7. Create a TLS secret from the certificate file
```sh
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=sample1.example.com"
kubectl create secret tls tls-sample --key /tmp/tls.key --cert /tmp/tls.crt
kubectl get secrets -o wide
``` 
8. Create a Docker Registry type secret from the command line
```sh
kubectl create secret docker-registry sample-registry-auth \
    --docker-server=REGISTRY_SERVER \
    --docker-username=REGISTRY_USER \
    --docker-password=REGISTRY_USER_PASSWORD \
    --docker-email=REGISTRY_USER_EMAIL
kubectl get secrets -o wide
``` 
9. Refer to secrets as environmental variables from pod
```sh
kubectl apply -f secret-single-env-sample.yaml
kubectl exec -it sample-secret-single-env env | grep DB_USERNAME
kubectl apply -f secret-multi-env-sample.yaml
kubectl exec -it sample-secret-multi-env env
``` 
10. Refer to secrets as volumeMounts configuration from pod
```sh
kubectl apply -f secret-single-volume-sample.yaml
kubectl exec -it sample-secret-single-volume cat /config/username.txt
kubectl apply -f secret-multi-volume-sample.yaml
kubectl exec -it sample-secret-multi-volume ls /config
password username
``` 
11. Volume & Persistent Volume samples
```sh
kubectl apply -f emptydir-sample.yaml
kubectl apply -f hostpath-sample.yaml
kubectl apply -f pv-sample.yaml
kubectl apply -f pvc-sample.yaml
kubectl get pvc
kubectl get pv
kubectl apply -f storageclass-sample.yaml
kubectl apply -f pvc-provisioner-sample.yaml
kubectl apply -f pvc-provisioner-pod-sample.yaml
kubectl get pvc
kubectl get pv
``` 
12. PersistentVolumeClaim for StatefulSet workload
```sh
kubectl apply -f storageclass-sample.yaml
kubectl apply -f statefulset-volumeclaim-sample.yaml
kubectl get pvc
kubectl get pv
```
13. Destroy the cluster in EKS by using `eksctl` utility
```sh
eksctl delete cluster --name eks-sample --wait
eksctl get cluster
```
  
This example shows how to demonstrate AWS EKS sample cluster. This [implementation][imp] was the main source to refer.
 
[imp]: https://thinkit.co.jp/article/14139 
