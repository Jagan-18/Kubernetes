# 📘 Helm – The Kubernetes Package Manager:
---
## 🔹 What is Helm?
* Helm is a **package manager for Kubernetes** (similar to `apt` for Ubuntu or `yum` for RHEL).
* Helm uses **Charts** (pre-configured templates of Kubernetes YAML manifests).
* Helps in **installing, upgrading, and managing applications** on Kubernetes easily.

✅ Without Helm → You manually apply multiple YAML files.
✅ With Helm → You use **one command (`helm install`)** and Helm manages everything.

---
## 🔹 Key Concepts in Helm:
1. **Chart**

   * A Helm package (collection of YAML templates + metadata).
   * Example: `nginx-chart` for deploying Nginx.

2. **Release**

   * An **instance of a chart** deployed on a cluster.
   * Example: Installing `nginx-chart` twice → you get 2 releases (`nginx1`, `nginx2`).

3. **Repository**

   * A place where charts are stored (like DockerHub for images).
   * Example: Helm stable repo, Bitnami repo.

4. **Values.yaml**

   * File to store configuration values for a chart.
   * You can override defaults without editing templates.

---
## 🔹 Helm Architecture:
```
   [Helm CLI]  --->  [Tiller (Helm v2, removed in v3)]
        |
        v
   [Kubernetes API Server]
        |
        v
   [Install Charts -> Creates K8s Objects]
```

👉 Helm v3 (current) **does not use Tiller**. It talks **directly** to Kubernetes API.

---
## 🔹 Helm Workflow:
1. **Search chart**

   ```bash
   helm search repo nginx
   ```

2. **Add a repository**

   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update
   ```

3. **Install a chart**

   ```bash
   helm install my-nginx bitnami/nginx
   ```

4. **Check releases**

   ```bash
   helm list
   ```

5. **Upgrade release**

   ```bash
   helm upgrade my-nginx bitnami/nginx --set replicaCount=3
   ```

6. **Rollback release**

   ```bash
   helm rollback my-nginx 1
   ```

7. **Uninstall release**

   ```bash
   helm uninstall my-nginx
   ```

---
## 🔹 Helm Chart Directory Structure:
When you create a new chart (`helm create mychart`), structure looks like:

<img width="1156" height="575" alt="Image" src="https://github.com/user-attachments/assets/f7a7bc21-ce21-4f9a-99a6-2670fa35c15a" />
```
mychart/
  Chart.yaml        # Metadata about the chart (name, version, etc.)
  values.yaml       # Default configuration values
  charts/           # Dependency charts
  templates/        # K8s YAML templates (.yaml files with Go templating)
  templates/_helpers.tpl  # Helper template functions
```

---
## 🔹 Example: Simple Nginx Helm Chart:
### 1. Chart.yaml

```yaml
apiVersion: v2
name: mynginx
description: A simple Nginx deployment
version: 0.1.0
appVersion: "1.21.1"
```

### 2. values.yaml

```yaml
replicaCount: 2
image:
  repository: nginx
  tag: "1.21.1"
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
```

### 3. templates/deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: nginx
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: {{ .Values.service.port }}
```

---
## 🔹 Advanced Helm Features:
* **Templating with Go Templates**

  * Example: `{{ .Values.image.tag }}` pulls value from `values.yaml`.

* **Subcharts (Dependencies)**

  * A chart can depend on other charts (e.g., WordPress → MySQL).

* **Helmfile**

  * Manage multiple charts and environments at once.

* **Helm Secrets Plugin**

  * Encrypt secrets (with tools like `sops` or `sealed-secrets`).

---
## 🔹 Helm in CI/CD:
* Store `values-dev.yaml`, `values-prod.yaml` for different environments.
* Deploy with:

  ```bash
  helm install myapp ./mychart -f values-prod.yaml
  ```

---
## 🔹 Helm vs Kustomize:
| Feature             | Helm             | Kustomize       |
| ------------------- | ---------------- | --------------- |
| Package Manager     | ✅ Yes            | ❌ No            |
| Templating          | ✅ (Go Templates) | ❌ (Patch-based) |
| Dependency Handling | ✅                | ❌               |
| Ease of Overrides   | ✅ Values.yaml    | ✅ Overlays      |

