# Inventory Management System Database

## Overview
An Inventory/Stock Management System designed to track, organize, and manage the flow of goods. This project implements a fully normalized relational database to handle procurement, sales, and real-time inventory tracking. It was developed to demonstrate advanced database management system (DBMS) concepts, including referential integrity, automated triggers, and complex analytical querying.

## Key Features
* **BCNF Normalized Schema:** A highly structured database design eliminating data redundancy across Product, Supplier, Customer, and Order tables.
* **Real-Time Stock Automation:** Utilizes MySQL `AFTER INSERT` triggers to automatically update stock levels whenever a Purchase Order (Receipt) or Sales Order (Issue) is processed.
* **Comprehensive Audit Trail:** An `InventoryTransaction` table autonomously logs every stock movement with auto-incremented IDs and timestamps for complete traceability.
* **Analytical Reporting:** Pre-built SQL queries to generate business intelligence reports, including low-stock alerts, unsold product identification, and total revenue calculations.

## Repository Contents
* `inventoryDB.sql`: The complete SQL script. Includes table creation (DDL), sample historical data insertion (DML), database triggers, and testing queries.
* `Inventory Management Database.docx`: Full project documentation, including requirement analysis, normalization proofs, and query output screenshots.
* `Inventory_schema.png` & `er_diagram.png`: Relational Schema and Entity-Relationship (ER) diagrams.

## Technologies Used
* **Database Engine:** MySQL
* **Design & Modeling:** MySQL Workbench, Draw.io
* **Concepts:** DDL, DML, Triggers, Joins, Aggregations, BCNF Normalization

## How to Run
1. Open MySQL Workbench (or any MySQL client).
2. Open the `inventoryDB.sql` file.
3. Execute the entire script. It will automatically drop any existing database with the same name, create the `InventoryDB` schema, build the tables, insert the historical data, establish the automation triggers, and run the analytical queries.
