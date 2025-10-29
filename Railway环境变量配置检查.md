# 🔍 Railway 环境变量配置检查清单

## 主公，502错误的根本原因

**应用无法启动**，最可能的原因是：

### ✅ 已修复的问题
1. ✅ Dockerfile 现在会在启动前检查环境变量
2. ✅ 如果环境变量未设置，会在部署日志中显示明确的错误信息

### ⚠️ 需要检查的内容

**请到 Railway 的 Deploy Logs 中查看是否有以下错误：**
```
ERROR: REACT_APP_API_URL environment variable is not set!
```
或
```
ERROR: REACT_APP_PROXY_PUBLIC_BASE environment variable is not set!
```

---

## 📋 环境变量值配置检查

### 前端服务（linkbot-ai-frontend）

**请在 Railway 中检查以下环境变量的值：**

#### 1. `REACT_APP_API_URL`
**应该是：** 后端Go服务的完整API地址
**示例：** `https://linkbot-ai-production.up.railway.app/api`
**❌ 错误示例：** `http://localhost:8080/api` （不能是localhost）

#### 2. `REACT_APP_PROXY_PUBLIC_BASE`  
**应该是：** 后端Go服务的完整地址（用于WebSocket和OAuth）
**示例：** `https://linkbot-ai-production.up.railway.app`
**❌ 错误示例：** `http://localhost:8080` （不能是localhost）

#### 3. `PORT`
**Railway会自动设置**，应该是 `3000` 或 Railway 分配的其他端口

---

## 🔧 修复步骤

### 步骤1：查看部署日志
1. 进入 Railway 项目
2. 选择 **linkbot-ai-frontend** 服务
3. 点击 **Deployments** 标签
4. 点击最新的部署记录
5. 查看 **Deploy Logs**

### 步骤2：检查环境变量值
1. 进入 **Variables** 标签
2. 检查 `REACT_APP_API_URL` 的值：
   - ✅ 必须以 `https://` 开头
   - ✅ 应该是后端服务的完整URL + `/api`
   - ❌ 不能是 `localhost`、`127.0.0.1` 或 `http://`

3. 检查 `REACT_APP_PROXY_PUBLIC_BASE` 的值：
   - ✅ 必须以 `https://` 开头
   - ✅ 应该是后端服务的完整URL（不带 `/api`）
   - ❌ 不能是 `localhost`、`127.0.0.1` 或 `http://`

### 步骤3：修正错误的变量值

**如果变量值错误，请按以下格式修改：**

假设您的后端服务Railway地址是：`https://linkbot-ai-production.up.railway.app`

那么：
- `REACT_APP_API_URL` = `https://linkbot-ai-production.up.railway.app/api`
- `REACT_APP_PROXY_PUBLIC_BASE` = `https://linkbot-ai-production.up.railway.app`

### 步骤4：重新部署
1. 修改环境变量后，Railway会自动重新部署
2. 或者手动点击 **Redeploy**

---

## 📝 快速验证

**在Railway的Deploy Logs中应该看到：**

✅ **成功启动的日志：**
```
✅ Configuration file /etc/nginx/conf.d/default.conf test is successful
nginx: configuration file /etc/nginx/conf.d/default.conf test is successful
```

❌ **失败的错误日志：**
```
ERROR: REACT_APP_API_URL environment variable is not set!
```
或者
```
nginx: [emerg] invalid URL in proxy_pass "http://localhost:8080"
```

---

**主公，请先查看Deploy Logs，告诉我具体看到了什么错误信息！** 🎯