---
✅ **Summary**:
* Helm makes Kubernetes application management simple.
* Charts → reusable templates.
* Values.yaml → easy overrides.
* Releases → version-controlled deployments.
* Great for CI/CD pipelines.

---
📌 Diagram: Helm Flow

```
        [Helm CLI]
             |
             v
   [Chart + Values.yaml]
             |
             v
   [Kubernetes API Server]
             |
             v
   [K8s Objects: Deployment, Service, PVC, ConfigMap, Secret]
```
---
# 📘 **Helmfile – Managing Multiple Helm Charts**

## 🔹 What is Helmfile?

* **Helmfile** is a **declarative way** to manage multiple Helm charts at once.
* Instead of running many `helm install` commands, you define everything in a **single YAML file (`helmfile.yaml`)**.
* Useful for **environments** (`dev`, `staging`, `prod`) where you deploy multiple apps with different configs.

✅ Without Helmfile → You manually install `frontend`, `backend`, `database` one by one.
✅ With Helmfile → One command deploys everything together.

---
## 🔹 Helmfile Workflow:
1. Create a `helmfile.yaml` file.
2. Define repositories and releases (charts).
3. Run `helmfile apply` → deploys/updates all charts at once.

---
## 🔹 Example: `helmfile.yaml`:

```yaml
repositories:
  - name: bitnami
    url: https://charts.bitnami.com/bitnami

releases:
  - name: my-nginx
    namespace: web
    chart: bitnami/nginx
    version: 15.5.2
    values:
      - values/nginx-values.yaml

  - name: my-mysql
    namespace: database
    chart: bitnami/mysql
    version: 9.10.3
    values:
      - values/mysql-values.yaml
```

---
## 🔹 Explanation:
* **repositories** → Define chart repos (like Bitnami).
* **releases** → Each app you want to install.

  * **name** → Release name.
  * **namespace** → Namespace where it will be deployed.
  * **chart** → Which Helm chart to use.
  * **values** → Path to custom values file.

---
## 🔹 Commands:

```bash
# Sync Helmfile (install/upgrade all charts)
helmfile apply

# List all releases
helmfile list

# Diff what changes will happen before applying
helmfile diff

# Destroy all releases
helmfile destroy
```

---
## 🔹 Advantages of Helmfile:
* Deploy **multiple charts** together.
* Manage **different environments** easily:

  * `helmfile -e dev apply`
  * `helmfile -e prod apply`
* Built-in **diffing** (preview changes before applying).
* Great for **GitOps** with ArgoCD or Flux.

---
## 🔹 Diagram – Helmfile Flow:

```
     [helmfile.yaml]
            |
            v
   [Multiple Helm Releases]
    ┌─────────────┬──────────────┐
    v             v              v
 [Nginx]       [MySQL]       [Redis]
```

---
✅ **Summary**: Helmfile is the **next step after Helm** → it lets you manage multiple charts and environments in one place.
It’s widely used in **production clusters** for environment consistency and CI/CD pipelines.

---
# 📘 Helm Core Concepts – Chart, Repository, Release

## 🔹 1. Helm Chart:
* A **Helm Chart** is a **package** that contains all the Kubernetes manifests (YAML files) needed to deploy an application.
* It includes:

  * `Chart.yaml` → metadata (name, version, app version).
  * `values.yaml` → default config values.
  * `templates/` → actual K8s resource templates.

✅ Think of a Chart like a **Docker image**: reusable and versioned.

**Example:**

```bash
helm create mychart
```

This generates a sample chart structure you can customize.

