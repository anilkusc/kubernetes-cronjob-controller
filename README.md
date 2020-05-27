# kubernetes-cronjob-controller
This container is checking cronjob in namespace and if any of cronjob has too many missed start and it is not running anymore it deletes the cronjob(at the same time queue of missed jobs) and recreate it again.It is also going to send mail about this operation.
