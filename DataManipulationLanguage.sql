
CREATE PROCEDURE Register(
@P_Username varchar(20),
@P_Password VARCHAR(256),
@P_Name VARCHAR(50),
@P_Lastname VARCHAR(50),
@P_Email VARCHAR(50),
@P_Phone_Number VARCHAR(11)
)
AS
BEGIN
    DECLARE @salt UNIQUEIDENTIFIER;
    SET @salt = NEWID();-- Generating the salt for hashing the password
    DECLARE @hashedPassword VARBINARY(256); -- adjust the length as needed
    SET @hashedPassword = HASHBYTES('SHA2_256', CAST(CONCAT(@P_Password, @salt) AS varchar(MAX)));--Final hashed password

    IF NOT EXISTS(SELECT * FROM Users WHERE @P_Username = username)
        BEGIN 
            INSERT INTO Users
            VALUES (@P_Username, @hashedPassword, @P_Name, @P_Lastname, @P_Email, @P_Phone_Number, @salt);
        END;
    ELSE
        BEGIN
            -- Aware the python program
            SELECT * FROM Users
            -- above line is just something TEMPORARY for skipping the error
        END;
END;
-------------------
GO
CREATE PROCEDURE Log_In(
    @P_Username VARCHAR(20),
    @P_Current_Password VARCHAR(256)
)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Users WHERE @P_Username = username)
    BEGIN
        PRINT 'The username doesn''t exist!'
    END;

    ELSE
    BEGIN
        DECLARE @User_Salt UNIQUEIDENTIFIER;
        DECLARE @Stored_Password VARCHAR(256);
        SELECT @User_Salt = salt , @Stored_Password = password FROM Users WHERE @P_Username = username;
        DECLARE @hashedPassword VARBINARY(256); -- adjust the length as needed
        SET @hashedPassword = HASHBYTES('SHA2_256', CAST(CONCAT(@P_Current_Password, @User_Salt) AS varchar(MAX)));

        IF @Stored_Password = @hashedPassword
        BEGIN
            PRINT'Correct';
        END;
        ELSE
        BEGIN
            PRINT 'Incorrect';
        END;
    END;
END;

---------------------

GO
CREATE PROCEDURE Change_Password(
@P_Username VARCHAR(20),
@P_Current_Password VARCHAR(256),
@P_New_Password VARCHAR(256)
)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Users WHERE @P_Username = username)
    BEGIN
        PRINT "The username doesn't exist!"
    END;

    ELSE
    BEGIN
        DECLARE @User_Salt UNIQUEIDENTIFIER;
        DECLARE @Stored_Password VARCHAR(256);
        SELECT @User_Salt = salt , @Stored_Password = password FROM Users WHERE @P_Username = username;
        DECLARE @hashedPassword VARBINARY(256); -- adjust the length as needed
        SET @hashedPassword = HASHBYTES('SHA2_256', CAST(CONCAT(@P_Current_Password, @User_Salt) AS varchar(MAX)));

        IF @Stored_Password = @hashedPassword
        BEGIN
            DECLARE @hashedNewPassword VARBINARY(256); -- adjust the length as needed
            SET @hashedNewPassword = HASHBYTES('SHA2_256', CAST(CONCAT(@P_New_Password, @User_Salt) AS varchar(MAX)));
            UPDATE Users
            set password = @hashedNewPassword
            WHERE @P_Username = username
            PRINT'Correct';
        END;
        ELSE
        BEGIN
            PRINT 'Discorrect';
        END;
    END;
END;

GO
CREATE PROCEDURE New_Account(
@P_Account_Number VARCHAR(16),
@P_Username VARCHAR(25),
@P_Amount DECIMAL(15,2),
@P_Block BIT,
@P_Loan_Status BIT
)
AS
BEGIN
    INSERT INTO Accounts
    VALUES(@P_Account_Number, @P_Username, @P_Amount, @P_Block, @P_Loan_Status);
END;

GO
CREATE FUNCTION Acounts_Info_byID(
@P_Username VARCHAR(25)
)
RETURNS TABLE
AS 
RETURN (SELECT * FROM Accounts WHERE @P_Username = username);

