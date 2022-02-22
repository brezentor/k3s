
--------------------------------------Спроба 1-----------------------------------------------------

За допомогою terraform розвернути кластер на AWS використовуючи t2.micro і ос ubuntu 20.04
Використовував сценарій: розвернути k3s кластер на 2 pod-ах. 1 pod - master, який використовує БД mysql (взяв цю ідею із документації на ресурсі rancher.com/docs/k3s), 
далі на кластері підняти rancher, argo cd, mongo db.

Структура:
variables.tf включає змінні середовища, шо будуть використовуватись в main.tf (дані для запуску інстансів та дані для підняття БД)
main.tf описує всю інфраструктуру:
---1 інстанс де буде піднятий master node k3s та підключений до mysql (в реальності БД повинна бути на окремому інстансі/rds) 
    використовується скріпт mysql-serv.sh.tpl для настройки інстансу
---2 інстанс де буде піднятий worker node k3s
    використовується скріпт k3s-set-agent.sh для настройки інстансу

В решті решт, спроба завершилась великою кількістю проблем (в першу чергу з встановлення rancher на кластері) і було прийнято рішення спробувати підняти кластер на k3d

--------------------------------------Спроба 2--------------------------------------------------------

Спроба полягає у підйомі на віртуальній машині k3d і в подальшому на кластері підняти rancher, argo cd, mongo db.

Структура дій:

1. --Підняти докер на віртуалці--

  apt -y install ca-certificates curl gnupg lsb-release
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt -y update
	apt -y install docker-ce docker-ce-cli containerd.io
  
2. --Підняти kubectl на віртуалці--

  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
	echo "$(<kubectl.sha256)  kubectl" | sha256sum --check
	sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
	kubectl version --client
  
3. --Підняти k3d--

  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  
4. --Створення кластеру--

  k3d cluster create mycluster
  
5. --Встановлення helm--

  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	chmod 700 get_helm.sh
	./get_helm.sh
  
6. --Додавання Rancher репозиторію в helm--

	helm repo add rancher-stable https:// releases.rancher.com/server-charts/stable
 
7. --Створення namespace для Rancher--

	kubectl create namespace cattle-system
  
8. --Встановлення CertManager--

8.1 --Встановлення CustomResourceDefinition відокремлено

	kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.crds.yaml
 
8.2 --Створення namespace для cert-manager--

	kubectl create namespace cert-manager
 
8.3 --Додавання Jetstack Helm репозиторію--

	helm repo add jetstack https://charts.jetstack.io
 
8.4 --Оновлення кешу локального Helm chart репозиторію--
	
  helm repo update
 
8.5 --Встановлення cert-manager чарту--

	helm install \
	cert-manager jetstack/cert-manager \
	--namespace cert-manager \
	--version v1.0.4
  
9. Встановлення Rancher

	hostname=<domain name / ip address>
	helm install rancher rancher-stable/rancher \
	--namespace cattle-system \
	--set hostname=$hostname
	
На даному етапі знову зустрівся з помилками і проблемами і зараз на етапі їх вирішення.