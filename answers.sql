-- ============================================================================
-- Library Management System Schema (MySQL)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;


-- ============================================================================
-- Table: Publisher
-- 1–M: One publisher can publish many books
-- ============================================================================
CREATE TABLE Publisher (
  publisher_id   INT            AUTO_INCREMENT PRIMARY KEY,
  name           VARCHAR(255)   NOT NULL UNIQUE,
  address        VARCHAR(500),
  phone          VARCHAR(20),
  created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- Table: Book
-- 1–M: One publisher ⇒ many books
-- M–M via BookAuthor to Author
-- ============================================================================
CREATE TABLE Book (
  book_id        INT            AUTO_INCREMENT PRIMARY KEY,
  title          VARCHAR(255)   NOT NULL,
  publisher_id   INT            NOT NULL,
  published_year YEAR,
  isbn           VARCHAR(20)    NOT NULL UNIQUE,
  pages          INT            CHECK (pages > 0),
  created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (publisher_id)
    REFERENCES Publisher(publisher_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);


-- ============================================================================
-- Table: Author
-- M–M with Book via BookAuthor
-- ============================================================================
CREATE TABLE Author (
  author_id      INT            AUTO_INCREMENT PRIMARY KEY,
  first_name     VARCHAR(100)   NOT NULL,
  last_name      VARCHAR(100)   NOT NULL,
  birth_date     DATE,
  UNIQUE(first_name, last_name, birth_date),
  created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- Table: BookAuthor
-- Junction table for Book ⇄ Author (M–M)
-- ============================================================================
CREATE TABLE BookAuthor (
  book_id        INT NOT NULL,
  author_id      INT NOT NULL,
  PRIMARY KEY (book_id, author_id),
  FOREIGN KEY (book_id)
    REFERENCES Book(book_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (author_id)
    REFERENCES Author(author_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);


-- ============================================================================
-- Table: Member
-- 1–M: A member can have many loans
-- 1–1: With MembershipCard
-- ============================================================================
CREATE TABLE Member (
  member_id      INT            AUTO_INCREMENT PRIMARY KEY,
  first_name     VARCHAR(100)   NOT NULL,
  last_name      VARCHAR(100)   NOT NULL,
  email          VARCHAR(255)   NOT NULL UNIQUE,
  phone          VARCHAR(20),
  join_date      DATE           NOT NULL DEFAULT CURRENT_DATE,
  created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- Table: MembershipCard
-- 1–1: Each member has exactly one card
-- Primary key is also FK to enforce 1–1
-- ============================================================================
CREATE TABLE MembershipCard (
  member_id      INT            PRIMARY KEY,
  card_number    VARCHAR(20)    NOT NULL UNIQUE,
  issue_date     DATE           NOT NULL DEFAULT CURRENT_DATE,
  expiry_date    DATE           NOT NULL,
  FOREIGN KEY (member_id)
    REFERENCES Member(member_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CHECK (expiry_date > issue_date)
);


-- ============================================================================
-- Table: BookCopy
-- 1–M: Each book may have multiple physical copies
-- ============================================================================
CREATE TABLE BookCopy (
  copy_id        INT            AUTO_INCREMENT PRIMARY KEY,
  book_id        INT            NOT NULL,
  copy_number    INT            NOT NULL,
  status         ENUM('available','on_loan','lost','maintenance')
                  NOT NULL DEFAULT 'available',
  UNIQUE (book_id, copy_number),
  FOREIGN KEY (book_id)
    REFERENCES Book(book_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);


-- ============================================================================
-- Table: Loan
-- 1–M: A member can borrow many copies over time
-- 1–M: A copy can be loaned many times (serially)
-- ============================================================================
CREATE TABLE Loan (
  loan_id        INT            AUTO_INCREMENT PRIMARY KEY,
  copy_id        INT            NOT NULL,
  member_id      INT            NOT NULL,
  loan_date      DATE           NOT NULL DEFAULT CURRENT_DATE,
  due_date       DATE           NOT NULL
