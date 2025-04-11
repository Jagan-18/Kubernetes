
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


