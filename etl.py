import logging
from dotenv import find_dotenv, load_dotenv
import sys
import os

import pandas as pd
from sqlalchemy import create_engine

# Set up logging
logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)
log = logging.getLogger(__name__)

# load environment variables
load_dotenv(find_dotenv(), override=True)


# Database connection details
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("DB_NAME")
DB_PORT = os.getenv("DB_PORT")

# Create database connection
engine = create_engine(f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

# Load the Excel file
file_path = "data.xlsx"
xls = pd.ExcelFile(file_path)

# Loop through sheets and load them into PostgreSQL
for sheet_name in xls.sheet_names:
    df = pd.read_excel(xls, sheet_name=sheet_name)  # Read sheet into DataFrame
    table_name = sheet_name.lower()  # Covert table name to lowercase
    
    try:
        with engine.connect() as con:
            df.to_sql(table_name, engine, if_exists="replace", index=False)  # Load to DB
            log.info(f"Loaded sheet '{sheet_name}' into table '{table_name}'")
    except Exception as e:
        log.error(f"Failed to load sheet '{sheet_name}' into table '{table_name}'")
        log.error(e)

# connection will be closed automatically
