require 'net/http'
require 'json'
require 'uri'
require 'action_view'

class GeminiService
  def self.analyze_compatibility(user1, user2)
    # APIキーが設定されているかチェック
    api_key = ENV["GEMINI_API_KEY"]
    if api_key.blank?
      Rails.logger.warn "⚠️ GEMINI_API_KEY environment variable is not set, using mock response"
      return generate_mock_compatibility(user1, user2)
    end

    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent")
    headers = { "Content-Type" => "application/json" }

    # プロフィール情報を安全に取得
    user1_description = user1.description.present? ? sanitize(user1.description) : "自己紹介なし"
    user2_description = user2.description.present? ? sanitize(user2.description) : "自己紹介なし"
    user1_skills = user1.github.present? ? "GitHub: #{user1.github}" : "GitHub情報なし"
    user2_skills = user2.github.present? ? "GitHub: #{user2.github}" : "GitHub情報なし"

    prompt = <<~PROMPT
      エンジニア専用マッチングアプリでの相性診断を行ってください。
      以下の2人のプロフィール情報をもとに、技術的な相性やキャリア観の一致度を100点満点で評価してください。

      【ユーザー1: #{user1.name}】
      自己紹介: #{user1_description}
      技術情報: #{user1_skills}
      年齢: #{user1.age.present? ? "#{user1.age}歳" : "非公開"}

      【ユーザー2: #{user2.name}】
      自己紹介: #{user2_description}
      技術情報: #{user2_skills}
      年齢: #{user2.age.present? ? "#{user2.age}歳" : "非公開"}

      以下の観点で評価してください：
      1. 技術スキルの相性
      2. キャリア目標の一致度
      3. コミュニケーションスタイル
      4. プロジェクトへの取り組み方

      出力フォーマット：
      🎯 相性スコア: [0-100点]点

      📊 詳細評価:
      ・技術相性: [評価とコメント]
      ・キャリア相性: [評価とコメント]
      ・コミュニケーション: [評価とコメント]

      💡 おすすめポイント:
      [この2人が一緒に働く/学ぶ上でのポジティブな点]

      ⚠️ 注意点:
      [気をつけるべき点があれば]
    PROMPT

    body = {
      contents: [
        { parts: [{ text: prompt }] }
      ],
      generationConfig: {
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024
      }
    }

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      http.open_timeout = 10
      
      request = Net::HTTP::Post.new(uri.request_uri, headers.merge({ "x-goog-api-key" => api_key }))
      request.body = body.to_json
      
      response = http.request(request)
      Rails.logger.debug "🟡 Gemini API Response Status: #{response.code}"
      Rails.logger.debug "🟡 Gemini API Response Body: #{response.body}"
      
      if response.code == "200"
        result = JSON.parse(response.body)
        
        if result["candidates"] && result["candidates"].first && result["candidates"].first["content"]
          text_result = result["candidates"].first["content"]["parts"].first["text"]
          Rails.logger.info "✅ Gemini API Success: Generated compatibility analysis"
          return text_result
        else
          Rails.logger.warn "⚠️ Gemini API: No valid content in response"
          return "診断結果の生成に失敗しました。APIレスポンスに問題があります。"
        end
      else
        Rails.logger.error "❌ Gemini API Error: Status #{response.code}, Body: #{response.body}"
        return "API呼び出しエラーが発生しました（Status: #{response.code}）。しばらく時間をおいて再度お試しください。"
      end
      
    rescue Net::TimeoutError => e
      Rails.logger.error "❌ Gemini API Timeout: #{e.message}"
      return "API呼び出しがタイムアウトしました。しばらく時間をおいて再度お試しください。"
    rescue JSON::ParserError => e
      Rails.logger.error "❌ Gemini API JSON Parse Error: #{e.message}"
      return "APIレスポンスの解析に失敗しました。"
    rescue => e
      Rails.logger.error "❌ Gemini API Unexpected Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return "予期せぬエラーが発生しました。システム管理者にお問い合わせください。"
    end
  end

  private

  def self.sanitize(text)
    return "" if text.blank?
    # HTMLタグを除去し、改行を保持
    ActionView::Base.full_sanitizer.sanitize(text).strip
  end

  def self.generate_mock_compatibility(user1, user2)
    # 基本的な相性計算のロジック
    score = calculate_basic_compatibility(user1, user2)
    
    user1_description = user1.description.present? ? user1.description : "自己紹介なし"
    user2_description = user2.description.present? ? user2.description : "自己紹介なし"

    <<~RESULT
