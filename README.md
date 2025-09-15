# Kubernetes
## 🚀 Complete Kubernetes Real-Time Commands with Explanations (Start → End):
This guide covers all essential Kubernetes (K8s) commands that DevOps engineers use in real projects — from cluster setup → deployments → scaling → troubleshooting → monitoring → cleanup

---
Here we have a **complete end-to-end Kubernetes real-time command guide** from:

1. Cluster Setup
2. Kubectl Basics
3. Namespaces
4. Nodes
5. Pods
6. Deployments
7. ReplicaSets
8. Services
9. Ingress
10. ConfigMaps & Secrets
11. Storage (PV, PVC)
12. DaemonSets
13. Jobs
14. CronJobs
15. Probes
16. Taints & Tolerations
17. RBAC
18. Monitoring & Metrics
19. Helm
20. Cleanup
---
# 🔥 1) Cluster Setup — ALL commands (copy-paste)

> Notes: pick one path (local: Minikube / Kind / kubeadm) **or** cloud (EKS/GKE/AKS). If cloud is already provided, skip local cluster steps.

```bash
########## Install kubectl (client) ##########
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --short

# macOS (Homebrew)
brew install kubectl
kubectl version --client --short

# Windows (Chocolatey)
choco install kubernetes-cli

########## Minikube (local single-node) ##########
minikube start --cpus=4 --memory=8192 --driver=docker
minikube status
minikube kubectl -- get nodes

########## Kind (local multi-node) ##########
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF
kind create cluster --name dev-cluster --config kind-config.yaml
kind get clusters
kubectl cluster-info --context kind-dev-cluster

########## kubeadm (bare-metal / VMs) ##########
# on control-plane
sudo swapoff -a
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes

# on worker (example; 'kubeadm init' prints exact join command)
sudo kubeadm join <CONTROL_PLANE_IP>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

########## Install CNI (network plugin) ##########
# Calico (example)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# or Flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

########## Verify cluster ##########
kubectl get nodes -o wide
kubectl get pods -A

########## Cloud: EKS / GKE / AKS quick create ##########
# EKS (using eksctl)
eksctl create cluster --name prod-cluster --region us-east-1 --nodes 3 --node-type t3.medium

# GKE (gcloud)
gcloud container clusters create my-gke-cluster --zone us-central1-a --num-nodes=3 --machine-type=e2-medium
gcloud container clusters get-credentials my-gke-cluster --zone us-central1-a

# AKS (az)
az aks create -g myResourceGroup -n myAKSCluster --node-count 3 --generate-ssh-keys
az aks get-credentials -g myResourceGroup -n myAKSCluster

########## Helm (optional, package manager) ##########
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

########## Cleanup / reset (kubeadm) ##########
sudo kubeadm reset -f
sudo rm -rf $HOME/.kube

```

---

# 🔥 1) Cluster Setup — Line-by-line explanations

(Each command from the block above, explained.)

### Install kubectl (Linux)

* `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"`

  * `curl -LO`: download a file from a URL and save with the remote filename.
  * `$(curl -L -s https://dl.k8s.io/release/stable.txt)`: fetches the latest stable Kubernetes release string (e.g., `v1.28.x`) and inserts it into the URL.
  * The full URL downloads the matching `kubectl` binary for your OS and arch.
* `sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl`

  * Moves the downloaded `kubectl` into `/usr/local/bin`, sets owner/root and executable permissions (`0755`).
* `kubectl version --client --short`

  * Verifies the client binary is installed and prints a short client version (doesn’t contact server).

### macOS / Windows installs

* `brew install kubectl` or `choco install kubernetes-cli`

  * Use the platform package manager to install `kubectl`.

---

### Minikube (local single-node)

* `minikube start --cpus=4 --memory=8192 --driver=docker`

  * Starts a local Kubernetes cluster using Minikube.
  * `--cpus=4` & `--memory=8192`: allocate 4 CPUs and 8GB RAM to the VM/container running the cluster.
  * `--driver=docker`: use Docker as the runtime (common for desktops).
* `minikube status`

  * Shows status of minikube components (host, kubelet, apiserver, kubeconfig).
* `minikube kubectl -- get nodes`

  * Runs the `kubectl` in the minikube context; helpful when you want the exact `kubectl` Minikube configured for the cluster.

### Kind (Kubernetes in Docker)

* `cat <<EOF > kind-config.yaml ... EOF`

  * Creates a config file for `kind` describing cluster topology (control-plane + worker).
* `kind create cluster --name dev-cluster --config kind-config.yaml`

  * Creates a multi-node cluster named `dev-cluster` according to the config.
* `kind get clusters`

  * Lists existing kind clusters.
* `kubectl cluster-info --context kind-dev-cluster`

  * Shows cluster endpoints using the `kind` context.

### kubeadm (bare-metal / VM clusters)

* `sudo swapoff -a`

  * Kubernetes requires swap to be disabled on nodes for kubelet to work predictably.

* `sudo kubeadm init --pod-network-cidr=10.244.0.0/16`

  * Initializes a control-plane node. `--pod-network-cidr` must match your CNI plugin’s expected CIDR (Flannel commonly uses `10.244.0.0/16`).
  * After this completes, `kubeadm` will print a `kubeadm join ...` command for worker nodes.

* `mkdir -p $HOME/.kube`

  * Ensure kubeconfig folder exists.

* `sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config`

  * Copy the admin kubeconfig so your local `kubectl` can talk to the new cluster.

* `sudo chown $(id -u):$(id -g) $HOME/.kube/config`

  * Make you the owner of the kubeconfig file so kubectl can read it as non-root.

* `kubectl get nodes`

  * Verify the control-plane node shows up (it may be `NotReady` until CNI is installed).

* Worker join (run on worker VM):

  * `sudo kubeadm join <CONTROL_PLANE_IP>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>`

    * This command is printed by `kubeadm init`. It securely enrolls the worker into the cluster. `<token>` and `<hash>` must match the control-plane data.

### Install CNI (network plugin)

* `kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml`

  * Applies Calico manifests to install the Calico CNI. The CNI provides pod networking — without it pods cannot reach each other.
* `kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml`

  * Apply Flannel manifests as an alternative CNI.

> Note: choose one CNI. The CIDR you passed to `kubeadm init` must be compatible with the chosen CNI.

### Verify cluster

* `kubectl get nodes -o wide`

  * Shows nodes and more details (addresses, OS, kernel, roles).
* `kubectl get pods -A`

  * Lists all pods in all namespaces (including kube-system, where the CNI daemonsets will run).

### Cloud quick-create examples

* `eksctl create cluster --name prod-cluster --region us-east-1 --nodes 3 --node-type t3.medium`

  * `eksctl` is a convenience tool to spin up an EKS cluster on AWS (creates control plane + nodegroup).
* `gcloud container clusters create my-gke-cluster --zone us-central1-a --num-nodes=3 --machine-type=e2-medium`

  * Creates a GKE cluster on Google Cloud.
* `gcloud container clusters get-credentials my-gke-cluster --zone us-central1-a`

  * Fetches kubeconfig credentials and context for `kubectl`.
* `az aks create -g myResourceGroup -n myAKSCluster --node-count 3 --generate-ssh-keys`

  * Creates an AKS cluster in Azure.
* `az aks get-credentials -g myResourceGroup -n myAKSCluster`

  * Retrieves credentials and sets `kubectl` context.

> These cloud commands assume you have the respective CLIs (`eksctl`, `gcloud`, `az`) installed and authenticated.

### Helm

* `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`

  * Installs Helm 3.
* `helm version`

  * Verify installation.

### Cleanup / reset (kubeadm)

* `sudo kubeadm reset -f`

  * Removes cluster configuration on a host (useful for tearing down test VMs).
* `sudo rm -rf $HOME/.kube`

  * Remove kubeconfig if you want a fresh start.

---

