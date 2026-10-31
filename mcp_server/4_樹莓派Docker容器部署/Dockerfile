FROM python:3.12-slim

# 讓 Python 的 print() 稽核紀錄即時輸出到 Docker logs，不會被緩衝區卡住
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# 先複製並安裝套件（利用 Docker 快取機制，改程式碼時不用重裝套件）
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 複製 MCP Server 程式碼
COPY server_http.py .

# 開放 8000 埠供區域網路員工連線
EXPOSE 8000

# 啟動遠端 HTTP + Token 驗證的 MCP Server
CMD ["python", "server_http.py"]

