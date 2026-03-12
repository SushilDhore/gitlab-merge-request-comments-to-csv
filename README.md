# GitLab Merge Request Comments Exporter (CSV)

A Bash script that extracts **all comments**, **system notes**, and **code review discussions** from GitLab Merge Requests and exports them into a clean **Excel‑friendly CSV file**.

This tool works with **GitLab Self‑Hosted** as well as **GitLab.com** and supports **multiple repositories** simply by changing the project ID.

---

## 📌 Problem Statement

GitLab provides powerful Merge Request features, but **there is no built‑in way to export reviewer comments or discussions into a CSV or Excel file**.  

Teams often need MR comments for:

- Audit & compliance  
- Code review tracking  
- Quality checks  
- Client submissions  
- Release documentation  

GitLab's UI and API store these comments across:
- MR notes  
- Code review discussions  
- System notes (“assigned”, “approved”, “merged”, “pushed commits”, etc.)  

This script consolidates **all** of them into one clean CSV extract.

---

## 🚀 Features

✔ Exports all Merge Request comments  
✔ Includes system notes (optional)  
✔ Includes discussion threads  
✔ Works with multiple repositories  
✔ Excel‑compatible CSV with correct escaping  
✔ Filters MRs by target branch  
✔ Supports self‑hosted GitLab  
✔ Uses only `curl` + `jq`  
✔ Easy configuration  
✔ Adds blank rows for MRs with no comments  

---

## 📁 Project Structure
