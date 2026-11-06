# ORDS MCP reports and custom SQL tools example

This directory contains the small example used by the blog:

```text
ORDS/mcp-reports-custom-sql-example/
├── ords-config/
│   ├── databases/
│   │   └── sales-admin/
│   │       ├── mcp_reports/
│   │       │   └── employee-directory-by-department.json
│   │       └── pool.xml.example
│   └── global/
│       ├── mcp_reports/
│       │   └── database-health-summary.json
│       └── mcp_tools/
│           └── find-high-earning-employees.json
└── sql/
    └── setup.sql
```

The JSON files are sanitized versions of the internal demo configuration. They contain no real passwords or secrets.

## Quick start

1. Run `sql/setup.sql` in a throwaway test PDB.
2. Copy the `ords-config` contents into an ORDS configuration directory.
3. Rename `pool.xml.example` to `pool.xml`.
4. Update the database host, service name, username, and password in `pool.xml`.
5. Make sure your ORDS MCP authentication is already configured.
6. Start ORDS and connect an MCP client.

The `database-health-summary.json` report reads DBA views. It is included to demonstrate a protected report, but it needs extra database privileges if you want to execute it. A caller with only the `pools:read` scope should be able to discover it but should not be able to execute it.

The setup script is for learning and testing only. Do not use its passwords or privileges in production.
