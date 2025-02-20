# Successful Git MCP Server Installation Guide

After extensive troubleshooting, we've discovered the correct method to install and run the Git MCP Server.

## Root Issue Identified

The primary issue was with package name format when using the UVX installer. The error message revealed that UVX doesn't handle scoped package names properly:

```
error: Not a valid package or extra name: "@modelcontextprotocol/git-server". Names must start and end with a letter or digit and may only contain -, _, ., and alphanumeric characters.
```

## Successful Installation Method

```bash
# Install using modified package name format (remove @ symbol)
uvx modelcontextprotocol-git-server
```

## Environment Variables for Better Results

Adding environment variables improves the installation and operation:

```bash
# With debug logging and custom port to avoid conflicts
uvx modelcontextprotocol-git-server --env DEBUG=* --env GIT_SERVER_PORT=3001
```

## Resolution Timeline

1. Analyzed log files at `/Users/Roger/Library/Logs/Claude/mcp-server-git-server.log`
2. Identified the package name format issue in UVX
3. Modified the package name by removing the @ symbol
4. Added environment variables to prevent port conflicts
5. Successfully installed the server
6. Required app restart to complete initialization

## Previous Errors and Their Fixes

| Error | Solution |
|-------|----------|
| `error: Not a valid package or extra name` | Modified package name format for UVX |
| `npm error 404 Not Found - GET https://registry.npmjs.org/mcp-server-git` | Used correct package name |
| `Error: Got unexpected extra argument (install)` | Removed unnecessary arguments |
| Port conflicts | Used custom port (3001) |

## Verification Steps

After restarting the application, verify the installation by:

1. Checking for Git tools in the functions list
2. Examining the logs for successful connection messages:
   ```
   [git-server] [info] Server started and connected successfully
   ```
3. Testing basic Git functions like repository listing

## Lessons Learned

1. UVX and NPX/NPM handle package names differently
2. Scoped package names need special handling with UVX
3. Environment variables can help debug and avoid conflicts
4. App restart is required after installation for proper initialization
