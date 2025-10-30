import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { message } from 'antd';
import { ApiResponse } from '../types';

// 创建 axios 实例
// 使用相对路径，让 nginx 代理到后端
const api: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器
api.interceptors.request.use(
  (config) => {
    // 添加认证 token
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    // 添加租户 ID
    const tenantId = localStorage.getItem('tenantId');
    if (tenantId) {
      config.headers['X-Tenant-ID'] = tenantId;
    }
    
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
api.interceptors.response.use(
  (response: AxiosResponse<ApiResponse>) => {
    const { data } = response;
    
    // 放宽判断：仅当存在 success 且明确为 false 时，才视为业务失败
    if (Object.prototype.hasOwnProperty.call(data || {}, 'success') && (data as any).success === false) {
      const msg = (data as any).message || '请求失败';
      message.error(msg);
      return Promise.reject(new Error(msg));
    }
    
    return response;
  },
  (error) => {
    // 处理 HTTP 错误
    if (error.response) {
      const { status, data } = error.response as any;
      
      switch (status) {
        case 401:
          message.error('登录已过期，请重新登录');
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          window.location.href = '/login';
          break;
        case 403:
          message.error('权限不足');
          break;
        case 404:
          message.error('请求的资源不存在');
          break;
        case 500:
          message.error('服务器内部错误');
          break;
        default:
          message.error((data && data.message) || '请求失败');
      }
    } else if (error.request) {
      message.error('网络连接失败，请检查网络');
    } else {
      message.error('请求配置错误');
    }
    
    return Promise.reject(error);
  }
);

export default api;
