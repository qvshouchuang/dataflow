好，直接一条命令创建文档文件，你复制粘贴到 Git Bash 执行即可。

---

## 在 Git Bash 中执行

```bash
cd /e/dateflow

cat > docs/environment-setup.md << 'ENDOFFILE'
# DataFlow 项目环境搭建全流程记录

**日期**：2026年6月20日  
**目标**：在 Windows 上搭建 WSL2 + Ubuntu + Docker 环境，启动 Kafka、MySQL、Redis、ClickHouse、Zookeeper

---

## 一、创建项目目录结构

**Windows 命令行 (cmd)**：
​```cmd
cd E:\
mkdir dateflow
cd dateflow
mkdir src\main\java\com\dataflow
mkdir src\main\resources
mkdir src\test\java\com\dataflow
mkdir docs
mkdir sql
```

**作用**：创建项目骨架目录。

---

## 二、创建 .gitignore

**Git Bash**：
```bash
cd /e/dateflow
cat > .gitignore << 'EOF'
# Java
target/
*.class
*.jar
*.war
# IDE
.idea/
*.iml
.vscode/
# 日志
*.log
logs/
# 环境变量
.env
# 前端
node_modules/
/dist
# 临时文件
*.tmp
*.bak
.DS_Store
Thumbs.db
# 大数据组件临时文件
checkpoint/
derby.log
metastore_db/
# 测试
coverage/
EOF
```

**作用**：告诉 Git 忽略编译产物、IDE配置、日志等不需要版本控制的文件。

---

## 三、创建 README.md

**Git Bash**：
```bash
cat > README.md << 'EOF'
# DataFlow
批流一体电商用户行为数据中台

