SET SERVEROUTPUT ON;
SET DEFINE OFF;

CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,
    transaction_type VARCHAR2(10) NOT NULL
        CHECK (transaction_type IN ('INCOME', 'EXPENSE')),
    amount NUMBER(12,2) NOT NULL CHECK (amount > 0),
    category VARCHAR2(50) NOT NULL,
    transaction_date DATE DEFAULT SYSDATE NOT NULL,
    description VARCHAR2(200)
);

CREATE SEQUENCE transaction_seq
START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE transaction_audit (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id NUMBER,
    action_type VARCHAR2(20),
    old_amount NUMBER(12,2),
    new_amount NUMBER(12,2),
    action_date DATE DEFAULT SYSDATE,
    details VARCHAR2(200)
);

CREATE OR REPLACE TRIGGER trg_validate_transaction
BEFORE INSERT OR UPDATE ON transactions
FOR EACH ROW
BEGIN
    IF :NEW.amount IS NULL OR :NEW.amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Amount must be positive.');
    END IF;

    IF :NEW.transaction_type NOT IN ('INCOME', 'EXPENSE') THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid transaction type.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_transaction_audit
AFTER INSERT OR UPDATE OR DELETE ON transactions
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO transaction_audit
        (transaction_id, action_type, old_amount, new_amount, details)
        VALUES
        (:NEW.transaction_id, 'INSERT', NULL, :NEW.amount,
         'Transaction added');

        IF :NEW.transaction_type = 'EXPENSE'
           AND :NEW.amount >= 10000 THEN
            DBMS_OUTPUT.PUT_LINE(
                'WARNING: High expense recorded: Rs ' || :NEW.amount
            );
        END IF;

    ELSIF UPDATING THEN
        INSERT INTO transaction_audit
        (transaction_id, action_type, old_amount, new_amount, details)
        VALUES
        (:NEW.transaction_id, 'UPDATE', :OLD.amount, :NEW.amount,
         'Transaction updated');

    ELSIF DELETING THEN
        INSERT INTO transaction_audit
        (transaction_id, action_type, old_amount, new_amount, details)
        VALUES
        (:OLD.transaction_id, 'DELETE', :OLD.amount, NULL,
         'Transaction deleted');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE add_transaction (
    p_type IN VARCHAR2,
    p_amount IN NUMBER,
    p_category IN VARCHAR2,
    p_date IN DATE,
    p_description IN VARCHAR2
)
AS
    v_type VARCHAR2(10);
BEGIN
    v_type := UPPER(TRIM(p_type));

    IF v_type NOT IN ('INCOME', 'EXPENSE') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Enter INCOME or EXPENSE.');
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid amount.');
    END IF;

    IF p_category IS NULL OR TRIM(p_category) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20005, 'Category is required.');
    END IF;

    INSERT INTO transactions
    VALUES (
        transaction_seq.NEXTVAL, v_type, p_amount,
        TRIM(p_category), NVL(p_date, SYSDATE), p_description
    );
END;
/

CREATE OR REPLACE PROCEDURE update_transaction (
    p_id IN NUMBER,
    p_type IN VARCHAR2,
    p_amount IN NUMBER,
    p_category IN VARCHAR2,
    p_date IN DATE,
    p_description IN VARCHAR2
)
AS
BEGIN
    IF UPPER(TRIM(p_type)) NOT IN ('INCOME', 'EXPENSE') THEN
        RAISE_APPLICATION_ERROR(-20006, 'Invalid type.');
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Invalid amount.');
    END IF;

    UPDATE transactions
    SET transaction_type = UPPER(TRIM(p_type)),
        amount = p_amount,
        category = TRIM(p_category),
        transaction_date = NVL(p_date, SYSDATE),
        description = p_description
    WHERE transaction_id = p_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Transaction not found.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Transaction updated successfully.');
END;
/

CREATE OR REPLACE PROCEDURE delete_transaction (
    p_id IN NUMBER
)
AS
BEGIN
    DELETE FROM transactions WHERE transaction_id = p_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Transaction not found.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Transaction deleted successfully.');
END;
/

CREATE OR REPLACE FUNCTION get_balance
RETURN NUMBER
AS
    v_income NUMBER(12,2);
    v_expense NUMBER(12,2);
BEGIN
    SELECT NVL(SUM(amount), 0) INTO v_income
    FROM transactions WHERE transaction_type = 'INCOME';

    SELECT NVL(SUM(amount), 0) INTO v_expense
    FROM transactions WHERE transaction_type = 'EXPENSE';

    RETURN v_income - v_expense;
END;
/

