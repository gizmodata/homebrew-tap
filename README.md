# [GizmoData](https://gizmodata.com) Homebrew Tap

This is the official Homebrew tap for GizmoData tools.

## Installation

```bash
brew tap gizmodata/tap
brew install gizmosql
brew install gizmosql-ui
brew install gizmosqlline
```

Or install directly:

```bash
brew install gizmodata/tap/gizmosql
brew install gizmodata/tap/gizmosql-ui
brew install gizmodata/tap/gizmosqlline
```

## Available Formulas

| Formula | Description |
|---------|-------------|
| [`gizmosql`](https://github.com/gizmodata/gizmosql) | High-performance SQL server built on DuckDB/SQLite with Arrow Flight SQL |
| [`gizmosql-ui`](https://github.com/gizmodata/gizmosql-ui) | Web-based SQL interface for GizmoSQL servers |
| [`gizmosqlline`](https://github.com/gizmodata/gizmosqlline) | Flight SQL command-line client (SQLLine with Arrow Flight SQL driver) |

## Usage

### gizmosql

Start the server:

```bash
GIZMOSQL_PASSWORD=tiger gizmosql_server --database-filename /path/to/database.duckdb --username scott
```

Connect with the client:

```bash
gizmosql_client --host localhost --port 31337 --username scott --password tiger --command Execute --query "SELECT 1"
```

For TLS and authentication options, run `gizmosql_server --help` or `gizmosql_client --help`.

### gizmosql-ui

```bash
gizmosql-ui
```

This starts a local web server at http://localhost:3000 and opens your browser.

### gizmosqlline

Interactive mode:

```bash
gizmosqlline
```

Connect directly:

```bash
gizmosqlline -u "jdbc:arrow-flight-sql://localhost:31337" -n user -p password
```

Type `!help` for available SQLLine commands.

## License

Apache-2.0
