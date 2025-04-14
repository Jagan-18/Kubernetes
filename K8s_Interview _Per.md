
## 1. what are the major limitations of docker that Kubernetes overcome ?
**In short:** Docker is great for building and running containers, but Kubernetes adds orchestration, automation, and resilience—making it ideal for production-scale deployments.
| **Docker Limitation**                         | **How Kubernetes Solves It**                                                        |
|-----------------------------------------------|-------------------------------------------------------------------------------------|
| **No native orchestration**                   | Kubernetes handles scheduling, scaling, and managing containers.                    |
| **Manual container scaling**                  | Kubernetes provides auto-scaling of pods based on resource usage.                   |
| **No service discovery/load balancing**       | Kubernetes has built-in service discovery and load balancing via Services.          |
| **Limited self-healing**                      | Kubernetes restarts failed pods and replaces unhealthy nodes automatically.         |
| **Manual rolling updates/rollbacks**          | Kubernetes supports automated rolling updates and easy rollbacks.                   |
| **No built-in monitoring/health checks**      | Kubernetes supports liveness/readiness probes and integrates with monitoring tools. |

---
## 2.what is key different between docker vs kubernetes?
- **Docker** is a containerization platform – it allows you to build, package, and run applications in lightweight containers.

- **Kubernetes** is a container orchestration platform – it manages, deploys, scales, and maintains containers (including Docker containers) across clusters of machines.
  
| Feature               |         Docker                              |          Kubernetes                                    |
| ----------------------| ------------------------------------------- | ------------------------------------------------------ |
| **Primary Role**      | Containerization Platform & Runtime         | Container Orchestration Platform                       |
| **Scope**             | Manages individual containers (primarily)   | Manages clusters of containers across multiple hosts   |
| **Orchestration**     | Basic (via Docker Swarm, less feature-rich) | Advanced, automated orchestration                      |
| **Scaling**           | Manual scaling (in standalone mode)         | Automated horizontal and vertical scaling              |
| **High Availability** | Limited in standalone mode                  | Built-in self-healing and load balancing               |
| **Complexity**        | Generally simpler for single hosts          | More complex to set up and manage                      |
| **Management Unit**   | Container                                   | Pod (group of one or more containers)                  |
| **Networking**        | Basic networking on a single host           | Advanced networking across a cluster                   |
| **Use Case**          | Local development, single-host deployments  | Production environments, large-scale applications      |

---
## 3. why do enterprises prefer Kubernetes over docker swarm for large scale deployments.?

| **Category**             | **Kubernetes**                                                                  | **Docker Swarm**                                                               |
|--------------------------|---------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| **1. Definition**        | Advanced open-source container orchestration platform backed by CNCF            | Simpler native orchestration tool for Docker containers                        |
| **2. Ease of Setup**     | Complex setup (but manageable with tools like kubeadm, Minikube ect)            | Easy to set up with `docker swarm init`                                        |
| **3. Scalability**       | Highly scalable (used in production by companies like Google, Netflix, etc.)    | Medium scalability, suitable for small to mid-sized clusters                   |
| **4. Networking**        | Advanced networking via CNI plugins, network policies, and Ingress              | Simple overlay network, lacks granular control                                 |
| **5. Load Balancing**    | Built-in load balancing plus support for Ingress Controllers, Envoy, Istio      | Basic internal load balancing, but no native ingress controller                |
| **6. Fault Tolerance**   | High resilience with self-healing, node health checks, and replica management   | Basic fault tolerance with auto container restart, less robust                 |
| **7. Service Discovery** | DNS-based with CoreDNS, supports external service integration                   | DNS-based within the Swarm, simpler but functional                             |
| **8. Storage (Story)**   | Persistent storage support via CSI drivers, dynamic provisioning                | Limited persistent volume support, manual setup required                       |
| **9. State Management**  | Manages desired state declaratively (self-healing, config drift prevention)     | Manages state imperatively, less control over desired state enforcement        |

