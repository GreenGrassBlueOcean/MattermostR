@echo off
REM OS-Level File Descriptor Redirection for MattermostR MCP Server
REM Prevents C/C++ libraries and R stdout from corrupting the JSON-RPC pipe.
set "RSCRIPT=%GGBO_RSCRIPT%"
if not defined RSCRIPT set "RSCRIPT=C:\Program Files\R\R-4.6.0\bin\x64\Rscript.exe"
if not exist "%RSCRIPT%" set "RSCRIPT=Rscript"
"%RSCRIPT%" --no-init-file -e "MattermostR::run_mcp_stdio(silent = TRUE)" 3>&1 1>&2 2>&3
