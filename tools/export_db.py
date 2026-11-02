"""Export the application schema and demo records from the migrated SQLite database."""
import json
import sqlite3
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]


def export():
    db = sqlite3.connect(BASE / 'db.sqlite3')
    db.row_factory = sqlite3.Row
    db.execute('PRAGMA foreign_keys=ON')
    tables = [row['name'] for row in db.execute(
        "SELECT name FROM sqlite_schema WHERE type='table' AND name LIKE 'portal_%' ORDER BY name"
    )]
    if not tables:
        raise RuntimeError('Run migrate and demo before exporting.')
    objects = list(db.execute(
        "SELECT type, tbl_name, sql FROM sqlite_schema WHERE sql IS NOT NULL AND tbl_name LIKE 'portal_%' ORDER BY type='index', rowid"
    ))
    dump = ['PRAGMA foreign_keys=ON;', 'BEGIN TRANSACTION;', 'PRAGMA defer_foreign_keys=ON;']
    dump += [row['sql']+';' for row in objects if row['type']=='table']
    dump += [line for line in db.iterdump() if line.startswith('INSERT INTO "portal_')]
    dump += [row['sql']+';' for row in objects if row['type']=='index']
    dump.append('COMMIT;')
    for suffix, rows in [
        ('database.sql', dump),
        ('schema.sql', [row['sql']+';' for row in objects]),
    ]:
        (BASE/suffix).write_text('\n\n'.join(rows)+'\n',encoding='utf-8')
    clone = sqlite3.connect(':memory:')
    clone.executescript('\n'.join(dump))
    assert not clone.execute('PRAGMA foreign_key_check').fetchall()
    info = []
    for table in tables:
        columns = [dict(row) for row in db.execute('SELECT * FROM pragma_table_info(?)', (table,))]
        refs = [dict(row) for row in db.execute('SELECT * FROM pragma_foreign_key_list(?)', (table,))]
        # All table identifiers below came from sqlite_schema, not from HTTP input.
        count = db.execute(f'SELECT COUNT(*) FROM "{table}"').fetchone()[0]
        assert clone.execute(f'SELECT COUNT(*) FROM "{table}"').fetchone()[0] == count
        info.append({'name':table,'fields':columns,'refs':refs,'count':count})
    (BASE/'schema.json').write_text(json.dumps(info, ensure_ascii=False, indent=2)+'\n',encoding='utf-8')
    print({row['name']:row['count'] for row in info})


if __name__ == '__main__':
    export()
