cask "aura" do
  version "0.10.3"
  sha256 "80cea1d09409c9a9d879f177c7b1fe7a5817685a275c5f0f2b332417fff70bce"

  url "https://github.com/debugly/fsplayer/releases/download/Aura-macos-#{version}/Aura-macos-#{version}.zip"
  name "Aura"
  desc "Multi-platform video player based on ijkplayer"
  homepage "https://github.com/debugly/fsplayer"

  app "AuraPlayer.app"

  # CI 构建的产物没有 Developer ID 签名，从浏览器/curl 下载后会带 quarantine 属性，
  # 双击直接被 Gatekeeper 拦下。装完就摘掉，省得用户再去「右键 → 打开」。
  # 改版号/校验和的 workflow 只用 sed 动上面两行，不会碰这段。
  postinstall do
    system("xattr", "-rd", "com.apple.quarantine", "/Applications/AuraPlayer.app")
  end

  zap trash: [
    "~/Library/Preferences/cn.debugly.AuraPlayer.plist",
    "~/Library/Caches/cn.debugly.AuraPlayer",
    "~/Library/Application Support/CrashReporter/AuraPlayer*",
  ]
end
