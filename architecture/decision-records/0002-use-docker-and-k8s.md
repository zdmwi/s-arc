# ADR 0002: Use Docker and Kubernetes 

|Category    | Value    |
|------------|----------|
| Identifier | adr-0002 |
| Status     | Proposed | 
| Author(s)  | Zidane Wright |
| Date:      | May 3, 2024 |

**keywords**: Runtime, Docker, Container, Kubernetes, K8s, Rancher, VM, Virtual, Machine

## Context and Problem Statement
Deploying our applications to bare-metal servers will most likely result in services that are underutilizing 
resources, difficult to scale and runtimes that are inconsistent and difficult to reproduce. These inefficiencies 
will translate to wasted capital for the company and slow releases to customers. 

## Decision 
We will use Docker and Kubernetes for deploying and managing our microservices.

## Rationale 
Docker and Kubernetes are the standard combination for many microservice applications and are the most 
documented solution as a result. Both are backed by large companies who are able to provide official support 
to engineers should any problems arise and will most likely be compatible with new innovations for our 
architecture.

**Rejected alternatives**:
- _Virtual Machines_: Virtual machines are much heavier than their Container alternatives. When it comes to 
scaling, spinning up a new virtual machine can take minutes whereas a new container can be spun up in milliseconds.
The host machine can run less virtual machines than containers as well and so scaling becomes more expensive.

- _Rancher_: Rancher is an open-source Docker alternative. It has pretty much all of the capabilities 
that Docker provides with some additional flexibility rolled in. It isn't a feasible choice for our system 
because we only need a very small subset of Docker/Rancher behavior for Containerization and working with 
kubernetes. Since Docker is more popular it is also much easier to debug and find help for any issues that 
engineers may face with any of the container stuff. Cost is a concern since Docker charges for teams, 
however in comparison to the cost of the man-hours that debugging Rancher issues is expected to take, $9 
per team member is acceptable.


## Consequences
- Locked into a paid contract with Docker. If for some reason we become unable to pay it will affect 
our deployment pipeline significantly. 

- Containers tend to have security concerns due to the nature of the shared OS resources with other 
containers. New and existing security risks will have to be monitored very closely.

- Very fast scaling and service recreation is possible if something goes wrong since containers are 
very lightweight. We also have the guarantee that the newly deployed service will be the same as the 
previous ones because they are created from images.
Describe here the resulting context, after applying the decision. All consequences should be listed, not just the "positive" ones. 

- Easy integration with other services in the ecosystem such as Helm, Istio, etc.

