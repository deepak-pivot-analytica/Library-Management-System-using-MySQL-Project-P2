Use library_management;

-- Create Tables
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);
select * from branch; 
select * from books;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;
-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

select * from branch; 
select * from books;
select * from issued_status;
select * from employees;
select * from members;
select * from return_status;
-- CRUD tasks
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
Select * from books;

-- Task 2: Update an Existing Member's Address
Update members
set member_address = '125 Oak St'
where member_id = 'C103';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_member_id, count(issued_member_id) AS Counts
from issued_status
group by issued_member_id
Having Counts > 1;
-- using where clause and not having clause
select issued_member_id, Counts
from 
( select issued_member_id, count(issued_member_id) AS Counts
from issued_status
group by issued_member_id
) As Sub
where Counts>1;

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
Create Table Summary As
select ist.issued_book_name, ist.issued_book_isbn, b.category, count(ist.issued_book_isbn) as issue_count
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by ist.issued_book_name, ist.issued_book_isbn;

select * from Summary;

-- 4. Data Analysis & Findings
-- Task 7. Retrieve All Books in a Specific Category:
select book_title from books
where category = 'Classic'; 

-- Task 8: Find Total Rental Income by Category:
select  b.category, sum(b.rental_price) as Rental_income
from issued_status as ist
join books as b
on ist.issued_book_isbn = b.isbn
group by b.category;

-- List Members Who Registered in the Last 180 Days:
select * from 
(
select * , datediff('2025-01-01', reg_date) As Days from members) As Diff
where Days <364;

-- List Employees with Their Branch Manager's Name and their branch details:
select * from branch;
select * from employees;

select e. emp_id, e.emp_name, b.manager_id, b.branch_id ,b.branch_address
from employees as e
join branch as b
on e.branch_id = b.branch_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
select avg(rental_price) from books;

select book_title, author, category, rental_price
from books
where rental_price > 6.3;

-- Task 12: Retrieve the List of Books Not Yet Returned
select * from return_status;
select * from issued_status;

Select *  from issued_status as ist
left join  return_status as r
on r.issued_id = ist.issued_id
where r.return_id is NULL;


create table re_status as
select ist.issued_id, r.return_id, ist.issued_book_name, ist.issued_book_isbn as return_book_isbn, ist.issued_emp_id, ist.issued_date, r.return_date, datediff(r.return_date, ist.issued_date) as Num_days_issued
from issued_status as ist
join return_status as r
on ist.issued_id = r.issued_id;
select * from re_status;

-- Advanced SQL Operations
-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.


select * from branch;
select * from employees; 
select * from members;
select * from books;
select * from issued_status;
select * from return_status;

select m.member_id, m.member_name, m.member_address, ist.issued_id, r.return_id, b.book_title, ist.issued_date, datediff( '2025-01-01', ist.issued_date) as days_overdue
from members as m
join issued_status as ist
on ist.issued_member_id = m.member_id
join books as b
on b.isbn = ist.issued_book_isbn
-- where status = 'no' and datediff('2025-01-01' , ist.issued_date)  > 30; -- this is correct one since the status of availablility in the books table shows no and since we are using return date as null 
left join return_status as r
on r.issued_id = ist.issued_id
where r.return_date is null and datediff('2025-01-01' , ist.issued_date)  > 30;


-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned 
-- (based on entries in the return_status table).
DROP PROCEDURE IF EXISTS add_return_records;
DELIMITER // 
create procedure add_return_records
(
IN p_return_id VARCHAR(10), 
IN p_issued_id VARCHAR(10)
)

Begin
-- declaring variables
DECLARE  v_isbn VARCHAR(50);
DECLARE  v_book_name VARCHAR(80);
    -- insert values in the return_status table
    insert into return_status(return_id, issued_id, return_date)
    values
    (p_return_id, p_issued_id, current_date());
    -- assigning values to the variable
    select 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;
    -- update the books table
   Update books
   set  
   status = 'yes'
   WHERE isbn = v_isbn;
   -- update return_status for adding name
    UPDATE return_status
    SET
    return_book_name = v_book_name,
    return_book_isbn = v_isbn
    WHERE issued_id = p_issued_id;
End //
DELIMITER ;

call add_return_records('RS120', 'IS135');

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

-- Task 16: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, 
-- and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), 
-- the procedure should return an error message indicating that the book is currently not available.
DELIMITER // 
CREATE PROCEDURE issue_book 
(
IN p_issued_id VARCHAR(10), 
IN p_issued_member_id VARCHAR(30), 
IN p_issued_book_isbn VARCHAR(30), 
IN p_issued_emp_id VARCHAR(10)
)
BEGIN
-- declaring Variable
declare v_status varchar(30);
-- checking if book is available
Select 
 status
 into v_status
 from books
 where isbn = p_issued_book_isbn;
-- insert the book record to issued_status table
IF v_status = 'yes' THEN
         insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
        
         Update books 
         SET status = 'no'
         WHERE isbn = p_issued_book_isbn;
         SELECT CONCAT('Book records added successfully for book isbn : ', p_issued_book_isbn) AS message;
	ELSE 
         SELECT CONCAT('Sorry to inform you the book you have requested is unavailable. book_isbn: ', p_issued_book_isbn) AS message;
   
END IF;
END//
   
DELIMITER ;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

-- Task 17: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
-- The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
-- The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines

CREATE TABLE member_overdue_summary AS
SELECT 
    m.member_id,
    COUNT(CASE 
            WHEN r.return_date IS NULL 
                 AND DATEDIFF('2025-01-01', ist.issued_date) > 30 
            THEN 1
            ELSE NULL
         END) AS number_of_overdue_books,
    
    SUM(CASE 
            WHEN r.return_date IS NULL 
                 AND DATEDIFF('2025-01-01', ist.issued_date) > 30 
            THEN (DATEDIFF('2025-01-01', ist.issued_date) - 30) * 0.5
            ELSE 0
        END) AS total_fines,
    
    COUNT(ist.issued_id) AS number_of_books_issued, m.member_name
FROM members m
JOIN issued_status ist ON ist.issued_member_id = m.member_id
LEFT JOIN return_status r ON r.issued_id = ist.issued_id
GROUP BY m.member_id
ORDER BY m.member_id;

Select * from member_overdue_summary;