GO
CREATE FUNCTION Accounts_Info_byNumber(
@P_Account_Nummber VARCHAR(16)
)
RETURNS TABLE
AS 
RETURN (SELECT * FROM Accounts WHERE @P_Account_Nummber = account_number);

GO  
CREATE FUNCTION Account_Owner(
@P_Account_Nummber VARCHAR(16)
)
RETURNS VARCHAR(100)
AS 
BEGIN
    DECLARE @fullName VARCHAR(100)
    SELECT @fullName = (name +' '+ lastname) 
    FROM Users, Accounts
    WHERE @P_Account_Nummber = account_number AND Accounts.username = Users.username
    RETURN (@fullName)
END;
GO



-- EXECUTE New_Account @P_Account_Number = '5810121345678090',@P_Username = 'Mohsen', 
-- @P_Amount = '556000000', @P_Block = 1 , @P_Loan_Status = 1

-- -- EXECUTE Change_Password @P_Username = 'Amiir', @P_Current_Password = '456', @P_New_Password = '789'

-- SELECT * FROM Accounts_Info_byNumber('5859831103511177')
-- SELECT * FROM Accounts
-- SELECT * FROM Users
-- PRINT dbo.Account_Owner ('5810121345678092')



------- FUNCTION And PROCEDURE for Loan -------------

CREATE FUNCTION Loan_List_byUsername(
@P_username VARCHAR(25)
)
RETURNS TABLE
AS
RETURN (select * from Loans where @P_username = Loan.username);

GO
CREATE PROCEDURE Get_New_Loan(
    @P_Username VARCHAR(25),
    @P_Account_Number VARCHAR(16),
    @P_Amount DECIMAL(15, 2)
)
AS
BEGIN
    IF NOT EXISTS(select * from Accounts where @@P_Account_Number = Accounts.account_number)
        BEGIN
            PRINT "The username doesn't exist!"
        END
    ELSE
        BEGIN
            IF EXISTS (select * 
                from Accounts 
                where @P_Account_Number = Accounts.account_number and loan_status = 1)
                BEGIN
                    PRINT "You must finish your payment. After you can get new loan"
                END;
            ELSE
                BEGIN
                    -- Add new loan
                    UPDATE Accounts
                    set loan_status = 1, amount = @P_Amount + amount
                    where @P_Account_Number = Accounts.account_number;
                    INSERT INTO Loans(username, account_number, amount, remain_payment, date)
                    VALUES (@P_Username, @P_Account_Number, @P_Amount, 12, GETDATE());
                    DECLARE @payment_times INTEGER
                    set @payment_times = 1
                    while @payment_times < 13
                        BEGIN
                            INSERT INTO Payments
                            VALUES (@P_Account_Number, @P_Amount, GETDATE() + 30 * @Payment_times, 0);
                            set @payment_times = @payment_times + 1
                        END
                END
        END
END;


Go 
CREATE PROCEDURE Pay_Loan(
    @P_Account_Number VARCHAR(16)
)
AS
BEGIN
    IF EXISTS (select * 
                from Accounts 
                where @P_Account_Number = Accounts.account_number and Accounts.loan_status = 1)
        BEGIN
            DECLARE @P_Payment_Amount DECIMAL(15, 2)
            DECLARE @P_Account_Amount DECIMAL(15, 2)
            select @P_Payment_Amount = amount / 12 from Loans where @P_Account_Number = Loans.amoun;
            select @P_Account_Amount = amount from Accounts where @P_Account_Number = amount;
            IF @P_Payment_Amount <= @P_Account_Amount
                BEGIN
                    UPDATE Loans
                    set remain_payment = remain_payment - 1
                    where Loans.account_number = @P_Account_Number;
                    UPDATE Payments
                    set is_payed = 1
                    where Payments.account_number = @P_Account_Number and date <= GETDATE();
                END
            ELSE
                BEGIN
                    PRINT "Don't have enough money!"
                END
        END
        ELSE
            BEGIN
                PRINT "You don't have loan"
            END
END;


GO
CREATE FUNCTION Info_Payment_byNumber(
    @P_Account_Number VARCHAR(16)
)
RETURNS TABLE
AS
RETURN (select * from Payments where @P_Account_Number = Payment.account_number);