CREATE OR REPLACE PROCEDURE show_summary
AS
    v_income NUMBER(12,2);
    v_expense NUMBER(12,2);
BEGIN
    SELECT NVL(SUM(amount), 0) INTO v_income
    FROM transactions WHERE transaction_type = 'INCOME';

    SELECT NVL(SUM(amount), 0) INTO v_expense
    FROM transactions WHERE transaction_type = 'EXPENSE';

    DBMS_OUTPUT.PUT_LINE('===== FINANCIAL SUMMARY =====');
    DBMS_OUTPUT.PUT_LINE('Total Income: Rs ' || v_income);
    DBMS_OUTPUT.PUT_LINE('Total Expenses: Rs ' || v_expense);
    DBMS_OUTPUT.PUT_LINE('Current Balance: Rs ' || get_balance());
END;
/

CREATE OR REPLACE PROCEDURE category_expense_report
AS
    v_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== CATEGORY-WISE EXPENSES =====');

    FOR r IN (
        SELECT category, SUM(amount) total_amount
        FROM transactions
        WHERE transaction_type = 'EXPENSE'
        GROUP BY category
        ORDER BY SUM(amount) DESC
    ) LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            r.category || ': Rs ' || r.total_amount
        );
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No expenses found.');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE monthly_report (
    p_month IN NUMBER,
    p_year IN NUMBER
)
AS
    v_start DATE;
    v_end DATE;
    v_income NUMBER(12,2);
    v_expense NUMBER(12,2);
BEGIN
    IF p_month IS NULL OR p_month NOT BETWEEN 1 AND 12
       OR p_year IS NULL OR p_year < 1 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Invalid month or year.');
    END IF;

    v_start := TO_DATE(
        TO_CHAR(p_year) || LPAD(p_month, 2, '0') || '01',
        'YYYYMMDD'
    );
    v_end := ADD_MONTHS(v_start, 1);

    SELECT
        NVL(SUM(CASE WHEN transaction_type = 'INCOME'
                     THEN amount ELSE 0 END), 0),
        NVL(SUM(CASE WHEN transaction_type = 'EXPENSE'
                     THEN amount ELSE 0 END), 0)
    INTO v_income, v_expense
    FROM transactions
    WHERE transaction_date >= v_start
      AND transaction_date < v_end;

    DBMS_OUTPUT.PUT_LINE('===== MONTHLY REPORT =====');
    DBMS_OUTPUT.PUT_LINE('Month: ' || TO_CHAR(v_start, 'Month YYYY'));
    DBMS_OUTPUT.PUT_LINE('Income: Rs ' || v_income);
    DBMS_OUTPUT.PUT_LINE('Expenses: Rs ' || v_expense);
    DBMS_OUTPUT.PUT_LINE('Monthly Net: Rs ' || (v_income - v_expense));
END;
/

CREATE OR REPLACE PROCEDURE show_transactions
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== ALL TRANSACTIONS =====');

    FOR r IN (
        SELECT * FROM transactions
        ORDER BY transaction_date DESC, transaction_id DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || r.transaction_id ||
            ' | Type: ' || r.transaction_type ||
            ' | Amount: Rs ' || r.amount ||
            ' | Category: ' || r.category ||
            ' | Date: ' || TO_CHAR(r.transaction_date, 'DD-MON-YYYY') ||
            ' | Description: ' || NVL(r.description, 'N/A')
        );
    END LOOP;
END;
/

BEGIN
    add_transaction('INCOME', 30000, 'Salary',
        DATE '2026-10-01', 'Monthly salary');

    add_transaction('INCOME', 5000, 'Freelancing',
        DATE '2026-10-05', 'Freelance work');

    add_transaction('EXPENSE', 3000, 'Food',
        DATE '2026-10-06', 'Monthly groceries');

    add_transaction('EXPENSE', 1500, 'Travel',
        DATE '2026-10-10', 'Bus and cab');

    add_transaction('EXPENSE', 12000, 'Education',
        DATE '2026-10-15', 'College fees');
    DBMS_OUTPUT.PUT_LINE('All 5 transactions added successfully.');
END;
/

COMMIT;

BEGIN
    show_summary;
    category_expense_report;
    monthly_report(10, 2026);
    show_transactions;
END;
/

SELECT * FROM transaction_audit ORDER BY audit_id;

-- UPDATE EXAMPLE
-- BEGIN
--     update_transaction(3, 'EXPENSE', 3500, 'Food',
--         DATE '2026-10-06', 'Updated groceries');
-- END;
-- /
-- COMMIT;

-- DELETE EXAMPLE
-- BEGIN
--     delete_transaction(4);
-- END;
-- /
-- COMMIT;