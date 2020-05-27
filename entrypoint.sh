#!/bin/bash
set -e
if [[ $DEBUG == "on"  ]];then
TOKEN=$(kubectl  get secret jenkins-token-cqdd7 -o jsonpath='{.data.token}'| base64 --decode)
KUBERNETES='https://192.168.1.50:6443'
NAMESPACE="default"
cronjobs=($(kubectl get cj -n $NAMESPACE | awk '{print $1}' | tail -n +2))
else
TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
KUBERNETES='https://kubernetes'
NAMESPACE=$(cat /run/secrets/kubernetes.io/serviceaccount/namespace)
cronjobs=($(kubectl get cj -n $NAMESPACE | awk '{print $1}' | tail -n +2))
fi

for cronjob in "${cronjobs[@]}";do
if [[ $cronjob == "" ]]; then
echo "Error fetching cronjob name"
else
describe=$(kubectl describe cj -n $NAMESPACE $cronjob)
if [[ $describe =~ "too many missed start time" ]]; then
LOGS=$(kubectl describe cj -n $NAMESPACE $cronjob)
YAML=$(kubectl get cj -n $NAMESPACE $cronjob -o yaml)
echo "Unhealty cronjob.Mailing..."
printf "To:anilkuscu95@gmail.com\nFrom:job.control@gmail.com\nSubject: Some of Cronjob is unhealty!\n\n\n\n\n This cronjob will be terminated: $cronjob \n\n It will start again but you should check cronjob status yet \n\n\n\n LOGS \n $LOGS \n\n\n YAML \n\n $YAML" > mail.txt
curl -s --url 'smtp://smtp.gmail.com:587' --ssl-reqd   --mail-from 'job.control@gmail.com' --mail-rcpt 'anilkuscu95@gmail.com'  --upload-file mail.txt --user 'job.control@gmail.com:my_passwd' --insecure
cronjob_config="$(kubectl get cj -n $NAMESPACE $cronjob -o json | jq -r '.metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"]')"
kubectl delete cj -n $NAMESPACE $cronjob
echo "$cronjob_config" > text
kubectl apply -f text
else
echo "CronJob is healthy: $cronjob"
fi
fi
done
