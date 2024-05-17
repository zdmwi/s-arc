workspace {

    !identifiers hierarchical

    model {
        user = person "User"

        sArcSystem = softwareSystem "S-ARC System" {
            webApplication = container "Web Application" "Delivers the static content and the chat interface single page application" "Python and FastAPI" {
                tags "Web Browser"
                user -> this "Visits chat.s-arc.com using" "HTTPS"
            }

            singlePageApplication = container "Single Page Application" "Provides a chat interface to interact with the LLM" "Typescript and React" {
                tags "Web Browser"
                webApplication -> this "Delivers to the user's web browser"
                user -> this "Interacts with the LLM through a chat interface using" "JSON/HTTPS"
            }

            authService = group "Auth Service" {
                authServiceApi = container "Auth API" "Provides user authentication and authorization functionality" "Kotlin and Spring Boot" {
                    tags "Auth Service" "Service API"

                    signInController = component "Sign In Controller" "Allows users to sign into the S-ARC System" "Spring Boot Controller" {
                        tags "Auth Service" "Service Component"
                        singlePageApplication -> this "Makes auth requests to" "JSON/HTTPS"
                    }

                    signUpController = component "Sign Up Controller" "Allows users to sign up for the S-ARC System" "Spring Boot Controller" {
                        tags "Auth Service" "Service Component"
                        singlePageApplication -> this "Requests new account creation from" "JSON/HTTPS"
                    }
                    
                    resetPasswordController = component "Reset Password Controller" "Allows users to reset their password with a one-time URL" "Spring Boot Controller" {
                        tags "Auth Service" "Service Component"
                        singlePageApplication -> this "Requests password reset from" "JSON/HTTPS"
                    }
                    
                    refreshTokenController = component "Refresh Token Controller" "Allows users to refresh their authentication tokens" "Spring Boot Controller" {
                        tags "Auth Service" "Service Component"
                        singlePageApplication -> this "Requests new auth tokens from" "JSON/HTTPS"
                    }

                    springSecurity = component "Spring Security" "Provides authentication and authorization functionality" "Spring Bean" {
                        tags "Auth Service" "Service Component"
                        signInController -> this "Delegates authentication and authorization to"
                        signUpController -> this "Delegates authentication and authorization to"
                        resetPasswordController -> this "Delegates authentication and authorization to"
                    }
                }

                container "Auth API Database" "Stores user information" "PostgreSQL" {
                    tags "Auth Service" "Database"
                    authServiceApi -> this "Reads from and writes to" "SQL/TCP"
                    authServiceApi.signInController -> this "Queries for user information" "JSON/HTTPS"
                    authServiceApi.signUpController -> this "Writes user information" "JSON/HTTPS"
                    authServiceApi.resetPasswordController -> this "Updates user information" "JSON/HTTPS"
                }
            }

            # This is a stateless service as well. It relies on the deploymed embedding model to return relevant embeddings.
            contextServiceApi = container "Context API" "Converts user prompts to vector embeddings and repackages the query for optimal response quality" "Python and FastAPI" {
                tags "Context Service" "Service API"
                singlePageApplication -> this "Sends natural language prompt to" "HTTPS"

                embeddingController = component "Embedding Model Controller" "Forwards the prompt to the Embedding Model" "FastAPI Controller" {
                    tags "Context Service" "Service Component"
                    singlePageApplication -> this "Forwards the prompt to" "HTTPS"
                }

                embeddingModel = component "Embedding Model" "Generates embeddings for the provided prompt" "Python" {
                    tags "Context Service" "Service Component"
                    embeddingController -> this "Gets prompt token embeddings from" "GRPC"
                }
            }

            # It's useful to have this as a separate service because this will need to be done for
            # each prompt that a user sends. This way, we can scale indepdently to maintain performance expectations.
            # This can be made into a serverless function
            promptOptimizationService = group "Prompt Optimization Service" {
                promptOptimizationServiceApi = container "Prompt Optimization API" "Optimizes the provided prompt with relevant embeddings" "Python and LangServe" {
                    tags "Prompt Optimization Service" "Service API"
                    contextServiceApi.embeddingController -> this "Forwards the prompt token embeddings generated by the embedding model" "GRPC"

                    optimizerController = component "Prompt Optimizer Controller" "Forwards the optimized prompt to the LLM" "LangServe Chain Route" {
                        tags "Prompt Optimization Service" "Service Component"
                        this -> contextServiceApi.embeddingController "Gets prompt token embeddings from"
                    }

                    optimizer = component "Prompt Optimizer" "Compiles vector embeddings, snippets of relevant context and optimizes the prompts" "Python and LangChain" {
                        tags "Prompt Optimization Service" "Service Component"
                        optimizerController -> this "Gets optimized prompt from"
                    }
                }

                container "Prompt Optimization API Database" "Performs a lookup " "Pinecone" {
                    tags "Prompt Optimization Service" "Database"
                    promptOptimizationServiceApi -> this "Reads from and writes to"
                }
            }

            llmService = group "LLM Service" {
                llmServiceApi = container "LLM API" "Serves as the interface to the fine-tuned LLM" "Python and FastAPI" {
                    tags "LLM Service" "Service API"

                    llmController = component "LLM Controller" "Forwards the optimized prompt to the LLM" "FastAPI Controller" {
                        tags "LLM Service" "Service Component"
                        promptOptimizationServiceApi.optimizerController -> this "Forwards the optimized prompt to"
                        this -> singlePageApplication "Streams the LLM response to" "HTTPS"
                    }

                    llmModel = component "LLM Model" "Generates a response to the provided prompt" "Python" {
                        tags "LLM Service" "Service Component"
                        llmController -> this "Gets the LLM response from" "GRPC"
                    }
                }

                container "LLM API Database" "Stores the fine-tuned LLM model" "Pinecone"{
                    tags "LLM Service" "Database"
                    llmServiceApi -> this "Reads from and writes to"
                }

                container "LLM API Knowledge Graph" "Provides structured domain-specific knowledge for Software Architecture concepts" "Neo4j" {
                    tags "LLM Service" "Database"
                    llmServiceApi -> this "Reads from"
                }
            }

            # This can be made into a serverless function
            communicationsServerlessFunction = container "Communication Serverless Function" "Forwards email requests and text messaging requests to the communication system" "NodeJS and Serverless" {
                tags "Communication Facade Service" "Serverless Function"
            }

            messageQueue = container "Message Queue" "Stores messages for the communication system" "RabbitMQ" {
                tags "Communication Facade Service" "Message Queue"
                authServiceApi -> this "Writes messages to" "AMQP"

                communicationsServerlessFunction -> this "Reads messages from" "AMQP"
            }

            paymentFacade = group "Payment Facade Service" {
                paymentFacadeApi = container "Payment Facade API" "Forwards payment processing requests to the payment system" "Kotlin and Spring Boot" {
                    tags "Payment Facade Service" "Service API"
                    authServiceApi -> this "Requests user subscription information from" "HTTPS"

                    paymentController = component "Payment Controller" "Provides a wrapper around main API calls to the external Payment System" "Spring Boot Controller" {
                        tags "Payment Facade Service" "Service Component"
                        singlePageApplication -> this "Requests payment processing from" "HTTPS"
                    }
                }

                container "Payment Facade API Database" "Tracks user subscription information" "PostgreSQL" {
                    tags "Payment Facade Service" "Database"
                    paymentFacadeApi.paymentController -> this "Reads from and writes to"
                }
            }
        }

        communicationsSystem = softwareSystem "Communications System" "Facilitates all email and text messaging processing functionalities" {
            tags "External System"
            sArcSystem.communicationsServerlessFunction -> this "Forwards email and text message requests to" "HTTPS"
        }

        paymentSystem = softwareSystem "Payment System" "Facilitates all payment processing functionalities" {
            tags "External System"
            sArcSystem.paymentFacadeApi.paymentController -> this "Sends payment processing requests for user subscriptions to" "HTTPS"
        }
    }

    views {
        systemContext sArcSystem "S-ARC_System" {
            include *
        }

        container sArcSystem "S-ARC_Container" {
            include *
        }

        component sArcSystem.authServiceApi "Auth_Service_API_Component" {
            include *
        }

        component sArcSystem.paymentFacadeApi "Payment_Facade_Service_API_Component" {
            include *
        }

        component sArcSystem.contextServiceApi "Context_Service_API_Component" {
            include *
        }

        component sArcSystem.promptOptimizationServiceApi "Prompt_Optimization_Service_API_Component" {
            include *
        }

        theme default

        styles {
            element "Web Browser" {
                shape WebBrowser
            }
            element "Person" {
                shape Person
            }
            element "Service API" {
                shape hexagon
            }
            element "Database" {
                shape cylinder
            }
            element "Message Queue" {
                shape pipe
            }
        }
    }

    configuration {
        scope softwaresystem
    }
}