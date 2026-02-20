# Claude Code: The Practical Guide

A step-by-step guide to building a Next.js note-taking application using Claude Code — from generating the specification to scaffolding, authentication, and leveraging MCP servers.

---

## Contents

- [Part 1: Generating the Specification (SPEC.MD)](#part-1-generating-the-specification-specmd)
- [Part 2: Project Initialization & The /init Command](#part-2-project-initialization--the-init-command)
- [Part 3: Linking SPEC.MD in CLAUDE.md](#part-3-linking-specmd-in-claudemd)
- [Part 4: Scaffolding a Next.js App](#part-4-scaffolding-a-nextjs-app)
- [Part 5: Authentication & Database Implementation](#part-5-authentication--database-implementation)
- [Part 6: Supercharging Claude Code with MCP Servers](#part-6-supercharging-claude-code-with-mcp-servers)
- [Part 7: Codebase Evaluation with Sub-Agents](#part-7-codebase-evaluation-with-sub-agents)
- [Part 8: Creating a Custom Documentation Sub-Agent](#part-8-creating-a-custom-documentation-sub-agent)
- [Part 9: Using DocsExplorer for Codebase Validation](#part-9-using-docsexplorer-for-codebase-validation)

---

# Part 1: Generating the Specification (SPEC.MD)

In this part, we set up the foundation for a note-taking application using Claude Code. Instead of jumping straight into coding, we focus on creating a "source of truth" specification document (`SPEC.MD`). This ensures the AI understands the full scope of the architecture, database schema, and feature set before writing a single line of code.

**Prerequisites:**
- **Claude Code** installed and authenticated in your terminal.
- A basic project folder created.
- **Tech Stack defined:** Next.js, Bun, TypeScript, TailwindCSS, SQLite, Better-Auth (Authentication), and TipTap (Rich Text Editor).

---

## Step 1: Generate the Initial Specification

Before engaging Claude Code to write software, you need a blueprint. We will use ChatGPT to generate a technical specification document (`SPEC.MD`) that serves as the "source of truth."

1. **Open ChatGPT** (or a similar LLM).
2. **Paste the following prompt:**
   This prompt clearly defines the scope, features, and tech stack (Next.js, Bun, SQLite, etc.) to ensure the AI understands exactly what to build.

   ```text
   I'm building a "Note Taking" web app.

   In the app, users will be able to create and manage notes. A "note" is simply a piece of text, created via a rich text editor (TipTap).

   In detail, authenticated users will be able to:
   - create, view, update and delete notes
   - share notes publicly (and also stop sharing)

   I'll build the app using Next.js with Bun & TypeScript. For styling, we'll use TailwindCSS.

   Authentication will be implemented using the better-auth library.
   The rich text editor will be implemented using the TipTap library.

   I'll provide basic rich text formatting:
   - Bold, Italic
   - Heading levels + Normal text
   - Inline Code + Code Snippets
   - Bullet point lists
   - Horizontal separator lines

   The data will be stored as JSON in a SQLite database. I'll use Bun's built-in SQLite client with raw SQL statements.

   Do you need more information to create a technical specification document which I can use as a foundation to build this application?
   ```

3. **Create the file:** Inside your project root, create a file named `SPEC.MD`.
4. **Paste the content:** Copy the output from ChatGPT into this file.

   > **Example SPEC.MD:** See the complete example specification: [[spec|SPEC.MD Example]]

   The example spec covers the following sections:
   - Overview & Core Features
   - Architecture (High-Level & Application Layers)
   - Functional Requirements (Auth, Notes CRUD, Sharing)
   - Non-Functional Requirements
   - Data Model & Database Schema (SQLite)
   - Backend: DB & API Layer
   - API Design (Next.js Route Handlers)
   - Frontend – Pages & Components
   - TipTap Integration
   - Styling, Security & Development Workflow

   Below is a short preview of the spec structure:

   ```markdown
   # Technical Specification – Note Taking Web App

   ## 1. Overview

   A web application where authenticated users can create, view, edit, delete, and publicly share rich-text notes. Notes are created with TipTap, stored as JSON in a SQLite database, and rendered in the browser with formatting.

   ## 2. Architecture ...
   ## 3. Functional Requirements ...
   ## 4. Non-Functional Requirements ...
   ## 5. Data Model & Database Schema ...
   ## 6. Backend: DB & API Layer ...
   ## 7. API Design ...
   ## 8. Frontend – Pages & Components ...
   ## 9. TipTap Integration ...
   ## 10. Styling ...
   ## 11. Security Considerations ...
   ## 12. Development Workflow ...
   ```

---

## Step 2: Prepare External Context (Documentation)

For specific libraries like **Better-Auth**, the AI might guess a generic database schema. To prevent errors, you should provide the *actual* documentation to Claude Code.

1. Navigate to the documentation of the library you are using (e.g., the Better-Auth "Database Adapters" page).
2. Copy the relevant section (specifically the Schema definitions) as Markdown or plain text.
3. Keep this text ready on your clipboard for the next step.

---

## Step 3: Prompt Engineering with Claude Code

Now, we will use Claude Code to polish our specification file. We will use **Context Engineering** to link our file and provide external knowledge.

1. Open your terminal in the project directory.
2. Run `claude`.
3. **Construct the Prompt:** You will combine instructions, file referencing, and external context.

### The Components of a Good Prompt:
- **The File Reference (`@`):** Use the `@` symbol to explicitly tell Claude to read a specific file.
- **The Instruction:** Tell Claude to format the file and correct specific logic errors.
- **The Context:** Paste the documentation you copied in Step 2. Use **XML tags** (e.g., `<docs>`) to help the AI distinguish between your instructions and the reference material.

### Execute this Command:
Type the following into the Claude Code prompt:

```text
We're building an app described in @SPEC.MD

Please format this file as proper markdown.

Also update the file and update the part about the 'users' table and auth-related tables.
We're using the better-auth library which expects a certain database structure.

Here's the official better-auth database documentation article:

<better-auth-database-docs>
[PASTE THE DOCUMENTATION CONTENT HERE]
</better-auth-database-docs>
```

> **Pro Tip:** Do not include every file in your project context. Only include files relevant to the specific task to avoid "polluting" the context with irrelevant information.

---

## Step 4: Automating the Edits

Claude Code has a mode that allows it to apply changes directly to your files without manual copy-pasting.

1. Before hitting `Enter`, press **Shift+Tab**.
2. Verify that the interface changes to **">> accept edits on"**.
3. Press **Enter**.

Claude will now:
1. Read `SPEC.MD`.
2. Read the pasted documentation.
3. Rewrite `SPEC.MD` with clean Markdown formatting.
4. Replace the generic User table schema with the specific schema required by Better-Auth.

---

## Step 5: Final Review

Once Claude finishes:

1. Open `SPEC.MD` in your editor.
2. Verify the formatting is clean (headers, lists, code blocks).
3. Check the "Database Schema" section. It should now reflect the specific fields required by your library (e.g., `user`, `session`, `account` tables) rather than a generic structure.

You now have a robust technical specification. You can proceed to ask Claude Code to start scaffolding the application, referencing `@SPEC.MD` in future prompts to maintain consistency.

---

# Part 2: Project Initialization & The `/init` Command

This section covers how to set up your project dependencies manually and use the Claude Code `/init` command to create a project guide for the AI.

---

## Step 6: Install Dependencies Manually

The speaker recommends installing critical packages manually rather than asking the AI to do it. This ensures you get the latest versions and avoid AI "hallucinations" regarding version numbers.

**1. Install Core & Validation Packages**

```bash
bun add better-auth zod
```

**2. Install TipTap (Rich Text Editor)**

Copy the official installation command from the TipTap documentation to ensure you get the correct extension packages:

```bash
bun add @tiptap/react @tiptap/pm @tiptap/starter-kit
```

**3. Install Development Types**

To prevent TypeScript errors related to the Bun runtime:

```bash
bun add -d @types/bun
```

---

## Step 7: Start a Fresh Claude Session

Once dependencies are installed, open Claude Code. If you have an active session, it is best to restart it to clear old context.

1. Run `claude` in your terminal.
2. (Optional) If already running, type `/clear` to reset the context.

---

## Step 8: Run the Initialization Command

This is the most critical step for a new or existing project. The `/init` command forces Claude to explore your file structure and understand your project context.

**Execute the command:**
```text
/init
```

**What happens next?**
1. **Analysis:** Claude will scan your codebase, including the `package.json` (to see the dependencies you just installed) and the `SPEC.MD` file created in the previous tutorial.
2. **Permissions:** It may ask for permission to read specific files or folders (e.g., `ls -R`). Type `y` or hit Enter to approve.
3. **Generation:** Claude will generate a file named **`CLAUDE.md`**.

---

## Step 9: Verify the `CLAUDE.md` File

The result of the `/init` command is the creation of `CLAUDE.md` in your project root.

- **What is it?** This file acts as a permanent "memory" for the AI about your project.
- **What it contains:** It includes details about your tech stack (Next.js, Bun, etc.), build commands, architectural patterns, and the dependencies found during the analysis.

You are now ready to start coding, as Claude fully understands the context of your application.

---

# Part 3: Linking SPEC.MD in CLAUDE.md

In this part, we configure `CLAUDE.md` to reference the spec and define response behavior — ensuring Claude works efficiently across every session.

---

## Step 10: Understand the File's Purpose

`CLAUDE.md` is the project's "long-term memory" — it is automatically loaded into every new Claude session. To tell Claude that `SPEC.MD` exists and serves as the source of truth, we need to explicitly link it.

---

## Step 11: Add the Spec Link and Behavior Rules

At the top of your `CLAUDE.md` file, add the following:

```markdown
We're building the app described in @SPEC.MD. Read that file for general architectural tasks or to double-check the exact database structure, tech stack or application architecture.

Keep your replies extremely concise and focus on conveying the key information. No unnecessary fluff, no long code snippets.
```

---

## Step 12: Understand Why This Format Works

The instruction has **two parts** that work together:

**1. Link to spec + condition for when to read it:**
```
@SPEC.MD ... Read that file for general architectural tasks or to double-check the exact database structure, tech stack or application architecture.
```
Without the condition, Claude would re-read the entire `SPEC.MD` for every small task (e.g. changing a button color) — wasting tokens and polluting the context with irrelevant information.

**2. Conciseness rule:**
```
Keep your replies extremely concise and focus on conveying the key information. No unnecessary fluff, no long code snippets.
```
AI models tend to be verbose by default. This rule ensures you get code and information, not essays.

---

# Part 4: Scaffolding a Next.js App

In this part, we move from configuration to implementation. We will use Claude Code to generate the file structure for our application based on our `SPEC.MD` file, using a safety-first approach called "Plan Mode."

**Prerequisites:**
- Your `SPEC.MD` file is ready.
- Your `CLAUDE.md` guide is configured.
- Dependencies are installed.

---

## Step 13: Clear the Context

Before starting a major coding task, it is best practice to clear the AI's "short-term memory" to ensure it isn't distracted by previous conversations or setup steps.

```bash
/clear
```

---

## Step 14: Construct the Scaffolding Prompt

We want to create the file structure without getting bogged down in complex logic immediately. We will ask Claude to create "dummy" pages first.

**The Prompt:**
```text
Let's start building the application described in @SPEC.MD .
Start by setting up the core route structure. Only add a dummy message to each page. No actual page content yet.
Just create all these different page.tsx files for the different application routes. Don't implement authentication yet.
```

**Do NOT hit Enter yet!** Move to Step 15.

---

## Step 15: Engage "Plan Mode" (Crucial Step)

Instead of letting the AI start writing code immediately, use **Plan Mode**. This forces Claude to analyze the project and propose a strategy before touching your files.

1. Press **Shift+Tab** in the terminal.
2. You should see the indicator change to `>> plan mode on`.
3. **Now** hit **Enter**.

### Why use Plan Mode?
- **Analysis:** It reads your file structure first.
- **Clarification:** It can ask questions if your prompt is vague.
- **Safety:** It prevents the AI from making sweeping changes without your approval.

---

## Step 16: Review and Refine the Plan

Claude will present a detailed plan of the routes it intends to create. **Review this carefully.**

In the video example, the user noticed Claude planned to create separate pages for login and register, but the user wanted a single authentication page.

**To correct the plan, type your feedback:**
```text
I only want a single '/authenticate' route which supports only email + password auth.
```

Claude will then update the plan based on this feedback.

---

## Step 17: Execute the Plan

Once the plan looks correct, Claude will present you with options to proceed.

1. Select **Option 1**: `Yes, clear context and auto-accept edits`.
   - *Note: This clears previous chat history to save tokens but keeps the current plan in memory.*
2. Claude will now create the files, run the linter, and run the build command to ensure no errors were introduced.

---

## Step 18: Verification

Once Claude finishes, verify the work manually.

1. Start your development server:
   ```bash
   bun run dev
   ```
2. Open your browser (e.g., `http://localhost:3000`).
3. Manually navigate to the routes created (e.g., `/dashboard`, `/authenticate`, `/notes/1`).
4. Confirm that the "dummy content" acts as a placeholder for every route you requested.

---

# Part 5: Authentication & Database Implementation

In this part, we task Claude Code with complex implementation details — specifically Authentication and Database setup — while managing external documentation requirements.

---

## Step 19: Start a Fresh Session

When beginning a major architectural task, clear the AI's "short-term memory" to prevent confusion from previous implementation details.

```bash
/clear
```

---

## Step 20: Formulate the Implementation Prompt

We need to tell Claude to implement the database logic and authentication. We will rely on our `SPEC.MD` file but should be explicit.

**Draft your prompt (do not send yet):**
```text
Implement authentication and database access.

Add a "lib" folder with "auth.ts" and "db.ts" files. Export a db handle in the db.ts file and make sure WAL mode is used and all required database tables are created if they don't exist yet.

Implement authentication and database access as described in @SPEC.MD
```

> **Note:** Even though `CLAUDE.md` automatically loads the context, explicitly adding "as described in @SPEC.MD" ensures the AI prioritizes your specification.

---

## Step 21: Identify the "Knowledge Gap"

This is the most critical step. As a developer, you know that:
1. **Better-Auth** has very specific setup requirements.
2. **Bun SQLite** has a specific syntax for connecting to the database.

If you only send the prompt above, Claude might "hallucinate" generic code or use outdated syntax. You need to provide it with the **official documentation**.

---

## Step 22: Choose a Strategy for External Context

There are three ways to provide missing technical context to Claude:

### Strategy A: Manual Context Injection (High Accuracy)
Copy the documentation text directly into your prompt.

**Append this to your prompt:**
```text
Here's the official guide on using Bun SQLite:
[PASTE COPIED DOCUMENTATION HERE]
```

### Strategy B: Web Search (Automated)
Instruct Claude to find the documentation itself.

**Append this to your prompt:**
```text
Use web search to find the relevant documentation for Bun SQLite and better-auth setup (with next.js and Bun SQLite).
```
*OR*
```text
Visit the official docs websites:
- https://bun.sh/docs/runtime/sqlite
- [Insert Link to Better-Auth Docs]
```

### Strategy C: MCP Servers (Advanced)
Use **Model Context Protocol (MCP)** servers to give Claude direct, structured access to external tools and documentation. *(Covered in Part 6.)*

---

## Step 23: Execute the Task

Once you have selected your strategy:

1. Paste the full prompt into the terminal.
2. Press **Shift+Tab** to ensure you are in **Plan Mode** (recommended for complex tasks).
3. Hit **Enter**.

Claude will read your `SPEC.MD`, search for the specific library documentation, and generate a plan to implement your `lib/db.ts` and `lib/auth.ts` files correctly.

---

# Part 6: Supercharging Claude Code with MCP Servers

MCP (Model Context Protocol) servers give Claude direct, structured access to external tools and documentation — more reliable than web search or manual copy-paste.

---

## Step 24: Install the Context7 MCP Server

**Context7** is a specialized MCP server designed to pull accurate documentation for libraries and frameworks.

1. **Install globally (works across all projects):**
   ```bash
   claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp
   ```
   - To use with an API key for higher limits:
     ```bash
     claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY
     ```

2. **Verify Installation:**
   Open Claude Code and type `/mcp`. You should see `context7` listed as an active tool.

---

## Step 25: Use MCP in a Prompt

1. **Clear Context:**
   ```bash
   /clear
   ```

2. **Construct the Prompt:**
   ```text
   Implement authentication and database access as described in @SPEC.MD

   Add a "lib" folder with "auth.ts" and "db.ts" files. Export a db handle in the db.ts file and make sure WAL mode is used and all required database tables are created if they don't exist yet.

   Use web search or the context7 mcp to find the relevant documentation for Bun SQLite and better-auth setup (with next.js and Bun SQLite).
   ```

3. **Execute in Plan Mode:**
   - Press **Shift+Tab** → `>> plan mode on`.
   - Hit **Enter**.

---

## Step 26: Approve Tool Usage

When Claude Code attempts to use Context7 for the first time, it will pause and ask for permission.

1. **Review the Request:** Claude will show it wants to use `context7` to query documentation.
2. **Grant Permission:** Type `y` (or select "Yes, and don't ask again for this tool").

---

## Step 27: Review the Plan

Claude will:
1. Use Context7 to fetch exact documentation for `better-auth` and `bun-sqlite`.
2. Read your `SPEC.MD`.
3. Generate a detailed implementation plan with correct API methods from the documentation.

---

## Step 28: Execute and Verify

1. **Accept the Plan:** Select "Clear context and auto-accept edits."
2. **Handle Verification:**
   - Claude might ask to run `bun run dev` to verify the setup.
   - If you prefer to verify manually: decline and add — *"I'll run the dev server myself, just check for typescript, linting and build errors."*

Claude will implement the files, run the build to check for errors, and complete the task.

---

# Part 7: Codebase Evaluation with Sub-Agents

In this part, we use Claude Code to perform a quality assurance check on our implementation. We ask it to verify that our authentication and database setup matches both our `SPEC.MD` and the official documentation for `better-auth` and `bun-sqlite`.

This part focuses on the power of **Sub-Agents** — a feature where Claude Code delegates specific tasks (like searching docs or exploring files) to specialized agents that run in parallel without polluting the main context.

**Prerequisites:**
- You have implemented the core features (Auth & DB).
- You have installed the `Context7` MCP server (or are ready to use Web Search).
- Your `SPEC.MD` file is up to date.

---

## Step 29: Formulate the Evaluation Prompt

Instead of asking Claude to write code, we are asking it to act as a senior code reviewer.

**Draft the prompt:**
```text
We're building @SPEC.MD .

Please evaluate the existing codebase to check whether authentication and database access are implemented correctly (in line with the expectations explained in SPEC.MD and the official documentation for the libraries / technologies used).

Use web search or the context7 mcp to look up docs.
```

**Key Elements of this Prompt:**
1. **Context Link (`@SPEC.MD`):** Tells Claude what the "source of truth" for requirements is.
2. **Explicit Goal:** "Evaluate... correctly."
3. **Tool Instruction:** "Use web search or the context7 mcp." This explicitly empowers the agent to go outside its training data to find the latest docs.

---

## Step 30: Execute the Evaluation

1. Clear your context to start fresh: `/clear`.
2. Paste the prompt into the terminal.
3. **Do not use Plan Mode.** Just hit **Enter**.
   - *Why?* We want an immediate analysis and report, not a plan to modify files.

---

## Step 31: Observe Sub-Agents in Action

Once you hit enter, watch the terminal output closely. You will see Claude Code spin up **Sub-Agents** to handle different parts of the job simultaneously.

- **The Main Agent:** Coordinates the overall task.
- **The Explorer Agent:** You will see a block labeled `Explore(Explore auth and db implementation)`. This sub-agent is reading your file system (`lib/auth.ts`, `lib/db.ts`) to understand the current code.
- **The MCP/Search Agent:** You will see blocks labeled `context7` or `web search`. This sub-agent is fetching external documentation for `better-auth` and `bun-sqlite`.

**Why this matters:**
- **Parallelism:** These tasks happen at the same time, speeding up the process.
- **Context Hygiene:** The massive amount of text from the documentation pages and file reads stays within the sub-agent's memory. Only the *relevant summary* is passed back to the main agent, keeping your main context clean and saving tokens.

---

## Step 32: Review the Evaluation Report

Claude will output a detailed report comparing your code against the docs and spec.

**What to look for:**
1. **Green Checks:** Confirming that your `WAL mode` configuration for SQLite matches the official Bun recommendation found by the sub-agent.
2. **Verification:** Confirming that the `better-auth` client setup follows the library's specific "Next.js App Router" instructions.
3. **Missing Components:** It will likely identify parts of the spec you haven't built yet (e.g., "Missing note repository functions"). This is expected and helpful for planning your next steps.

By using this workflow, you turn Claude Code into an autonomous QA engineer. It validates your code against real-time documentation without you having to manually look up a single page, thanks to the efficiency of Sub-Agents and MCP tools.

---

# Part 8: Creating a Custom Documentation Sub-Agent

In this part, we build a custom **Sub-Agent** named `DocsExplorer`.

By default, Claude Code uses its main "Opus" agent for everything. This is powerful but expensive and slow for reading documentation. We will create a specialized agent that uses **Claude Sonnet** (faster/cheaper) to handle documentation research in parallel, keeping your main context window clean.

**Prerequisites:**
- **Claude Code** initialized in your project.
- (Recommended) **Context7 MCP Server** installed (as described in Part 6), though this agent can fallback to standard web search.

---

## Step 33: Create the Agents Directory

Claude Code detects custom agents based on a specific folder structure within your project (or globally).

1. Open your project root.
2. Navigate to the hidden `.claude` folder.
3. Create a new subfolder named `agents`.

**File Path:**
```text
[project-root]/.claude/agents/
```

> **Pro Tip (Global Agents):** If you want this agent available in *all* your projects, you can instead create this folder in your user's home directory: `~/.claude/agents/`.

---

## Step 34: Define the Agent Configuration

Create a new Markdown file inside the `agents` folder. The filename must match the name you want to use to call the agent.

1. Create a file named **`DocsExplorer.md`**.
2. Paste the following content exactly. This uses the `sonnet` model for efficiency and defines a strict lookup strategy prioritizing MCP tools over generic web scraping.

```markdown
---
name: DocsExplorer
description: Documentation lookup specialist. Use proactively when needing docs for any library, framework, or technology. Fetches docs in parallel for multiple technologies.
tools: WebFetch, WebSearch, Skill, MCPSearch
model: sonnet
---

You are a documentation specialist that fetches up-to-date docs for libraries, frameworks, and technologies. Your goal is to provide accurate, relevant documentation quickly.

## Workflow

When given one or more technologies/libraries to look up:

1. **Execute ALL lookups in parallel** - batch your tool calls for maximum speed
2. **Use Context7 MCP as primary source** - it has high-quality, LLM-optimized docs
3. **Fall back to web search** when Context7 lacks coverage
4. **Prefer machine-readable formats** - llms.txt and .md files over HTML pages

## Lookup Strategy

### Step 1: Context7 MCP (Primary)

For each library, call these in sequence:

1. `mcp_Context7_resolve-library-id` with the library name to get the Context7 ID
2. `mcp_Context7_query-docs` with the resolved ID and specific query

Run Step 1 for ALL libraries in parallel.

### Step 2: Web Fallback (If Context7 fails or lacks info)

If Context7 doesn't have the library or lacks specific info:

1. **Search for LLM-friendly docs first:**
   - Search: `{library} llms.txt site:{official-docs-domain}`
   - Search: `{library} documentation llms.txt`

2. **Try known llms.txt paths:**
   - Navigate to `{docs-base-url}/llms.txt`
   - Navigate to `{docs-base-url}/docs/llms.txt`
   - Navigate to `{docs-base-url}/llms-full.txt`

3. **Try .md documentation paths:**
   - Search: `{library} {topic} filetype:md site:github.com`
   - Navigate to `{docs-base-url}/docs/{topic}.md`
   - Navigate to `{docs-base-url}/{topic}.md`

4. **Final fallback - fetch normal page:**
   - If no llms.txt or .md found, navigate to the official docs page
   - Use browser_snapshot to extract content

## Parallel Execution Rules

- When looking up multiple libraries, start ALL Context7 resolve-library-id calls simultaneously
- After resolving IDs, batch all query-docs calls together
- For web fallback, batch navigate calls for different libraries
- Never wait for one library lookup to complete before starting another

## Output Format

For each library/technology, provide:

## {Library Name}

**Source:** {Context7 | URL}

### Key Information
{Relevant docs content, API references, examples}

### Code Examples
{Practical code snippets from the docs}
```

---

## Step 35: Use the Sub-Agent

Now that the agent is defined, you can instruct Claude Code to use it for specific tasks.

1. **Clear your session** to ensure a fresh start:
   ```bash
   /clear
   ```

2. **Prompt the AI.** You can now ask it to evaluate code or implement features, specifically instructing it to use your new agent for the research phase.

   **Example Prompt:**
   ```text
   We're building @SPEC.MD.

   Please evaluate the existing codebase to check whether authentication and database access are implemented correctly.

   Use the DocsExplorer agent to look up relevant documentation.
   ```

---

## Step 36: Verify Execution

When you hit **Enter**, watch the terminal output carefully.

1. **Delegation:** Instead of seeing "Web Search" immediately on the main thread, you will see a task block labeled **`DocsExplorer(...)`**.
2. **Parallelism:** If you asked it to look up multiple libraries (e.g., SQLite and Better-Auth), you will see the `DocsExplorer` triggering multiple tool calls at once, rather than one by one.
3. **Results:** Once finished, the sub-agent will collapse its work and pass a clean summary back to the main agent, allowing the main agent to proceed with the evaluation using the fresh data.

---

# Part 9: Using DocsExplorer for Codebase Validation

In this part, we use our newly created `DocsExplorer` agent to validate our codebase. You will learn how to prompt the main agent to delegate tasks, understand the parallel execution of sub-agents, and apply the insights gained from the documentation lookup.

**Prerequisites:**
- The `.claude/agents/DocsExplorer.md` file is created and configured.
- Your `CLAUDE.md` file is updated with instructions to use the sub-agent.
- (Optional but recommended) The Context7 MCP server is installed.

---

## Step 37: Execute the Evaluation Prompt

Now that our infrastructure is set up, we can run the evaluation task. This time, instead of the main agent doing the heavy lifting, it will delegate the research to `DocsExplorer`.

**Run the command:**
```text
We're building @SPEC.MD.

Please evaluate the existing codebase to check whether authentication and database access are implemented correctly.

Use the DocsExplorer agent to look up relevant documentation.
```

---

## Step 38: Observe Sub-Agent Delegation

Watch the terminal output closely.

1. **Parallel Execution:** You will see multiple blocks appearing simultaneously.
   - **Main Agent:** `Explore(Explore auth and db implementation)` - Reading your local files.
   - **DocsExplorer (Instance 1):** `DocsExplorer(Lookup better-auth docs)` - Fetching auth docs.
   - **DocsExplorer (Instance 2):** `DocsExplorer(Lookup Bun SQLite docs)` - Fetching database docs.

2. **Resource Efficiency:**
   - The `DocsExplorer` instances run on the **Sonnet** model (cheaper/faster).
   - The Main agent runs on **Opus** (smarter) but only processes the *summaries* returned by the sub-agents, keeping your main context window clean.

---

## Step 39: Review the Evaluation Report

Once all agents finish, Claude will present a consolidated report.

- **Look for Validation:** It will confirm if your setup (e.g., SQLite WAL mode, `better-auth` client) matches the official docs found by the sub-agent.
- **Identify Issues:** In the video example, the report correctly identifies a missing configuration: the `nextCookies` plugin for `better-auth`.

---

## Step 40: Apply Fixes

You have two options to fix the identified issue:

### Option A: Manual Fix (Faster/Cheaper)

Since the report is specific, you can make the change yourself.
1. Open `lib/auth.ts`.
2. Import `nextCookies` from `better-auth/next-js`.
3. Add it to the `plugins` array in your auth config.

### Option B: AI Fix (Automated)

You can instruct Claude to fix it for you.
1. **Prompt:** `Go ahead and fix that nextCookies() issue. Don't do anything else.`
2. **Execute:** Claude will apply the edit based on the documentation it just retrieved.

By using a custom **Sub-Agent**, you:
1. **Saved Tokens:** By offloading documentation reading to a separate context.
2. **Saved Time:** By running code exploration and documentation research in parallel.
3. **Improved Accuracy:** By ensuring every implementation detail is checked against the latest official documentation.