# 🔥 2) Kubectl Basics — ALL commands (copy-paste)

```bash
kubectl version --client --short
kubectl cluster-info
kubectl config view
kubectl config get-contexts
kubectl config current-context
kubectl config use-context <context>
kubectl config set-context --current --namespace=<namespace>

kubectl get nodes -o wide
kubectl describe node <node-name>

kubectl get namespaces
kubectl get pods -A
kubectl get pods -n <namespace>
kubectl get pods -o wide -n <namespace>
kubectl describe pod <pod-name> -n <namespace>

kubectl logs <pod-name> -n <namespace>
kubectl logs -f <pod-name> -c <container-name> -n <namespace>

kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh

kubectl get svc -n <namespace>
kubectl describe svc <svc-name> -n <namespace>

kubectl get deploy -n <namespace>
kubectl apply -f deployment.yaml
kubectl create -f deployment.yaml
kubectl delete -f deployment.yaml

kubectl scale deployment/<name> --replicas=3 -n <namespace>
kubectl set image deployment/<name> <container>=<image>:<tag> -n <namespace>

kubectl rollout status deployment/<name> -n <namespace>
kubectl rollout history deployment/<name> -n <namespace>
kubectl rollout undo deployment/<name> -n <namespace>

kubectl expose deployment <name> --port=80 --target-port=8080 --type=ClusterIP -n <namespace>
kubectl port-forward svc/<svc-name> 8080:80 -n <namespace>

kubectl top nodes
kubectl top pods -n <namespace>

kubectl get events -n <namespace> --sort-by='.metadata.creationTimestamp'
kubectl explain pod
kubectl apply -k ./kustomize-dir

kubectl label pod <pod-name> app=frontend -n <namespace>
kubectl annotate pod <pod-name> description="testing" -n <namespace>

kubectl wait --for=condition=available --timeout=120s deployment/<name> -n <namespace>

# output formatting & inspection
kubectl get pods -o wide
kubectl get pods -o yaml -n <namespace>
kubectl get pods -o json -n <namespace>
kubectl get pod <pod> -o jsonpath='{.status.containerStatuses[0].state}'
```

---

# 🔥 2) Kubectl Basics — Line-by-line explanations

(Each kubectl command explained, flags broken down, tips & common gotchas.)

### `kubectl version --client --short`

* Shows only the client (`kubectl`) version in a short form.
* Useful to confirm you installed the expected kubectl binary. To see server version too, remove `--client`.

### `kubectl cluster-info`

* Prints the Kubernetes master and DNS service endpoints (where the API server is reachable).
* Good sanity check that your kubeconfig context points to a working API server.

### `kubectl config view`

* Prints the kubeconfig file loaded by `kubectl` (contexts, clusters, users).
* **CAUTION:** kubeconfig may contain credentials (tokens/certs) — don’t share publicly.

### `kubectl config get-contexts`

* Lists saved contexts (a context = cluster + user + namespace).
* Shows which contexts exist and which is current.

### `kubectl config current-context`

* Prints the name of the currently active context.

### `kubectl config use-context <context>`

* Switches active context to `<context>` (changes which cluster `kubectl` talks to).

### `kubectl config set-context --current --namespace=<namespace>`

* Sets the namespace for the current context so you don’t need `-n` on every command.

---

### Node & describe

* `kubectl get nodes -o wide`

  * Lists cluster nodes; `-o wide` adds extra columns (IP, node role, version).
* `kubectl describe node <node-name>`

  * Shows detailed info: capacity, allocatable, addresses, conditions (Ready/MemoryPressure), non-terminated pods on the node, events. Use for node-level troubleshooting.

---

### Namespaces and pods

* `kubectl get namespaces`

  * Lists namespaces.
* `kubectl get pods -A`

  * Show pods across all namespaces (`-A` = `--all-namespaces`).
* `kubectl get pods -n <namespace>`

  * Show pods only in the provided namespace.
* `kubectl get pods -o wide -n <namespace>`

  * Adds node, IP, and restart count columns.
* `kubectl describe pod <pod-name> -n <namespace>`

  * Full details about a pod: containers, images, mount points, events (why a pod is failing). The events section is often the #1 troubleshooting aid.

---

### Logs

* `kubectl logs <pod-name> -n <namespace>`

  * Show logs for the pod’s **first/default** container.
* `kubectl logs -f <pod-name> -n <namespace>`

  * `-f` follow logs (like `tail -f`).
* `kubectl logs -f <pod-name> -c <container-name> -n <namespace>`

  * For multi-container pods, `-c` picks the container.
* Tips:

  * If `kubectl logs` returns nothing, check `kubectl describe pod` for CrashLoopBackOff / image pull errors.

---

### Exec (run a shell inside a container)

* `kubectl exec -it <pod-name> -n <namespace> -- /bin/bash`

  * `-i` interactive, `-t` allocate a TTY. The command after `--` runs inside the container.
  * Use `/bin/sh` if `bash` is not installed (common in tiny images).
* Do **not** exec into containers in production unless you have permission and a reason (debugging).

---

### Services

* `kubectl get svc -n <namespace>`

  * List services in namespace.
* `kubectl describe svc <svc-name> -n <namespace>`

  * Show ClusterIP / External IP, ports, endpoints (which pods/ips answer the service).

---

### Deployments & apply/create/delete

* `kubectl get deploy -n <namespace>`

  * Show deployments (desired/available replicas).
* `kubectl apply -f deployment.yaml`

  * Declarative: create or update resources to match the YAML (recommended for GitOps).
* `kubectl create -f deployment.yaml`

  * Imperative create; fails if resource exists.
* `kubectl delete -f deployment.yaml`

  * Delete resources defined in YAML.

Tip: Use `kubectl apply --dry-run=client -f file.yaml` to validate without applying.

---

### Scaling & image updates

* `kubectl scale deployment/<name> --replicas=3 -n <namespace>`

  * Scale the Deployment to 3 replicas.
* `kubectl set image deployment/<name> <container>=<image>:<tag> -n <namespace>`

  * Update the image of a container in a Deployment (triggers a rolling update).

---

### Rollouts (deploy updates safely)

* `kubectl rollout status deployment/<name> -n <namespace>`

  * Waits and shows rollout progress until all replicas are updated and ready.
* `kubectl rollout history deployment/<name> -n <namespace>`

  * Shows historical revisions with images and change-cause (if recorded).
* `kubectl rollout undo deployment/<name> -n <namespace>`

  * Roll back to previous revision.

---

### Expose / port-forward

* `kubectl expose deployment <name> --port=80 --target-port=8080 --type=ClusterIP -n <namespace>`

  * Creates a Service object that targets pods from the Deployment.
  * `--type=ClusterIP` (internal), `NodePort` or `LoadBalancer` for external access (cloud only).
* `kubectl port-forward svc/<svc-name> 8080:80 -n <namespace>`

  * For local testing: forwards local port `8080` to service port `80`. Good for debugging when no external LB exists.

---

### Metrics & events

* `kubectl top nodes`

  * Shows CPU/Memory usage for nodes (requires metrics-server installed).
* `kubectl top pods -n <namespace>`

  * CPU/memory per pod.
* `kubectl get events -n <namespace> --sort-by='.metadata.creationTimestamp'`

  * Shows events sorted by timestamp — useful to see recent scheduling, image-pull, or readiness events.

---

### Kustomize & explain

* `kubectl apply -k ./kustomize-dir`

  * Apply a Kustomize directory (overlays, patches).
* `kubectl explain pod`

  * Prints the API schema for `Pod` resource. Great to learn fields and nesting.
* `kubectl explain deployment.spec.template.spec.containers`

  * Drill into nested fields.

---

### Labels, annotations, wait

* `kubectl label pod <pod-name> app=frontend -n <namespace>`

  * Adds/updates a label; labels are used for selectors (services, deployments).
* `kubectl annotate pod <pod-name> description="testing" -n <namespace>`

  * Adds metadata that is not used for selection (free-text info).
