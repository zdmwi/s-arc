# ADR 0005: Use API Gateway for Client communication

|Category    | Value    |
|------------|----------|
| Identifier | adr-0005 |
| Status     | Proposed | 
| Author(s)  | Zidane Wright |
| Date:      | May 3, 2024 |

**keywords**: API, Gateway, Client, BFF, Backend, Frontend, Pattern

## Context and Problem Statement
Our application has 3 user-facing clients that need to communicate with the services on each request.
One for web, iOS and Android. All 3 frontend applications will be responsible for accepting and 
sending a query to the LLM service for each prompt sent.

## Decision 
We will use the API Gateway pattern for frontend client communication.

## Rationale 
Requires the least amount of development effort to get implemented while still providing the same 
functionality. The frontend client will largely be sending text and images and all clients should 
handle them in the same way without deviation.

**Rejected alternatives**: 
- _BFF (Backend-for-frontend)_: Too much development and maintenance overhead for the minor convenience of 
being able to change something for any client's backend. There is no reason for the clients backends to be 
separated.

## Consequences
Describe here the resulting context, after applying the decision. All consequences should be listed, not just the "positive" ones. 

- Platform specific changes may be difficult to implement since the backend is shared by all clients.
Considering the nature of the application we expect there to be little to none such changes.

- Developers only need to manage one backend instead of the 3 for each frontend client.
