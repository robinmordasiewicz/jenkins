# jenkins

kubectl exec --namespace <yournamespace> -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo
