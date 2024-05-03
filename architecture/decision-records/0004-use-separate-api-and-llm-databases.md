# ADR 0004: Use separate database for LLM services

|Category    | Value    |
|------------|----------|
| Identifier | adr-0004 |
| Status     | Proposed | 
| Author(s)  | Zidane Wright |
| Date:      | May 3, 2024 |

**keywords**: Database, Vector, Relational, LLM, Embeddings 

## Context and Problem Statement
Our application services can be divided into two main types: General and LLM (Large Language Model) related.
Both service types need to read and write data to fulfill their requests and should be able to access their data 
even if the other service type's data is corrupt or lost. The databases should also be able to be scaled 
independently of each other and be able to be positioned in regions and zones where there is compliance with 
the law.

## Decision 
We will use a separate database for LLM services than the one we use for more general application services.

## Rationale 
A database supporting both vector and relational entries can be inefficient and costly to scale when only 
one side of functionality is required. When we separate the databases for the two types of services we can 
utilize resources better and scale much more flexibly. 

**Rejected alternatives**:
- _Combined Vector and Relational Database_: A database that can manage both vector and relational entries 
simplifies management and implementation for the development team. The solution, however, means that 
scaling up due to increased activity from one service type results in a waste of resources for the other 
service type.

- _NoSQL Database_: A NoSQL database suffers from the same problems as the combined vector and relational 
database but also incurs some overhead from transforming the entries to the correct format when requested. 
It can also be difficult to provide the same "context" that a vector database can since the storage in a 
NoSQL database does not have any semantic meaning.

- _Relational Database_: Same problems as the combined vector and relational database. Things are natural 
for the general services, but become difficult to implement for the LLM services. 

## Consequences
- Requires paying for and configuring two databases instead of just one.

- Developers have to manage schemas in two different database languages. 

- Able to scale general and LLM services independently. We also don't have to worry about a crash or 
inconsistency in one database affecting the other because they are separate.

