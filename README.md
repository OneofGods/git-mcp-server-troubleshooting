# Git MCP Server Troubleshooting

This repository contains troubleshooting information for the Git MCP server based on real-world debugging experience.

## Common Issues

### Package Not Found Error

```
npm error code E404
npm error 404 Not Found - GET https://registry.npmjs.org/mcp-server-git - Not found
npm error 404
npm error 404  'mcp-server-git@*' is not in this registry.
npm error 404
npm error 404 Note that you can also install from a
npm error 404 tarball, folder, http url, or git url.
```

**Problem**: The package name is incorrect or not published to npm registry.

**Solution**:
1. The correct package name is `@modelcontextprotocol/git-server`, not `mcp-server-git`
2. Install using the correct package name:
   ```bash
   npm install -g @modelcontextprotocol/git-server
   # or
   npx @modelcontextprotocol/git-server
   ```

### Server Disconnection Issues

```
Server transport closed unexpectedly, this is likely due to the process exiting early.
```

**Problem**: The server process is terminating prematurely, causing connection issues.

**Possible causes**:
1. Incorrect environment variables
2. Port conflicts
3. Permission issues
4. Missing dependencies

**Troubleshooting steps**:
1. Check error logs: `~/.npm/_logs/2025-02-20T04_22_32_357Z-debug-0.log`
2. Ensure correct environment variables:
   ```bash
   # For GitHub
   export GITHUB_TOKEN=your_token_here
   
   # For GitLab
   export GITLAB_PERSONAL_ACCESS_TOKEN=your_token_here
   ```
3. Use stderr for debugging as suggested in logs:
   ```javascript
   console.error('Debugging information here');
   ```

## Documentation Resources

For more detailed troubleshooting information, visit:
- [MCP Debugging Documentation](https://modelcontextprotocol.io/docs/tools/debugging)

## Log Analysis

When analyzing logs, look for these specific patterns:

```
2025-02-20T04:22:33.935Z [mcp-server-git] [error] Server disconnected. For troubleshooting guidance, please visit our [debugging documentation](https://modelcontextprotocol.io/docs/tools/debugging) {"context":"connection"}
```

This indicates a connection issue rather than an authentication problem.
