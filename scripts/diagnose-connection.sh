#!/bin/bash
# diagnose-connection.sh
# Diagnostic script for Git MCP Server connection issues

set -e

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MCP_HOME="${HOME}/.mcp"
LOG_DIR="${MCP_HOME}/logs"
PORT=3000
SERVER_PACKAGE="@modelcontextprotocol/git-server"

# Banner
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Git MCP Server Connection Diagnostics ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check package installation
check_package_installation() {
  echo -e "${BLUE}Checking package installation...${NC}"
  
  # Check if package is installed globally
  if npm list -g "$SERVER_PACKAGE" &>/dev/null; then
    GLOBAL_VERSION=$(npm list -g "$SERVER_PACKAGE" --depth=0 | grep "$SERVER_PACKAGE" | awk -F@ '{print $3}')
    echo -e "${GREEN}✅ Package installed globally: ${SERVER_PACKAGE}@${GLOBAL_VERSION}${NC}"
    INSTALL_STATUS="global"
  else
    echo -e "${YELLOW}⚠️ Package not installed globally.${NC}"
    
    # Check if package is installed locally
    if npm list "$SERVER_PACKAGE" &>/dev/null; then
      LOCAL_VERSION=$(npm list "$SERVER_PACKAGE" --depth=0 | grep "$SERVER_PACKAGE" | awk -F@ '{print $3}')
      echo -e "${GREEN}✅ Package installed locally: ${SERVER_PACKAGE}@${LOCAL_VERSION}${NC}"
      INSTALL_STATUS="local"
    else
      echo -e "${RED}❌ Package not installed locally either.${NC}"
      echo -e "${YELLOW}⚠️ Checking for incorrect package name usage...${NC}"
      
      if npm list -g "mcp-server-git" &>/dev/null || npm list "mcp-server-git" &>/dev/null; then
        echo -e "${RED}❌ Incorrect package 'mcp-server-git' is installed. This is wrong.${NC}"
        echo -e "${YELLOW}➡️ You should use '@modelcontextprotocol/git-server' instead.${NC}"
      fi
      
      INSTALL_STATUS="none"
    fi
  fi
  
  echo ""
}

# Function to check for port conflicts
check_port_conflicts() {
  echo -e "${BLUE}Checking for port conflicts...${NC}"
  
  # Check if port is in use
  if command_exists lsof; then
    PORT_PROCESS=$(lsof -i:"$PORT" -t 2>/dev/null)
    if [ -n "$PORT_PROCESS" ]; then
      PROCESS_NAME=$(ps -p "$PORT_PROCESS" -o comm=)
      echo -e "${RED}❌ Port ${PORT} is already in use by process ${PORT_PROCESS} (${PROCESS_NAME})${NC}"
      
      # Check if it's Claude
      if [[ "$PROCESS_NAME" == *"Claude"* ]]; then
        echo -e "${YELLOW}⚠️ Claude desktop appears to be running and using this port.${NC}"
        echo -e "${YELLOW}➡️ Consider changing the port in your config or closing Claude desktop.${NC}"
      fi
    else
      echo -e "${GREEN}✅ Port ${PORT} is available${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️ 'lsof' command not found. Cannot check port availability.${NC}"
  fi
  
  echo ""
}

# Function to check environment variables
check_environment() {
  echo -e "${BLUE}Checking environment variables...${NC}"
  
  # Check GitHub token
  if [ -n "$GITHUB_TOKEN" ]; then
    echo -e "${GREEN}✅ GITHUB_TOKEN is set${NC}"
  else
    echo -e "${YELLOW}⚠️ GITHUB_TOKEN not set.${NC}"
  fi
  
  # Check GitLab token - correct variable
  if [ -n "$GITLAB_PERSONAL_ACCESS_TOKEN" ]; then
    echo -e "${GREEN}✅ GITLAB_PERSONAL_ACCESS_TOKEN is set${NC}"
  else
    echo -e "${YELLOW}⚠️ GITLAB_PERSONAL_ACCESS_TOKEN not set.${NC}"
  fi
  
  # Check GitLab token - incorrect variable
  if [ -n "$GITLAB_ACCESS_TOKEN" ]; then
    echo -e "${RED}❌ GITLAB_ACCESS_TOKEN is set but should be GITLAB_PERSONAL_ACCESS_TOKEN.${NC}"
    echo -e "${YELLOW}➡️ The variable name is incorrect. Set GITLAB_PERSONAL_ACCESS_TOKEN instead.${NC}"
  fi
  
  echo ""
}

