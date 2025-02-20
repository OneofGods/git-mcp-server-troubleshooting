# Git MCP Server Connection Checklist

Use this comprehensive checklist to methodically troubleshoot Git MCP Server connection issues.

## 1. Package Installation Verification

- [ ] Verify package is installed with the correct name
  ```bash
  # Check global installation
  npm list -g @modelcontextprotocol/git-server
  
  # Check local installation
  npm list @modelcontextprotocol/git-server
  ```

- [ ] Check for incorrect package name usage
  ```bash
  # This should NOT be installed
  npm list -g mcp-server-git
  ```

- [ ] Verify npm registry accessibility
  ```bash
  npm ping
  ```

## 2. Environment Variable Configuration

- [ ] For GitHub connections, verify token:
  ```bash
  echo $GITHUB_TOKEN
  ```

- [ ] For GitLab connections, verify correct token variable:
  ```bash
  # This should be set
  echo $GITLAB_PERSONAL_ACCESS_TOKEN
  
  # This should NOT be set
  echo $GITLAB_ACCESS_TOKEN
  ```

- [ ] Check other environment variables:
  ```bash
  # Port configuration
  echo $MCP_SERVER_PORT
  
  # Log level
  echo $MCP_LOG_LEVEL
  
  # Config path
  echo $MCP_CONFIG_PATH
  ```

## 3. Port Availability

- [ ] Check if default port (3000) is available:
  ```bash
  lsof -i:3000
  ```

- [ ] Look for Claude desktop processes:
  ```bash
  ps aux | grep -i claude
  ```

- [ ] Check for any MCP server processes already running:
  ```bash
  ps aux | grep -i mcp-server
  ```

## 4. File System Checks

- [ ] Verify MCP directory structure exists:
  ```bash
  ls -la ~/.mcp
  ls -la ~/.mcp/config
  ls -la ~/.mcp/logs
  ```

- [ ] Check for lock files:
  ```bash
  find ~/.mcp -name "*.lock"
  ```

- [ ] Verify log file permissions:
  ```bash
  ls -la ~/.mcp/logs
  ```

## 5. Configuration Verification

- [ ] Check configuration file existence and format:
  ```bash
  cat ~/.mcp/config/config.json
  ```

- [ ] Verify correct paths in configuration:
  ```bash
  # Check for relative vs absolute paths
  grep -r "path" ~/.mcp/config/
  ```

- [ ] Check for port configuration:
  ```bash
  grep -r "port" ~/.mcp/config/
  ```

## 6. Network Connectivity

- [ ] Verify local network connectivity:
  ```bash
  curl -v http://localhost:3000/status
  ```

- [ ] Check Git provider API accessibility:
  ```bash
  # For GitHub
  curl -s -I https://api.github.com
  
  # For GitLab
  curl -s -I https://gitlab.com/api/v4/version
  ```

- [ ] Verify DNS resolution:
  ```bash
  ping github.com
  ping gitlab.com
  ping registry.npmjs.org
  ```

## 7. Process Monitoring

- [ ] Start server with debug logging:
  ```bash
  DEBUG=mcp:* npx @modelcontextprotocol/git-server
  ```

- [ ] Monitor process in another terminal:
  ```bash
  # Watch for server processes
  watch "ps aux | grep mcp-server"
  ```

- [ ] Check for log updates:
  ```bash
  tail -f ~/.mcp/logs/server.log
  ```

## 8. Testing Connection

- [ ] Test connection with minimal configuration:
  ```bash
  npx @modelcontextprotocol/git-server --port 3001
  ```

- [ ] Test connection with curl in another terminal:
  ```bash
  curl http://localhost:3001/status
  ```

- [ ] Verify logs for successful connection:
  ```bash
  grep "transport opened" ~/.mcp/logs/server.log
  ```

## 9. Diagnostic Script

- [ ] Run the diagnostic script:
  ```bash
  chmod +x ./scripts/diagnose-connection.sh
  ./scripts/diagnose-connection.sh
  ```

## 10. Common Error Resolution

- [ ] For 404 Not Found package errors:
  - [ ] Use correct package name: `@modelcontextprotocol/git-server`
  - [ ] Check npm registry configuration
  - [ ] Try installing from GitHub directly

- [ ] For port conflict errors (EADDRINUSE):
  - [ ] Change port in configuration
  - [ ] Check for and close Claude desktop
  - [ ] Kill any lingering MCP server processes

- [ ] For authentication errors:
  - [ ] Regenerate Git provider token
  - [ ] Ensure token has correct permissions
  - [ ] Use correct environment variable name

- [ ] For server transport closed errors:
  - [ ] Check npm debug logs for details
  - [ ] Enable verbose logging
  - [ ] Verify package installation integrity
