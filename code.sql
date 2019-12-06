/*3)Implement your extensions in the database by first creating tables, if any, then populating them with existing manager data, then adding/modifying foreign key constraints.Do you have to initialize the bonusattributeto a value? Why?
*/
CREATE table jbmanager (id int, name varchar(250), salary int, manager int, birthyear int, startyear int);

ALTER TABLE jbmanager add constraint PK_manager PRIMARY KEY (id);

ALTER TABLE jbemployee add constraint FK_manager FOREIGN KEY (manager) REFERENCES jbmanager(id);

ALTER TABLE jbdept add constraint FK_dept_manager FOREIGN KEY (manager) REFERENCES jbmanager(id);


INSERT INTO jbmanager SELECT * from jbemployee where id in(SELECT DISTINCT manager FROM jbemployee);

INSERT IGNORE INTO jbmanager SELECT * from jbemployee where id in  (SELECT id from jbmanager where id union (SELECT DISTINCT  manager from jbdept));

alter table jbmanager add bonus int;

/*
We think so yes, null is not a value at all and therefore the bonus cannot be NULL it has to be zero from the  start. I might be hard to let's say increase something if it is null as well ex add 1 to null.



4)All departments showed good sales figures last year! Give all current department managers $10,000 in bonus. This bonus is an addition to other possible bonuses they have.
*/
UPDATE jbmanager SET bonus = bonus + 10000 where id in (select distinct manager from jbdept);
/*
5)
*/
create table  transaction(transaction_number int, sdate DATETIME, account_number int, amount int, employee_id int);

create table account (account_number int, balance int, customer_id int);

create table customer (id int, state varchar(250), street_adress varchar(250), name varchar(250));

alter table jbcity add customer_id int;

alter table customer add constraint PK_customer PRIMARY KEY(id);
alter table jbcity add constraint FK_locatedIn FOREIGN KEY(customer_id) REFERENCES customer(id);

alter table account add constraint PK_account PRIMARY KEY(account_number);

alter table account add constraint FK_owns FOREIGN KEY(customer_id) REFERENCES customer(id);

alter table transaction add constraint FK_does_transaction FOREIGN KEY(account_number) REFERENCES account(account_number);

alter table transaction add constraint PK_transaction PRIMARY KEY(transaction_number);

alter table transaction add constraint FK_makes FOREIGN KEY(employee_id) REFERENCES jbemployee(id);

create table deposit(id int);

create table withdrawal(id int);

alter table deposit add constraint PK_deposit PRIMARY KEY(id);

alter table withdrawal add constraint PK_withdrawal PRIMARY KEY(id);

alter table deposit add constraint FK_deposit FOREIGN KEY(id) REFERENCES transaction(transaction_number);

alter table withdrawal add constraint FK_withdrawal FOREIGN KEY(id) REFERENCES transaction(transaction_number);

ALTER TABLE jbdebit drop foreign key fk_debit_employee;

drop view view_debit;

drop view view_debit_join;

alter table jbsale drop FOREIGN KEY fk_sale_debit;

drop table jbdebit;

create table debit (id int);

alter table debit add constraint PRIMARY KEY(id);
alter table debit add constraint FK_debit FOREIGN KEY(id) references transaction(transaction_number);

ALTER TABLE jbsale ADD CONSTRAINT fk_sale_debit FOREIGN KEY (debit) REFERENCES debit(id);

