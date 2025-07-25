import os
import pandas as pd
import psycopg2

# Environment variables (set in docker-compose)
DB_NAME = os.getenv("POSTGRES_DB", "denverdb")
USER = os.getenv("POSTGRES_USER", "postgres")
PASSWORD = os.getenv("POSTGRES_PASSWORD", "postgres")
HOST = os.getenv("POSTGRES_HOST", "db")
PORT = os.getenv("POSTGRES_PORT", "5432")

conn = psycopg2.connect(
    dbname=DB_NAME, user=USER, password=PASSWORD, host=HOST, port=PORT
)

cur = conn.cursor()

csv_folder = "/data"


def sql_type(series: pd.Series) -> str:
    non_null = series.dropna().astype(str)

    if len(non_null) == 0:
        return "TEXT"

    sample = non_null.sample(min(100, len(non_null)), random_state=42)

    # ✅ Reject INTEGER if even one value contains a non-digit
    if sample.str.fullmatch(r"\d+").all():
        return "INTEGER"

    # ✅ Accept FLOAT if 90%+ values are parseable
    try:
        numeric = pd.to_numeric(sample, errors="coerce")
        if numeric.notnull().mean() > 0.9:
            return "FLOAT"
    except Exception:
        pass

    # ✅ Fallback
    return "TEXT"


for filename in os.listdir(csv_folder):
    if not filename.endswith(".csv"):
        continue

    table_name = os.path.splitext(filename)[0].lower()
    path = os.path.join(csv_folder, filename)

    print(f"\n📄 Processing file: {filename}")

    try:
        # Load CSV
        df = pd.read_csv(path, keep_default_na=False, na_values=[""])

        # Infer SQL types
        inferred_types = {col: sql_type(df[col]) for col in df.columns}

        print(f"📊 Inferred schema for '{table_name}': {inferred_types}")

        # Format datetime columns and clean blanks
        for col, dtype in inferred_types.items():
            if dtype == "TIMESTAMP":
                df[col] = pd.to_datetime(df[col], errors="coerce")
                df[col] = df[col].dt.strftime("%Y-%m-%d %H:%M:%S")

            # Explicitly set hairy columns
            if col == "DISTRICT_ID":
                inferred_types[col] = "TEXT"
            if col in [
                "FIRST_OCCURRENCE_DATE",
                "LAST_OCCURRENCE_DATE",
                "REPORTED_DATE",
                "datetime",
                "sunrise",
                "sunset",
            ]:
                inferred_types[col] = "TIMESTAMP"

        df.replace(r"^\s*$", None, regex=True, inplace=True)

        # Write cleaned temp file
        tmp_path = f"/tmp/cleaned_{filename}"
        df.to_csv(tmp_path, index=False, header=False)

        # Create SQL table
        columns = ", ".join(f'"{col}" {inferred_types[col]}' for col in df.columns)
        cur.execute(f"DROP TABLE IF EXISTS {table_name};")
        cur.execute(f"CREATE TABLE {table_name} ({columns});")

        # Copy data
        with open(tmp_path, "r") as f:
            cur.copy_expert(f"COPY {table_name} FROM STDIN WITH CSV", f)

        print(f"✅ Loaded table '{table_name}' with {len(df)} rows.")

    except Exception as e:
        print(f"Failed to load {filename}: {e}")

# Finalize
conn.commit()
cur.close()
conn.close()
print("\n🎉 All CSVs processed.")
