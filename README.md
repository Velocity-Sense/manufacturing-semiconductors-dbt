# Semiconductor Manufacturing Analytics Platform
A modern analytics project that simulates a semiconductor fab environment and demonstrates how to centralize, clean, and model complex manufacturing data into a streamlined star schema — using dbt Cloud, PostgreSQL, and Hex.

![Semiconductor Manufacturing](https://images.unsplash.com/photo-1510746001195-0db09655b6db?q=80&w=3732&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D)


## Overview

Semiconductor manufacturing generates massive amounts of tool and process data but often, that data exists underutilized across different equipment and hard to analyze consistently. Many process engineers aren't data experts, and their ability to extract insights is limited.

This project demonstrates how to solve that using modern data engineering practices.

## The Problems We Solve with Data

- Yield analysis is critical, but messy and inconsistent across tools
- Cross-equipment analysis is difficult due to lack of data standardization
- Process optimization efforts rely on manual work or inconsistent spreadsheets
- Engineers and stakeholders lack accessible, trusted dashboards

## The Value You Get with Data

### Dashboard for Actionable Insights

- Track yield rates across product types and machines
- Identify patterns in defect rates
- Pinpoint exactly where quality issues arise

### Equipment Health Monitoring

- Monitor sensor readings from all manufacturing equipment
- Get alerts when readings fall outside normal parameters
- Predict maintenance needs before failures occur

### Inventory Intelligence

- Maintain optimal stock levels of critical materials
- Receive automatic alerts when supplies run low
- Track consumption patterns and costs

### Production Performance

- Compare efficiency metrics across machines and product types
- Identify bottlenecks in your manufacturing process
- Optimize production schedules based on historical performance

---

## 🛠 Tech Stack

| Layer              | Tool                |
|-------------------|---------------------|
| Data Generation    | Python              |
| Data Warehouse     | PostgreSQL (Cloud)  |
| Transformation     | dbt Cloud           |
| Modeling Strategy  | Star Schema         |
| Visualization      | Hex.tech            |

---

## 📐 Data Model

The data warehouse utilizes a **star schema** design:

### ✅ Fact Table

- `fct_wafer_process`: Each row represents a wafer event at a process step, enriched with yield, defect, and process metadata

### ✅ Dimensions

- `dim_equipment`: Equipment metadata and tool age
- `dim_process`: Manufacturing steps, target parameters, complexity
- `dim_lot`: Lot-level info including customer and priority
- `dim_defect`: Standardized defect types with severity ratings

### 🧼 Intermediate Layer

- `int_wafer_process`: Adds pressure buckets, yield loss, and flags

---

## Sample Insights

- "What are the most common defect types and their impact on yield?"
- "Which process steps have the highest average yield loss?"
- "What is the correlation between last maintenance date and defect rate?"
- "What are the process and equipment parameters for high-yield wafers?"
- "How do wafer counts impact cycle time or yield?"

## Contact

For support or questions about this analytics platform, please contact:

- Gideon Fernandez - Founder, Velocity Sense - at gideonfernandez@velocitysense.com
- Or visit our website at www.velocitysense.com

---
_Built with modern data stack technologies including dbt Cloud and Hex_
