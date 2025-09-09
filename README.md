## InvestigationDB – Crime Record & Investigation Database ##
Objective
--------------

InvestigationDB is a MySQL database project created to store and analyze investigation and criminal records.
It manages details about cases, officers, suspects, victims, witnesses, and evidence for effective crime investigation.

Tools & Technologies
-------------------------

Database: MySQL (MySQL Workbench)

Diagramming: ER Diagram (MySQL Workbench)

Version Control: Git & GitHub

Project Files
--------------------

schema.sql → Database & tables creation script

queries.sql → SQL queries for solved/unsolved cases, analysis

views_triggers.sql → Views, triggers, and stored procedures

ER_Diagram.png → Entity Relationship Diagram

outputs/ → Query results (screenshots or SQL outputs)

README.md → Documentation

Database Schema
-------------------

Officers – officer details

Cases – case details (linked to officer)

Suspects – suspects linked with cases

Victims – victim details

Evidence – evidence records with chain of custody

Witnesses – witness statements

Features
------------------------

Indexing on case_id and suspect_name

Queries for solved and unsolved case analysis

Views for officer workloads and case summaries

Triggers for evidence updates and case closure

Stored procedures for investigation reports

How to Run (MySQL Workbench)
----------------------------

Open MySQL Workbench

Run schema.sql → create InvestigationDB and tables

Run views_triggers.sql → create views, triggers, procedures

Run queries.sql → execute sample queries

View ER_Diagram.png → database design

Example Queries
-----------------
-- Fetch unsolved cases
SELECT case_id, case_title, opened_date
FROM Cases
WHERE case_status = 'Unsolved';

-- Officer workloads
SELECT * FROM officer_workloads;

Deliverables
--------------

MySQL Schema

SQL Queries

Views, Triggers & Procedures

ER Diagram

Query Outputs
