# ADR 0003: Facade Pattern for External Services

|Category    | Value    |
|------------|----------|
| Identifier | adr-0003 |
| Status     | Proposed | 
| Author(s)  | Zidane Wright |
| Date:      | May 3, 2024 |

**keywords**: External, Facade, Wrapper, Interface, Third-Party, Substitution

## Context and Problem Statement
Implementing the system to directly interact with an external or third-pary service is a recipe for disaster. 
If we have N services that communicate with the external service directly and there is a breaking change in 
the API, then we have N different source code changes to make and N different services to redeploy. By 
using a wrapper we reduce the number of code bases we need to modify to just 1 - which is the code base 
for the wrapper.

## Decision 
We will use the Facade pattern and wrap external service APIs in a uniform interface that all our services 
will make use of.

## Rationale 
Using a Facade saves us development time in the event that an external service makes a breaking change. It 
also leaves us with the flexibility to switch to a different service with minimal changes to our application 
in the future.

## Consequences
- The cost of change and the radius of effect after a breaking change from an external API are reduced from 
N services to just 1.

- Added overhead when making requests to external services since requests and responses must be processed 
through the Wrapper service before the actual requesting service gets a response.

- Since all requests and responses go through the same service we can cache requests and responses to 
save costs on API calls and improve the response time.

- Retain the option of switching to a different service with similar offerings without needing to change 
N services.
