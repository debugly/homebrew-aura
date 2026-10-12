cask "aura" do
  version :latest
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

  caveats <<~EOS
    Aura 构建自 CI，没有 Developer ID 签名，Gatekeeper 可能会拦一下。
    如果双击打不开，先执行：
      xattr -rd com.apple.quarantine /Applications/AuraPlayer.app
  EOS

  app "AuraPlayer.app"
end
