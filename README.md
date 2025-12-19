# LookML Framework

## Goals
The goal of the LookML framework is to deliver a comprehensible, light-weight, easy-to-learn framework on how you can organize your LookML in Looker (Enterprise).

The framework focuses on the following items:
- Separation between database logic, organization logic, joins and access permissions
- Reduce the chance on duplicate LookML
- Flexible enough to apply this to different development models

# Folders
1. 1_sources = contains the database table views that are created by Looker (with Create View from Table)
2. 2_views = refinements of the views under 1_sources. Must keep the exact same folder structure as under 1_sources. Can contain non-existing database elements, like persistent-derived tables.
3. 3_explores = holds all the joins between the views. You can only include LookML files from 2_views. LookML file name must be suffixed with .explore.lkml. 1 explore per file, or 1 explore file holds the same view joins, but with different base tables.
4. 4_models = contains refinements and extensions of the explores and the connection to the database.

# Sub-folder structure
Depending on your way of working this setup can be different.

Most common:

<database name or project id> / <schema name or dataset> / <view name>.view.lkml

If you work with Developent/Test/Acceptance/Production database, where the database name (or project id) is a different one per environment, you can leave it out and use this:

<schema name or dataset> / <view name>.view.lkml

## Versions
* V3 - December, 2025
