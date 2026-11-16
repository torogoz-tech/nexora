# Declarative analysis profiles

An analysis profile is the language-specific knowledge that the common Nexora engine applies to source files. Profiles are maintained independently so that support for one language can evolve without forcing a release of every other profile.

## The four-file contract

| File | Human responsibility |
| --- | --- |
| `language.yaml` | Names the language, version, extensions, and high-level behavior. |
| `lexer.yaml` | Defines tokens, keywords, trivia, regions, transitions, and lexical limits. |
| `grammar.yaml` | Describes patterns, productions, captures, expressions, and recovery. |
| `graph.yaml` | Maps recognized structures to canonical nodes, edges, and evidence. |

The repository also contains fixtures and verification documentation. JSON Schemas and domain validation reject invalid references, captures, progress conditions, resource limits, and incompatible capability combinations.

## What a profile means

“Supported” means supported for the documented constructs and verified fixtures. It does not mean that the entire language standard is implemented. A profile can explicitly report partial support, rejected syntax, incomplete resolution, or not-assessed semantics.

## Why profiles are separate repositories

Each profile has its own maintainers, fixtures, benchmark evidence, compatibility decisions, and release history. The common engine provides the mechanism; the profile provides the language knowledge. This boundary also makes it possible to review a profile without accepting unrelated changes in the platform.

## Current profile families

The public layout contains independent repositories for JavaScript, TypeScript, TSX, JSX, HTML, CSS, Lua, C#, C# views, Razor, Razor views, Dart/Flutter, Java, Kotlin, and Swift.

Each profile is versioned `0.1.0` for this publication preparation. Its own README is the authoritative guide to its current scope.
