#!/usr/bin/env bash
# renoise-manual-connect.sh — Renoise MCP 手动 OAuth 接入（WorkBuddy 备用方案）
#
# 背景：WorkBuddy 自定义 MCP 的 OAuth 客户端把「不带 expires_in、无 refresh_token」的
# token 按 0 秒有效期写入，导致授权成功但工具数恒为 0（expired-without-refresh）。
# 本脚本绕过该客户端判断：动态注册 OAuth 客户端 → PKCE → 本地回环回调 → 换 token →
# 直接以 Bearer 调用官方端点 https://renoise.tv/api/public/mcp（地址固定，不要改）。
#
# 用法: bash renoise-manual-connect.sh
# 产物: $WORKDIR/token.json（chmod 600）、mcp.sh（后续调用的通道）
# 依赖: curl、python3
set -euo pipefail

MCP_URL="https://renoise.tv/api/public/mcp"
OAUTH_META="$MCP_URL/.well-known/oauth-protected-resource"
REGISTER_URL="https://renoise.tv/api/public/mcp-oauth/register"
TOKEN_URL="https://renoise.tv/api/public/mcp-oauth/token"
AUTHZ_URL="https://renoise.tv/mcp-connect"
SCOPE="renoise"
PORT="${PORT:-8765}"
WORKDIR="${WORKDIR:-$HOME/.renoise-mcp}"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"

mkdir -p "$WORKDIR"
echo "[1/6] 工作目录: $WORKDIR"

# 0) 端口占用检查
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "端口 $PORT 已被占用。用 PORT=其他端口 bash $0 重试，或先停掉占用进程。" >&2
  exit 1
fi

# 1) 动态注册客户端（每次可重复注册）
echo "[2/6] 注册本地 OAuth 客户端..."
CLIENT_JSON=$(curl -sS --max-time 20 -X POST "$REGISTER_URL" \
  -H "Content-Type: application/json" -H "User-Agent: $UA" \
  -d "{\"client_name\":\"renoise-manual\",\"redirect_uris\":[\"http://127.0.0.1:$PORT/callback\"],\"grant_types\":[\"authorization_code\"],\"response_types\":[\"code\"],\"token_endpoint_auth_method\":\"none\"}")
CLIENT_ID=$(printf '%s' "$CLIENT_JSON" | python3 -c "import sys,json;print(json.load(sys.stdin)['client_id'])")
echo "    client_id: $CLIENT_ID"

# 2) PKCE + state
VERIFIER=$(python3 -c "import secrets;print(secrets.token_urlsafe(64)[:64])")
CHALLENGE=$(printf '%s' "$VERIFIER" | python3 -c "import sys,hashlib,base64;print(base64.urlsafe_b64encode(hashlib.sha256(sys.stdin.read().strip().encode()).digest()).rstrip(b'=').decode())")
STATE=$(python3 -c "import secrets;print(secrets.token_urlsafe(16))")

# 3) 本地回调服务器（仅捕获一次授权码）
cat > "$WORKDIR/callback_server.py" <<PYEOF
import http.server, json, urllib.parse
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        p = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        if p.get('code'):
            json.dump(p, open('$WORKDIR/callback.json','w'))
        self.send_response(200); self.send_header('Content-Type','text/html; charset=utf-8'); self.end_headers()
        self.wfile.write('授权已完成！回到终端查看结果。'.encode())
    def log_message(self,*a): pass
http.server.HTTPServer(('127.0.0.1',$PORT),H).serve_forever()
PYEOF
rm -f "$WORKDIR/callback.json"
python3 "$WORKDIR/callback_server.py" &
SERVER_PID=$!
trap 'kill $SERVER_PID 2>/dev/null || true' EXIT
sleep 1

# 4) 打印授权链接，等用户浏览器授权
AUTH_URL="$AUTHZ_URL?response_type=code&client_id=$CLIENT_ID&redirect_uri=http%3A%2F%2F127.0.0.1%3A$PORT%2Fcallback&scope=$SCOPE&state=$STATE&code_challenge=$CHALLENGE&code_challenge_method=S256"
echo "[3/6] 请在浏览器打开下面这条链接，登录 Renoise 并授权："
echo
echo "  $AUTH_URL"
echo
printf "[4/6] 等待授权回调（最长 300 秒）"
for i in $(seq 1 150); do
  [ -f "$WORKDIR/callback.json" ] && break
  printf '.'; sleep 2
done
echo
[ -f "$WORKDIR/callback.json" ] || { echo "超时：未收到授权回调，请重跑本脚本。" >&2; exit 1; }

# 5) 校验 state，换 token（必须带浏览器 UA，否则 Cloudflare 403/1010）
CODE=$(python3 -c "import json;print(json.load(open('$WORKDIR/callback.json'))['code'][0])")
GOT_STATE=$(python3 -c "import json;print(json.load(open('$WORKDIR/callback.json'))['state'][0])")
[ "$GOT_STATE" = "$STATE" ] || { echo "state 不匹配，中止。" >&2; exit 1; }

echo "[5/6] 换取 access token..."
HTTP_CODE=$(curl -sS --max-time 30 -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" -H "User-Agent: $UA" -H "Accept: application/json" \
  --data-urlencode "grant_type=authorization_code" \
  --data-urlencode "code=$CODE" \
  --data-urlencode "redirect_uri=http://127.0.0.1:$PORT/callback" \
  --data-urlencode "client_id=$CLIENT_ID" \
  --data-urlencode "code_verifier=$VERIFIER" \
  -o "$WORKDIR/token.json" -w "%{http_code}")
[ "$HTTP_CODE" = "200" ] || { echo "换 token 失败 HTTP $HTTP_CODE（多见于 Cloudflare 拦截，换网络/UA 重试）" >&2; exit 1; }
chmod 600 "$WORKDIR/token.json"
echo "    已保存 $WORKDIR/token.json（600）。Renoise 的 token 不带 expires_in，属长期有效。"

# 6) 生成通用调用通道 mcp.sh 并验证
cat > "$WORKDIR/mcp.sh" <<'SHEOF'
#!/usr/bin/env bash
# 用法: mcp.sh <tool_name> '<json_arguments>'   例: mcp.sh get_account '{}'
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
TOKEN=$(python3 -c "import json;print(json.load(open('$DIR/token.json'))['access_token'])")
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
curl -sS --max-time "${MCP_TIMEOUT:-120}" -X POST "https://renoise.tv/api/public/mcp" \
  -H "Authorization: Bearer $TOKEN" -H "User-Agent: $UA" \
  -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" \
  -d "{\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"tools/call\",\"params\":{\"name\":\"$1\",\"arguments\":${2:-{\}}}}" \
  | python3 -c "
import sys,json
for line in sys.stdin.read().splitlines():
    if line.startswith('data: '):
        d=json.loads(line[6:])
        if 'error' in d: print('RPC ERROR:',json.dumps(d['error'],ensure_ascii=False)); break
        r=d.get('result',{})
        if r.get('isError'): print('[tool error]')
        for c in r.get('content',[]): print(c.get('text',''))
        break
else: print('NO_DATA_LINE')
"
SHEOF
chmod 700 "$WORKDIR/mcp.sh"

echo "[6/6] 验证 get_account..."
"$WORKDIR/mcp.sh" get_account '{}' | head -3
echo
echo "完成。之后所有调用用: $WORKDIR/mcp.sh <tool_name> '<json>'"
