# ADR 0001: Use the Microservice Architecture Pattern 

|Category    | Value    |
|------------|----------|
| Identifier | adr-0001 |
| Status     | Proposed | 
| Author(s)  | Zidane Wright |
| Date:      | May 3, 2024 |

**keywords**: Microservices, Architecture, Services, Coupling

## Context and Problem Statement
The system will have distinct sections that will all grow independently of each other and will require 
the expertise of professionals from different disciplines. From a business perspective, it is especially 
important that the application remains accessible for customers if an unrelated component fails and that 
the system scales up and down to meet demand and save costs. Because of this, it is important to choose 
an architecture style that is reliable, loosely-coupled, programming language agnostic and highly 
scalable.

## Decision 
We will implement our backend services using the Microservice Architecture.

## Rationale 
The Microservice Architecture best supports the goals of the organization while supporting the necessary
flexibility and performance constraints that the engineering team would like. The architecture also 
benefits from a large (and still growing) body of discussions and established best practices from 
large companies like Netflix and Amazon so there are resources and roadmaps to help avoid pitfalls 
during adoption.

**Rejected Alternatives**:
- Service-Oriented Architecture: Suffers from a single point of failure due to the message bus. An 
explicit constraint of the Organization is that a failure in one service or part of the application 
should not trigger a failure in another.

- Space-Based Architecture: This alternative would have been ideal since the we could use a service mesh to 
provides capabilities like observability, traffic management and security without having to modify source
code. However, the upfront complexity for the increased scalability in the future did not seem warranted
given that the S-ARC system is targeted to a very niche customer base. If we had a larger set of microservices 
then this would have been an excellent choice.

## Consequences
- Flexible development and deployment. Each service can be developed in the development team's preferred
language and at varying paces and timelines. Upgrades to one service do not affect another and can be 
deployed or rolled back in the case of any issues.

- Increased development and deployment complexity. There is quite a bit of overhead in establishing 
API contracts between services. Telemetry, security, rate-limiting and log consolidation will need to be 
setup for the system.


