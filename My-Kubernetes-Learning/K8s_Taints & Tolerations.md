# 🚀 Kubernetes Taints & Tolerations:
---
## 1. **What are Taints & Tolerations?**

* **Taint (on Node)** → A *restriction* you put on a Node. It says:
  *“Only Pods that can tolerate this taint are allowed to run here.”*

* **Toleration (on Pod)** → A *permission* you put on a Pod. It says:
  *“I can live with this taint, so please schedule me on that Node.”*

👉 In simple terms:

* **Taint = Don’t allow unless…**
* **Toleration = I can handle it, let me in.**

---
## 2. **Why do we use Taints & Tolerations?**

* To **control which pods go to which nodes**.
* Useful in real projects:

  * Run **databases** only on special nodes.
  * Keep **system workloads** separate from application workloads.
  * Prevent test pods from running on **production nodes**.

---
## 3. **How it works (Scheduling Logic)**

1. You add a **taint** on a node.
   That node **repels** all pods (they won’t be scheduled there).
2. If a pod has a **matching toleration**, it can still be scheduled on that node.
3. If no toleration, pod will **stay pending**.
---

### Diagram:
 ```sh
 Node-1 (tainted) ──────┐
 role=logging:NoSchedule│
                        │
   ✔ Pod with toleration │   ✘ Pod without toleration
   (Scheduled here)      │   (Stays Pending)

```
---
## 4. **Commands**

### 👉 Add a taint to a node

```bash
kubectl taint nodes <node-name> key=value:effect
```

**Effects can be:**

* `NoSchedule` → Pods won’t be scheduled unless they tolerate.
* `PreferNoSchedule` → Try to avoid scheduling, but not guaranteed.
* `NoExecute` → New pods won’t schedule, and existing pods will be evicted unless they tolerate.

---
### 👉 Remove a taint

```bash
kubectl taint nodes <node-name> key:effect-
```

---
### 👉 Check taints on a node

```bash
kubectl describe node <node-name> | grep Taints
```

---
## 5. **YAML Example**

### Pod with Toleration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toleration-pod
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "env"
    operator: "Equal"
    value: "prod"
    effect: "NoSchedule"
```

---
## 6. **Explanation of YAML**

* `tolerations:` → Section in pod spec.
* `key: "env"` → Matches the taint key on the node.
* `value: "prod"` → Must match the taint value.
* `effect: "NoSchedule"` → Must match the taint effect.

👉 This pod can run on nodes that have this taint:

```
kubectl taint nodes <node-name> env=prod:NoSchedule
```

---
## 7. **Real-Time Example (End-to-End)**

1. Add a taint to a node:

```bash
kubectl taint nodes node1 env=prod:NoSchedule
```

2. Try to run a normal pod:

```bash
kubectl run test --image=nginx
```

👉 Pod will stay **Pending** (because node is tainted).

3. Now run a pod with toleration (YAML above).
   👉 Pod will be scheduled on `node1`.

---
## 8. **Best Practices**

✅ Use **taints** for dedicated workloads (like DB nodes, monitoring nodes).
✅ Don’t overuse — tolerations everywhere reduce their usefulness.
✅ Combine with **nodeSelector / nodeAffinity** for stronger scheduling control.

---
### Use Cases:

✅ Run GPU workloads on GPU nodes
✅ Run monitoring/logging Pods on dedicated nodes
✅ Block workloads from draining/maintenance nodes
---

