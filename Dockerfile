# 构建阶段
FROM node:18-alpine as builder

WORKDIR /app

# 复制 package 文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

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

# 运行前用 envsubst 注入 $PORT 到 nginx 配置
CMD ["/bin/sh", "-c", "envsubst < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
