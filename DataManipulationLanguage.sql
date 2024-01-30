
-- CREATE PROCEDURE Register(
-- @P_Username varchar(20),
-- @P_Password VARCHAR(256),
-- @P_Name VARCHAR(50),
-- @P_Lastname VARCHAR(50),
-- @P_Email VARCHAR(50),
-- @P_Phone_Number VARCHAR(11)
-- )
-- AS
-- BEGIN
--     DECLARE @salt UNIQUEIDENTIFIER;
--     SET @salt = NEWID();-- Generating the salt for hashing the password
--     DECLARE @hashedPassword VARBINARY(256); -- adjust the length as needed
--     SET @hashedPassword = HASHBYTES('SHA2_256', CAST(CONCAT(@P_Password, @salt) AS varchar(MAX)));--Final hashed password

--     IF NOT EXISTS(SELECT * FROM Users WHERE @P_Username = username)
--         BEGIN 
--             INSERT INTO Users
--             VALUES (@P_Username, @hashedPassword, @P_Name, @P_Lastname, @P_Email, @P_Phone_Number, @salt);
--         END;
--     ELSE
--         BEGIN
--             -- Aware the python program
--             SELECT * FROM Users
--             -- above line is just something TEMPORARY for skipping the error
--         END;
-- END;
-- -------------------

-- CREATE PROCEDURE Log_In(
-- @P_Username VARCHAR(20),
-- @P_Current_Password VARCHAR(256)
-- )
-- AS
-- BEGIN
--     IF NOT EXISTS (SELECT * FROM Users WHERE @P_Username = username)
--     BEGIN
--         PRINT 'The username doesn''t exist!'
--     END;

--     ELSE
--     BEGIN
--         DECLARE @User_Salt UNIQUEIDENTIFIER;
--         DECLARE @Stored_Password VARCHAR(256);
--         SELECT @User_Salt = salt , @Stored_Password = password FROM Users WHERE @P_Username = username;
--         DECLARE @hashedPassword VARBINARY(256); -- adjust the length as needed
--         SET @hashedPassword = HASHBYTES('SHA2_256', CAST(CONCAT(@P_Current_Password, @User_Salt) AS varchar(MAX)));

--         IF @Stored_Password = @hashedPassword
--         BEGIN
--             PRINT'Correct';
--         END;
--         ELSE
--         BEGIN
--             PRINT 'Discorrect';
--         END;
--     END;
-- END;

-- ---------------------


-- CREATE PROCEDURE Change_Password(
-- @P_Username VARCHAR(20),
-- @P_Current_Password VARCHAR(256),
-- @P_New_Password VARCHAR(256)
-- )
-- AS
-- BEGIN
--     IF NOT EXISTS (SELECT * FROM Users WHERE @P_Username = username)
--     BEGIN
--         PRINT 'The username doesn''t exist!'
--     END;

--     ELSE
--     BEGIN
--         DECLARE @User_Salt UNIQUEIDENTIFIER;
--         DECLARE @Stored_Password VARCHAR(256);
--         SELECT @User_Salt = salt , @Stored_Password = password FROM Users WHERE @P_Username = username;
--         DECLARE @hashedPassword VARBINARY(256); -- adjust the length as needed
--         SET @hashedPassword = HASHBYTES('SHA2_256', CAST(CONCAT(@P_Current_Password, @User_Salt) AS varchar(MAX)));

--         IF @Stored_Password = @hashedPassword
--         BEGIN
--             DECLARE @hashedNewPassword VARBINARY(256); -- adjust the length as needed
--             SET @hashedNewPassword = HASHBYTES('SHA2_256', CAST(CONCAT(@P_New_Password, @User_Salt) AS varchar(MAX)));
--             UPDATE Users
--             set password = @hashedNewPassword
--             WHERE @P_Username = username
--             PRINT'Correct';
--         END;
--         ELSE
--         BEGIN
--             PRINT 'Discorrect';
--         END;
--     END;
-- END;

-- CREATE PROCEDURE New_Account(
-- @P_Account_Number VARCHAR(16),
-- @P_Username VARCHAR(25),
-- @P_Amount DECIMAL(15,2),
-- @P_Block BIT,
-- @P_Loan_Status BIT
-- )
-- AS
-- BEGIN
--     INSERT INTO Accounts
--     VALUES(@P_Account_Number, @P_Username, @P_Amount, @P_Block, @P_Loan_Status);
-- END;



-- CREATE FUNCTION Acounts_Info_byID(
-- @P_Username VARCHAR(25)
-- )
-- RETURNS TABLE
-- AS 
-- RETURN (SELECT * FROM Accounts WHERE @P_Username = username);

-- CREATE FUNCTION Accounts_Info_byNumber(
-- @P_Account_Nummber VARCHAR(16)
-- )
-- RETURNS TABLE
-- AS 
-- RETURN (SELECT * FROM Accounts WHERE @P_Account_Nummber = account_number);

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





-- EXECUTE New_Account @P_Account_Number = '5810121345678090',@P_Username = 'Mohsen', 
-- @P_Amount = '556000000', @P_Block = 1 , @P_Loan_Status = 1

-- -- EXECUTE Change_Password @P_Username = 'Amiir', @P_Current_Password = '456', @P_New_Password = '789'

-- SELECT * FROM Accounts_Info_byNumber('5859831103511177')
-- SELECT * FROM Accounts
-- SELECT * FROM Users
-- PRINT dbo.Account_Owner ('5810121345678092')