* `kubectl wait --for=condition=available --timeout=120s deployment/<name> -n <namespace>`

  * Block until the deployment is `available` or timeout; useful in scripts/CI.

---

### Output formatting & JSONPath

* `kubectl get pods -o wide`

  * Extra columns.
* `kubectl get pods -o yaml -n <namespace>`

  * Full YAML of the resource.
* `kubectl get pod <pod> -o jsonpath='{.status.containerStatuses[0].state}'`

  * Extract specific JSON fields (good for scripting).

---

# Quick tips & recommended workflow for learning/practice

1. Start with **Minikube** or **Kind** — quick to spin up locally.
2. Practice `kubectl apply -f` vs `kubectl create -f` and `kubectl edit` / `kubectl patch`.
3. Use `kubectl describe` and `kubectl logs -f` as your first troubleshooting steps.
4. Install `metrics-server` in your cluster so `kubectl top` works.
5. Try a full lifecycle on one small app: `deploy -> expose -> scale -> set image -> rollout undo -> cleanup`.

---
# 🔥 3) Namespaces — ALL commands (copy-paste)
```bash
# List namespaces
kubectl get ns
kubectl get namespaces

# Create a namespace
kubectl create ns dev

# Describe namespace details
kubectl describe ns dev

# Set default namespace for current context
kubectl config set-context --current --namespace=dev

# Verify which namespace is active
kubectl config view --minify | grep namespace:

# Switch back to default namespace
kubectl config set-context --current --namespace=default

# Delete a namespace
kubectl delete ns dev
```
---
# 🔥 3) Namespaces — Line-by-line explanation
### `kubectl get ns` / `kubectl get namespaces`

* Lists all namespaces in the cluster.
* Default ones:

  * `default` → where resources go if you don’t specify a namespace.
  * `kube-system` → system pods (CoreDNS, kube-proxy, CNI plugins).
  * `kube-public` → readable by anyone (often cluster info/config).
  * `kube-node-lease` → tracks node heartbeats.

---
### `kubectl create ns dev`
* Creates a new namespace called `dev`.
* Useful to isolate workloads per environment/team (e.g., `dev`, `qa`, `prod`).

---

### `kubectl describe ns dev`

* Shows detailed info about the namespace:

  * Labels, annotations
  * Resource quotas, limits (if configured)
  * Status (Active/Terminating)

---
### `kubectl config set-context --current --namespace=dev`

* Sets your **current namespace** to `dev`.
* Now all `kubectl` commands default to `-n dev` so you don’t need to type `-n dev` each time.
  Example:

  ```bash
  kubectl get pods    # will now list pods in dev namespace
  ```

---
### `kubectl config view --minify | grep namespace:`

* Displays the namespace currently active in your kubeconfig.
* `--minify` ensures it only shows your current context.

---
### `kubectl config set-context --current --namespace=default`

* Switches back to default namespace (undo previous change).

---
### `kubectl delete ns dev`

* Deletes the entire namespace and **all resources inside it** (pods, deployments, services, etc.).
* Careful ⚠️ — this is destructive.

---

👉 So **Namespaces** are like “folders” for resources inside a cluster. They help organize, isolate, and apply RBAC or resource quotas per environment/team.

---

# 🔥 4) Nodes — ALL commands (copy-paste)

```bash
# List all nodes in the cluster
kubectl get nodes
kubectl get nodes -o wide

# Describe a node
kubectl describe node <node-name>

# Check node resource usage (requires metrics-server)
kubectl top node
kubectl top nodes

# Cordon a node (no new pods will schedule here)
kubectl cordon <node-name>

# Drain a node (evict pods safely, usually before maintenance)
kubectl drain <node-name> --ignore-daemonsets --force --delete-emptydir-data

# Uncordon (make node schedulable again)
kubectl uncordon <node-name>

# Label a node (used for scheduling / selectors)
kubectl label node <node-name> env=prod

# Remove a label from a node
kubectl label node <node-name> env-

# Get node annotations
kubectl get node <node-name> -o yaml | grep annotations

# Delete a node object (e.g., when VM is terminated)
kubectl delete node <node-name>
```

---

# 🔥 4) Nodes — Line-by-line explanation

### `kubectl get nodes`

* Lists all nodes registered in the cluster.
* Shows **STATUS**:

  * `Ready` → healthy & schedulable.
  * `NotReady` → problem with kubelet or network.
* Other columns: roles (control-plane/worker), version, age.

### `kubectl get nodes -o wide`

* Adds details: Internal/External IP, OS, Kernel, Container Runtime.
* Helpful for troubleshooting node infra.

---

### `kubectl describe node <node-name>`

* Shows full details of the node:

  * Allocatable resources (CPU/memory)
  * Pod capacity
  * Labels
  * Conditions (Ready, DiskPressure, MemoryPressure, NetworkUnavailable)
  * List of pods running on this node
  * Recent node events

---

### `kubectl top node` / `kubectl top nodes`

* Requires `metrics-server` installed.
* Shows live CPU and memory usage per node.

---

### `kubectl cordon <node-name>`

* Marks node as **unschedulable** — no new pods will be scheduled there.
* Existing pods continue running.

---

### `kubectl drain <node-name> --ignore-daemonsets --force --delete-emptydir-data`

* Prepares a node for maintenance by evicting pods.
* `--ignore-daemonsets` → DaemonSet pods are ignored (they always run on all nodes).
* `--delete-emptydir-data` → deletes local `emptyDir` volumes (warning: data loss).
* `--force` → required when dealing with non-managed pods.

---

### `kubectl uncordon <node-name>`

* Marks the node as schedulable again — new pods can be placed here.

---
### `kubectl label node <node-name> env=prod`

* Attaches a key/value label to the node.
* Labels are used for scheduling with **nodeSelector**, **node affinity**, or **taints/tolerations**.

### `kubectl label node <node-name> env-`

* Removes the `env` label from the node.

---
### `kubectl get node <node-name> -o yaml | grep annotations`

* View annotations (metadata often used by cloud providers or operators).

---
### `kubectl delete node <node-name>`

* Deletes the Node object from Kubernetes.
* Used if the underlying VM/host is gone, and you want to clean up the cluster view.

---

👉 **Nodes** are the worker machines (VMs/servers) where pods actually run. Master/control-plane nodes manage the cluster, worker nodes run workloads.

---
# 🔥 5) Pods — ALL commands (copy-paste)

```bash
# List all pods in current namespace
kubectl get pods
kubectl get pod
kubectl get pods -o wide

# List pods in all namespaces
kubectl get pods -A

# Describe a specific pod
kubectl describe pod <pod-name>

# Get pod details in YAML/JSON format
kubectl get pod <pod-name> -o yaml
kubectl get pod <pod-name> -o json

# Create a pod using imperative command
kubectl run mypod --image=nginx

# Expose pod as a service
kubectl expose pod mypod --port=80 --type=NodePort

# Execute a command inside a pod container
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- ls /usr/share/nginx/html

# Copy files between pod and local system
kubectl cp <pod-name>:/path/in/container /path/on/local
kubectl cp /path/on/local <pod-name>:/path/in/container

# Get logs from a pod
kubectl logs <pod-name>
kubectl logs -f <pod-name>     # follow logs (live streaming)

# Delete a pod
kubectl delete pod <pod-name>
kubectl delete pod --all       # delete all pods in namespace
```

---

# 🔥 5) Pods — Line-by-line explanation

### `kubectl get pods` / `kubectl get pod`

* Lists all pods in the current namespace.
* Columns: NAME, READY, STATUS, RESTARTS, AGE.

  * **READY** → how many containers are running vs. expected.
  * **STATUS** → Pending, Running, Completed, CrashLoopBackOff, etc.
  * **RESTARTS** → number of times the pod containers restarted.
  * **AGE** → how long the pod has been running.

