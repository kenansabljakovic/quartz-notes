Based on the video provided, here is a tutorial on how to use Claude Code to **evaluate** and verify your codebase against documentation and specifications, leveraging both web search and the previously installed MCP tools.

This tutorial focuses on the power of **Sub-Agents**, a feature where Claude Code delegates specific tasks (like searching docs or exploring files) to specialized agents that run in parallel without polluting the main context.

---

# Tutorial: Codebase Evaluation with Claude Code & Sub-Agents

In this guide, we will use Claude Code to perform a quality assurance check on our implementation. We will ask it to verify that our authentication and database setup matches both our `SPEC.MD` and the official documentation for `better-auth` and `bun-sqlite`.

## Prerequisites
*   You have implemented the core features (Auth & DB).
*   You have installed the `Context7` MCP server (or are ready to use Web Search).
*   Your `SPEC.MD` file is up to date.

---

## Step 1: Formulate the Evaluation Prompt
Instead of asking Claude to write code, we are asking it to act as a senior code reviewer.

**Draft the prompt:**
```text
We're building @SPEC.MD .

Please evaluate the existing codebase to check whether authentication and database access are implemented correctly (in line with the expectations explained in SPEC.MD and the official documentation for the libraries / technologies used).

Use web search or the context7 mcp to look up docs.
```

**Key Elements of this Prompt:**
1.  **Context Link (`@SPEC.MD`):** Tells Claude what the "source of truth" for requirements is.
2.  **Explicit Goal:** "Evaluate... correctly."
3.  **Tool Instruction:** "Use web search or the context7 mcp." This explicitly empowers the agent to go outside its training data to find the latest docs.

## Step 2: Execute the Evaluation
1.  Clear your context to start fresh: `/clear`.
2.  Paste the prompt into the terminal.
3.  **Do not use Plan Mode.** Just hit **Enter**.
    *   *Why?* We want an immediate analysis and report, not a plan to modify files.

## Step 3: Observe Sub-Agents in Action
Once you hit enter, watch the terminal output closely. You will see Claude Code spin up **Sub-Agents** to handle different parts of the job simultaneously.

*   **The Main Agent:** Coordinates the overall task.
*   **The Explorer Agent:** You will see a block labeled `Explore(Explore auth and db implementation)`. This sub-agent is reading your file system (`lib/auth.ts`, `lib/db.ts`) to understand the current code.
*   **The MCP/Search Agent:** You will see blocks labeled `context7` or `web search`. This sub-agent is fetching external documentation for `better-auth` and `bun-sqlite`.

**Why this matters:**
*   **Parallelism:** These tasks happen at the same time, speeding up the process.
*   **Context Hygiene:** The massive amount of text from the documentation pages and file reads stays within the sub-agent's memory. Only the *relevant summary* is passed back to the main agent, keeping your main context clean and saving tokens.

## Step 4: Review the Evaluation Report
Claude will output a detailed report comparing your code against the docs and spec.

**What to look for:**
1.  **Green Checks:** Confirming that your `WAL mode` configuration for SQLite matches the official Bun recommendation found by the sub-agent.
2.  **Verification:** Confirming that the `better-auth` client setup follows the library's specific "Next.js App Router" instructions.
3.  **Missing Components:** It will likely identify parts of the spec you haven't built yet (e.g., "Missing note repository functions"). This is expected and helpful for planning your next steps.

## Summary
By using this workflow, you turn Claude Code into an autonomous QA engineer. It validates your code against real-time documentation without you having to manually look up a single page, thanks to the efficiency of Sub-Agents and MCP tools.

Based on the video provided and the specific configuration you supplied, here is the complete tutorial for creating and using the custom **DocsExplorer** sub-agent.

---

# Tutorial: Creating a Custom Documentation Sub-Agent in Claude Code

In this guide, we will build a custom **Sub-Agent** named `DocsExplorer`.

By default, Claude Code uses its main "Opus" agent for everything. This is powerful but expensive and slow for reading documentation. We will create a specialized agent that uses **Claude Sonnet** (faster/cheaper) to handle documentation research in parallel, keeping your main context window clean.

