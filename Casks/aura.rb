cask "aura" do
  # 这个 cask 故意不写死版本号：url 块在安装时才去 GitHub 查最新的 Aura-macos-* release。
  # 好处是 homebrew-aura 这个 tap 从此不用随发布更新 —— fsplayer 的 CI 也就不需要
  # 跨仓库触发这里的 workflow（GITHUB_TOKEN 跨仓库 dispatch 必然 403）。
  # 发新版只要在 fsplayer 发 Aura-macos-<version> release，brew 就能拿到。
  version :latest
  # 因为 url 每次安装时都可能不同（指向新 release），没法预先写死校验和。
  sha256 :no_check

  url do
    require "net/http"
    require "json"
    require "uri"

    api = URI("https://api.github.com/repos/debugly/fsplayer/releases?per_page=100")
    req = Net::HTTP::Get.new(api)
    req["User-Agent"] = "Homebrew"
    req["Accept"] = "application/vnd.github+json"

    res = Net::HTTP.start(api.host, api.port, use_ssl: true) { |h| h.request(req) }
    abort "::error::GitHub API returned #{res.code}" unless res.is_a?(Net::HTTPSuccess)

    rel = JSON.parse(res.body).find { |r| r["tag_name"].to_s.start_with?("Aura-macos-") }
    abort "::error::no Aura-macos-* release found on debugly/fsplayer" if rel.nil?

    asset = rel["assets"].find do |a|
      a["name"].to_s.start_with?("Aura-macos-") && a["name"].to_s.end_with?(".zip")
    end
    abort "::error::no Aura-macos-*.zip asset in #{rel["tag_name"]}" if asset.nil?

    asset["browser_download_url"]
  end

  name "Aura"
  desc "Multi-platform video player based on ijkplayer"
  homepage "https://github.com/debugly/fsplayer"

  app "AuraPlayer.app"

  # CI 构建的产物没有 Developer ID 签名，从浏览器/curl 下载后会带 quarantine 属性，
  # 双击直接被 Gatekeeper 拦下。装完就摘掉，省得用户再去「右键 → 打开」。
  postinstall do
    system("xattr", "-rd", "com.apple.quarantine", "/Applications/AuraPlayer.app")
  end

  zap trash: [
    "~/Library/Preferences/cn.debugly.AuraPlayer.plist",
    "~/Library/Caches/cn.debugly.AuraPlayer",
    "~/Library/Application Support/CrashReporter/AuraPlayer*",
  ]
end
