# LookML Framework

## Goals
The goal of the LookML framework is to deliver a comprehensible, light-weight, easy-to-learn framework on how you can organize your LookML in Looker (Enterprise).

The framework focuses on the following items:
- Separation between database logic, organization logic, joins and access permissions
- Reduce the chance on duplicate LookML
- Flexible enough to apply this to different development models

# Folders
1. [`0_library`](#0_library) | **The Support System**: Centralize your TopoJSON, localization strings, and assets. A logical home for everything that isn't code.
1. [`1_sources`](#1_sources-and-2_views) | **The Raw Truth**: Untouched database table views. This is your foundation—keep it clean, generated straight from the source.
1. [`2_views`](#1_sources-and-2_views) | **The Refinement Layer**: This is where the magic happens. Use refinements to transform raw data into business metrics without cluttering your source files.
1. [`3_explores`](#3_explores) | **The Relationship Map**: Join your views here. By enforcing one explore per file, we eliminate the "massive model file" headache and keep your UI snappy.
1. [`4_models`](#4_models) | **The Final Assembly**: The bridge between your logic and your database connection. This layer handles the final extensions and permissions.
1. [`5_tests`](#5_tests) | **The Safety Net**: Integrated CI/CD tests that ensure a simple commit doesn’t break your entire reporting suite.
1. `manifest.lkml` | **The Configuration**: Your project’s control center for constants and remote dependencies.
1. `README.md` | **The Navigator**: Documentation that actually helps. Focus on the "why" so your team stays aligned from day one.
1. **LICENSE** | The Freedom: We use the MIT License—it's yours to adapt, evolve, and scale.

# Folder structures
## `0_library`
Looker supports many extra files for e.g. localization or TopoJSON files. Organize and structure your folders in a logical way

## `1_sources` and `2_views`
Depending on your way of working this setup can be different.

In most cases the folder structure below is sufficient:

`<database type> / <database name or project id> / <schema name or dataset> / <view name>.view.lkml`

You should test the folder structure structure on how likely it is that you will have a chance on duplicates of LookML views. If, for example, you work with Developent/Test/Acceptance/Production databases, where the database name (or project id) is a different one per environment, but the schema and view names are exactly the same on all different environments (production/acceptance/testing/development) you can leave it out. You folder structure would then look like:

`<database type> / <schema name or dataset> / <view name>.view.lkml`

## `3_explores`

In these files, you'll create all the joins between the views from `2_views`. Since choosing the base table is essential in Looker, you are encouraged to group them in a single folder with a descriptive name.

`<logical name of business unit> / <logical name of collection of explores> / <base table name>.explore.lkml`

## `4_models`

In these files, you'll connect the explores from `3_explores` with a connection. Make sure to organize them in a logical way.

`<logical name of business unit> / <explore collection name>.model.lkml`

## `5_tests`

In these files, you'll add all the CI/CD tests for Looker.

`<logical test folder name> / <test collection name>.test.lkml`

# Versions
* V4 - February, 2026
* V3 - December, 2025
