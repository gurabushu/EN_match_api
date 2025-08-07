require 'net/http'
require 'json'
require 'uri'
require 'action_view'                      # ←追加
include ActionView::Helpers::SanitizeHelper # ←追加

class GeminiService
  def self.analyze_compatibility(user1, user2)
    uri = URI("https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent")
    headers = { "Content-Type" => "application/json" }

    prompt = <<~PROMPT
      以下の2人の自己紹介文をもとに、相性を100点満点で評価し、簡潔な理由を添えてください。

      ユーザーA: #{sanitize(user1.description)}
      ユーザーB: #{sanitize(user2.description)}

      出力フォーマット:
      相性スコア: [数字]
      コメント: [理由]
    PROMPT

    body = {
      contents: [
        { parts: [{ text: prompt }] }
      ]
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, headers.merge({ "x-goog-api-key" => ENV["GEMINI_API_KEY"] }))
    request.body = body.to_json
    response = http.request(request)
    Rails.logger.debug "🟡 Gemini API Response Body: #{response.body}"
    result = JSON.parse(response.body)

    if result["candidates"] && result["candidates"].first
      result["candidates"].first["content"]["parts"].first["text"]
    else
      "診断結果を取得できませんでした。"
    end
  rescue => e
    Rails.logger.error "❌ Gemini API Error: #{e.message}"
    "診断結果を取得できませんでした。"
  end

end