---

## 4. How do you run the POD on minikube? what steps will you follow?
**Minikube** is a tool that lets you run a local single-node Kubernetes cluster on your machine. It's great for learning, development, and testing Kubernetes applications without using cloud infrastructure.
### **Steps to Run a Pod on Minikube:**
1. **Start Minikube:** `minikube start`   
2. **Create a Pod Manifest (YAML):**  
   Example: `pod.yaml`
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: mypod
   spec:
     containers:
     - name: mycontainer
       image: nginx
       ports:
       - containerPort: 80
   ```
3. **Apply the Pod YAML:** `kubectl apply -f pod.yaml`
4. **Check Pod Status:** `kubectl get pods`
5. **Access the Pod (optional - for testing):** `kubectl port-forward pod/mypod 8080:80`
6. **View Pod Logs (optional):** `kubectl logs mypod`
---
## 5.Tell me about pod lifecycle in k8s
**pod:** The smallest deployable unit in Kubernetes, encapsulating one or more containers.

1. **Pending**  - Pod is accepted by the cluster but not yet running (e.g., waiting for scheduling or image pull).
2. **Running**  - Pod is scheduled to a node, and at least one container is up and running.
3. **Succeeded**  - All containers in the pod have completed successfully (for batch jobs).
4. **Failed**   - One or more containers in the pod terminated with an error.
5. **Unknown**     - The state of the pod cannot be determined (e.g., due to network issues).
---
## 6. What is an init container, and how is it different from a normal container?
An Init Container is a special type of container in a Pod that runs before the main (application) containers start.

**Key Differences Between Init Container and Normal Container:**

| **Init Container**                                       | **Normal (App) Container**                                 |
|----------------------------------------------------------|------------------------------------------------------------|
| Runs **before** the main container starts                | Runs **as the main application** in the Pod                |
| **Runs once and exits** when the task is done            | **Runs continuously** until the application stops          |
| Used for **setup tasks** like config checks, DB readiness| Used to run the **actual application** (e.g., web server)  |
| Runs **sequentially** (if multiple Init containers exist)| Can run **in parallel** with other app containers          |

**Example Use Case:** - An Init Container can be used to wait for a database to be ready, download a config file, or set permissions — tasks that must finish before your app starts.

---
## 7. How do you debug a failing Pod?
**In short:** Use `kubectl describe`, `logs`, and `exec` to investigate pod failures, starting with status and events, then checking logs and container behavior.
1. **Check Pod Status:** - ` kubectl get pods `
2. **Describe the Pod:**  `kubectl describe pod <pod-name> `
   - Look for events, errors, image pull issues, failed probes, etc.
3. **Check Container Logs:** `kubectl logs <pod-name>`
    - If multiple containers: - `kubectl logs <pod-name> -c <container-name>`
4. **Exec Into the Pod (if running):** - `kubectl exec -it <pod-name> -- /bin/sh`
5. **Check Node Issues (if scheduling failed):**
   ```bash
   kubectl get nodes
   kubectl describe node <node-name>
   ```
6. **Events & YAML Validation:**  - Check `kubectl get events` and validate YAML configs for errors.
---

## 8. How do containers in a Pod communicate with each other?
1. Containers in the **same Pod share the same network namespace**, so they can communicate with each other **using localhost**.
   - **For example**, if one container runs a service on port 8080, the other container can access it at localhost:8080.
2. This works because they share the **same IP address and ports inside the Pod**.
3. Additionally, containers in a **Pod can also share volumes**, which allows them to exchange data using a shared file system.
4. This is useful for scenarios like logging, caching, or temporary storage between containers.
---

## 9. What are different ways you ensure a Pod always runs?**
To ensure a Pod always runs, we can use different Kubernetes controllers and features:
1. **Deployment** – Automatically restarts Pods if they crash or get deleted. It keeps the desired number of replicas running.
2. **ReplicaSet** – Ensures a specific number of Pod replicas are always up.
3. **DaemonSet** – Ensures a Pod runs on **every node** (or selected nodes) in the cluster.
4. **StatefulSet** – Used for stateful applications and ensures stable identities and persistent storage.
5. **Liveness and Readiness Probes** – Help detect and restart unhealthy Pods.
6. **PodDisruptionBudget (PDB)** – Prevents too many Pods from being evicted during node maintenance.
7. **Node Affinity / Tolerations** – Ensures Pods get scheduled correctly and not stuck in pending state.
   
---
## 10. what is a pod disruption budget(PDB)? why do we need a pod disruption Budget(PDB)if Deployments & Replicas ensure availability?
**In short:**
- Deployments & Replicas handle automatic scaling and Pod recovery.
- PDBs ensure that disruption operations don’t take down too many Pods, maintaining high availability during planned disruptions
  
✅ **What is a Pod Disruption Budget (PDB)?**
- A **Pod Disruption Budget (PDB)** defines the **minimum number or percentage of Pods** that **must remain available** during **voluntary disruptions** (like node maintenance, upgrades, or autoscaling).

---
**Why do we need a Pod Disruption Budget (PDB) if Deployments & Replicas ensure availability?**
- While Deployments and ReplicaSets ensure the desired number of Pods are always running by automatically replacing failed Pods, they do not account for planned disruptions, like during node upgrades, maintenance, or manual scaling.
  
**A PDB ensures that:**

**1.Minimum Availability:** At least a minimum number or percentage of Pods stay running even when disruptions are happening.

**2.Safe Maintenance:** During planned disruptions (e.g., when a node is drained), Kubernetes respects the PDB, preventing more Pods from being terminated than allowed, ensuring the service remains available.

**3.Control over Disruptions:** Prevents over-scaling down or accidental termination of too many Pods, which could lead to downtime or degraded performance.

✅ **Example Scenario:** - If you have 5 replicas in a Deployment and set a PDB that allows a maximum of 1 Pod to be disrupted, Kubernetes will ensure that, even during voluntary disruptions (like during node maintenance), at least 4 Pods will remain running to maintain service availability.

---

## 11.How to Safely Drain a Kubernetes Node?
- Draining a node means safely evicting all Pods from a node so you can perform maintenance, upgrade, or decommission it — without downtime or data loss.
  
**Steps to Safely Drain a Node**

| **Step**                         | **Command / Explanation**                                                                                                                      |
|----------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| **1. Cordon the Node**           | Prevent new Pods from being scheduled on the node ```kubectl cordon <node-name>```                                                             |
| **2. Drain the Node**           | Evict Pods safely (respects PodDisruptionBudgets, avoids DaemonSets) ```kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data``` |
| **3. Perform Maintenance**      | Do your update, patch, or other task                                                                                                            |
| **4. Uncordon the Node**        | Allow the scheduler to place Pods back on the node   ```kubectl uncordon <node-name>```                                                         |

---
## 12. Can you run a Pod on a specific node? If yes, how?
- Yes, you can run a Pod on a specific node using nodeName, nodeSelector, or nodeAffinity depending on how strict or flexible you want the scheduling to be.

**Methods to Schedule a Pod on a Specific Node**

| **Method**         | **Description**                                                                  | **Use Case**                           |
|--------------------|----------------------------------------------------------------------------------|----------------------------------------|
| `nodeName`         | Hard-code the exact node name where the Pod should run                           | Simple, manual scheduling              |
| `nodeSelector`     | Match Pod to a node using key-value labels                                       | Basic label-based targeting            |
| `nodeAffinity`     | Advanced rules with soft/hard preferences using expressions                      | Flexible, scalable node matching       |

---

Absolutely! Here's your **interview-ready answer** — short, structured, and to the point, just like you'd deliver in a real interview:

---

### 13. Explain Container, Pod, ReplicaSet, and Deployment in Kubernetes. What are they and why are they used?**
#### **1. Container:**

- **What is it?**  
   - A container is a lightweight and smallest unit of execution in kubernetes.
   - It encapsulates an application and it dependencies.
   - containers run inside pods.
- **Why use it?**  
  - It ensures consistency across environments (dev, test, prod) and allows fast, reliable deployments.
  - To package application and their dependencies in a portable way.

---
#### **2. Pod:**

- **What is it?**  
  - A Pod is the **smallest deployable unit in Kubernetes**.
  - It can have one or more containers that share the same network and storage, configurations.
  - Containers inside the same pod can communicate using **localhost**
  
- **Why use it?**  
   - To run tightly coupled applications (eg: a web app and its sidecar logging agent).
   - To enable sharing of network and storage resources.
---
#### **3. ReplicaSet:**

- **What is it?**  
  -  A ReplicaSet ensures a **specified number of Pod replicas** are running at all times.
  -  If a pod fails, the Replicaset automatically creates a new one.

- **Why use it?**  
   - To maintain high availability by ensuring the required number of pods are always running.
   - Used internally by Deployments to scale application up or down.
---
#### **4. Deployment:**

- **What is it?**  
   - A Deployment is a higher-level abstraction that manages ReplicaSets and Pods.
   -  It provides **rolling updates**,**rollbacks** and scalability.
   -  A deploymeny defines how many replicas of a pod should be running and manages their updates.

- **Why use it?**  
  - To ensureZero-downtime deployments with rolling updates.
  - To manage application versions and enable rollbacks.
---
   **Summary in One Line:**
> **Container** runs the app → **Pod** wraps the container → **ReplicaSet** ensures multiple Pods → **Deployment** manages everything (scaling, updates, rollback).

**How they work together:** - Deployment → manages ReplicaSet → maintains Pods → runs Containers

---
### 14. What is a Selector in Kubernetes?
A **Selector** in Kubernetes is a way to **filter and select resources** (such as Pods, Services, ReplicaSets, etc.) based on labels. Kubernetes uses selectors to **identify a set of resources** for scheduling, communication, or management.

#### Types of Selectors:
1. **Label Selector:**
   -  A **Label Selector** allows you to select resources based on **labels** and **label values**.
   -  You define a set of **key-value pairs** (labels) to filter resources.
**Example Use Cases:**
     - **Services** use label selectors to identify which Pods they should route traffic to.
     - **ReplicaSets** use label selectors to ensure that the correct Pods are managed.
 - **Example:**
     ```yaml
     selector:
       matchLabels:
         app: web-app
     ```
 - This would select Pods with the label `app=web-app`.

2. **Field Selector:**
   - A **Field Selector** allows you to select resources based on **resource fields** like name, namespace, or status.
**Example Use Case:**
   - Selecting Pods that are in a specific **namespace** or have a certain **status**.
 - **Example:** - `kubectl get pods --field-selector status.phase=Running`
- This selects Pods that are in the `Running` state.
  
---
### What is a Service in Kubernetes, and why is it needed?**
- A Service in Kubernetes is an abstraction that defines a logical set of pods and a policy to access them. It enables communication between pods and external clients or within the cluster.
##### Why do we need a Service in Kubernetes?
1. **Stable Access**:  - Services provide a fixed IP and name, even if Pods change.

2. **Load Balancing**: - It distributes traffic to multiple Pods, so no Pod gets overwhelmed.

3. **Service Discovery**: -Other Pods can find and connect to the Service by name, not by IP.

4. **Decoupling**: - Clients talk to the Service, not individual Pods, simplifying communication.
---
#### Common Types of Services:
1. **ClusterIP (default)**: - Exposes the Service on an internal IP within the cluster. It is accessible only within the cluster.
   
2. **NodePort**: - Exposes the Service on a static port on each Node's IP, making it accessible externally.

3. **LoadBalancer**: - Exposes the Service externally using a cloud provider’s load balancer, providing automatic external access.

4. **ExternalName**: - Maps the Service to an external DNS name (not commonly used).

---





