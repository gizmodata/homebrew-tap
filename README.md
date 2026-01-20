# GizmoData Homebrew Tap

This is the official Homebrew tap for GizmoData tools.

## Installation

```bash
brew tap gizmodata/tap
brew install gizmosql
brew install gizmosql-ui
```

Or install directly:

```bash
brew install gizmodata/tap/gizmosql
brew install gizmodata/tap/gizmosql-ui
```

## Available Formulas

| Formula | Description |
|---------|-------------|
| [`gizmosql`](https://github.com/gizmodata/gizmosql) | High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL |
| [`gizmosql-ui`](https://github.com/gizmodata/gizmosql-ui) | Web-based SQL interface for GizmoSQL servers |

## Usage

### gizmosql

Start the server:

```bash
GIZMOSQL_PASSWORD=secret gizmosql_server --database-filename /path/to/database.duckdb
```

Connect with the client:

```bash
gizmosql_client --host localhost --port 31337 --password secret --command Execute --query "SELECT 1"
```

For TLS and authentication options, run `gizmosql_server --help` or `gizmosql_client --help`.

### gizmosql-ui

```bash
gizmosql-ui
```

This starts a local web server at http://localhost:4821 and opens your browser.

## License

Apache-2.0
