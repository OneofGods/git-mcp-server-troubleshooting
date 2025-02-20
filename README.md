# Git MCP Server Troubleshooting Guide

This repository documents common connection issues with Git MCP servers and their solutions based on real-world experience.

## Quick Start

If you're experiencing connection issues with Git MCP Server:

1. Run our [diagnostic script](scripts/diagnose-connection.sh) to identify common problems
2. Follow the [connection checklist](connection-checklist.md) for step-by-step verification
3. Check [log analysis](log-analysis.md) to understand error patterns
4. Implement [resolution steps](resolution-steps.md) for your specific issue

## Common Connection Issues

### 1. Package Name Error

```
npm error 404 Not Found - GET https://registry.npmjs.org/mcp-server-git - Not found
```

**Problem:** The package name is incorrect. Many users try `mcp-server-git` but this package doesn't exist in the npm registry.

**Solution:** Use the correct package name: `@modelcontextprotocol/git-server`
```bash
npm install -g @modelcontextprotocol/git-server
# or
npx @modelcontextprotocol/git-server
```

### 2. Server Transport Closure

```
Server transport closed unexpectedly, this is likely due to the process exiting early.
```

**Problem:** The server process terminates prematurely before proper initialization.

**Potential causes:**
- Incorrect environment variables
- Port conflicts
- Missing dependencies
- Permission issues
- Incorrect token configuration

### 3. Authentication Issues

Authentication issues typically show different error patterns from what we're seeing. When you see:
```
Server disconnected. {"context":"connection"}
```
This indicates a connection issue rather than an authentication problem.

## Additional Connection Issues

### Port Conflicts

If Claude desktop or other applications are using the same port:

```
Error: EADDRINUSE: address already in use :::3000
```

**Solution:** 
- Change the port in your configuration
- Use a dynamic port allocation strategy
- Check for and close conflicting processes

### Environment Variable Problems

Different Git providers require different environment variables:

- GitHub: `GITHUB_TOKEN`
- GitLab: `GITLAB_PERSONAL_ACCESS_TOKEN` (not `GITLAB_ACCESS_TOKEN`)

Incorrectly named environment variables will cause connection failures.

### Process Management Issues

Multiple server instances can interfere with each other:

- Stale lock files prevent new server instances from starting
- Log file access conflicts occur when multiple processes try to write to the same log
- Claude desktop may start its own server instances causing conflicts

## Tools & Resources

| Resource | Purpose |
|----------|---------|
| [Connection Checklist](connection-checklist.md) | Step-by-step verification process |
| [Diagnostic Script](scripts/diagnose-connection.sh) | Automated troubleshooting tool |
| [Log Analysis](log-analysis.md) | Understanding error patterns in logs |
| [Resolution Steps](resolution-steps.md) | Specific solutions for common issues |
| [MCP Debugging Docs](https://modelcontextprotocol.io/docs/tools/debugging) | Official debugging documentation |

## Verification Steps

After attempting fixes, verify your connection with:

```bash
# Start the server
npx @modelcontextprotocol/git-server

# In another terminal
curl http://localhost:3000/status
```

Look for these logs indicating success:
```
[mcp-server-git] [info] Server transport opened
[mcp-server-git] [info] Client transport opened
```
