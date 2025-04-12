#!/bin/bash

# 1️⃣ 输入密码变量
read -s -p "请输入你的 Solana 钱包密码（用于生成 keypair）: " password
echo ""

# 2️⃣ 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# 3️⃣ 安装 Solana
curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# 4️⃣ 自动输入密码生成 keypair（使用 expect）
if ! command -v expect &>/dev/null; then
  sudo apt update && sudo apt install -y expect
fi

mkdir -p "$HOME/.config/solana"

expect <<EOF
spawn solana-keygen new --force
expect "Enter same passphrase again:"
send "$password\r"
expect "Enter same passphrase again:"
send "$password\r"
expect eof
EOF

# 5️⃣ 输出私钥内容
echo ""
echo "✅ 你的 Solana 私钥已生成如下，请复制导入 Backpack 钱包："
echo ""
cat $HOME/.config/solana/id.json
echo ""
echo "⚠️ 这是一组数组形式的私钥，请妥善保存并导入 bp 钱包"

# 6️⃣ 提示是否继续
read -p "是否已向该钱包的 Eclipse 网络转入 0.005 ETH？[y/N]: " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  echo "🚀 开始安装并部署 bitz..."
  
  # 安装 bitz
  cargo install bitz

  # 设置 RPC
  solana config set --url https://mainnetbeta-rpc.eclipse.xyz/

  # 安装 screen（如未安装）
  if ! command -v screen &>/dev/null; then
    sudo apt update && sudo apt install -y screen
  fi

  # 启动 bitz collect
  screen -S eclipse -dm bash -c "bitz collect"

  echo "✅ bitz collect 已在后台 screen 中运行，可用以下命令查看："
  echo "screen -r eclipse"

else
  echo "❌ 已取消后续操作，退出。"
fi
