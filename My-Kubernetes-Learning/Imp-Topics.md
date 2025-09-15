### ❓ Question:
**You have 1 master node and 2 worker nodes. How will you set up and integrate them into a Kubernetes cluster?**
**What is the process to join a worker node with the master node?**
**How do you verify that worker nodes are successfully added to the cluster?**

---
In Kubernetes:
* **Master Node (Control Plane)** → runs the brain of the cluster (API Server, Scheduler, Controller Manager, etc.).
* **Worker Nodes** → run your application Pods and workloads.

👉 To **integrate Worker Nodes with the Master Node** (so they form one cluster), you follow this flow:

---
### 🔹 Step 1: Install Kubernetes + Container Runtime on All Nodes

* On **all nodes (master + workers)**, install:

  * `kubeadm`, `kubelet`, `kubectl`
  * A container runtime (e.g., `containerd` or `Docker`)

---

### 🔹 Step 2: Initialize the Master Node

On the master:

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

* This will set up the control plane.
* At the end, you’ll see a command like this:

```bash
kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxx
```

👉 That’s the **join command** for workers.

---

### 🔹 Step 3: Configure kubectl on Master

Run these on master (so you can use `kubectl`):

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

### 🔹 Step 4: Install Pod Network (CNI)

Choose a network plugin (e.g., Flannel, Calico). Example (Flannel):

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

---

### 🔹 Step 5: Join Worker Nodes

On **each worker node**, run the **join command** you got from Step 2:

```bash
sudo kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxxxx
```

---

### 🔹 Step 6: Verify Cluster

Back on **master**, check:

```bash
kubectl get nodes
```

You should see:

```
NAME        STATUS   ROLES           AGE   VERSION
master      Ready    control-plane   5m    v1.29.x
worker1     Ready    <none>          2m    v1.29.x
worker2     Ready    <none>          1m    v1.29.x
```

✅ Now your **master + 2 workers** are integrated into one Kubernetes cluster.

---
# **1️⃣ Architecture Diagram**

```
               ┌─────────────────────┐
               │     Master Node     │
               │---------------------│
               │ kube-apiserver      │
               │ kube-scheduler      │
               │ kube-controller     │
               │ etcd                │
               │ Pod Network (CNI)   │
               └─────────┬──────────┘
                         │ kubeadm join
                         │
       ┌─────────────────┴─────────────────┐
       │                                   │
┌───────────────┐                   ┌───────────────┐
│ Worker Node 1 │                   │ Worker Node 2 │
│---------------│                   │---------------│
│ kubelet       │                   │ kubelet       │
│ kube-proxy    │                   │ kube-proxy    │
│ Pods          │                   │ Pods          │
└───────────────┘                   └───────────────┘
```

---
## **2️⃣ Step-by-Step Commands Flow**

### **Step 1: Install Kubernetes on All Nodes**

On **all nodes (master + workers)**:

```bash
sudo apt update && sudo apt install -y kubeadm kubelet kubectl
sudo apt install -y containerd
sudo systemctl enable --now kubelet
```

---
### **Step 2: Initialize Master Node**

On **master**:

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

* At the end, you’ll get a **join command** for workers:

```bash
kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxx
```

---
### **Step 3: Configure kubectl on Master**

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes  # should show master in NotReady (before network setup)
```

---
### **Step 4: Install Pod Network (CNI)**

On **master**:

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl get nodes  # master should show Ready
```

---
### **Step 5: Join Worker Nodes**

On **each worker node**, run the `kubeadm join` command obtained from Step 2:

```bash
sudo kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxx
```

---
### **Step 6: Verify Cluster**

On **master node**:

```bash
kubectl get nodes
```

**Expected Output:**

```
NAME        STATUS   ROLES           AGE   VERSION
master      Ready    control-plane   10m   v1.xx.x
worker1     Ready    <none>          5m    v1.xx.x
worker2     Ready    <none>          5m    v1.xx.x
```

✅ Cluster is ready! All nodes integrated.

---