## Prerequisites
*   **Claude Code** initialized in your project.
*   (Recommended) **Context7 MCP Server** installed (as described in the previous tutorial), though this agent can fallback to standard web search.

---

## Step 1: Create the Agents Directory
Claude Code detects custom agents based on a specific folder structure within your project (or globally).

1.  Open your project root.
2.  Navigate to the hidden `.claude` folder.
3.  Create a new subfolder named `agents`.

**File Path:**
```text
[project-root]/.claude/agents/
```

> **Pro Tip (Global Agents):** If you want this agent available in *all* your projects, you can instead create this folder in your user's home directory: `~/.claude/agents/`.

---

## Step 2: Define the Agent Configuration
Create a new Markdown file inside the `agents` folder. The filename must match the name you want to use to call the agent.

1.  Create a file named **`DocsExplorer.md`**.
2.  Paste the following content exactly. This uses the `sonnet` model for efficiency and defines a strict lookup strategy prioritizing MCP tools over generic web scraping.

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

## Step 3: Use the Sub-Agent
Now that the agent is defined, you can instruct Claude Code to use it for specific tasks.

1.  **Clear your session** to ensure a fresh start:
    ```bash
    /clear
    ```

2.  **Prompt the AI.** You can now ask it to evaluate code or implement features, specifically instructing it to use your new agent for the research phase.

    **Example Prompt:**
    ```text
    We're building @SPEC.MD.

    Please evaluate the existing codebase to check whether authentication and database access are implemented correctly.

    Use the DocsExplorer agent to look up relevant documentation.
    ```

---

## Step 4: Verify Execution
When you hit **Enter**, watch the terminal output carefully.

1.  **Delegation:** instead of seeing "Web Search" immediately on the main thread, you will see a task block labeled **`DocsExplorer(...)`**.
2.  **Parallelism:** If you asked it to look up multiple libraries (e.g., SQLite and Better-Auth), you will see the `DocsExplorer` triggering multiple tool calls at once, rather than one by one.
3.  **Results:** Once finished, the sub-agent will collapse its work and pass a clean summary back to the main agent, allowing the main agent to proceed with the evaluation using the fresh data.

Based on the video provided, here is a tutorial on how to configure and run the custom `DocsExplorer` sub-agent for a more efficient coding workflow.

---

In this guide, we will use our newly created `DocsExplorer` agent to validate our codebase. You will learn how to prompt the main agent to delegate tasks, understand the parallel execution of sub-agents, and apply the insights gained from the documentation lookup.

## Prerequisites
*   The `.claude/agents/DocsExplorer.md` file is created and configured.
*   Your `CLAUDE.md` file is updated with instructions to use the sub-agent.
*   (Optional but recommended) The Context7 MCP server is installed.

---

## Step 1: Execute the Evaluation Prompt
Now that our infrastructure is set up, we can run the evaluation task again. This time, instead of the main agent doing the heavy lifting, it will delegate the research to `DocsExplorer`.

**Run the command:**
```text
We're building @SPEC.MD.

Please evaluate the existing codebase to check whether authentication and database access are implemented correctly.

Use the DocsExplorer agent to look up relevant documentation.
```

## Step 2: Observe Sub-Agent Delegation
Watch the terminal output closely.

1.  **Parallel Execution:** You will see multiple blocks appearing simultaneously.
    *   **Main Agent:** `Explore(Explore auth and db implementation)` - Reading your local files.
    *   **DocsExplorer (Instance 1):** `DocsExplorer(Lookup better-auth docs)` - Fetching auth docs.
    *   **DocsExplorer (Instance 2):** `DocsExplorer(Lookup Bun SQLite docs)` - Fetching database docs.

2.  **Resource Efficiency:**
    *   The `DocsExplorer` instances run on the **Sonnet** model (cheaper/faster).
    *   The Main agent runs on **Opus** (smarter) but only processes the *summaries* returned by the sub-agents, keeping your main context window clean.

## Step 3: Review the Evaluation Report
Once all agents finish, Claude will present a consolidated report.

*   **Look for Validation:** It will confirm if your setup (e.g., SQLite WAL mode, `better-auth` client) matches the official docs found by the sub-agent.
*   **Identify Issues:** In the video example, the report correctly identifies a missing configuration: the `nextCookies` plugin for `better-auth`.

