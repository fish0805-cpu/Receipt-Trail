from __future__ import annotations

import argparse
import os
from pathlib import Path

from receipt_trail_api.legacy_migration import MigrationError, migrate_legacy_database


def main() -> int:
    parser = argparse.ArgumentParser(description="Safely migrate Receipt Trail SQLite data")
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--target-env", default="DATABASE_URL")
    parser.add_argument("--backup-dir", type=Path, default=Path("backups"))
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    target_url = os.environ.get(args.target_env)
    if not target_url:
        parser.error(f"environment variable {args.target_env} is required")
    try:
        report = migrate_legacy_database(
            args.source, target_url, apply=args.apply, backup_dir=args.backup_dir
        )
    except MigrationError as error:
        parser.error(str(error))
    print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
