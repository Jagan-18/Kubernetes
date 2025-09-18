# A **StorageClass** defines how **dynamic storage provisioning** works in Kubernetes.

It tells K8s **which storage backend (like AWS EBS, GCP PD, Azure Disk, NFS, Ceph, etc.)** to use when a PersistentVolumeClaim (PVC) requests storage.

---
# 🔹 StorageClass in Kubernetes:
## 📘 What is StorageClass?
* StorageClass acts as a **template** for creating PersistentVolumes (PVs).
* PVCs can request a StorageClass to get a dynamically created volume.
* If no StorageClass is specified, the cluster may use a **default StorageClass** (if defined).

---
## 📘 Example: StorageClass YAML

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-storageclass
provisioner: kubernetes.io/aws-ebs   # storage backend plugin
parameters:
  type: gp2                         # EBS volume type
  fsType: ext4                      # filesystem type
reclaimPolicy: Delete               # Delete PV when PVC is deleted
volumeBindingMode: WaitForFirstConsumer
```
---
### 🔹 Explanation (Line by Line):
1. **`apiVersion: storage.k8s.io/v1`**

   * This tells Kubernetes which API group & version this object belongs to.
   * Since `StorageClass` is part of the **storage API group**, we use `storage.k8s.io/v1`.

2. **`kind: StorageClass`**

   * Defines the type of Kubernetes object you’re creating.
   * Here, it’s a **StorageClass** object.

3. **`metadata:`**

   * Section for identifying information about this object.

   * **`name: gp2-storageclass`**

     * This is the name of your StorageClass.
     * PVCs will use this name in `storageClassName` to request this type of storage.

4. **`provisioner: kubernetes.io/aws-ebs`**

   * The **plugin (provisioner)** that knows how to talk to the storage backend.
   * In this case, it uses **AWS Elastic Block Store (EBS)**.
   * Different provisioners exist for different cloud providers or CSI drivers (e.g., `kubernetes.io/gce-pd`, `kubernetes.io/azure-disk`, `csi.storage.k8s.io`).

5. **`parameters:`**

   * Key/value options that customize how the storage volume is created.

   * **`type: gp2`**

     * Defines the type of AWS EBS volume.
     * `gp2` = General Purpose SSD.
     * Other types could be `io1` (IOPS optimized), `st1` (throughput optimized), etc.

   * **`fsType: ext4`**

     * Specifies the filesystem to format the volume with.
     * `ext4` is the default for Linux.
     * Could also be `xfs` or others.

6. **`reclaimPolicy: Delete`**

   * Defines what happens to the **PersistentVolume (PV)** when the **PersistentVolumeClaim (PVC)** is deleted.
   * Options:

     * `Delete` → The PV (and actual EBS disk) will be deleted automatically.
     * `Retain` → The PV will stay even if PVC is deleted (manual cleanup needed).

7. **`volumeBindingMode: WaitForFirstConsumer`**

   * Controls *when* the actual storage volume is created and bound.
   * Options:

     * `Immediate` (default) → volume is created as soon as PVC is created.
     * `WaitForFirstConsumer` → volume is created **only when a Pod using the PVC is scheduled**, ensuring the volume is created in the correct availability zone where the Pod runs.
   * This avoids mismatch issues in multi-zone clusters.

✅ This StorageClass defines a template for AWS EBS `gp2` volumes, formatted as `ext4`, automatically deleted with PVC, and created only when a Pod actually needs it.

---
## 🔹 PersistentVolumeClaim (PVC) using StorageClass

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
      storage: 5Gi
  storageClassName: gp2-storageclass
```

---

## 🔹 Pod using the PVC

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod-storage
spec:
  containers:
    - name: mycontainer
      image: nginx
      volumeMounts:
        - mountPath: "/data"
          name: myvolume
  volumes:
    - name: myvolume
      persistentVolumeClaim:
        claimName: mypvc
```

---

## 🔹 Key Fields in StorageClass

* **`provisioner`** → Defines which storage backend to use

  * AWS EBS → `kubernetes.io/aws-ebs`
  * GCP PersistentDisk → `kubernetes.io/gce-pd`
  * Azure Disk → `kubernetes.io/azure-disk`
  * CSI drivers → `csi.storage.k8s.io`
* **`parameters`** → Specific options (disk type, filesystem, etc.)
* **`reclaimPolicy`** → What happens when PVC is deleted

  * `Delete` → delete the volume
  * `Retain` → keep the volume
* **`volumeBindingMode`** →

  * `Immediate` → volume created right away
  * `WaitForFirstConsumer` → volume created only when a Pod uses it

---
### Here’s a clean **ASCII flow diagram** you can paste at the end of your file:

```markdown
---
## 🔹 End-to-End Flow Diagram