---
### `kubectl get pods -o wide`

* Adds more details like **Node name** (where pod is running) and Pod IP.

---
### `kubectl get pods -A`

* Lists pods across **all namespaces**.
* Useful for troubleshooting system pods (like in `kube-system`).

---

### `kubectl describe pod <pod-name>`

* Shows detailed info about the pod:

  * Labels, annotations
  * Containers inside pod
  * Events (like scheduling issues, image pull errors)

---

### `kubectl get pod <pod-name> -o yaml` / `-o json`

* Dumps the complete pod spec in YAML/JSON.
* Useful for debugging or exporting configs.

---

### `kubectl run mypod --image=nginx`

* Creates a pod named **mypod** running the **nginx** image.
* This is an **imperative** way (quick test).
* In real projects, pods are usually created via YAML manifests.

---

### `kubectl expose pod mypod --port=80 --type=NodePort`

* Creates a **Service** exposing pod `mypod` on port `80`.
* `NodePort` → accessible on a port of the cluster node IP.

---

### `kubectl exec -it <pod-name> -- /bin/bash`

* Opens an interactive shell inside the pod’s container.
* `-it` → interactive + terminal.
* Useful for debugging inside containers.

### `kubectl exec -it <pod-name> -- ls /usr/share/nginx/html`

* Runs a one-off command (here, `ls`) inside container without entering shell.

---

### `kubectl cp <pod-name>:/path/in/container /path/on/local`

* Copies file **from pod → local system**.

### `kubectl cp /path/on/local <pod-name>:/path/in/container`

* Copies file **from local → pod container**.

---

### `kubectl logs <pod-name>`

* Fetches logs from a pod’s **main container**.
* Helpful to check application output/errors.

### `kubectl logs -f <pod-name>`

* Follows logs in real-time (like `tail -f`).

---

### `kubectl delete pod <pod-name>`

* Deletes a specific pod.
* Since pods are usually managed by **ReplicaSets/Deployments**, Kubernetes will recreate them automatically.

### `kubectl delete pod --all`

* Deletes **all pods** in the namespace.

---
👉 **Key Takeaways on Pods**

* Pod = smallest deployable unit in Kubernetes.
* It can contain **one or multiple containers**.
* Pods are usually **not created directly** in real projects — instead, Deployments, ReplicaSets, or StatefulSets manage them.

---
# 🔥 6) Deployments — ALL commands

```bash
# List all deployments
kubectl get deploy
kubectl get deployment

# Create deployment (imperative way)
kubectl create deployment nginx --image=nginx:latest --replicas=3

# Apply deployment from YAML manifest
kubectl apply -f deployment.yaml

# Get detailed info about a deployment
kubectl describe deploy nginx

# Scale deployment
kubectl scale deployment nginx --replicas=5

# Update container image in deployment
kubectl set image deployment/nginx nginx=nginx:1.21

# Check rollout status
kubectl rollout status deployment/nginx

# View rollout history
kubectl rollout history deployment/nginx

# Undo last rollout
kubectl rollout undo deployment/nginx

# Delete deployment
kubectl delete deployment nginx
```

---
# 🔥 6) Deployments — Line-by-line explanation

### `kubectl get deploy` / `kubectl get deployment`

* Lists all deployments in current namespace.
* Shows NAME, READY pods, UP-TO-DATE, AVAILABLE, AGE.

---

### `kubectl create deployment nginx --image=nginx:latest --replicas=3`

* Creates a deployment named **nginx** with 3 replicas of the nginx container.
* Imperative (quick test) way, mostly for demos.

---

### `kubectl apply -f deployment.yaml`

* Applies configuration from a YAML file.
* Preferred in real projects (declarative approach).

---

### `kubectl describe deploy nginx`

* Detailed info about the deployment:

  * Number of replicas desired vs running.
  * Events like scaling, rollout progress.

---

### `kubectl scale deployment nginx --replicas=5`

* Increases (or decreases) replicas count.
* Scaling is instant and common in real workloads.

---

### `kubectl set image deployment/nginx nginx=nginx:1.21`

* Updates the container image version in deployment.
* Triggers a **rolling update** of pods.

---

### `kubectl rollout status deployment/nginx`

* Shows status of rollout (update).
* Helpful for checking if rollout completed successfully.

---

### `kubectl rollout history deployment/nginx`

* Displays history of deployment revisions (for rollback reference).

---

### `kubectl rollout undo deployment/nginx`

* Rollback to previous version of deployment.
* Common when new release has issues.

---

### `kubectl delete deployment nginx`

* Deletes the deployment and all its pods.

---
# 🔥 7) ReplicaSets — ALL commands

```bash
# List ReplicaSets
kubectl get rs

# Describe a ReplicaSet
kubectl describe rs <replicaset-name>

# Get ReplicaSet in YAML
kubectl get rs <replicaset-name> -o yaml

# Delete a ReplicaSet
kubectl delete rs <replicaset-name>
```

---
# 🔥 7) ReplicaSets — Line-by-line explanation

### `kubectl get rs`

* Lists all ReplicaSets created in namespace.
* ReplicaSets manage **desired number of pod replicas**.

---

### `kubectl describe rs <replicaset-name>`

* Shows details about the ReplicaSet:

  * Labels, selectors
  * Pods it manages
  * Events

---

### `kubectl get rs <replicaset-name> -o yaml`

* Outputs complete YAML configuration.

---

### `kubectl delete rs <replicaset-name>`

* Deletes ReplicaSet and its pods.

---

👉 **Key Takeaways**

* **Deployment** → manages ReplicaSets + rolling updates.
* **ReplicaSet** → manages Pods (ensures desired number).
* In practice, you almost always use **Deployments**, not ReplicaSets directly.

---
# 🔥 8) Services (Networking) — ALL commands

```bash
# List services
kubectl get svc
kubectl get services

# Create service (ClusterIP, default type)
kubectl expose deployment nginx --port=80 --target-port=8080 --type=ClusterIP

# Create NodePort service
kubectl expose deployment nginx --port=80 --type=NodePort

# Create LoadBalancer service (on cloud providers)
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Describe service
kubectl describe svc nginx

# Get service in YAML/JSON
kubectl get svc nginx -o yaml
kubectl get svc nginx -o json

# Delete service
kubectl delete svc nginx
```

---
# 🔥 8) Services — Line-by-line explanation

### `kubectl get svc` / `kubectl get services`

* Lists all services in the current namespace.
* Columns: NAME, TYPE, CLUSTER-IP, EXTERNAL-IP, PORT(S), AGE.

---

### `kubectl expose deployment nginx --port=80 --target-port=8080 --type=ClusterIP`

* Creates a **Service** that forwards traffic on port 80 → to container port 8080.
* **ClusterIP** (default): accessible **inside the cluster only**.

---

### `kubectl expose deployment nginx --port=80 --type=NodePort`

* Creates a **NodePort Service**.
* Opens a port (30000–32767) on each node’s IP → traffic is forwarded to pods.
* Useful for accessing apps from outside the cluster (on bare-metal/local).

---

### `kubectl expose deployment nginx --port=80 --type=LoadBalancer`

* Creates a **LoadBalancer Service**.
* Works on cloud providers (AWS, GCP, Azure).
* Exposes app to the internet via external load balancer.

---

### `kubectl describe svc nginx`

* Shows detailed info: selector, endpoints (pods connected), and ports.

---

### `kubectl get svc nginx -o yaml`

* Dumps service config in YAML → can be used for backup/infra as code.

---

### `kubectl delete svc nginx`

* Deletes the service (pods keep running, but no network exposure).

---
# 🔥 9) Ingress — ALL commands
```bash
# List ingresses
kubectl get ing
kubectl get ingress

# Apply ingress from YAML file
kubectl apply -f ingress.yaml

# Describe ingress
kubectl describe ing <ingress-name>

# Get ingress details in YAML
kubectl get ing <ingress-name> -o yaml

# Delete ingress
kubectl delete ing <ingress-name>
```

