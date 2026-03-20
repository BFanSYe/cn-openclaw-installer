# cn-openclaw-installer

一个面向 **Debian 12** 的 **OpenClaw 基础安装器**。

目标很简单：

- 把 OpenClaw 基础环境安装好
- 让用户只用一行命令就能开始部署
- 不掺杂飞书、模型、密钥等业务配置

---

## 功能
安装脚本会完成以下内容：

- 基础依赖安装
- swap 配置（默认 2G，如系统没有 swapfile）
- Node.js 22 安装
- npm / pnpm 国内镜像配置
- GitHub 拉包 SSH -> HTTPS 修正
- OpenClaw 安装
- Gateway 安装与启动
- `gateway.mode=local`
- 可选 OOM 保护（默认关闭）

---

## 不包含
这个仓库只负责 **OpenClaw 基础部署**，不包含：

- 飞书配置
- 模型 provider 配置
- 火山 / OpenAI / 其他 API 接入
- 任何账号、密钥、业务参数

也就是说，这个仓库适合拿来做：

- 新机器基础初始化
- 公网一行安装
- 后续再接自己的 channel / model / workflow

---

## 适用环境
- Debian 12
- root 用户
- 推荐最低配置：2核 2G

---

## 一行安装
```bash
curl -fsSL https://raw.githubusercontent.com/BFanSYe/cn-openclaw-installer/main/install-openclaw-base.sh | bash
```

---

## 可选：2G 机器启用 OOM 保护
如果你的机器是 **2G 内存**，建议加上：

```bash
curl -fsSL https://raw.githubusercontent.com/BFanSYe/cn-openclaw-installer/main/install-openclaw-base.sh | GATEWAY_HEAP_MB=1024 bash
```

作用是给 Gateway 增加：

```bash
NODE_OPTIONS=--max-old-space-size=1024
```

默认情况下，这个 OOM 保护是关闭的。

---

## 可选参数
可以通过环境变量覆盖默认值：

```bash
curl -fsSL https://raw.githubusercontent.com/BFanSYe/cn-openclaw-installer/main/install-openclaw-base.sh | \
OPENCLAW_VERSION=latest \
NODE_MAJOR=22 \
SWAP_SIZE_MB=2048 \
GATEWAY_HEAP_MB=1024 \
GATEWAY_PORT=18789 \
bash
```

### 默认值
- `OPENCLAW_VERSION=latest`
- `NODE_MAJOR=22`
- `SWAP_SIZE_MB=2048`
- `GATEWAY_HEAP_MB=`（默认不启用）
- `GATEWAY_PORT=18789`

---

## 安装完成后
脚本会输出：

- `openclaw --version`
- `openclaw gateway status`
- Dashboard 地址：
  - `http://127.0.0.1:18789/`

如果你要从本地电脑访问 Dashboard：

```bash
ssh -L 18789:127.0.0.1:18789 root@你的服务器IP
```

然后浏览器打开：

```text
http://127.0.0.1:18789/
```

---

## 推荐使用方式
建议分两步：

### 第一步：先装基础环境
```bash
curl -fsSL https://raw.githubusercontent.com/BFanSYe/cn-openclaw-installer/main/install-openclaw-base.sh | bash
```

### 第二步：再单独配置业务能力
例如：
- 飞书
- 模型 provider
- 其他 channel
- 插件和技能

这样结构更干净，也更适合公开分发。

---

## 安全说明
为了安全起见，这个基础安装器：

- 不内置任何密钥
- 不写死任何账号信息
- 不默认接入第三方模型
- 不默认接入飞书或其他通信渠道

所有业务接入建议在基础安装完成后单独处理。

---

## License
MIT