## Step 4: Applying Fixes
You have two options to fix the identified issue:

### Option A: Manual Fix (Faster/Cheaper)
Since the report is specific, you can make the change yourself.
1.  Open `lib/auth.ts`.
2.  Import `nextCookies` from `better-auth/next-js`.
3.  Add it to the `plugins` array in your auth config.

### Option B: AI Fix (Automated)
You can instruct Claude to fix it for you.
1.  **Prompt:** `Go ahead and fix that nextCookies() issue. Don't do anything else.`
2.  **Execute:** Claude will apply the edit based on the documentation it just retrieved.

## Summary
You have successfully implemented a sophisticated AI workflow. By using a custom **Sub-Agent**, you:
1.  **Saved Tokens:** By offloading documentation reading to a separate context.
2.  **Saved Time:** by running code exploration and documentation research in parallel.
3.  **Improved Accuracy:** By ensuring every implementation detail is checked against the latest official documentation.

Based on the video provided, here is a tutorial on how to configure and run the custom `DocsExplorer` sub-agent for a more efficient coding workflow.

---

In this guide, we will use our newly created `DocsExplorer` agent to validate our codebase. You will learn how to prompt the main agent to delegate tasks, understand the parallel execution of sub-agents, and apply the insights gained from the documentation lookup.

## Prerequisites
*   The `.claude/agents/DocsExplorer.md` file is created and configured.
*   Your `CLAUDE.md` file is updated with instructions to use the sub-agent.
*   (Optional but recommended) The Context7 MCP server is installed.

---

## Step 1: Execute the Evaluation Prompt
Now that our infrastructure is set up, we can run the evaluation task again. This time, instead of the main agent doing the heavy lifting, it will delegate the research to `DocsExplorer`.

**Run the command:**
```text
We're building @SPEC.MD.

Please evaluate the existing codebase to check whether authentication and database access are implemented correctly.

Use the DocsExplorer agent to look up relevant documentation.
```

## Step 2: Observe Sub-Agent Delegation
Watch the terminal output closely.

1.  **Parallel Execution:** You will see multiple blocks appearing simultaneously.
    *   **Main Agent:** `Explore(Explore auth and db implementation)` - Reading your local files.
    *   **DocsExplorer (Instance 1):** `DocsExplorer(Lookup better-auth docs)` - Fetching auth docs.
    *   **DocsExplorer (Instance 2):** `DocsExplorer(Lookup Bun SQLite docs)` - Fetching database docs.

2.  **Resource Efficiency:**
    *   The `DocsExplorer` instances run on the **Sonnet** model (cheaper/faster).
    *   The Main agent runs on **Opus** (smarter) but only processes the *summaries* returned by the sub-agents, keeping your main context window clean.

## Step 3: Review the Evaluation Report
Once all agents finish, Claude will present a consolidated report.

*   **Look for Validation:** It will confirm if your setup (e.g., SQLite WAL mode, `better-auth` client) matches the official docs found by the sub-agent.
*   **Identify Issues:** In the video example, the report correctly identifies a missing configuration: the `nextCookies` plugin for `better-auth`.

## Step 4: Applying Fixes
You have two options to fix the identified issue:

### Option A: Manual Fix (Faster/Cheaper)
Since the report is specific, you can make the change yourself.
1.  Open `lib/auth.ts`.
2.  Import `nextCookies` from `better-auth/next-js`.
3.  Add it to the `plugins` array in your auth config.

### Option B: AI Fix (Automated)
You can instruct Claude to fix it for you.
1.  **Prompt:** `Go ahead and fix that nextCookies() issue. Don't do anything else.`
2.  **Execute:** Claude will apply the edit based on the documentation it just retrieved.

## Summary
You have successfully implemented a sophisticated AI workflow. By using a custom **Sub-Agent**, you:
1.  **Saved Tokens:** By offloading documentation reading to a separate context.
2.  **Saved Time:** by running code exploration and documentation research in parallel.
3.  **Improved Accuracy:** By ensuring every implementation detail is checked against the latest official documentation.