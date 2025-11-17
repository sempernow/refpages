# Artificial Intelligence (AI)

## AI-assited Workflow 

### [Simple Workflow Commands](https://www.youtube.com/watch?v=LUFJuj1yIik "DOT")

References

- [`dot-ai`](https://github.com/vfarcic/dot-ai "GitHub")
    - [Quick Start](https://github.com/vfarcic/dot-ai/blob/main/docs/quick-start.md)
        - Product Requirements Document (PRD)

### Technologies 

- __AI Agent__ : A software system that uses artificial intelligence 
  to act autonomously and pursue specific goals.
- LLM (Large Language Model)
- [MCP (Model Context Protocol)](https://modelcontextprotocol.io/docs/getting-started/intro)
    - __Standard interface__ : A __bridge__ between AI agent and external systems. Using __MCP servers__, AI applications can connect to __data sources__ (e.g. local files, databases), __tools__ (e.g. search engines, calculators) and __workflows__ (e.g. specialized prompts), enabling them to access key information and perform tasks.
    - [__MCP Server__](https://www.youtube.com/watch?v=7baGJ1bC9zE "YouTube/DOT")
        - Terminal agents have access to all CLI tools natively. 
          No need to wrap any of that in an MCP server. 
          Add an MCP server only to __extend agent capabilities__
          to __satisfy user intentions__.  
            - Access to tools and services inaccessible to the agent alone.
                - Bundle primitives into higher level construct. 
                    - [AWS MCP Servers](https://github.com/awslabs/mcp)
                        - [AWS EKS MCP Server](https://awslabs.github.io/mcp/servers/eks-mcp-server "awslabs.github.io") | 
                        [`eks-mcp-server`](https://github.com/awslabs/mcp/tree/main/src/eks-mcp-server "github.com")
        - Agents can be embedded in an MCP Server!
            - Else use Sampling; allows client agent to preserve prompts
        - Use MCP servers to serve prompts 
        - __Combine code, prompts, and agent__ as apropos.
- __Vector Database__ : For semantic search. Chunk content into pieces fitting the number of elements of a model; embeddings; __embedding model__.
- __RAG__ (Retrieval Augmented Generation) : Bridge between vector database and AI responses. Provides AI with vector-database enhanced context for the subject query.
    - <abbr title="Large Language Model">LLM</abbr> + [Vector Databases](https://en.wikipedia.org/wiki/Vector_database "Wikipedia") 


With RAG, an agent query becomes an embedding that searches the vector database, which contains all the rules and meta of your code base, org policies, and such, and provides all that context to the agent.

### Concepts

- __AI Context Management__  
[Serving Prompts through MCPs](https://www.youtube.com/watch?v=XwWCFINXIoU "DOT")  
Stop Wasting Time:      
    - __AI without context is useless__.   
    - __Prompts are that context__.
    - Turn AI Prompts and __Context__ Into Production Code
        - Treat prompts like prod code; a shared asset that evolves with your team.
        More than merely instructions, prompts are the team's collective knowledge encoded in a way that AI can execute.
        - Build the MCP prompt server : Have AI create it, and maintain it as a real Git project, complete with documentation, MR, and such. So, the latest version of all prompts is available for use in all projects by all team members. 
        See `shared-prompts` dir of [`dot-ai`](https://github.com/vfarcic/dot-ai "GitHub : vfarcic/dot-ai")

## Terminal-based Agents

- [Claude Code](https://claude.com/product/claude-code) | [`dot-ai`](https://github.com/vfarcic/dot-ai "GitHub")
    - Phases
        - Planning : Opus Plan Mode (best)
        - Execution : Sonnet (cheap)

[Everything else sucks.](https://www.youtube.com/watch?v=MXOP4WELkCc)

- [Cursor Agent CLI](https://cursor.com/blog/cli)

Untested:

- goose
- Warp 
- gwen-code
- Gemini-cli

Table Stakes:

1. MCP Servers and their status
2. Safe Prompts; security guardrails


## AI-native IDEs

An AI-native IDE is an Integrated Development Environment built from the ground up with an AI assistant as its core, central component. 
The AI is not a plugin; it's the fundamental interface.

Built to contain and host AI agents

- Cursor Agent
    - IDE is fork of VS Code
    - Interacts with IDE-integrated terminal
- Warp
- Claude Code 

|Tool|Account Model|Who You Pay|
|----|-------------|-----------|
|Cursor|Cursor|Cursor (subscription)|
|Warp|Warp|Warp (freemium/subscription)|
|Claude for VS Code|BYOK|Anthropic|
|VS Code + Extensions|BYOK|Multiple providers directly|



## Run LLMs locally

[Ollama](https://ollama.com/) is a model runner; run locally. 

- Works offline
- Requires GPU and such resources

So while Cursor, Warp, and Claude are end-user applications, 
Ollama is more like the engine that can power those applications with local, 
open-source models instead of cloud-based proprietary ones.

It's part of the growing "local-first" AI movement 
that complements rather than replaces the cloud-based tools.

## Prompt Template

Implement [function/class/endpoint] to [goal] using [library/framework].

Work in [files/paths] only.

Respect [sytle/tests/rules].

Provide [tests/docs/migration].

(And either a or b:)
a. If assumptions are needed, list them first.
b. If anything in the plan is ambiguous, stop and output options with trade-offs instead of guessing.

- More context begets less cost (tokens).
- Don't let the AI guess.
- Specify the model.

---

## [ArdanLabs : Guide to AI](https://www.youtube.com/watch?v=wbo7M2jF0Lc&list=PLADD_vxzPcZDzTmmub99S0Ne58ApvJZjJ "YouTube : ArdanLabs : Exploring Vector Databases and Embeddings in AI")

### [`ardanlabs/ai-training`](https://github.com/ardanlabs/ai-training "GitHub")

- Ep.1 : [Exploring Vector Databases and Embeddings in AI](https://www.youtube.com/watch?v=wbo7M2jF0Lc&list=PLADD_vxzPcZDzTmmub99S0Ne58ApvJZjJ&index=4)
    - [example1](ai-training/examples/example1/main.go) : 
        - Hand craft a vector embedding scheme for a data set
        - Use cosine-similarity function to evaluate it
- Ep.2 : [Leveraging LLMs for Powerful Vector Embedding](https://www.youtube.com/watch?v=rV162WwQ1hw&list=PLADD_vxzPcZDzTmmub99S0Ne58ApvJZjJ&index=2)
    - [example2](ai-training/examples/example2/main.go) : 
        Same as Ep.1, but use an __LLM vector-embedding model__ to generate the embedding scheme.
        - Ollama model server : Create vector embedding
            ```Makefile
            ollama-pull:
                ollama pull mxbai-embed-large
                ollama pull llama3.1
            ```
            - `mxbai-embed-large` is for text data
- Ep.3 : [Training AI Models on Custom Data with Word2Vec](https://www.youtube.com/watch?v=inWa6TTVdfU&list=PLADD_vxzPcZDzTmmub99S0Ne58ApvJZjJ&index=1) : [Word2Vec](https://github.com/fogfish/word2vec) model : 
      a technique in __Natural Language Processing__ (NLP) 
      for obtaining vector representations of words. 
      These vectors capture information about the meaning of the word 
      based on the surrounding words.
    - [example3](ai-training/examples/example3/main.go) : 
        1. Clean the data
        1. Train the model on the data
        1. Evaluate/experiment 
- Ep.4 : [Enhancing AI Similarity Searches with MongoDB](https://www.youtube.com/watch?v=HEptRbPbbic&list=PLADD_vxzPcZDzTmmub99S0Ne58ApvJZjJ&index=4)
    - [MongoDB](https://www.mongodb.com/products/self-managed/community-edition) Atlas (Vector DB extension)


---

## Level Up

Fastest path to learn ML, AI/Agenic Framworks, and such

The "fastest path" requires a focused, project-driven approach that prioritizes practical skills over deep theoretical understanding at the beginning. The key is to **build and deploy working systems as quickly as possible.**

Here is a structured, ___four-phase fast-track plan___.

### Guiding Philosophy: "Deploy First, Theory Later"
*   **Goal-Oriented:** You will learn by building specific, tangible projects.
*   **Stack-Focused:** You'll learn a specific, modern toolchain from day one.
*   **Iterative:** You will start simple and progressively add complexity.

---

### Phase 1: Foundational Grounding (2-4 Weeks)
**Goal:** Understand the landscape and get your hands dirty with basic code.

1.  **Core Concepts (The "What"):**
    *   Understand the difference between AI, Machine Learning (ML), and Deep Learning.
    *   Learn key terminology: Supervised vs. Unsupervised Learning, Training vs. Inference, Models, Parameters, etc.
    *   **Resources:** Watch short, conceptual videos on YouTube (channels like [3Blue1Brown](https://www.youtube.com/watch?v=aircAruvnKk) for intuition).

2.  **Essential Tooling (The "How"):**
    *   **Python:** If you don't know it, focus *only* on the basics: variables, loops, functions, and importing libraries. Use a crash course.
    *   **Libraries:** Install and learn the basic usage of:
        *   `pandas` (for data manipulation)
        *   `numpy` (for numerical operations)
        *   `matplotlib`/`seaborn` (for plotting)
    *   **Environment:** Use **[Google Colab](https://colab.research.google.com/)** to start. It's free, has GPUs, and comes with most libraries pre-installed. This avoids setup hell.

3.  **First Project:**
    *   **Build a classic ML model.** Follow a tutorial to build a simple image classifier (on MNIST dataset) or a house price predictor. Use a high-level library like `scikit-learn`. The goal is to see a full cycle: load data, train a model, evaluate it.

---

### Phase 2: Core Machine Learning & Deep Learning (4-6 Weeks)
**Goal:** Build a solid practical understanding of how neural networks work and how to train them.

1.  **Deep Learning Fundamentals:**
    *   **Framework:** Choose **PyTorch**. It's more pythonic and is the dominant framework in research and most new AI companies. ([TensorFlow](https://www.youtube.com/watch?v=i8NETqtGHms) is also valid, but PyTorch is recommended for a faster start).
    *   **Core Concepts:** Learn about Tensors, Datasets & DataLoaders, building a simple Neural Network (Linear layers, ReLU), the training loop (loss functions, optimizers), and how to train on a GPU.

2.  **Key Project:**
    *   **Build an image classifier from scratch.** Use a dataset like CIFAR-10. Don't use a pre-trained model yet. Manually build a Convolutional Neural Network (CNN) in PyTorch. Struggle with the training loop, debugging, and overfitting. This struggle is where the real learning happens.

3.  **Specialize:**
    *   Pick one domain to apply your skills:
        *   **Computer Vision (CV):** CNNs, Object Detection (YOLO), Image Segmentation.
        *   **Natural Language Processing (NLP):** Transformers, Text Classification, Named Entity Recognition.

---

### Phase 3: The "Agentic" & Modern AI Stack (4-6 Weeks)
**Goal:** Move from static models to interactive, reasoning AI systems using large language models.

This is the most critical and high-value phase for the current market.

1.  **Master Prompt Engineering & LLM APIs:**
    *   **Skill:** Learn to effectively call and instruct LLMs via APIs.
    *   **Tool:** Start with the **OpenAI API** (for GPT-4o) or **Anthropic's Claude API**. Learn about system prompts, few-shot learning, and controlling output (temperature, max tokens).
    *   **Project:** Build a simple chatbot or a text summarizer.

2.  **Introduction to RAG (Retrieval-Augmented Generation):**
    *   **Concept:** This is the foundation of most modern AI applications. It allows an LLM to use your own private data.
    *   **Toolchain:** Learn a basic stack:
        *   **Vector Database:** **ChromaDB** (easiest to start with) or **Pinecone** (managed service).
        *   **Embedding Models:** Learn to use OpenAI's `text-embedding-ada-002` or a similar open-source model.
    *   **Project:** Build a **Document Q&A System**. Ingest a PDF (or many), chunk the text, create embeddings, store them in ChromaDB, and query it using an LLM. This is a *massive* portfolio piece.

3.  **Introduction to AI Frameworks & Agents:**
    *   **Framework:** Learn **LangChain** or **LlamaIndex**. These are the standard frameworks for building LLM applications.
        *   **LangChain:** More flexible, great for building complex agentic workflows where an LLM can use tools (e.g., a calculator, web search, your API).
        *   **LlamaIndex:** Specialized and often simpler for RAG applications.
    *   **Project:** Use **LangChain** to build a simple agent. For example, a "Research Agent" that can use the Google Search API to find recent news and then write a summary.

---

### Phase 4: Integration & Production (Ongoing)
**Goal:** Turn your scripts into deployable applications.

1.  **Build a Full-Stack AI Application:**
    *   Combine your skills. Build a web app with a frontend that uses your RAG system or agent on the backend.
    *   **Simple Stack:** A **Streamlit** app is the fastest way to create a UI for your Python backend. It's the go-to for data scientists and ML engineers to demo their work.

2.  **Deployment & MLOps Basics:**
    *   **Containers:** Learn the absolute basics of **Docker**. Create a Dockerfile for your Streamlit app.
    *   **Cloud Deployment:** Deploy your containerized app to a cloud service. The easiest path is **Google Cloud Run** or **AWS ECS**.
    *   **Concept:** Understand what an API endpoint is and how your frontend would call your model.

### Your "Fast-Track" Learning Stack Summary

| Phase | Focus Area | Key Tools & Technologies |
| :--- | :--- | :--- |
| **1. Foundation** | Python, Data, Basic ML | Python, Pandas, NumPy, Scikit-learn, **Google Colab** |
| **2. Core ML/DL** | Neural Networks, Training | **PyTorch**, CNNs, Transformers |
| **3. Modern AI** | LLMs, RAG, Agents | **OpenAI/Claude API**, **ChromaDB**, **LangChain**, **LlamaIndex** |
| **4. Production** | Deployment, Applications | **Streamlit**, **Docker**, **Google Cloud Run / AWS** |

### Fastest Possible Path to a Job

If you need to get job-ready in 3-6 months, your portfolio should consist of these 3 projects:

1.  **A "from-scratch" DL Project:** A custom image or text classifier built in PyTorch. (Shows fundamentals).
2.  **A RAG System:** A sophisticated Document Q&A system using LangChain/LlamaIndex and a vector DB. (Shows modern LLM skills).
3.  **A Deployed Agentic App:** A Streamlit web app, deployed on the cloud, that demonstrates an AI agent using tools (e.g., search, calculator, your own data). (Shows full-stack, production potential).

**Final Advice:** Don't get stuck in "tutorial purgatory." Spend 20% of your time on tutorials and 80% on building your own projects, even if they are messy and break. That is the fastest path to true, marketable expertise.




### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

