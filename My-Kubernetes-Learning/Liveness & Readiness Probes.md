# 🚀 Kubernetes: Liveness Probe & Readiness Probe
---
## 1. Why do we need Probes?
In Kubernetes, Pods run containers. But just because a container is **running**, it doesn’t always mean the **application inside is healthy**.
Examples:

* The container process is alive but stuck in an infinite loop.
* The app started but isn’t ready to serve traffic yet.
* The app crashed but the container didn’t exit properly.

👉 To handle these cases, Kubernetes uses **Probes**:

* **Liveness Probe** → Is the app alive? (If not, restart the container)
* **Readiness Probe** → Is the app ready to serve traffic? (If not, remove it from Service endpoints)

---
## 2. Liveness Probe: 🟢
* Checks if the **application is still running** properly.
* If the probe **fails repeatedly**, Kubernetes **kills the container** and restarts it.
* Think of it like a "pulse check".

📌 **Use Case**

* App stuck in a deadlock.
* App crashed but process didn’t exit.
* Container is up, but service is unusable.

✅ Example (HTTP check):

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3
```

Here:

* Waits 5s before first check.
* Probes every 10s.
* If it fails 3 times in a row → container is restarted.

---
## 3. Readiness Probe 🟡:
* Checks if the app is **ready to receive traffic**.
* If the probe **fails**, Kubernetes temporarily removes the Pod’s IP from the **Service Endpoints**.
* Unlike Liveness, it **doesn’t restart the container**.

📌 **Use Case**

* App is starting up slowly.
* App depends on a DB connection or cache before being usable.
* App temporarily unavailable (e.g., doing maintenance or warming cache).

✅ Example (TCP check):

```yaml
readinessProbe:
  tcpSocket:
    port: 3306
  initialDelaySeconds: 10
  periodSeconds: 5
```

Here:

* Kubernetes checks port `3306` is open.
* If not ready → pod is removed from service load balancing.

---

## 4. Startup Probe 🔵 (Bonus)

* Special probe introduced for **slow-starting apps**.
* Runs first → gives enough time for app to start **before liveness kicks in**.
* Prevents premature restarts.

✅ Example:

```yaml
startupProbe:
  httpGet:
    path: /healthz
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```

This allows **5 minutes (30×10s)** for startup before marking pod unhealthy.

---
## 5. Types of Probes: 
All probes (liveness, readiness, startup) can be of three types:

1. **httpGet** → Call HTTP endpoint. (Best for APIs)
2. **tcpSocket** → Check if port is open. (Best for DBs, non-HTTP apps)
3. **exec** → Run a command inside container. (Best for custom checks)

Example (`exec` probe):

```yaml
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
  initialDelaySeconds: 5
  periodSeconds: 10
```
---
## 6. Flow Diagram (High Level)

```
              ┌─────────────┐
              │   Pod/Container
              └──────┬──────┘
                     │
          ┌──────────┴──────────┐
          │                     │
   Liveness Probe         Readiness Probe
     (Am I alive?)          (Am I ready?)
          │                     │
   Fail → Restart         Fail → Remove Pod 
    Pod/Container          from Service LB
```

---
## 7. Best Practices ✅

* Always define **readiness probes** for production workloads.
* Use **liveness probes carefully** — bad config may cause restart loops.
* Use **startup probe** for apps with **slow initialization**.
* Don’t make probes too aggressive → avoid unnecessary restarts.
* Probe endpoints should be **lightweight** (not DB-heavy queries).

---
## 8. Combined Example: Web App Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: webapp
    image: myapp:1.0
    ports:
    - containerPort: 8080
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 15
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
    startupProbe:
      httpGet:
        path: /healthz
        port: 8080
      failureThreshold: 30
      periodSeconds: 10
```
**Flow here:**

1. Startup probe waits up to 5 min for the app.
2. Once running, readiness probe ensures traffic is sent **only when app is ready**.
3. Liveness probe continuously checks → restart container if it hangs.

---
✅ **In short:**

* **Liveness** → Should I restart this container?
* **Readiness** → Should I send traffic to this container?
* **Startup** → Give app enough time to boot before checking liveness.

---
# 🔹 Kubernetes Demo: Liveness & Readiness Probes: 👍
We’ll create a Pod, test probes, and observe Pod status changes.

---
## 1. Create a Demo Pod with Probes

📄 **pod-probes.yaml**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo
spec:
  containers:
  - name: demo-app
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      touch /tmp/healthy;
      httpd -p 8080 -h /; 
      sleep 3600;
    ports:
    - containerPort: 8080

    # Liveness Probe - checks /tmp/healthy file
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 10

    # Readiness Probe - checks if HTTP server is responding
    readinessProbe:
      httpGet:
        path: /
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
```

---
## 2. Apply the Pod

```bash
kubectl apply -f pod-probes.yaml
```

Check pod status:

```bash
kubectl get pods probe-demo -w
```

👉 You should see `Running` and `READY: 1/1`.

---
## 3. Test **Readiness Probe**

Simulate app being **not ready** by stopping HTTP server inside container:

```bash
kubectl exec -it probe-demo -- pkill httpd
```

Check Pod status:

```bash
kubectl get pods probe-demo
```

👉 Pod will still be **Running** but **READY = 0/1** (traffic won’t go to this Pod if part of a Service).

Restart HTTP server:

```bash
kubectl exec -it probe-demo -- httpd -p 8080 -h /
```

👉 Pod will return to `READY: 1/1`.

---
## 4. Test **Liveness Probe**

Delete the health file so probe fails:

```bash
kubectl exec -it probe-demo -- rm /tmp/healthy
```

Watch Pod events:

```bash
kubectl describe pod probe-demo | grep -A5 "Events"
```

👉 You’ll see messages like:

```
Liveness probe failed: cat /tmp/healthy: No such file
Back-off restarting failed container
```

After failures, Kubernetes will **restart the container** automatically.

---
## 5. Cleanup

```bash
kubectl delete pod probe-demo
```
---
## 6. Flow Recap (kubectl demo)

1. Pod created → **both probes succeed** → Pod Ready.
2. Stop HTTP server → **readiness probe fails** → Pod not in service.
3. Delete `/tmp/healthy` file → **liveness probe fails** → Pod restarts.

---