---
# 🔥 9) Ingress — Line-by-line explanation

### `kubectl get ing` / `kubectl get ingress`

* Lists all ingress resources in current namespace.
* Columns: NAME, CLASS, HOSTS, ADDRESS, PORTS, AGE.

---

### `kubectl apply -f ingress.yaml`

* Creates ingress resource from YAML.
* YAML defines **rules** mapping domain/path → service backend.
* Example:

  * `example.com/app1` → service1
  * `example.com/app2` → service2

---

### `kubectl describe ing <ingress-name>`

* Shows details: rules, backends, and events.
* Useful for troubleshooting ingress issues.

---

### `kubectl get ing <ingress-name> -o yaml`

* Outputs ingress configuration in YAML.

---

### `kubectl delete ing <ingress-name>`

* Deletes ingress resource.

---

👉 **Key Takeaways (Services vs Ingress):**

* **Service** = stable internal/external access to pods.
* **ClusterIP** = internal only.
* **NodePort** = external via node’s IP + port.
* **LoadBalancer** = external via cloud LB.
* **Ingress** = routes HTTP/HTTPS traffic to services using hostname/path rules.

---
# 🔥 10) ConfigMaps & Secrets — ALL commands

```bash
# ----------------
# ConfigMaps
# ----------------

# Create ConfigMap from literal key-value pairs
kubectl create configmap app-config --from-literal=APP_ENV=prod --from-literal=APP_DEBUG=false

# Create ConfigMap from a file
kubectl create configmap app-config-file --from-file=config.properties

# List all ConfigMaps
kubectl get configmap
kubectl get cm

# Describe ConfigMap
kubectl describe configmap app-config

# View ConfigMap in YAML
kubectl get configmap app-config -o yaml

# Delete ConfigMap
kubectl delete configmap app-config

# ----------------
# Secrets
# ----------------

# Create Secret from literal values
kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASS=pass123

# Create Secret from a file
kubectl create secret generic tls-secret --from-file=cert.crt --from-file=cert.key

# List all Secrets
kubectl get secret
kubectl get secrets

# Describe Secret
kubectl describe secret db-secret

# View secret (base64 encoded)
kubectl get secret db-secret -o yaml

# Decode secret value
kubectl get secret db-secret -o jsonpath='{.data.DB_PASS}' | base64 --decode

# Delete Secret
kubectl delete secret db-secret
```

---

# 🔥 10) ConfigMaps — Line-by-line explanation

### `kubectl create configmap app-config --from-literal=APP_ENV=prod --from-literal=APP_DEBUG=false`

* Creates ConfigMap named **app-config**.
* Stores key-value pairs (like env vars).
* Example: `APP_ENV=prod`, `APP_DEBUG=false`.

---

### `kubectl create configmap app-config-file --from-file=config.properties`

* Creates ConfigMap from an external file.
* File contents → become key-value entries in ConfigMap.

---

### `kubectl get configmap` / `kubectl get cm`

* Lists all ConfigMaps in namespace.

---

### `kubectl describe configmap app-config`

* Shows details of ConfigMap (keys/values, metadata).

---

### `kubectl get configmap app-config -o yaml`

* Dumps the ConfigMap YAML.
* Useful for backup or applying elsewhere.

---

### `kubectl delete configmap app-config`

* Deletes the ConfigMap.

---

# 🔥 10) Secrets — Line-by-line explanation

### `kubectl create secret generic db-secret --from-literal=DB_USER=admin --from-literal=DB_PASS=pass123`

* Creates a generic Secret named **db-secret**.
* Stores sensitive data (base64-encoded).
* Example keys: DB\_USER, DB\_PASS.

---

### `kubectl create secret generic tls-secret --from-file=cert.crt --from-file=cert.key`

* Creates a Secret from files (useful for TLS certs, SSH keys).

---

### `kubectl get secret` / `kubectl get secrets`

* Lists all Secrets in namespace.
* Shows NAME, TYPE (Opaque, TLS, Docker config), AGE.

---

### `kubectl describe secret db-secret`

* Shows metadata (but **not actual secret values**).
* For security reasons, values are hidden.

---

### `kubectl get secret db-secret -o yaml`

* Prints YAML including `data` field (base64 encoded values).

---

### `kubectl get secret db-secret -o jsonpath='{.data.DB_PASS}' | base64 --decode`

* Extracts and decodes secret value.
* Example: prints `pass123`.

---

### `kubectl delete secret db-secret`

* Deletes the secret.

---

👉 **Key Takeaways (ConfigMap vs Secret):**

* **ConfigMap** → Non-sensitive data (app configs, env vars).
* **Secret** → Sensitive data (passwords, API keys, TLS certs).
* Both are injected into pods as:

  * **Environment variables**
  * **Mounted volumes (files)**

---

# 🔥 11) Storage (PV & PVC) — ALL commands

```bash
# ----------------
# Persistent Volumes (PV)
# ----------------

# List all PersistentVolumes
kubectl get pv

# Get detailed info about a PV
kubectl describe pv <pv-name>

# Get PV definition in YAML
kubectl get pv <pv-name> -o yaml

# Delete a PV
kubectl delete pv <pv-name>

# ----------------
# Persistent Volume Claims (PVC)
# ----------------

# List all PersistentVolumeClaims
kubectl get pvc

# Get details about a PVC
kubectl describe pvc <pvc-name>

# Get PVC definition in YAML
kubectl get pvc <pvc-name> -o yaml

# Create a PVC from YAML
kubectl apply -f pvc.yaml

# Delete PVC
kubectl delete pvc <pvc-name>

# ----------------
# Pods using PVC
# ----------------

# Create a pod that uses PVC
kubectl apply -f pod-using-pvc.yaml

# Check mounted volumes inside pod
kubectl exec -it <pod-name> -- df -h
kubectl exec -it <pod-name> -- ls /mnt/data
```

---

# 🔥 11) Storage — Line-by-line explanation

### PersistentVolume (PV)

* A **cluster-wide resource** representing storage (local disk, NFS, EBS, GCP Disk, etc).
* Admins create PVs, developers claim them using PVCs.

---

### `kubectl get pv`

* Lists all PVs in cluster.
* Columns: NAME, CAPACITY, ACCESS MODES, RECLAIM POLICY, STATUS, CLAIM, STORAGECLASS, AGE.

---

### `kubectl describe pv <pv-name>`

* Detailed info about the PV:

  * Capacity (size of storage)
  * Access modes:

    * `RWO` → ReadWriteOnce
    * `ROX` → ReadOnlyMany
    * `RWX` → ReadWriteMany
  * Reclaim policy (Retain, Delete, Recycle)
  * Bound claim (PVC using it)

---

### `kubectl get pv <pv-name> -o yaml`

* Shows PV definition in YAML.
* Useful for debugging or exporting config.

---

### `kubectl delete pv <pv-name>`

* Deletes a PV.
* If a PVC is bound, it must be released first.

---

### PersistentVolumeClaim (PVC)

* A **request for storage** made by users.
* PVC specifies storage size & access mode → Kubernetes binds it to a suitable PV.

---

### `kubectl get pvc`

* Lists all PVCs in namespace.
* Shows NAME, STATUS (Pending/Bound), VOLUME (bound PV), CAPACITY, ACCESS MODES, STORAGECLASS.

---

### `kubectl describe pvc <pvc-name>`

* Shows detailed info about claim: requested size, access mode, events.

---

### `kubectl get pvc <pvc-name> -o yaml`

* Prints YAML definition of PVC.

---

### `kubectl apply -f pvc.yaml`

* Creates PVC from YAML definition.
* Example `pvc.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

---

### `kubectl delete pvc <pvc-name>`

* Deletes PVC.
* PV may be released or deleted depending on reclaim policy.

---

### Using PVC in Pods

* PVCs are mounted into Pods as volumes.

Example `pod-using-pvc.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - mountPath: "/mnt/data"
          name: storage
  volumes:
    - name: storage
      persistentVolumeClaim:
        claimName: mypvc
