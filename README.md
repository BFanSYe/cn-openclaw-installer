# cn-openclaw-installer

一个用于 **Debian 12** 的 OpenClaw 基础安装脚本。

## 功能
执行后一键完成：

- 基础依赖安装
- swap 配置
- Node.js 22 安装
- npm / pnpm 国内镜像配置
- GitHub SSH -> HTTPS 修正
- OpenClaw 安装
- Gateway 安装与启动
- `gateway.mode=local`
- 可选 OOM 保护（默认关闭）

## 不包含
这个安装器只做 **OpenClaw 基础部署**，不包含：

- 飞书配置
- 模型配置
- 火山 / OpenAI / 其他 provider 配置
- 任何账号、密钥、业务参数

## 适用环境
- Debian 12
- root 用户
- 推荐最低配置：2核 2G

## 一行安装
```bash
curl -fsSL https://raw.githubusercontent.com/BFanSYe/cn-openclaw-installer/main/install-openclaw-base.sh | bash
```

## 可选：2G 机器启用 OOM 保护
```bash
curl -fsSL https://raw.githubusercontent.com/BFanSYe/cn-openclaw-installer/main/install-openclaw-base.sh | GATEWAY_HEAP_MB=1024 bash
```

## 可选参数
可通过环境变量覆盖默认值：

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

## 安装完成后
脚本会输出：

- `openclaw --version`
- `openclaw gateway status`
- Dashboard 本地地址：
  - `http://127.0.0.1:18789/`

如果你要从本地电脑访问 Dashboard：

```bash
ssh -L 18789:127.0.0.1:18789 root@你的服务器IP
```

然后浏览器打开：

```text
http://127.0.0.1:18789/
```

## 后续配置
基础环境安装完成后，你可以再单独配置：

- 飞书
- 模型 provider
- 其他 channel
- 插件与技能

## 说明
为了安全起见，这个基础安装器不内置任何密钥或业务配置。
所有后续接入应在安装完成后分步执行。