---
## 🔹 2. Helm Repository:
* A **Helm Repository** is a **collection of Helm Charts** stored at a remote location (similar to DockerHub for container images).
* Popular repos:

  * Bitnami → [https://charts.bitnami.com/bitnami](https://charts.bitnami.com/bitnami)
  * ArtifactHub → [https://artifacthub.io](https://artifacthub.io)

**Commands:**

```bash
# Add a repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repo
helm repo update

# Search charts in repo
helm search repo nginx
```

✅ Repositories allow **sharing & reusing charts**.

---
## 🔹 3. Helm Release:
* A **Release** is a **running instance of a Helm Chart** in your Kubernetes cluster.
* Every time you install a chart, Helm creates a Release with a unique name.

**Example:**

```bash
helm install my-nginx bitnami/nginx
```

* Here:

  * **Chart** = `bitnami/nginx`
  * **Release** = `my-nginx`
* You can install the same chart multiple times → each will be a different release.

**Release Lifecycle Commands:**

```bash
helm list                  # List all releases
helm upgrade my-nginx ...  # Upgrade release
helm rollback my-nginx 1   # Rollback to previous version
helm uninstall my-nginx    # Delete release
```

---
## 🔹 Diagram: Helm Chart → Repository → Release:
```
   [Helm Repository]
        |
        |  (contains multiple Charts)
        v
     [Chart: Nginx]
        |
        |  helm install my-nginx bitnami/nginx
        v
   [Release: my-nginx running in cluster]
```
---
✅ **Summary**:
* **Chart** = Package (blueprint of app).
* **Repository** = Storage location for charts.
* **Release** = Deployed instance of a chart in K8s.
---

# 📘 **ArgoCD with Helm – GitOps for Kubernetes**

## 🔹 What is ArgoCD?
* **ArgoCD** = *Argo Continuous Delivery*.
* A **GitOps tool** for Kubernetes.
* Ensures your **cluster state = Git repo state**.
* Supports plain YAML, Kustomize, and Helm charts.

✅ Without ArgoCD → You run `kubectl apply` or `helm install` manually.
✅ With ArgoCD → Just push changes to Git → ArgoCD applies them automatically.

---
## 🔹 How ArgoCD Works:

1. **Git Repository** = Source of Truth (stores Helm charts / YAML).
2. **ArgoCD** watches the repo.
3. If repo changes → ArgoCD applies changes to cluster.
4. Provides UI & CLI for monitoring apps.

---
## 🔹 ArgoCD Architecture:

```
           ┌────────────┐
           │   Git Repo │  (YAML/Helm Charts)
           └──────┬─────┘
                  │
                  v
           ┌──────────────┐
           │   ArgoCD     │
           │  (Controller │
           │   + API + UI)│
           └──────┬───────┘
                  │
                  v
        ┌───────────────────┐
        │ Kubernetes Cluster│
        │ (Pods, Services,  │
        │  PVCs, etc.)      │
        └───────────────────┘
```

---
## 🔹 Install ArgoCD:

```bash
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Get admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

Expose ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

---
## 🔹 Create an Application with Helm:
Example `argocd-app.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://charts.bitnami.com/bitnami'
    chart: nginx
    targetRevision: 15.5.2
    helm:
      values: |
        replicaCount: 2
  destination:
    server: https://kubernetes.default.svc
    namespace: web
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply it:

```bash
kubectl apply -f argocd-app.yaml
```

---
## 🔹 Explanation of Key Fields:
* **repoURL** → Git repo or Helm repo containing charts.
* **chart** → Which Helm chart to install.
* **values** → Inline Helm values (like `values.yaml`).
* **destination** → Where to deploy in cluster.
* **syncPolicy** → Auto-sync + self-healing.

---
## 🔹 Benefits of ArgoCD + Helm:
* **GitOps Workflow** → Push code to Git, auto-deploys.
* **Self-Healing** → If someone changes resources manually, ArgoCD reverts to Git state.
* **Version Control** → Every deployment is tracked in Git.
* **Multi-Cluster Support** → Deploy apps to many clusters.

---

## 🔹 End-to-End Flow Diagram

```
   [Git Repo with Helm Charts]
               |
               v
          [ArgoCD Controller]
               |
               v
    [Kubernetes Cluster Resources]
```

---
✅ **Summary**:
* Helm simplifies packaging → Helmfile manages multiple → **ArgoCD automates GitOps delivery**.
* With ArgoCD + Helm, your apps are **version-controlled, automated, and self-healing**.

---

