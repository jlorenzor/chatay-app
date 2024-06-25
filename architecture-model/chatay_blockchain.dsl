workspace "NYPL eReading" "The eReading system at the New York Public Library." {

  !identifiers hierarchical

  model {

    citizen = person "Citizen" "Citizen victim or witness of the incident"

    councilAgents = person "Council Agents" "Monitoring agents of the serenazgo or CCTV security camera of the municipality"

    policeOfficers = person "Police Officers" "Police, forensic experts, detectives, etc"

    courtAgents = person "Court Agents" "Prosecutors, judges, lawyers, etc"
    
    chataySecurity = softwareSystem "Chatay Auth" "Provides third party authentication and authorization for citizens by the government" "Existing System"

    group "Chatay Ecosystem" {

      chatayPublicApp = softwareSystem "Chatay Public Application" "Recording of incidents and citizen reports (Phase 1 [s1, s2, s3] and Phase 2 [s4, s5, s6, s7])" {
        cpHybridApp = container "Mobile Hybrid App" "Offers a minimalist interface for public incident reporting" "Flutter" "Mobile App" {
          nativeReader = component "Native Reader" {
            technology "Readium 2, Kotlin/Swift"
            description "Native reader for viewing a book in the app"
          }
          drmModule = component "Native DRM Module" {
            technology "Kotlin/Swift"
            description "Native DRM module for decrypting books"
          }
          nativeReader -> drmModule "Decrypts books with"
                    
          cpWebCatalog = component "Web Catalog" "Login, browse the catalog, borrow & return books" "HTML, CSS, JavaScript"
          cpWebCatalog -> nativeReader "Opens books using"
          nativeReader -> cpWebCatalog "Sends reading location and bookmarks to"
        }
        cpWebApp = container "Web Application" "Offers a public incident reporting interface that allows you to attach evidence such as images and short videos." "Flutter Web" "Web Browser"{
          group "Web Reader Utilities" {
            webReader = component "Web Reader" "Web-based reader for eBooks in multiple formats (PDF & EPUB)" "React"
            epubToWebpub = component "Epub to Webpub" "Package to generate Webpub manifests from exploded EPUBs" "TypeScript" {
              -> webReader "Sends Webpub manifest to"
              webReader -> this "Sends decryption parameters and container.xml to"
            }
            epubToWebpubApp = component "Epub to Webpub App" "Next.js app with an API endpoint to convert EPUBs to Webpub manifests" "Next.js" {
              -> epubToWebpub "Uses to turn EPUBS into Webpubs"
            }
            axisNowWebDecryptor = component "AxisNow Access Control Web" "AxisNow Decryptor for Web" "TypeScript" {
              webReader -> this "Instantiates"
            }
          }
        }
      }

      chatayConsortiumApp = softwareSystem "Chatay Consortium Application" "Culminacion de la investigacion y presentacion de pruebas en el juicio [s8]" {
        ccWebApp = container "DRB Web App" "Web interface for courtAgentss to search, find, and retrieve digital resources" "Next.js" "Web App" {
          webReader = component "Web Reader" "Web-based reader for eBooks in multiple formats (PDF & EPUB)" "React"
          iFrameReader = component "IFrame Reader" "Web-based reader for eBooks in embeddable formats (HTML)"
          ccSearch = component "DRB Search" "Find research resources to read, request, or download"
          researchCatalog = component "NYPL Research Catalog" "Online research catalog for requesting scans or physical research material at NYPL locations"
        }

        
        ccApi = container "DRB Extract, Transform & Load API" "Application for loading records from external sources into the DRB collection and providing access via API" "Python/Flask" {
          group "Web Reader Utilities" {
            webReader = component "Web Reader" "Web-based reader for eBooks in multiple formats (PDF & EPUB)" "React"
            epubToWebpub = component "Epub to Webpub" "Package to generate Webpub manifests from exploded EPUBs" "TypeScript" {
              -> webReader "Sends Webpub manifest to"
              webReader -> this "Sends decryption parameters and container.xml to"
            }
            epubToWebpubApp = component "Epub to Webpub App" "Next.js app with an API endpoint to convert EPUBs to Webpub manifests" "Next.js" {
              -> epubToWebpub "Uses to turn EPUBS into Webpubs"
            }
            axisNowWebDecryptor = component "AxisNow Access Control Web" "AxisNow Decryptor for Web" "TypeScript" {
              webReader -> this "Instantiates"
            }
          }
          webpubGenerator = component "Webpub Generator" "Generates Webpubs from PDFs & EPUBs"
        }

        ccWebApp -> ccApi "Reads data from"
        ccApi.webpubGenerator -> ccWebApp "Sends Webpubs to"
        ccApi.webpubGenerator -> ccApi.epubToWebpubApp "Sends a container.xml file of an exploded EPUB to"
        ccApi.epubToWebpubApp -> ccApi.webpubGenerator "Sends Webpub manifest to"
      }

      chatayBlockchain = softwareSystem "Chatay Blockchain" {
        // Blockchain APIs
        group "Chatay Auth API Integration (Off-Chain)" {
          chatayAuthApiIntegration = container "Auth API Integration" "Auth Goverment Integration"
        }

        group "Chatay L1 & L2 Blockchains (On-Chain)" {
          chatayBlockchainApi = container " Chatay API Blockchain" "Provides API endpoints for client applications" "Actix Web" {
            cbApiSmartContractApi = component "Smart Contract API" "API for smart contract interactions"
            cbApiBlockchainApi = component "Blockchain API" "API for blockchain interactions"
          }

          chatayL2Blockchain = container "Chatay L2 Blockchain" "Provides scalability: Enhances scalability and additional features" "Sidechains, Shards and Rollups" "L2BC" {
            group "Rollups (En cada uno de los 1874 distritos)" {
              cl2bRollup = component "Rollup" "Rollup" "Rollup" "Rollup"
              cl2bRollupManager = component "RollupManager" "Gestiona el ciclo de vida del rollup" "RollupManager" "Rollup"
              cl2bTransactionBatcher = component "TransactionBatcher" "Agrupa transacciones en lotes" "Rollup" "Rollup"
              cl2bStateCommitmentEngine = component "StateCommitmentEngine" "Genera compromisos de estado" "Rollup" "Rollup"
            }
            cl2bShard = component "Shard" "Shard por provincia (196)" "Shard" "Shard"
            cl2bSidechain = component "Sidechain" "Sidechain por delitos (20?)" "HotStuff" "Sidechain"

            cl2bShard -> cl2bSidechain "Shards data to"
            cl2bRollup -> cl2bShard "Rolls up data to"
          }

          chatayL1Blockchain = container "Chatay L1 Blockchain" "Provides foundational framework: Consensus, network and data layer" "HotStuff, P2P, Cryptography, etc" "L1BC" {
            group "Consensus Layer Components" {
              cl1bNetwork = component "Network" "Network" "P2P"
              cl1bConsensus = component "Consensus" "Consensus" "HotStuff"
            }

            group "Network Layer Components" {
              cl1bPacemaker = component "Pacemaker" "Pacemaker" "HotStuff"
              cl1bLeaderElection = component "Leader Election" "Leader Election" "HotStuff"
              cl1bMempool = component "Mempool" "Mempool" "HotStuff"
            }

            group "Data Layer Components" {
              cl1bNodeDB = component "Node DB" "Node DB" "RocksDB"
              cl1bNode = component "Node" "Node" "HotStuff"<
              cl1bCrypto = component "Cryptography" "Cryptography" "BLS"
            }

            cl1bNode -> cl1bMempool "Adds transactions to"
            cl1bLeaderElection -> cl1bNetwork
          }
        }
        chatayAuthApiIntegration -> chatayBlockchainApi.cbApiBlockchainApi "Allows access to"
        chatayAuthApiIntegration -> chatayBlockchainApi.cbApiSmartContractApi "Allows execution of"
        chatayBlockchainApi -> chatayL2Blockchain "Writes to"
        chatayBlockchainApi.cbApiSmartContractApi -> chatayL2Blockchain.cl2bRollup "Interacts with"
        chatayBlockchainApi.cbApiBlockchainApi -> chatayL1Blockchain "Reads from"

        chatayL2Blockchain -> chatayL1Blockchain.cl1bNode "Writes to"
        chatayL2Blockchain.cl2bSidechain -> chatayL1Blockchain.cl1bNode "Two-way pegs data to"
      }
    }

    chatayBlockchain.chatayAuthApiIntegration -> chataySecurity "Authenticates with"

    chatayConsortiumApp.ccWebApp -> chatayBlockchain.chatayAuthApiIntegration "Gets authentication tokens from"
    chatayPublicApp.cpWebApp -> chatayBlockchain.chatayAuthApiIntegration "Gets authentication tokens from"
    chatayPublicApp.cpHybridApp.cpWebCatalog -> chatayBlockchain.chatayAuthApiIntegration "Gets authentication tokens from"

    citizen -> chatayPublicApp "[s2, s3, s5, s7] Manage evidence using"
    citizen -> chatayPublicApp.cpHybridApp "[s2, s3, s5, s7] Manage evidence using"
    
    councilAgents -> chatayPublicApp.cpWebApp.webReader "[s2, s3, s5, s7] Manage evidence using"
    councilAgents -> chatayPublicApp.cpHybridApp "[s2, s3, s5, s7] Manage evidence using"
    councilAgents -> chatayPublicApp.cpHybridApp.cpWebCatalog "Browse and search collection using"
    policeOfficers -> chatayPublicApp "[s3, s5, s6, s7] Manage evidence using"

    courtAgents -> chatayConsortiumApp.ccWebApp "[s8] Get evidence using"
    courtAgents -> chatayConsortiumApp.ccWebApp.webReader "Opens books using"
    courtAgents -> chatayConsortiumApp.ccWebApp.iFrameReader "Opens books using"
    courtAgents -> chatayConsortiumApp.ccWebApp.ccSearch "Downloads books using"
    courtAgents -> chatayConsortiumApp.ccWebApp.researchCatalog "Request books using"
  }

  views {
    systemlandscape "SystemLandscape" {
      include *
      autoLayout
    }

    systemContext chatayPublicApp {
      include *
      autoLayout
    }

    container chatayPublicApp {
      include *
      autoLayout
    }

    component chatayPublicApp.cpHybridApp {
      include *
      autoLayout
    }

    component chatayPublicApp.cpWebApp {
      include *
      autoLayout
    }

    systemContext chatayConsortiumApp {
      include *
      autoLayout
    }

    container chatayConsortiumApp {
      include *
      autoLayout
    }

    component chatayConsortiumApp.ccApi {
      include *
      autoLayout
    }

    component chatayConsortiumApp.ccWebApp {
      include *
      autoLayout
    }

    systemContext chatayBlockchain {
      include *
      autoLayout
    }

    container chatayBlockchain {
      include *
      autoLayout
    }

    component chatayBlockchain.chatayBlockchainApi {
      include *
      autoLayout
    }

    component chatayBlockchain.chatayL1Blockchain {
      include *
      autoLayout
    }

    component chatayBlockchain.chatayL2Blockchain {
      include *
      autoLayout
    }
    
    theme default

    styles {
      element "Person" {
        color #ffffff
        fontSize 22
        shape Person
      }
      element "Customer" {
        background #08427b
      }
      element "Bank Staff" {
        background #999999
      }
      element "Software System" {
        background #1168bd
        color #ffffff
      }
      element "Existing System" {
        background #999999
        color #ffffff
      }
      element "Container" {
        background #438dd5
        color #ffffff
      }
      element "Web Browser" {
        shape WebBrowser
      }
      element "Mobile App" {
        shape MobileDeviceLandscape
      }
      element "Database" {
        shape Cylinder
      }
      element "Component" {
        background #85bbf0
        color #000000
      }
      element "Failover" {
        opacity 25
      }

      element "L1BC" {
        background #007910
        color #ffffff
        shape RoundedBox
      }

      element "Rollup" {
        background #D81010
        color #ffffff
        shape Folder
      }

      element "Shard" {
        background #D81010
        color #ffffff
        shape Box
      }

      element "Sidechain" {
        background #D81010
        color #ffffff
        shape RoundedBox
      }

      element "L2BC" {
        background #D81010
        color #ffffff
        shape RoundedBox
      }
    }
  }
}