🎯 相性スコア: #{score}点

📊 詳細評価:
・技術相性: #{get_tech_compatibility_comment(user1, user2)}
・キャリア相性: #{get_career_compatibility_comment(user1, user2)}
・コミュニケーション: #{get_communication_comment(user1, user2)}

💡 おすすめポイント:
#{get_positive_points(user1, user2)}

⚠️ 注意点:
#{get_attention_points(user1, user2)}

※ この診断結果はモック版です。より詳細な分析にはGemini APIキーの設定が必要です。
    RESULT
  end

  def self.calculate_basic_compatibility(user1, user2)
    score = 50 # ベーススコア
    
    # 年齢差による調整
    if user1.age.present? && user2.age.present?
      age_diff = (user1.age - user2.age).abs
      score += case age_diff
               when 0..2 then 20
               when 3..5 then 15
               when 6..10 then 10
               else 5
               end
    end

    # 自己紹介文の長さによる調整
    if user1.description.present? && user2.description.present?
      score += 15
    elsif user1.description.present? || user2.description.present?
      score += 8
    end

    # GitHubアカウントの有無による調整
    if user1.github.present? && user2.github.present?
      score += 10
    elsif user1.github.present? || user2.github.present?
      score += 5
    end

    # スコアを100点満点に調整
    [score, 100].min
  end

  def self.get_tech_compatibility_comment(user1, user2)
    if user1.github.present? && user2.github.present?
      "両方がGitHubアカウントを設定しており、技術への関心が高いと推測されます"
    elsif user1.github.present? || user2.github.present?
      "片方がGitHubアカウントを設定しており、技術レベルに差がある可能性があります"
    else
      "GitHub情報が不足しているため、技術相性の判断が困難です"
    end
  end

  def self.get_career_compatibility_comment(user1, user2)
    age_diff = if user1.age.present? && user2.age.present?
                 (user1.age - user2.age).abs
               else
                 nil
               end

    if age_diff && age_diff <= 3
      "年齢が近く、似たようなキャリアステージにあると考えられます"
    elsif age_diff && age_diff > 10
      "年齢差があるため、メンター・メンティー関係が築けるかもしれません"
    else
      "キャリア情報が限られているため、詳細な分析は困難です"
    end
  end

  def self.get_communication_comment(user1, user2)
    desc1_length = user1.description&.length || 0
    desc2_length = user2.description&.length || 0

    if desc1_length > 100 && desc2_length > 100
      "両方とも詳細な自己紹介を書いており、コミュニケーション意欲が高いと思われます"
    elsif desc1_length > 50 || desc2_length > 50
      "適度な自己紹介があり、基本的なコミュニケーションは期待できます"
    else
      "自己紹介が簡潔なため、コミュニケーションスタイルの把握が困難です"
    end
  end

  def self.get_positive_points(user1, user2)
    points = []
    
    if user1.github.present? && user2.github.present?
      points << "技術的な話題で盛り上がれる可能性が高い"
    end
    
    if user1.description.present? && user2.description.present?
      points << "お互いの価値観や目標を理解しやすい"
    end

    age_diff = if user1.age.present? && user2.age.present?
                 (user1.age - user2.age).abs
               else
                 nil
               end

    if age_diff && age_diff <= 5
      points << "近い世代として共通の話題が多そう"
    end

    points.any? ? points.join("、") : "お互いを知ることで新しい発見がありそうです"
  end

  def self.get_attention_points(user1, user2)
    points = []
    
    if user1.description.blank? || user2.description.blank?
      points << "自己紹介が不足しているため、まずはお互いをよく知ることから始めましょう"
    end

    if user1.github.blank? && user2.github.blank?
      points << "技術的なバックグラウンドが不明なため、スキルレベルの確認が必要かもしれません"
    end

    points.any? ? points.join("、") : "特に大きな懸念点はありません。積極的にコミュニケーションを取ってみてください"
  end
end