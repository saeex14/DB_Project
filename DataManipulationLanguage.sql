
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
            PRINT 'Discorrect';
        END;
    END;
END;

---------------------


CREATE PROCEDURE Change_Password(
@P_Username VARCHAR(20),
@P_Current_Password VARCHAR(256),
@P_New_Password VARCHAR(256)
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

CREATE PROCEDURE New_Account(
@P_Account_Number VARCHAR(16),
@P_Username VARCHAR(25),
@P_Amount DECIMAL(15,2),
@P_Block BIT,
@P_Loan_Status BIT
)
AS
BEGIN
    INSERT INTO Account_Info
    VALUES(@P_Account_Number, @P_Username, @P_Amount, @P_Block, @P_Loan_Status);
END;



-- EXECUTE New_Account @P_Account_Number = '5859831103511167',@P_Username = 'Amir', 
-- @P_Amount = '4000000', @P_Block = 0 , @P_Loan_Status = 0

-- EXECUTE Change_Password @P_Username = 'Amiir', @P_Current_Password = '456', @P_New_Password = '789'

-- SELECT * FROM Account_Info
    