```

---

### `kubectl exec -it <pod-name> -- df -h`

* Check mounted volumes inside pod.

### `kubectl exec -it <pod-name> -- ls /mnt/data`

* Verify data is accessible in the mounted path.

---

👉 **Key Takeaways (Storage):**

* **PV** = actual storage resource.
* **PVC** = claim/request for storage.
* **Pod** mounts PVC → gets persistent storage.
* Without PV/PVC, data in Pods is **lost when Pod restarts**.

---
# 🔥 12) DaemonSets — ALL commands

```bash
# List all DaemonSets in current namespace
kubectl get ds

# List DaemonSets across all namespaces
kubectl get ds -A

# Describe a DaemonSet
kubectl describe ds <daemonset-name>

# Get DaemonSet in YAML/JSON
kubectl get ds <daemonset-name> -o yaml
kubectl get ds <daemonset-name> -o json

# Apply a DaemonSet from YAML
kubectl apply -f daemonset.yaml

# Delete a DaemonSet
kubectl delete ds <daemonset-name>
```

---

# 🔥 12) DaemonSets — Line-by-line explanation

### `kubectl get ds`

* Lists all **DaemonSets** in current namespace.
* Columns: NAME, DESIRED, CURRENT, READY, UP-TO-DATE, AVAILABLE, NODE SELECTOR, AGE.
* Example:

  * DESIRED = number of nodes that should run a pod.
  * CURRENT = number of nodes actually running the pod.

---

### `kubectl get ds -A`

* Lists DaemonSets across **all namespaces**.
* Useful for checking system-level DaemonSets (like logging/monitoring agents).

---

### `kubectl describe ds <daemonset-name>`

* Shows detailed info:

  * Pods managed by the DaemonSet.
  * Events (scheduling, errors, etc).
  * Node selectors, tolerations, etc.

---

### `kubectl get ds <daemonset-name> -o yaml`

* Dumps YAML config of DaemonSet.
* Good for debugging or exporting config.

---

### `kubectl apply -f daemonset.yaml`

* Creates or updates a DaemonSet from YAML definition.
* Example `daemonset.yaml`:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-agent
spec:
  selector:
    matchLabels:
      app: log-agent
  template:
    metadata:
      labels:
        app: log-agent
    spec:
      containers:
        - name: fluentd
          image: fluent/fluentd:latest
```

👉 This ensures **one Fluentd pod runs on every node** for log collection.

---

### `kubectl delete ds <daemonset-name>`

* Deletes the DaemonSet.
* Removes pods scheduled by it from all nodes.

---

👉 **Key Takeaways (DaemonSets):**

* DaemonSet ensures **one copy of a pod runs on each node** (or selected nodes).
* Commonly used for:

  * **Log collection agents** (Fluentd, Filebeat).
  * **Monitoring agents** (Prometheus Node Exporter, Datadog agent).
  * **Networking components** (CNI plugins, kube-proxy).
* Unlike Deployments, scaling = number of nodes (not replicas).

---
# 🔥 13) Jobs — ALL commands

```bash
# Create a Job from YAML
kubectl apply -f job.yaml

# List all Jobs
kubectl get jobs

# Describe a Job
kubectl describe job <job-name>

# Get Job details in YAML
kubectl get job <job-name> -o yaml

# Check pods created by a Job
kubectl get pods --selector=job-name=<job-name>

# Delete a Job
kubectl delete job <job-name>
```

---

# 🔥 13) Jobs — Line-by-line Explanation

### `kubectl apply -f job.yaml`

* Creates a **Job**.
* A Job runs **one-time tasks** (e.g., data migration, batch process).

Example `job.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-job
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```

👉 This Job runs a Perl script to calculate π (pi) to 2000 digits and then **exits**.

---

### `kubectl get jobs`

* Lists all jobs.
* Columns: NAME, COMPLETIONS, DURATION, AGE.
* Example: `1/1` completions = job finished successfully.

---

### `kubectl describe job <job-name>`

* Shows detailed info:

  * How many pods were created.
  * Pod success/failure history.
  * Conditions (e.g., Completed, Failed).

---

### `kubectl get job <job-name> -o yaml`

* Dumps YAML config of a job.
* Useful for debugging or cloning jobs.

---

### `kubectl get pods --selector=job-name=<job-name>`

* Each Job creates one or more pods.
* This command lists those pods.

---

### `kubectl delete job <job-name>`

* Deletes the Job and its pods.

---

# 🔥 14) CronJobs — ALL commands

```bash
# Create a CronJob from YAML
kubectl apply -f cronjob.yaml

# List all CronJobs
kubectl get cronjobs

# Describe a CronJob
kubectl describe cronjob <cronjob-name>

# Get CronJob in YAML
kubectl get cronjob <cronjob-name> -o yaml

# Delete a CronJob
kubectl delete cronjob <cronjob-name>
```

---

# 🔥 14) CronJobs — Line-by-line Explanation

### `kubectl apply -f cronjob.yaml`

* Creates a **CronJob**.
* A CronJob runs a **Job on a schedule** (like Linux cron).

Example `cronjob.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cron
spec:
  schedule: "*/2 * * * *"   # Runs every 2 minutes
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo "Hello from Kubernetes CronJob"
          restartPolicy: OnFailure
```

👉 This runs every **2 minutes** and prints "Hello".

---

### `kubectl get cronjobs`

* Lists CronJobs.
* Columns: NAME, SCHEDULE, SUSPEND, ACTIVE, LAST SCHEDULE, AGE.

---

### `kubectl describe cronjob <cronjob-name>`

* Shows full details:

  * Schedule, concurrency policy.
  * Last schedule time.
  * Jobs created by this CronJob.

---

### `kubectl get cronjob <cronjob-name> -o yaml`

* Dumps CronJob config.

---

### `kubectl delete cronjob <cronjob-name>`

* Deletes CronJob and prevents future jobs.

---

👉 **Key Takeaways (Jobs & CronJobs):**

* **Job** = Run a one-time task until completion.
* **CronJob** = Schedule jobs to run periodically.
* Common use cases:

  * Jobs → Database migrations, backups, report generation.
  * CronJobs → Log rotation, sending daily emails, cleanup tasks.

---
# 🔥 15) Probes — ALL commands

```bash
# Apply a pod with probes from YAML
kubectl apply -f probes-pod.yaml

# List pods
kubectl get pods

# Describe pod (to check probe status/events)
kubectl describe pod <pod-name>

# Check logs of a pod failing probe
kubectl logs <pod-name>

# Delete pod with probes
kubectl delete pod <pod-name>
```

---

# 🔥 15) Probes — Explanation Line by Line

## 1) `kubectl apply -f probes-pod.yaml`

* Creates a pod with **probes** (health checks).
* Example YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 5
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 30
      periodSeconds: 10
```

👉 In this YAML:

* **Liveness Probe** → Checks if app is alive. If it fails, K8s **restarts** the container.
* **Readiness Probe** → Checks if app is ready to serve traffic. If it fails, pod is **removed from service endpoints** (no traffic).
* **Startup Probe** → Useful for slow-starting apps. K8s waits until startup probe passes before running liveness/readiness.

---

## 2) `kubectl get pods`

* Shows pod status.
* If probes are failing → pod may show `CrashLoopBackOff` or `Running` but not ready.

---

## 3) `kubectl describe pod <pod-name>`

* Shows probe details and events.
* Example output:

  ```
  Liveness: http-get http://:80/ delay=5s timeout=1s period=10s #success=1 #failure=3
  Readiness: http-get http://:80/ delay=3s timeout=1s period=5s #success=1 #failure=3
  ```
* You can see if the probe passed/failed.

---

## 4) `kubectl logs <pod-name>`

* Useful when probes keep failing.
* You check logs to debug why the app is not healthy or not responding.

---

## 5) `kubectl delete pod <pod-name>`

* Deletes the pod.
* If managed by Deployment/ReplicaSet, it will be recreated with probes again.

---

# 👉 Key Takeaways (Probes)

* **Liveness Probe** → Ensures the app is alive. Restart container if it hangs.
* **Readiness Probe** → Ensures the app is ready to serve requests. No traffic until it’s ready.
* **Startup Probe** → Used for apps that take long to start (database, JVM apps, etc.).
* Without probes, Kubernetes cannot automatically detect if your app is **dead** or just **unready**.

---
# 🔥 16) RBAC — ALL Commands

```bash
# 1. Create a ServiceAccount
kubectl create sa dev-sa -n dev

