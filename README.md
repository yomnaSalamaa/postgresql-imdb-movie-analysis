# 🎬 Movie Database Analysis (PostgreSQL Project)

## 📊 Overview
This project explores a comprehensive **movie dataset** using PostgreSQL.  
It covers everything from **data creation and cleaning** to **advanced analysis** using SQL window functions, aggregations, and ranking queries.

![Dashboard Preview](images/movies_sql_project.png)

---

## 🧱 Database Schema

### Tables Created:
- **movies** — movie details (title, year, duration, country, etc.)
- **genre** — movie genres
- **director_mapping** — links between movies and directors
- **role_mapping** — actor/actress roles in movies
- **names** — people involved (actors, directors, etc.)
- **ratings** — movie ratings data

---

## 🧮 Key SQL Operations

### 1. Data Cleaning
- Checked for nulls in key columns.
- Validated relationships between tables.

### 2. Exploratory Queries
- Movie counts per **year** and **month**.
- Most popular **genres** and **production companies**.
- Average **duration per genre** and **rating distribution**.

### 3. Advanced Analysis
- **Ranking movies** by average rating and votes.
- Identified **top directors and actors** by performance.
- Calculated **moving averages** and **running totals**.
- Classified movies into *Superhit*, *Hit*, *One-time-watch*, and *Flop*.

---

## 🏆 Insights
- The most common genres released in 2019.
- Top-performing production houses with multilingual hits.
- Leading Indian actors and actresses based on weighted average ratings.
- Directors with the shortest intervals between movie releases.

---

## ⚙️ Tools & Technologies
- **PostgreSQL**
- **SQL Window Functions**
- **Joins & Subqueries**
- **CTEs (WITH Clauses)**

