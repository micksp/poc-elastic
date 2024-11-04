-- Create the user table
-- this table is probably not needed currently,
-- but it is here for completeness
CREATE TABLE "user"
(
  id        VARCHAR PRIMARY KEY, -- Primary key for user
  name      VARCHAR NOT NULL,
  loginName VARCHAR NOT NULL
);
-- Create the summaryconfig table
CREATE TABLE summaryconfig
(
  id         VARCHAR PRIMARY KEY, -- Primary key for summaryconfig
  userId     VARCHAR NOT NULL,    -- Foreign key to the user (assuming user table exists)
  configName VARCHAR NOT NULL,

  -- Define the foreign key constraint
  CONSTRAINT fk_user FOREIGN KEY (userId)
    REFERENCES "user" (id) ON DELETE CASCADE
);

-- Create the summaryfield table
CREATE TABLE summaryfield
(
  id            VARCHAR PRIMARY KEY, -- Primary key for summaryfield
  technicalName VARCHAR NOT NULL
);

-- Create the summaryconfig_summaryfield table
CREATE TABLE summaryconfig_summaryfield
(
  id              VARCHAR PRIMARY KEY, -- Primary key for summaryconfig_summaryfield
  summaryconfigId VARCHAR NOT NULL,    -- Foreign key to summaryconfig
  summaryfieldId  VARCHAR NOT NULL,    -- Foreign key to summaryfield
  displayOrder    INT     NOT NULL,

  -- Define the foreign key constraints
  CONSTRAINT fk_summaryconfig FOREIGN KEY (summaryconfigId)
    REFERENCES summaryconfig (id) ON DELETE CASCADE,
  CONSTRAINT fk_summaryfield FOREIGN KEY (summaryfieldId)
    REFERENCES summaryfield (id) ON DELETE CASCADE,

  -- Add a unique constraint on the combination of summaryconfigId and summaryfieldId
  CONSTRAINT unique_summaryconfig_summaryfield UNIQUE (summaryconfigId, summaryfieldId)
);
