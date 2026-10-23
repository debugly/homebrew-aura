cask "aura" do
  version "0.10.10"
  sha256 "fd4c873e740723b58bcd6a8bd909ad76c1b4eee3c528a411fdee1a493591ea32"

  url "https://github.com/debugly/fsplayer/releases/download/Aura-macos-#{version}/Aura-macos-#{version}.zip"
  name "Aura"
  desc "Multi-platform video player based on ijkplayer"
  homepage "https://github.com/debugly/fsplayer"

  app "AuraPlayer.app"

  zap trash: [
    "~/Library/Preferences/cn.debugly.AuraPlayer.plist",
    "~/Library/Caches/cn.debugly.AuraPlayer",
    "~/Library/Application Support/CrashReporter/AuraPlayer*",
  ]
end