Storage provisioning in Kubernetes follows this path:

[StorageClass: gp2-storageclass]
             |
             v
[PersistentVolumeClaim: mypvc]
             |
             v
[PersistentVolume: AWS EBS volume created dynamically]
             |
             v
[Pod: mypod-storage mounts PVC at /data]

✅ Data written inside `/data` in the container is stored on the EBS volume.
```
---
This way, your `.md` file has:
1. **Concept** → What is StorageClass
2. **YAML Examples** → StorageClass, PVC, Pod
3. **Key Fields** → provisioner, parameters, reclaimPolicy, volumeBindingMode
4. **Diagram Flow** → visual representation
---

# Heres a **combined YAML manifest** that includes **StorageClass + PVC + Pod** in one file. You can save it as `storage-demo.yaml` and apply directly:

```yaml
# -----------------------------
# StorageClass
# -----------------------------
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp2-storageclass
provisioner: kubernetes.io/aws-ebs   # storage backend plugin
parameters:
  type: gp2                         # EBS volume type
  fsType: ext4                      # filesystem type
reclaimPolicy: Delete               # Delete PV when PVC is deleted
volumeBindingMode: WaitForFirstConsumer
---
# -----------------------------
# PersistentVolumeClaim (PVC)
# -----------------------------
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: gp2-storageclass
---
# -----------------------------
# Pod using the PVC
# -----------------------------
apiVersion: v1
kind: Pod
metadata:
  name: mypod-storage
spec:
  containers:
    - name: mycontainer
      image: nginx
      volumeMounts:
        - mountPath: "/data"
          name: myvolume
  volumes:
    - name: myvolume
      persistentVolumeClaim:
        claimName: mypvc
```

---
### 🔹 How this works:
1. `StorageClass` defines AWS EBS gp2 storage.
2. `PVC` (`mypvc`) requests **5Gi** from that StorageClass.
3. `Pod` (`mypod-storage`) mounts the PVC at `/data`.
4. When the Pod runs, Kubernetes dynamically provisions an **EBS volume**, binds it to the PVC, and mounts it inside the Pod.

✅ Any data written in `/data` inside the Nginx container is persisted on the EBS volume.

---
**end-to-end kubectl command sequence** 

## 🔹 End-to-End Demo with `kubectl`
### 1. Apply the manifest

```bash
kubectl apply -f storage-demo.yaml
```

This creates:

* StorageClass (`gp2-storageclass`)
* PVC (`mypvc`)
* Pod (`mypod-storage`)

---
### 2. Check the StorageClass:

```bash
kubectl get storageclass
```

You should see:

```
NAME               PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE
gp2-storageclass   kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer
```

---
### 3. Check the PVC status:

```bash
kubectl get pvc
```

Expected output:

```
NAME    STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
mypvc   Bound    pvc-xxxxxx-xxxx-xxxx-xxxx                  5Gi        RWO            gp2-storageclass   10s
```

✅ `STATUS` must be **Bound** → means PVC is successfully using a PV created dynamically.

---
### 4. Check the Pod status:

```bash
kubectl get pods
```

You should see:

```
NAME            READY   STATUS    RESTARTS   AGE
mypod-storage   1/1     Running   0          20s
```

---
### 5. Exec into the Pod to test storage:

```bash
kubectl exec -it mypod-storage -- /bin/bash
```

Inside the container:

```bash
cd /data
echo "Hello from Kubernetes Storage" > test.txt
cat test.txt
```

Output:

```
Hello from Kubernetes Storage
```

✅ This file is stored on the **EBS volume** provisioned by your StorageClass.

---
### 6. Delete the Pod but keep the PVC:

```bash
kubectl delete pod mypod-storage
```

Now recreate the Pod using the same PVC → your file `/data/test.txt` will still be there (because PVC is still bound to the PV).

---
### 7. Delete the PVC (and check reclaimPolicy):

```bash
kubectl delete pvc mypvc
```

* Since `reclaimPolicy: Delete`, the **PV + AWS EBS volume** will also be deleted.
* If it were `Retain`, the PV would remain, and you’d have to clean up manually.

---
✅ **Full workflow verified!**
* `StorageClass` defines storage rules.
* `PVC` requests storage dynamically.
* `Pod` mounts PVC and persists data.
---