# 2. Create a Role (namespace scoped)
kubectl create role pod-reader --verb=get,list,watch --resource=pods -n dev

# 3. Create a RoleBinding (binds role to SA)
kubectl create rolebinding read-pods-binding --role=pod-reader --serviceaccount=dev:dev-sa -n dev

# 4. View Roles and RoleBindings
kubectl get role,rolebinding -n dev

# 5. Create a ClusterRole (cluster-wide)
kubectl create clusterrole pod-admin --verb=get,list,watch,create,delete --resource=pods

# 6. Bind ClusterRole to SA (ClusterRoleBinding)
kubectl create clusterrolebinding pod-admin-binding --clusterrole=pod-admin --serviceaccount=dev:dev-sa

# 7. Describe Role/ClusterRole
kubectl describe role pod-reader -n dev
kubectl describe clusterrole pod-admin

# 8. Delete Role/Binding
kubectl delete role pod-reader -n dev
kubectl delete rolebinding read-pods-binding -n dev
```

---

# 🔥 16) RBAC — Line by Line Explanation

---

### `kubectl create sa dev-sa -n dev`

* Creates a **ServiceAccount** named `dev-sa` in `dev` namespace.
* ServiceAccounts are identities for pods/users inside cluster.
* By default, pods use `default` ServiceAccount.

---

### `kubectl create role pod-reader --verb=get,list,watch --resource=pods -n dev`

* Creates a **Role** named `pod-reader` in namespace `dev`.
* Role is **namespace-scoped**.
* It allows **get, list, watch** on `pods`.
* Does NOT apply outside namespace.

---

### `kubectl create rolebinding read-pods-binding --role=pod-reader --serviceaccount=dev:dev-sa -n dev`

* Binds **Role = pod-reader** to **ServiceAccount = dev-sa**.
* Now `dev-sa` can only **read pods** in namespace `dev`.

---

### `kubectl get role,rolebinding -n dev`

* Lists all Roles and RoleBindings in namespace `dev`.
* Useful to verify RBAC setup.

---

### `kubectl create clusterrole pod-admin --verb=get,list,watch,create,delete --resource=pods`

* Creates a **ClusterRole** named `pod-admin`.
* Unlike Role, **ClusterRole is cluster-wide**.
* This one allows **full pod management** (get, list, watch, create, delete).

---

### `kubectl create clusterrolebinding pod-admin-binding --clusterrole=pod-admin --serviceaccount=dev:dev-sa`

* Creates a **ClusterRoleBinding** that gives `pod-admin` permissions to ServiceAccount `dev-sa`.
* Now `dev-sa` can manage pods **across all namespaces**.

---

### `kubectl describe role pod-reader -n dev`

### `kubectl describe clusterrole pod-admin`

* Shows detailed rules of Role / ClusterRole.
* Useful for debugging permissions.

---

### `kubectl delete role pod-reader -n dev`

### `kubectl delete rolebinding read-pods-binding -n dev`

* Removes Role and RoleBinding.
* The ServiceAccount `dev-sa` will lose access.

---

# 👉 Key Takeaways (RBAC)

* **Role** → Namespace-scoped permissions.
* **ClusterRole** → Cluster-wide permissions.
* **RoleBinding** → Grants Role to a user/ServiceAccount in one namespace.
* **ClusterRoleBinding** → Grants ClusterRole across namespaces.
* **ServiceAccounts** → Pods use them to talk to the API securely.

Common real use cases:

* Developers → read-only access to dev namespace.
* CI/CD pipelines → ServiceAccount with create/update rights.
* Monitoring tools → ClusterRole with list/watch across cluster.

---
# 🔥 17) Monitoring & Metrics — ALL Commands

```bash
# 1. Check resource usage (requires metrics-server)
kubectl top nodes
kubectl top pods
kubectl top pods -n dev

# 2. Get events in a namespace
kubectl get events -n dev
kubectl get events --sort-by=.metadata.creationTimestamp

# 3. Describe resources (to check detailed status)
kubectl describe pod <pod-name>
kubectl describe node <node-name>

# 4. Get logs of a pod
kubectl logs <pod-name>
kubectl logs -f <pod-name>
kubectl logs <pod-name> -c <container-name>

# 5. Debugging with ephemeral containers (K8s v1.23+)
kubectl debug -it <pod-name> --image=busybox --target=<container-name>

# 6. Check cluster info and component health
kubectl cluster-info
kubectl get componentstatuses   # (deprecated, but often used)
```

---

# 🔥 17) Monitoring & Metrics — Line by Line Explanation

---

### `kubectl top nodes`

* Shows **CPU & Memory usage per node**.
* Requires **metrics-server** to be installed.
* Useful for capacity planning, scaling decisions.

---

### `kubectl top pods`

* Shows **CPU & Memory usage per pod** in the current namespace.
* Use `-n <namespace>` for other namespaces.
* Helps identify high resource consumers.

---

### `kubectl get events -n dev`

* Lists all recent **events** in `dev` namespace.
* Events = scheduling, failures, image pull errors, restarts, etc.

---

### `kubectl get events --sort-by=.metadata.creationTimestamp`

* Shows events in **time order**.
* Very useful when debugging crashes or deployments.

---

### `kubectl describe pod <pod-name>`

* Detailed pod info → containers, probes, node placement, events.
* Useful when pod stuck in `Pending` or `CrashLoopBackOff`.

---

### `kubectl describe node <node-name>`

* Shows node info → capacity, taints, allocatable resources, conditions.
* Helps debug scheduling failures.

---

### `kubectl logs <pod-name>`

* Fetches **logs from pod’s main container**.
* `-f` = stream logs live.
* `-c <container-name>` = logs from a specific container in multi-container pod.

---

### `kubectl debug -it <pod-name> --image=busybox --target=<container-name>`

* Starts an **ephemeral container** inside a running pod for debugging.
* Example: add busybox shell to check networking, DNS, files, etc.
* Great for troubleshooting production pods without modifying images.

---

### `kubectl cluster-info`

* Shows Kubernetes control plane endpoint URLs.
* Example output:

  ```
  Kubernetes control plane is running at https://127.0.0.1:6443
  CoreDNS is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
  ```

---

### `kubectl get componentstatuses`

* (Deprecated, but still seen in many clusters).
* Shows status of API server, etcd, controller-manager, scheduler.

---

# 👉 Key Takeaways (Monitoring & Metrics)

* **`kubectl top`** → Resource usage (requires metrics-server).
* **Events** → Show why scheduling failed, why pods crash, etc.
* **Logs** → Debug container-level issues.
* **Describe** → Detailed resource view (node/pod).
* **Debug** → Run extra container inside a pod for troubleshooting.
* **Cluster Info** → Verify control plane health.

---
# 🔥 18) Taints & Tolerations — ALL commands

```bash
# 1. Add a taint to a node (no pod will schedule here unless it has toleration)
kubectl taint nodes <node-name> key=value:NoSchedule

# 2. Remove a taint from a node
kubectl taint nodes <node-name> key:NoSchedule-

