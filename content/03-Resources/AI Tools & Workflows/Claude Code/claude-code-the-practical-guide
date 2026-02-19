Here is the updated tutorial with the provided `SPEC.MD` content integrated into **Step 1**.

---
In this guide, we will set up the foundation for a note-taking application using **Claude Code**. Instead of jumping straight into coding, we will focus on creating a "source of truth" specification document (`SPEC.MD`). This ensures the AI understands the full scope of the architecture, database schema, and feature set before writing a single line of code.

## Prerequisites
*   **Claude Code** installed and authenticated in your terminal.
*   A basic project folder created.
*   **Tech Stack defined:** Next.js, Bun, TypeScript, TailwindCSS, SQLite, Better-Auth (Authentication), and TipTap (Rich Text Editor).

---

## Step 1: Generate the Initial Specification
Before engaging Claude Code to write software, you need a blueprint. We will use ChatGPT to generate a technical specification document (`SPEC.MD`) that serves as the "source of truth."

1.  **Open ChatGPT** (or a similar LLM).
2.  **Paste the following prompt:**
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

3.  **Create the file:** Inside your project root, create a file named `SPEC.MD`.
4.  **Paste the content:** Copy the output from ChatGPT into this file.

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

1.  Navigate to the documentation of the library you are using (e.g., the Better-Auth "Database Adapters" page).
2.  Copy the relevant section (specifically the Schema definitions) as Markdown or plain text.
3.  Keep this text ready on your clipboard for the next step.

---

## Step 3: Prompt Engineering with Claude Code
Now, we will use Claude Code to polish our specification file. We will use **Context Engineering** to link our file and provide external knowledge.

1.  Open your terminal in the project directory.
2.  Run `claude`.
3.  **Construct the Prompt:** You will combine instructions, file referencing, and external context.

### The Components of a Good Prompt:
*   **The File Reference (`@`):** Use the `@` symbol to explicitly tell Claude to read a specific file.
*   **The Instruction:** Tell Claude to format the file and correct specific logic errors.
*   **The Context:** Paste the documentation you copied in Step 2. Use **XML tags** (e.g., `<docs>`) to help the AI distinguish between your instructions and the reference material.

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

1.  Before hitting `Enter`, press **Shift+Tab**.
2.  Verify that the interface changes to **">> accept edits on"**.
3.  Press **Enter**.

Claude will now:
1.  Read `SPEC.MD`.
2.  Read the pasted documentation.
3.  Rewrite `SPEC.MD` with clean Markdown formatting.
4.  Replace the generic User table schema with the specific schema required by Better-Auth.

---

## Step 5: Final Review
Once Claude finishes:

1.  Open `SPEC.MD` in your editor.
2.  Verify the formatting is clean (headers, lists, code blocks).
3.  Check the "Database Schema" section. It should now reflect the specific fields required by your library (e.g., `user`, `session`, `account` tables) rather than a generic structure.

You now have a robust technical specification. You can proceed to ask Claude Code to start scaffolding the application, referencing `@SPEC.MD` in future prompts to maintain consistency.

---

# Part 2: Project Initialization & The `/init` Command

This section covers how to set up your project dependencies manually and use the Claude Code `/init` command to create a project guide for the AI.

## Step 6: Install Dependencies Manually
The speaker recommends installing critical packages manually rather than asking the AI to do it. This ensures you get the latest versions and avoid AI "hallucinations" regarding version numbers.

**1. Install Core & Validation Packages**
Run the following in your terminal (using Bun as the package manager):
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

1.  Run `claude` in your terminal.
2.  (Optional) If already running, type `/clear` to reset the context.

---

## Step 8: Run the Initialization Command
This is the most critical step for a new or existing project. The `/init` command forces Claude to explore your file structure and understand your project context.

**Execute the command:**
```text
/init
```

**What happens next?**
1.  **Analysis:** Claude will scan your codebase, including the `package.json` (to see the dependencies you just installed) and the `SPEC.MD` file created in the previous tutorial.
2.  **Permissions:** It may ask for permission to read specific files or folders (e.g., `ls -R`). Type `y` or hit Enter to approve.
3.  **Generation:** Claude will generate a file named **`CLAUDE.md`**.

## Step 9: Verify the `CLAUDE.md` File
The result of the `/init` command is the creation of `CLAUDE.md` in your project root.

*   **What is it?** This file acts as a permanent "memory" for the AI about your project.
*   **What it contains:** It includes details about your tech stack (Next.js, Bun, etc.), build commands, architectural patterns, and the dependencies found during the analysis.

You are now ready to start coding, as Claude fully understands the context of your application.

---

# Part 3: Linking SPEC.MD in CLAUDE.md

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