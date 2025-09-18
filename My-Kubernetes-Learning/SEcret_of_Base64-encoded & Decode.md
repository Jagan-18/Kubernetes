# In Kubernetes, whenever you create a **Secret**, the values (like passwords, tokens, keys) must be **Base64-encoded**.

---
## 🔹 Why Base64 Encoding?
* Kubernetes Secrets are stored as key/value pairs.
* The value must be in **Base64 format** (so YAML doesn’t break due to special characters).
* ⚠️ Note: Base64 is **not encryption** → it’s only encoding. Anyone can decode it. For security, you should use proper secret managers (Vault, Sealed Secrets, etc.).

---
## 🔹 Example: Creating a Secret (Base64 encoding manually)
### 1. Encode your password

Suppose your password is:

```bash
echo -n 'MyPass123' | base64
```

Output:

```
TXlQYXNzMTIz
```

### 2. Create Secret YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=          # "admin" encoded
  password: TXlQYXNzMTIz     # "MyPass123" encoded
```

---
## 🔹 Decoding (to verify)

```bash
echo -n 'TXlQYXNzMTIz' | base64 --decode
```

Output:

```
MyPass123
```

---
## 🔹 Shortcut (kubectl create secret)

Instead of encoding manually, you can let Kubernetes do it:

```bash
kubectl create secret generic mysecret \
  --from-literal=username=admin \
  --from-literal=password=MyPass123
```

This generates the same YAML with Base64 automatically.

---
Perfect 👍 Let’s extend your **YAML + apiVersion cheat sheet** with a **Secrets workflow section**.  
Here’s the Markdown content you can save directly in your file (`k8s-apiversion-yaml-cheatsheet.md`).  

---

# 📘 Kubernetes YAML Manifest & API Version Guide

## 🔹 Manifest Structure

```text
┌───────────────────────────────────────────┐
│ apiVersion: <API group/version>           │  ← Which API schema to use
│ kind: <Resource Type>                     │  ← Type of resource (Pod, Deployment, Service, etc.)
│ metadata:                                 │
│   name: <resource-name>                   │  ← Resource name
│   namespace: <namespace> (optional)       │  ← Namespace (default if not given)
│   labels: (optional)                      │
│     key: value                            │
│ spec:                                     │  ← Desired configuration of the resource
│   ...fields depend on the resource...     │
└───────────────────────────────────────────┘
```

---

## 🔹 Common API Versions

| Resource Type        | Kind         | apiVersion                     |
|----------------------|-------------|--------------------------------|
| Pod                  | Pod         | `v1`                           |
| Service              | Service     | `v1`                           |
| ConfigMap            | ConfigMap   | `v1`                           |
| Secret               | Secret      | `v1`                           |
| Deployment           | Deployment  | `apps/v1`                      |
| StatefulSet          | StatefulSet | `apps/v1`                      |
| DaemonSet            | DaemonSet   | `apps/v1`                      |
| Job                  | Job         | `batch/v1`                     |
| CronJob              | CronJob     | `batch/v1`                     |
| Ingress              | Ingress     | `networking.k8s.io/v1`         |
| NetworkPolicy        | NetworkPolicy | `networking.k8s.io/v1`        |
| Role/ClusterRole     | Role        | `rbac.authorization.k8s.io/v1` |
| RoleBinding/ClusterRoleBinding | RoleBinding | `rbac.authorization.k8s.io/v1` |
| HPA (Autoscaler)     | HPA         | `autoscaling/v2`               |

---

## 🔹 Examples

### Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

### Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp-container
          image: nginx:latest
          ports:
            - containerPort: 80
```

---

## 🔹 Secrets Workflow

### 1. Encode your values
```bash
echo -n 'admin' | base64
# Output: YWRtaW4=

echo -n 'MyPass123' | base64
# Output: TXlQYXNzMTIz
```

### 2. Secret YAML
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=          # "admin"
  password: TXlQYXNzMTIz     # "MyPass123"
```

### 3. Decode (to verify)
```bash
echo -n 'TXlQYXNzMTIz' | base64 --decode
# Output: MyPass123
```

### 4. Shortcut with kubectl
```bash
kubectl create secret generic mysecret \
  --from-literal=username=admin \
  --from-literal=password=MyPass123
```

---

✅ Now your `.md` file has:
1. YAML structure diagram  
2. API version cheat sheet  
3. Pod & Deployment examples  
4. Secret workflow (encode → YAML → decode → kubectl)  

---
# ConfigMap + Secret: 
Awesome 👍 Let’s add a **ConfigMap section** so your guide covers **ConfigMap + Secret** together.

## 🔹 Examples:
### Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp-container
          image: nginx:latest
          ports:
            - containerPort: 80
```

---
## 🔹 Secrets Workflow:
### 1. Encode your values

```bash
echo -n 'admin' | base64
# Output: YWRtaW4=

echo -n 'MyPass123' | base64
# Output: TXlQYXNzMTIz
```

### 2. Secret YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=          # "admin"
  password: TXlQYXNzMTIz     # "MyPass123"
```

### 3. Decode (to verify)

```bash
echo -n 'TXlQYXNzMTIz' | base64 --decode
# Output: MyPass123
```

### 4. Shortcut with kubectl

```bash
kubectl create secret generic mysecret \
  --from-literal=username=admin \
  --from-literal=password=MyPass123
```

---
## 🔹 ConfigMap Workflow:
### 1. ConfigMap YAML

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfig
data:
  APP_ENV: "production"
  APP_DEBUG: "false"
  DB_HOST: "mysql-service"
  DB_PORT: "3306"
```

### 2. Create via kubectl

```bash
kubectl create configmap myconfig \
  --from-literal=APP_ENV=production \
  --from-literal=DB_HOST=mysql-service
```

### 3. Use ConfigMap in a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: mycontainer
      image: nginx
      envFrom:
        - configMapRef:
            name: myconfig
```
---
# Here we are merge Secrets + ConfigMap usage together in one Pod example (so you can see both being used side by side)?

## 🔹 Examples

### Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp-container
          image: nginx:latest
          ports:
            - containerPort: 80
```

---
## 🔹 Secrets Workflow:
### Encode values

```bash
echo -n 'admin' | base64
# YWRtaW4=

echo -n 'MyPass123' | base64
# TXlQYXNzMTIz
```

### Secret YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=          # "admin"
  password: TXlQYXNzMTIz     # "MyPass123"
```

---
## 🔹 ConfigMap Workflow:
### ConfigMap YAML

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfig
data:
  APP_ENV: "production"
  DB_HOST: "mysql-service"
  DB_PORT: "3306"
```

---
## 🔹 Combined Usage: Pod with Secret + ConfigMap

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod-with-secrets-configmap
spec:
  containers:
    - name: mycontainer
      image: nginx
      env:
        # Inject Secret values as environment variables
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: password
      envFrom:
        # Inject all ConfigMap values as environment variables
        - configMapRef:
            name: myconfig
```

---
✅ In this example:
* `DB_USER` and `DB_PASSWORD` come from **Secret (`mysecret`)**
* `APP_ENV`, `DB_HOST`, and `DB_PORT` come from **ConfigMap (`myconfig`)**

This is the **most common pattern** you’ll use in real deployments.

---





