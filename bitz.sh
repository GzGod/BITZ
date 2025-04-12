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

# 4️⃣ 安装 expect（如未安装）
if ! command -v expect &>/dev/null; then
  echo "🔧 未检测到 expect，正在安装..."
  sudo apt update && sudo apt install -y expect
else
  echo "✅ expect 已安装"
fi

# 5️⃣ 自动输入密码生成 keypair
mkdir -p "$HOME/.config/solana"

expect <<EOF
spawn solana-keygen new --force
expect "Enter same passphrase again:"
send "$password\r"
expect "Enter same passphrase again:"
send "$password\r"
expect eof
EOF

# 6️⃣ 输出私钥内容
echo ""
echo "✅ 你的 Solana 私钥已生成如下，请复制导入 Backpack 钱包："
echo ""
cat $HOME/.config/solana/id.json
echo ""
echo "⚠️ 这是一组数组形式的私钥，请妥善保存并导入 bp 钱包"

# 7️⃣ 提示是否继续（默认 y）
read -p "是否已向该钱包的 Eclipse 网络转入 0.005 ETH？[Y/n]: " confirm
confirm=${confirm:-y}

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  echo "🚀 开始安装并部署 bitz..."

  # 安装 bitz
  cargo install bitz

  # 设置 RPC
  solana config set --url https://mainnetbeta-rpc.eclipse.xyz/

  # 直接运行 bitz collect（前台模式）
  echo ""
  echo "🚀 正在运行 bitz collect..."
  echo "📌 如果需要后台运行，可按 Ctrl+C 后用 pm2/screen/tmux 等工具手动处理"
  echo ""

  bitz collect

else
  echo "❌ 已取消后续操作，退出。"
fi
