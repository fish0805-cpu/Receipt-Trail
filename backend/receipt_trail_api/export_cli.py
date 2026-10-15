from __future__ import annotations

import argparse
import os
from pathlib import Path

from receipt_trail_api.data_export import export_database


def main() -> int:
    parser = argparse.ArgumentParser(description="Export Receipt Trail data")
    parser.add_argument("--database-env", default="DATABASE_URL")
    parser.add_argument("--output-dir", type=Path, default=Path("exports"))
    args = parser.parse_args()
    database_url = os.environ.get(args.database_env)
    if not database_url:
        parser.error(f"environment variable {args.database_env} is required")
    print(export_database(database_url, args.output_dir))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
