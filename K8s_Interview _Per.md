
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

1. **Check Pod Status:** - ` kubectl get pods `

2. **Describe the Pod:**
   `kubectl describe pod <pod-name> `
   - Look for events, errors, image pull issues, failed probes, etc.

3. **Check Container Logs:**
   ```bash
   kubectl logs <pod-name>
   ```
   - If multiple containers:
   ```bash
   kubectl logs <pod-name> -c <container-name>
   ```

4. **Exec Into the Pod (if running):**
   ```bash
   kubectl exec -it <pod-name> -- /bin/sh
   ```

5. **Check Node Issues (if scheduling failed):**
   ```bash
   kubectl get nodes
   kubectl describe node <node-name>
   ```

6. **Events & YAML Validation:**
   - Check `kubectl get events` and validate YAML configs for errors.

---

**In short:** Use `kubectl describe`, `logs`, and `exec` to investigate pod failures, starting with status and events, then checking logs and container behavior.