# 3. View taints on all nodes
kubectl describe node <node-name> | grep Taints

# 4. Apply a pod with toleration from YAML
kubectl apply -f toleration-pod.yaml

# 5. Get pods to see if scheduled
kubectl get pods -o wide

# 6. Delete the pod
kubectl delete pod <pod-name>
```

---

# 🔥 18) Taints & Tolerations — Line by Line Explanation

---

### `kubectl taint nodes <node-name> key=value:NoSchedule`

* Adds a **taint** on the node.
* Example:

  ```bash
  kubectl taint nodes node1 env=dev:NoSchedule
  ```
* Meaning: Node `node1` is **tainted** → no pod can run on it unless it has matching **toleration**.
* Effects:

  * `NoSchedule` → New pods without toleration won’t schedule.
  * `PreferNoSchedule` → Tries to avoid scheduling but not guaranteed.
  * `NoExecute` → Existing pods get evicted + new pods won’t schedule.

---

### `kubectl taint nodes <node-name> key:NoSchedule-`

* Removes a taint from a node.
* Example:

  ```bash
  kubectl taint nodes node1 env:NoSchedule-
  ```
* Now node becomes **normal** → pods can schedule again freely.

---

### `kubectl describe node <node-name> | grep Taints`

* Shows taints applied on a node.
* Example output:

  ```
  Taints: env=dev:NoSchedule
  ```
* If `Taints: <none>` → node is normal, no restrictions.

---

### `kubectl apply -f toleration-pod.yaml`

* Creates a pod that **tolerates** a taint.
* Example YAML:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerant-pod
spec:
  tolerations:
  - key: "env"
    operator: "Equal"
    value: "dev"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx
```

👉 This pod **tolerates** nodes tainted with `env=dev:NoSchedule`.

* It will schedule on the tainted node.

---

### `kubectl get pods -o wide`

* Shows where the pod got scheduled (which node).
* If toleration is missing → pod status = `Pending`.

---

### `kubectl delete pod <pod-name>`

* Deletes the pod.
* If created via Deployment, ReplicaSet will re-create it again.

---

# 👉 Key Takeaways (Taints & Tolerations)

* **Taint = "Don’t allow pods unless tolerated."**
* **Toleration = "I can live on a tainted node."**
* Used for:

  * Dedicated nodes (DB nodes, GPU nodes, logging nodes).
  * Protecting nodes for specific workloads.
  * Isolating special workloads.

---
# 🔥 19) Helm — ALL Commands

```bash
# 1. Add a Helm repo (bitnami is popular)
helm repo add bitnami https://charts.bitnami.com/bitnami

# 2. Update repo list
helm repo update

# 3. Search for a chart
helm search repo nginx

# 4. Install a chart (nginx in this case)
helm install my-nginx bitnami/nginx

# 5. List installed releases
helm list
helm list -n dev   # for specific namespace

# 6. Upgrade a release (change version or values)
helm upgrade my-nginx bitnami/nginx --set replicaCount=3

# 7. Rollback a release
helm rollback my-nginx 1

# 8. Get release status and values
helm status my-nginx
helm get values my-nginx

# 9. Uninstall a release
helm uninstall my-nginx
```

---

# 🔥 19) Helm — Line by Line Explanation

---

### `helm repo add bitnami https://charts.bitnami.com/bitnami`

* Adds the **Bitnami Helm repository**.
* Repositories = collection of packaged apps (charts).
* Example repos: `bitnami`, `stable`, `prometheus-community`.

---

### `helm repo update`

* Refreshes repo index.
* Ensures you get the latest charts (versions).

---

### `helm search repo nginx`

* Searches Helm repo for available charts matching `nginx`.
* Shows name, version, and description.

---

### `helm install my-nginx bitnami/nginx`

* Installs the `nginx` chart from Bitnami repo.
* `my-nginx` = release name (your custom name).
* Creates all related Kubernetes objects (Deployment, Service, ConfigMaps, etc.) in one go.

---

### `helm list`

* Lists all installed releases in current namespace.
* Use `helm list -n dev` for other namespaces.

---

### `helm upgrade my-nginx bitnami/nginx --set replicaCount=3`

* Upgrades an existing release with new configuration.
* Here → sets replicas = 3 without editing YAML manually.
* Helm upgrade is like `kubectl apply` but for packaged apps.

---

### `helm rollback my-nginx 1`

* Rolls back `my-nginx` release to revision 1.
* Useful if upgrade fails.

---

### `helm status my-nginx`

* Shows current release status, pods, services, and revision history.

---

### `helm get values my-nginx`

* Retrieves the values used in installation.
* Helps to review applied config (replicas, image, ports, etc.).

---

### `helm uninstall my-nginx`

* Deletes all Kubernetes objects created by this Helm release.
* Clean way to remove apps.

---

# 👉 Key Takeaways (Helm)

* **Helm = Kubernetes package manager.**
* Apps are packaged as **charts** (YAML + templates + values).
* Benefits:

  * One command deploys full app stack.
  * Easy upgrades, rollbacks.
  * Reusable across environments (dev/stage/prod).
* Widely used for deploying:

  * Databases (MySQL, PostgreSQL).
  * Monitoring (Prometheus, Grafana).
  * Ingress controllers, Nginx, cert-manager.

---
# 🔥 20) Cleanup — ALL Commands

```bash
# 1. Delete a pod
kubectl delete pod <pod-name>

# 2. Delete a deployment
kubectl delete deploy <deployment-name>

# 3. Delete a service
kubectl delete svc <service-name>

# 4. Delete a namespace (deletes everything inside it)
kubectl delete ns dev

# 5. Delete all resources of a type in a namespace
kubectl delete pods --all -n dev
kubectl delete deploy --all -n dev
kubectl delete svc --all -n dev

# 6. Delete everything in a namespace (pods, deploys, svc, ing, etc.)
kubectl delete all --all -n dev

# 7. Delete from a YAML file
kubectl delete -f deployment.yaml

# 8. Force delete pod stuck in terminating
kubectl delete pod <pod-name> --grace-period=0 --force
```

---
# 🔥 20) Cleanup — Line by Line Explanation

---

### `kubectl delete pod <pod-name>`

* Deletes a single pod.
* If pod is controlled by a Deployment/ReplicaSet → it will be recreated.
* Useful only for testing restarts or clearing stuck pods.

---

### `kubectl delete deploy <deployment-name>`

* Deletes a Deployment.
* Also deletes its ReplicaSets and Pods.
* Example:

  ```bash
  kubectl delete deploy nginx
  ```

---

### `kubectl delete svc <service-name>`

* Deletes a Service (ClusterIP / NodePort / LoadBalancer).
* Traffic routing to pods stops.

---

### `kubectl delete ns dev`

* Deletes the entire namespace `dev`.
* ⚠️ This deletes all resources (pods, services, secrets, configmaps, PVCs, etc.) in that namespace.

---

### `kubectl delete pods --all -n dev`

* Deletes **all pods** in namespace `dev`.
* Similar for deployments, services.

---

### `kubectl delete all --all -n dev`

* Deletes **everything** in namespace `dev`.
* Includes: pods, deploys, services, ingress, jobs, cronjobs, etc.
* Very handy in dev/test clusters.

---

### `kubectl delete -f deployment.yaml`

* Deletes resources defined in the YAML file.
* Example: if file has Deployment + Service → both get deleted.

---

### `kubectl delete pod <pod-name> --grace-period=0 --force`

* Forcefully deletes a pod stuck in `Terminating` state.
* ⚠️ Use only when pod is unresponsive or finalizer is blocking deletion.

---

# 👉 Key Takeaways (Cleanup)

* Always clean up unused resources to free cluster capacity.
* **Namespace deletion** is the fastest way to wipe an environment.
* **Force delete** should be last resort (can cause corruption if PVCs not released).
* In CI/CD → cleanup commands are automated in pipeline jobs.

---
✅ Done! 🎉











