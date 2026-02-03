# LookML Framework

## Goals
The goal of the LookML framework is to deliver a comprehensible, light-weight, easy-to-learn framework on how you can organize your LookML in Looker (Enterprise).

The framework focuses on the following items:
- Separation between database logic, organization logic, joins and access permissions
- Reduce the chance on duplicate LookML
- Flexible enough to apply this to different development models

# Folders
1. [`1_sources`](#1_sources-and-2_views): contains the database table views that are created by Looker (with Create View from Table)
2. [`2_views`](#1_sources-and-2_views): refinements of the views under `1_sources`. Must keep the exact same folder structure as under `1_sources`. Can contain non-existing database elements, like persistent-derived tables.
3. [`3_explores`](#3_explores): holds all the joins between the views. You can only include LookML files from `2_views`. LookML file name must be suffixed with .explore.lkml. 1 explore per file, or 1 explore file holds the same view joins, but with different base tables.
4. [`4_models`](#4_models): contains refinements and extensions of the explores and the connection to the database.
5. [`5_tests`](#5_tests): Contains the CI/CD tests when committing code to the main branch

# Folder structures
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
* V3 - December, 2025
