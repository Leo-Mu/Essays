# WebIDE 部署方案

Gitpod 是一个基于容器的开发平台，基于 visual studio code 的在线IDE，它可以快速的启动一个适用于大多数流行语言的开发环境，并且可以很顺畅的进行开发。

Gitpod 可以使用任何兼容 GitHub GitLab 或 Bitbucket 协议的 Git 提供程序作为身份验证和 Git 存储库的后端，学生可以一键完成 Gitpod 环境的启动并开发，也可以很方便地使用 Git 提供程序进行提交和下载。

Gitpod 使教学团队能够将他们的教学环境描述为简单的配置代码，并完全在云中为每个新任务启动可配置的全新开发环境。

## 准备

参考 [Configure the ingress to your Gitpod installation](https://www.gitpod.io/docs/self-hosted/latest/configuration/ingress)

要求：
- 一个域名（一级二级等域名均可）
- 至少一个公网 IP （仅内网部署可以不是必须）

### 配置 DNS 

将主域名和子域名 ```*.``` 和 ```*.ws.``` 的 A 记录配置到 IP ，例如，针对一级域名为 ```your-domain.com .your-domain.com .ws.your-domain.com```，针对二级域名为 ```gitpod.your-domain.com .gitpod.your-domain.com .ws.gitpod.your-domain.com```

### 获取 HTTPS 证书

1. 安装 [certbot](https://certbot.eff.org/)
2. 修改占位符并运行脚本[certbot.sh](./certbot.sh)
``` bash
export DOMAIN=your-domain.com
export EMAIL=your@email.here
export WORKDIR=$PWD/letsencrypt

certbot certonly \
    --config-dir $WORKDIR/config \
    --work-dir $WORKDIR/work \
    --logs-dir $WORKDIR/logs \
    --manual \
    --preferred-challenges=dns \
    --email $EMAIL \
    --server https://acme-v02.api.letsencrypt.org/directory \
    --agree-tos \
    -d *.ws.$DOMAIN \
    -d *.$DOMAIN \
    -d $DOMAIN
```
3. 将输出的文件夹记录，需将其中的文件复制到相应位置。

## docker 部署方案（简单快捷的试验部署）

参考 [Running Gitpod as a Docker container](https://github.com/gitpod-io/gitpod/tree/main/contrib/docker)

1. 将证书文件夹中的 ```fullchain.pem``` 复制为 ```./certs/tls.crt``` ，将 ```privkey.pem``` 复制为 ```./certs/tls.key```
2. 创建 .env 文件 ``` DOMAIN=your-domain.example.com ```
3. 创建 [docker-compose.yaml](https://github.com/gitpod-io/gitpod/blob/main/contrib/docker/examples/gitpod/docker-compose.yaml) 文件
```Dockerfile
version: '3'
services:

  gitpod:
    image: gcr.io/gitpod-io/self-hosted/gitpod-k3s:${VERSION:-latest}
    privileged: true
    volumes:
      - ./values:/values
      - ./certs:/certs
    ports:
      - 443:443
      - 80:80
    environment:
      - DOMAIN=${DOMAIN}
```
4. 运行 ``` docker-compose up ```

## Kubernetes 部署方案

参考 [Install Gitpod Self-Hosted on Kubernetes
](https://www.gitpod.io/docs/self-hosted/latest/installation/on-kubernetes)

### 要求

- Kubernetes ≥ 1.18
- containerd ≥ 1.2
- helm ≥ 3.6
- Calico

### Https 证书相关
1. 将证书文件夹中的内容复制到 ``` secrets/https-certificates/ ```
2. 使用命令生成 dhparams.pem 文件 ``` openssl dhparam -out secrets/https-certificates/dhparams.pem 2048 ```

### 启动

1. 创建 ``` values.custom.yaml ```，其中的 key 使用 ``` openssl rand -hex 20 ``` 生成。 
```yaml
rabbitmq:
  auth:
    username: your-rabbitmq-user
    password: your-secret-rabbitmq-password
minio:
  accessKey: your-random-access-key
  secretKey: your-random-secret-key
```
2. 运行
``` bash 
helm repo add gitpod.io https://charts.gitpod.io

helm repo update

helm install -f values.custom.yaml gitpod gitpod.io/gitpod --version=0.10.0

kubectl create secret generic https-certificates --from-file=secrets/https-certificates

helm upgrade --install -f values.custom.yaml gitpod gitpod.io/gitpod --version=0.10.0

```
3. 通过  ``` kubectl get pods ``` 检查所有 pods 都处于 ```RUNNING``` 状态

## 运行后配置

访问 ```https://<your-domain.com>``` 即可开始初始化配置。任何兼容 GitHub GitLab 或 Bitbucket 协议的 Git 提供程序都可以作为认证器。推荐部署一个私有的校内 GitLab 来作为学生的认证和存储库管理软件，从而方便地进行环境分发和作业提交。