# Function to check npmrc configuration
check_npm_registry() {
  echo -e "${BLUE}Checking npm registry configuration...${NC}"
  
  # Check if npm can access registry
  if npm ping &>/dev/null; then
    echo -e "${GREEN}✅ npm registry is accessible${NC}"
  else
    echo -e "${RED}❌ Cannot connect to npm registry${NC}"
    echo -e "${YELLOW}➡️ Check your internet connection and npm configuration${NC}"
  fi
  
  # Check for custom registry configuration
  if grep -q "registry=" ~/.npmrc 2>/dev/null; then
    CUSTOM_REGISTRY=$(grep "registry=" ~/.npmrc | head -n1)
    echo -e "${YELLOW}⚠️ Custom npm registry detected: ${CUSTOM_REGISTRY}${NC}"
    echo -e "${YELLOW}➡️ Make sure this registry has the @modelcontextprotocol packages${NC}"
  fi
  
  echo ""
}

# Function to check recent logs
check_logs() {
  echo -e "${BLUE}Checking recent log files...${NC}"
  
  # Find most recent npm debug log
  if [ -d "${HOME}/.npm/_logs" ]; then
    LATEST_LOG=$(ls -t ${HOME}/.npm/_logs/*-debug-*.log 2>/dev/null | head -n1)
    if [ -n "$LATEST_LOG" ]; then
      echo -e "${GREEN}✅ Found npm debug log: ${LATEST_LOG}${NC}"
      
      # Check for common errors in log
      if grep -q "404 Not Found.*mcp-server-git" "$LATEST_LOG" 2>/dev/null; then
        echo -e "${RED}❌ Log shows incorrect package name error${NC}"
        echo -e "${YELLOW}➡️ Use '@modelcontextprotocol/git-server' instead of 'mcp-server-git'${NC}"
      fi
      
      if grep -q "EADDRINUSE" "$LATEST_LOG" 2>/dev/null; then
        echo -e "${RED}❌ Log shows port conflict (EADDRINUSE) error${NC}"
      fi
      
      if grep -q "EACCES" "$LATEST_LOG" 2>/dev/null; then
        echo -e "${RED}❌ Log shows permission (EACCES) error${NC}"
      fi
    else
      echo -e "${YELLOW}⚠️ No recent npm debug logs found${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️ npm logs directory not found${NC}"
  fi
  
  echo ""
}

# Function to test connection
test_connection() {
  echo -e "${BLUE}Testing Git MCP Server connection...${NC}"
  
  if [ "$INSTALL_STATUS" == "none" ]; then
    echo -e "${YELLOW}⚠️ Cannot test connection - package not installed${NC}"
    return 1
  fi
  
  # Try to start server in background
  echo -e "${YELLOW}➡️ Starting server in background...${NC}"
  npx $SERVER_PACKAGE --port $PORT &>/dev/null &
  SERVER_PID=$!
  
  # Wait for server to start
  sleep 3
  
  # Test connection
  if command_exists curl; then
    echo -e "${YELLOW}➡️ Testing connection with curl...${NC}"
    if curl -s "http://localhost:$PORT/status" &>/dev/null; then
      echo -e "${GREEN}✅ Connection successful!${NC}"
      CONNECTION_SUCCESS=true
    else
      echo -e "${RED}❌ Connection failed${NC}"
      CONNECTION_SUCCESS=false
    fi
  else
    echo -e "${YELLOW}⚠️ 'curl' command not found. Cannot test connection.${NC}"
    CONNECTION_SUCCESS=false
  fi
  
  # Kill server process
  kill $SERVER_PID &>/dev/null || true
  
  echo ""
}

# Function to provide recommendations
provide_recommendations() {
  echo -e "${BLUE}Recommendations based on diagnostics:${NC}"
  
  if [ "$INSTALL_STATUS" == "none" ]; then
    echo -e "${YELLOW}➡️ Install the correct package:${NC}"
    echo -e "   npm install -g @modelcontextprotocol/git-server"
    echo ""
  fi
  
  if [ -n "$GITLAB_ACCESS_TOKEN" ] && [ -z "$GITLAB_PERSONAL_ACCESS_TOKEN" ]; then
    echo -e "${YELLOW}➡️ Fix GitLab token environment variable:${NC}"
    echo -e "   export GITLAB_PERSONAL_ACCESS_TOKEN=$GITLAB_ACCESS_TOKEN"
    echo -e "   unset GITLAB_ACCESS_TOKEN"
    echo ""
  fi
  
  if [ "$CONNECTION_SUCCESS" == "false" ]; then
    echo -e "${YELLOW}➡️ Try running the server with verbose logging:${NC}"
    echo -e "   DEBUG=mcp:* npx @modelcontextprotocol/git-server"
    echo ""
  fi
  
  echo -e "${GREEN}➡️ For additional help, visit:${NC}"
  echo -e "   https://modelcontextprotocol.io/docs/tools/debugging"
  echo ""
}

# Main execution
main() {
  check_package_installation
  check_port_conflicts
  check_environment
  check_npm_registry
  check_logs
  test_connection
  provide_recommendations
  
  echo -e "${GREEN}Diagnostics complete!${NC}"
  echo -e "${BLUE}================================${NC}"
}

# Run the script
main