## 技术栈
Java 8 · Spring Boot · Kafka · Flink · ClickHouse · Redis · MySQL · Hive
EOF
```

**作用**：项目首页说明文档。

---

## 四、初始化 Git 仓库并推送

**Git Bash**：
```bash
cd /e/dateflow
git init
git config --global user.name "qvshouchuang"
git config --global user.email "qvshouchuang@163.com"
git add .
git status
git commit -m "chore: 初始化项目骨架，添加.gitignore和README"
git remote add origin https://github.com/qvshouchuang/dataflow.git
git push -u origin master
```

**作用**：
- `git init` — 把当前目录变成 Git 仓库
- `git config` — 设置提交者信息
- `git add .` — 添加所有文件到暂存区
- `git status` — 查看暂存区状态
- `git commit -m "..."` — 保存快照，`-m` 后面是提交说明
- `git remote add origin` — 关联远程 GitHub 仓库
- `git push -u origin master` — 推送到 GitHub 并绑定分支

---

## 五、生成 GitHub Token（用于身份验证）

1. 浏览器打开 https://github.com/settings/tokens
2. 点左侧 **Tokens (classic)**
3. 点 **Generate new token (classic)**
4. Note 填 `dataflow-dev`，Expiration 选 `90 days`
5. 勾选 **repo**
6. 点 **Generate token**，复制 `ghp_` 开头的字符串

**推送时使用**：
```bash
git push https://qvshouchuang:TOKEN@github.com/qvshouchuang/dataflow.git master
```

**作用**：Token 替代密码进行身份验证，因为 GitHub 已不支持密码登录。

---

## 六、安装 WSL 和 Ubuntu

**问题**：Docker Desktop 卡在启动引擎。  
**解决**：改用 WSL2 + Docker Engine。

**PowerShell（管理员）**：
```powershell
wsl --version
net start LxssManager
wsl --install -d Ubuntu-22.04
```

**作用**：
- `wsl --version` — 确认 WSL 版本（2.7.8.0）
- `net start LxssManager` — 启动 WSL 服务管理器
- `wsl --install -d Ubuntu-22.04` — 安装 Ubuntu 22.04

安装完成后创建用户 `cc` 和密码。

---

## 七、修复 WSL DNS

**问题**：`sudo apt update` 报 `Temporary failure resolving 'archive.ubuntu.com'`。

**Ubuntu 中执行**：
```bash
cd ~
sudo cp /etc/resolv.conf /etc/resolv.conf.bak
sudo rm /etc/resolv.conf
echo "nameserver 114.114.114.114" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
ping -c 2 baidu.com
sudo apt update
```

**作用**：
- `nameserver 114.114.114.114` — 换成国内公共 DNS
- `chattr +i` — 锁定文件防止被 WSL 自动覆盖
- `ping baidu.com` — 验证网络连通
- `apt update` — 更新软件源列表

---

## 八、安装 Docker Engine

**Ubuntu 中执行**：
```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo docker --version
sudo service docker start
sudo docker ps
```

**作用**：
- 安装依赖工具（ca-certificates、curl、gnupg、lsb-release）
- 添加阿里云 Docker 镜像源和 GPG 密钥
- 安装 Docker 引擎、命令行工具和 Compose 插件
- 启动 Docker 服务并验证

---

## 九、配置 Docker 镜像加速

**问题**：`docker compose up -d` 拉取镜像超时 `dial tcp ... i/o timeout`。

**Ubuntu 中执行**：
```bash
sudo nano /etc/docker/daemon.json
```

粘贴内容：
```json
{
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
```

`Ctrl+O` 保存，`Ctrl+X` 退出。

```bash
sudo service docker restart
```

**作用**：使用 DaoCloud 国内镜像站加速镜像下载。

---

## 十、复制项目到 WSL

```bash
cp -r /mnt/e/dateflow ~/dateflow
cd ~/dateflow
```

**作用**：将 Windows 上的项目复制到 WSL Ubuntu 中，避免跨文件系统性能问题。

---

## 十一、docker-compose.yml

```yaml
services:
  zookeeper:
    image: wurstmeister/zookeeper
    container_name: zookeeper
    ports:
      - "2181:2181"

  kafka:
    image: wurstmeister/kafka
    container_name: kafka
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: localhost
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    depends_on:
      - zookeeper

  mysql:
    image: mysql:8.0
    container_name: mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: data_miner
    volumes:
      - ./sql/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"

  clickhouse:
    image: clickhouse/clickhouse-server:23.3
    container_name: clickhouse
    ports:
      - "8123:8123"
      - "9000:9000"
    environment:
      CLICKHOUSE_DB: default
      CLICKHOUSE_USER: default
      CLICKHOUSE_PASSWORD: ""
```

**作用**：定义 5 个服务。`ports` 左边宿主机端口，右边容器端口。`depends_on` 控制启动顺序。`volumes` 挂载初始化脚本。

---

## 十二、MySQL 初始化 SQL

```sql
CREATE TABLE IF NOT EXISTS ods_user_behavior (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    item_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    behavior_type VARCHAR(10) NOT NULL,
    event_time DATETIME NOT NULL,
    tenant_id VARCHAR(32) DEFAULT 'shop001',
    INDEX idx_user (user_id),
    INDEX idx_event_time (event_time),
    INDEX idx_behavior (behavior_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**作用**：MySQL 启动时自动执行，创建 ODS 原始行为数据表。

---

## 十三、启动中间件

```bash
sudo docker compose up -d
sudo docker ps
```

**输出**：
```
CONTAINER ID   IMAGE                               STATUS         PORTS
7a49f1cd6b27   wurstmeister/kafka                  Up             0.0.0.0:9092->9092/tcp
eec9aaacf2d3   redis:7-alpine                      Up             0.0.0.0:6379->6379/tcp
a44f9383a8c8   mysql:8.0                           Up             0.0.0.0:3306->3306/tcp
0d682f63ce10   clickhouse/clickhouse-server:23.3   Up             0.0.0.0:8123->8123/tcp
0b2069989fb7   wurstmeister/zookeeper              Up             0.0.0.0:2181->2181/tcp
```

---

## 十四、验证服务

```bash
# 验证 MySQL
sudo docker exec -it mysql mysql -uroot -proot123 -e "SHOW TABLES;" data_miner

# 验证 ClickHouse
sudo docker exec -it clickhouse clickhouse-client -q "SELECT 1"
```

---

## 十五、创建 Kafka Topic

```bash
sudo docker exec -it kafka kafka-topics.sh --create --topic user_behavior_topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
sudo docker exec -it kafka kafka-topics.sh --list --bootstrap-server localhost:9092
```

**作用**：创建 3 分区的用户行为 Topic，Flink 从此消费数据。

---

## 十六、提交到 Git

```bash
git config --global user.name "qvshouchuang"
git config --global user.email "qvshouchuang@163.com"
git add .
git commit -m "feat: 添加 Docker Compose 配置，搭建 Kafka/MySQL/Redis/ClickHouse 环境"
git push
```

---

## 最终状态

| 组件       | 端口      | 状态      |
| ---------- | --------- | --------- |
| Zookeeper  | 2181      | ✅ Running |
| Kafka      | 9092      | ✅ Running |
| MySQL      | 3306      | ✅ Running |
| Redis      | 6379      | ✅ Running |
| ClickHouse | 8123/9000 | ✅ Running |

**GitHub**：https://github.com/qvshouchuang/dataflow

**每次启动环境**：
```bash
wsl -d Ubuntu-22.04
cd ~/dateflow
sudo service docker start
sudo docker compose up -d
```
ENDOFFILE

git add docs/environment-setup.md
git commit -m "docs: 添加环境搭建完整流程文档"
git push
```

执行完把输出发给我。
```