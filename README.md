# Expense Management System using Oracle SQL and PL/SQL

## 1. Project Overview

The **Expense Management System** is a database-based project developed using Oracle SQL and PL/SQL. It is designed to manage income and expense transactions, calculate the current balance, generate financial reports, validate transaction data, and maintain an audit history of database changes.

This project demonstrates the practical use of SQL queries, PL/SQL blocks, stored procedures, functions, triggers, sequences, and database constraints.

## 2. Objectives

- Store and manage income and expense transactions.
- Calculate total income, total expenses, and current balance.
- Generate category-wise expense reports.
- Generate monthly financial reports.
- Add, update, and delete transactions.
- Validate transaction amounts and types.
- Maintain an audit trail of database operations.
- Display a warning for high-value expenses.

## 3. Technologies Used

- **Database:** Oracle Database / Oracle-compatible SQL environment
- **Database Language:** SQL
- **Programming Language:** PL/SQL
- **Database Objects:** Tables, Sequence, Triggers, Stored Procedures, Function
- **Output:** DBMS_OUTPUT

## 4. Features

### Income and Expense Management
Users can add income and expense transactions with an amount, category, date, and description.

### Financial Summary
The system calculates:

- Total Income
- Total Expenses
- Current Balance

**Formula:**

Current Balance = Total Income − Total Expenses

### Category-Wise Expense Report
Displays expenses grouped by category, such as Food, Travel, and Education.

### Monthly Financial Report
Generates income, expenses, and net balance for a selected month and year.

### Update and Delete Transactions
Existing transactions can be updated or deleted using their transaction IDs.

### Data Validation
The system checks transaction types and amounts before accepting data.

### Audit Trail
The `transaction_audit` table records INSERT, UPDATE, and DELETE operations.

### High-Expense Warning
The audit trigger prints a warning when a newly inserted expense is ₹10,000 or more.

## 5. Database Structure

### Table 1: `transactions`

Stores the main transaction records.

| Column | Description |
|---|---|
| `transaction_id` | Unique transaction ID |
| `transaction_type` | INCOME or EXPENSE |
| `amount` | Transaction amount |
| `category` | Transaction category |
| `transaction_date` | Date of transaction |
| `description` | Additional details |

### Table 2: `transaction_audit`

Stores a history of transaction changes.

| Column | Description |
|---|---|
| `audit_id` | Unique audit record ID |
| `transaction_id` | Related transaction ID |
| `action_type` | INSERT, UPDATE, or DELETE |
| `old_amount` | Previous amount |
| `new_amount` | New amount |
| `action_date` | Audit date |
| `details` | Description of the action |

### Sequence

`transaction_seq` generates transaction IDs automatically.

## 6. PL/SQL Objects

| Object | Purpose |
|---|---|
| `trg_validate_transaction` | Validates transaction data |
| `trg_transaction_audit` | Maintains audit records and high-expense warnings |
| `add_transaction` | Adds a new transaction |
| `update_transaction` | Updates an existing transaction |
| `delete_transaction` | Deletes a transaction |
| `get_balance` | Calculates the current balance |
| `show_summary` | Displays the financial summary |
| `category_expense_report` | Displays category-wise expenses |
| `monthly_report` | Displays a selected month's financial report |
| `show_transactions` | Displays all transactions |

## 7. How to Run the Project

1. Open Oracle SQL Developer, SQL*Plus, or an Oracle-compatible PL/SQL environment.
2. Connect to your Oracle database.
3. Open a new SQL worksheet or script editor.
4. Copy the complete project SQL/PLSQL code into the editor.
5. Execute the script in order so that tables, sequence, triggers, procedures, and function are created before the sample data is inserted.
6. Check the output panel for the high-expense warning and financial reports.
7. Run the audit query to verify recorded operations.

**Important:** Run the complete setup and sample-data script only once for a fresh setup. Running the entire script again may produce table or sequence already-exists errors, or insert duplicate sample transactions.

## 8. Sample Data

The project inserts the following sample transactions:

| Type | Amount (₹) | Category |
|---|---:|---|
| INCOME | 30,000 | Salary |
| INCOME | 5,000 | Freelancing |
| EXPENSE | 3,000 | Food |
| EXPENSE | 1,500 | Travel |
| EXPENSE | 12,000 | Education |

## 9. Sample Output

For the five sample transactions, the expected financial summary is:

```text
===== FINANCIAL SUMMARY =====
Total Income: Rs 35000
Total Expenses: Rs 16500
Current Balance: Rs 18500
```

Category-wise expenses:

```text
===== CATEGORY-WISE EXPENSES =====
Education: Rs 12000
Food: Rs 3000
Travel: Rs 1500
```

The high-expense trigger should also print a warning for the ₹12,000 Education expense.

The monthly report for October 2026 should show:

- Income: ₹35,000
- Expenses: ₹16,500
- Monthly Net: ₹18,500

These figures assume the database contains only the five sample transactions and that they have been inserted once.

## 10. Testing

The following operations can be tested:

- View all transactions.
- Calculate total income and expenses.
- Verify the current balance.
- Generate category-wise expense reports.
- Generate monthly reports.
- Add a new income or expense.
- Test invalid transaction types and amounts.
- Update a transaction.
- Delete a test transaction.
- Verify audit records.
- Check trigger and procedure status.

## 11. Advantages

- Simple and organized transaction management.
- Automatic calculation of financial totals.
- Reusable PL/SQL procedures and functions.
- Validation of transaction data.
- Audit history for database changes.
- Useful reporting for financial analysis.

## 12. Limitations

- The project is database-focused and does not include a graphical user interface.
- It does not implement user authentication or role-based access.
- Reports are displayed through database output rather than a dashboard.
- Audit records depend on successful trigger execution and transaction commits.

## 13. Future Enhancements

- Develop a web or desktop interface.
- Add user registration and login.
- Introduce budget limits and budget alerts.
- Generate PDF and Excel reports.
- Add graphical charts for income and expenses.
- Support user-wise transaction management.

## 14. Conclusion

The Expense Management System demonstrates how Oracle SQL and PL/SQL can be used to build a database application for managing income and expenses. It combines transaction storage, data validation, automatic ID generation, audit logging, and financial reporting. The project provides practical experience with database programming concepts and can be extended with additional features in the future.

## 15. Author

**Project:** Expense Management System using Oracle SQL and PL/SQL  
**Student:** Samarth Pratap Singh  
**UID:** 26MCA20183  
**Program:** Master of Computer Applications (MCA)  
**University:** Chandigarh University
