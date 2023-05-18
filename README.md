# Overview

Infrastructure example using Microk8s and setting up in a bare metal server or any linux distribution using snap as a package manager.

## Setup infrastructure

To start coding with the initial infrastructure we have a process to follow and install dependencies correctly,

### Microk8s

If you're a linux user and have the snap installed

```bash
sudo snap install microk8s --classic --channel=1.27
```

If you're not in a linux distribution go ahead and [click here](https://microk8s.io/docs/install-alternatives) to download the microk8s in your OS

After installing Check the status after installation and if everything

```bash
microk8s status --wait-ready
```

##### microk8s addons that we use

We have a couple of dependencies to get the microk8s executing fine in the machine, just run the following and fortunetely will be fine:

```bash
microk8s enable dashboard #dashboard to visualize the kubernetes resources
microk8s enable dns #enable traffic by custom local hostname
microk8s enable registry # Locally option to enable registry docker images
microk8s enable community # enable the repository of the community to access different  addons
```

To enable the storage addon you'll need to enable some dependencies(Tested only in linux distribution)

```bash
sudo systemctl enable iscsid
microk8s enable openebs
```

For more references in how to use the storage openebs, go ahead and check the reference in [microk8s addon openebs](https://microk8s.io/docs/addon-openebs)

After everything is installed correctly, go ahead and create an alias for kubectl with copy pasting the bash below to your `~/.zshrc` or `~/.bashrc`.

```bash
alias kubectl='microk8s kubectl'
```

It's important not to have one kubectl installed in your machine, so if you have it uninstall first anything related MiniKube, Kubectl or any k8s provider to not conflict with Microk8s if you did not uninstall don't create the alias for kubectl

In case you did not enable the alias the commands that reference the `kubectl`
you'll need to call with microk8s like so `microk8s kubectl <commmand>`

##### Installing RabbitMQ

Here we're going to install rabbitmq with the helm

```bash
kubectl create namespace rabbitmq \
helm repo add bitnami https://charts.bitnami.com/bitnami \
helm install rabbit-operator bitnami/rabbitmq-cluster-operator --namespace rabbitmq \
kubectl apply -f k8s/rabbitmq/cluster.yaml \
```

### Deleting infrastructure

##### RabbitMQ

Run this bash below to delete everything related to RabbitMQ from your cluster

```bash
kubectl delete -f k8s/rabbitmq/cluster.yaml \
helm delete rabbit-operator -n rabbitmq \
kubectl delete CustomResourceDefinition $(kubectl get CustomResourceDefinition -A | grep "rabbitmq.com" | awk '{print $1}') \
kubectl delete namespace rabbitmq \
kubectl get namespace "rabbitmq" -o json \
 | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
 | kubectl replace --raw /api/v1/namespaces/rabbitmq/finalize -f -
```

##### Microk8s

After deleting helm packages you go ahead and reset the microk8s cluster, then stop everything with the following command below:

```bash
microk8s reset \
microk8s stop
```
