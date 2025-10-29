# 构建阶段
FROM node:18-alpine as builder

WORKDIR /app

# 复制 package 文件
COPY package*.json ./

# 安装依赖（包括devDependencies，React构建需要）
RUN npm ci

# 复制源代码
COPY . .

# 构建应用
RUN npm run build

# 生产阶段
FROM nginx:alpine

ENV PORT=3000

# 复制构建产物
COPY --from=builder /app/build /usr/share/nginx/html

# 复制 nginx 配置模板
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

# 安装 envsubst（来自 gettext），用于将 $PORT 注入到 nginx 配置
RUN apk add --no-cache gettext

# 暴露端口
EXPOSE 3000

# 运行前用 envsubst 注入环境变量到 nginx 配置
# 将Railway中的REACT_APP_API_URL映射为API_BASE，REACT_APP_PROXY_PUBLIC_BASE映射为WS_BASE
# 检查环境变量是否设置，如果未设置则给出明确错误并退出
CMD ["/bin/sh", "-c", "set -e && echo '=== Starting nginx configuration ===' && echo 'PORT='\"$PORT\" && echo 'REACT_APP_API_URL='\"$REACT_APP_API_URL\" && echo 'REACT_APP_PROXY_PUBLIC_BASE='\"$REACT_APP_PROXY_PUBLIC_BASE\" && if [ -z \"$REACT_APP_API_URL\" ]; then echo 'ERROR: REACT_APP_API_URL is not set!' && exit 1; fi && if [ -z \"$REACT_APP_PROXY_PUBLIC_BASE\" ]; then echo 'ERROR: REACT_APP_PROXY_PUBLIC_BASE is not set!' && exit 1; fi && export API_BASE=\"$REACT_APP_API_URL\" && export WS_BASE=\"$REACT_APP_PROXY_PUBLIC_BASE\" && echo 'Exported: API_BASE='\"$API_BASE\" && echo 'Exported: WS_BASE='\"$WS_BASE\" && echo 'Generating nginx config from template...' && envsubst '$$PORT $$API_BASE $$WS_BASE' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && echo 'Generated nginx config:' && cat /etc/nginx/conf.d/default.conf | grep -E '(proxy_pass|listen)' && echo 'Testing nginx configuration...' && nginx -t && echo '=== Nginx configuration OK ===' && echo 'Starting nginx...' && nginx -g 'daemon off;'"]
