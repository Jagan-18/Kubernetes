# **RBAC (Role-Based Access Control) in Kubernetes** with full explanation and examples.

---
# 🔹 RBAC in Kubernetes:

## 📘 What is RBAC?
* **RBAC (Role-Based Access Control)** is a way to **control access to Kubernetes resources**.
* It ensures **who (user/service account)** can do **what (verbs)** on **which resources** in the cluster.
* Helps enforce **security & least privilege principle**.

✅ Without RBAC → Anyone with access can do anything.
✅ With RBAC → Access is fine-grained and controlled.

---
## 🔹 Key Components of RBAC:
1. **Role**

   * Defines a set of **permissions (rules)** within a **namespace**.
   * Example: Allow listing Pods only in `dev` namespace.

2. **ClusterRole**

   * Like Role, but applies **cluster-wide** (all namespaces).
   * Example: View nodes, create PVs, etc.

3. **RoleBinding**

   * Binds a **Role** to a **user, group, or ServiceAccount** in a namespace.

4. **ClusterRoleBinding**

   * Binds a **ClusterRole** to a **user, group, or ServiceAccount** across the cluster.

---
## 🔹 Example: Role + RoleBinding:
### Role: Allow listing pods in `dev` namespace

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
```
---
# 🔹 Example: Role with Wide Permissions

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role               # Role name
  namespace: webapps           # Namespace where this Role applies
rules:
  - apiGroups:                 # API groups this Role has access to
      - ""                     # Core API group (pods, services, configmaps, etc.)
      - apps                   # For Deployments, StatefulSets, DaemonSets
      - autoscaling            # For HorizontalPodAutoscaler
      - batch                  # For Jobs, CronJobs
      - extensions             # For older resources (Ingress, ReplicaSets)
      - policy                 # For PodSecurityPolicies
      - rbac.authorization.k8s.io  # For Roles, RoleBindings, ClusterRoles
    resources:                 # Resources this Role can access
      - pods
      - secrets
      - componentstatuses
      - configmaps
      - daemonsets
      - deployments
      - events
      - endpoints
      - horizontalpodautoscalers
      - ingresses
      - jobs
      - limitranges
      - namespaces
      - nodes
      - persistentvolumes
      - persistentvolumeclaims
      - resourcequotas
      - replicasets
      - replicationcontrollers
      - serviceaccounts
      - services
    verbs:                     # Actions allowed on above resources
      - "get"
      - "list"
      - "watch"
      - "create"
      - "update"
      - "patch"
      - "delete"
```

---
## 🔹 Explanation of Each Section

* **`apiVersion: rbac.authorization.k8s.io/v1`** → API group for RBAC resources.

* **`kind: Role`** → This is a Role (namespace-scoped).

* **`metadata`**

  * `name: app-role` → Name of the Role.
  * `namespace: webapps` → Applies only inside `webapps` namespace.

* **`rules`** → Defines permissions.

  * **`apiGroups`** → Which API groups are included.

    * `""` → Core resources (Pods, Services, ConfigMaps).
    * `apps` → Deployments, StatefulSets, DaemonSets.
    * `autoscaling` → HorizontalPodAutoscaler.
    * `batch` → Jobs, CronJobs.
    * `extensions` → Legacy API group for Ingress/ReplicaSet.
    * `policy` → PodSecurityPolicies.
    * `rbac.authorization.k8s.io` → Roles, RoleBindings.

  * **`resources`** → Which resources can be controlled.

    * Includes Pods, Deployments, Services, Secrets, PVCs, ConfigMaps, Jobs, etc.

  * **`verbs`** → What actions can be taken.

    * `"get", "list", "watch"` → Read-only operations.
    * `"create", "update", "patch", "delete"` → Write operations.

✅ This Role gives **almost full control over all key resources in the `webapps` namespace**.

---
### RoleBinding: Attach role to ServiceAccount

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-binding
  namespace: dev
subjects:
  - kind: ServiceAccount
    name: dev-sa
    namespace: dev
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

✅ Meaning: `dev-sa` ServiceAccount can only **get & list Pods** in the `dev` namespace.

---
## 🔹 Example: ClusterRole + ClusterRoleBinding

### ClusterRole: View pods across all namespaces

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-viewer
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
```

### ClusterRoleBinding: Attach role to ServiceAccount

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-viewer-binding
subjects:
  - kind: ServiceAccount
    name: dev-sa
    namespace: dev
roleRef:
  kind: ClusterRole
  name: pod-viewer
  apiGroup: rbac.authorization.k8s.io
```

✅ Meaning: `dev-sa` ServiceAccount can **get, list, and watch pods in all namespaces**.

---

## 🔹 RBAC Flow Diagram

```
   [User / ServiceAccount]
             |
             v
     (RoleBinding / ClusterRoleBinding)
             |
             v
       [Role / ClusterRole]
             |
             v
     [Rules: Verbs + Resources + API Groups]
             |
             v
      [Kubernetes API Server]
```

---
## 🔹 Common Verbs in RBAC

* `get` → Read a resource
* `list` → List multiple resources
* `watch` → Watch for changes
* `create` → Create new resource
* `update` → Modify resource
* `delete` → Remove resource

--- 
✅ **End-to-End Flow:**

1. Define **Role/ClusterRole** → what actions allowed.
2. Bind it with **RoleBinding/ClusterRoleBinding** → assign to user/SA.
3. User/Pod uses ServiceAccount → API server checks RBAC before allowing request.

---
