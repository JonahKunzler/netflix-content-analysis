"""
Phase 0: load the raw Netflix CSVs into SQLite untouched, so SQL analysis
has a database to query against. No cleaning happens here — see notebooks/cleaning.ipynb
for Phase 1.
"""

import sqlite3
from pathlib import Path

import pandas as pd

RAW_DIR = Path(__file__).parent / "data" / "raw"
DB_PATH = Path(__file__).parent / "netflix.db"

TABLES = {
    "titles": RAW_DIR / "titles.csv",
    "credits": RAW_DIR / "credits.csv",
}


def main():
    conn = sqlite3.connect(DB_PATH)
    for table_name, csv_path in TABLES.items():
        df = pd.read_csv(csv_path)
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        print(f"Loaded {len(df):,} rows into '{table_name}' from {csv_path.name}")
    conn.close()
    print(f"\nSQLite database ready at {DB_PATH}")


if __name__ == "__main__":
    main()
