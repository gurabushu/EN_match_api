require 'net/http'
require 'json'
require 'uri'
require 'timeout'
require 'action_view'

class GeminiService
  def self.analyze_compatibility(user1, user2)
    # APIキーが設定されているかチェック
    api_key = ENV["GEMINI_API_KEY"]
    Rails.logger.debug "🔍 GEMINI_API_KEY present: #{api_key.present?}"
    
    if api_key.blank?
      Rails.logger.warn "⚠️ GEMINI_API_KEY environment variable is not set, using mock response"
      return generate_mock_compatibility(user1, user2)
    end

    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent")
    headers = { "Content-Type" => "application/json" }

    # プロフィール情報を安全に取得
    user1_description = user1.description.present? ? sanitize(user1.description) : "自己紹介なし"
    user2_description = user2.description.present? ? sanitize(user2.description) : "自己紹介なし"
    
    # 安全なエンコーディング変換
    user1_skills = if user1.github.present?
                     "GitHub: #{safe_encode(user1.github)}"
                   else
                     "GitHub情報なし"
                   end
    user2_skills = if user2.github.present?
                     "GitHub: #{safe_encode(user2.github)}"
                   else
                     "GitHub情報なし"
                   end
    
    user1_name = safe_encode(user1.name)
    user2_name = safe_encode(user2.name)

    prompt_text = "エンジニア専用マッチングアプリでの相性診断を行ってください。
以下の2人のプロフィール情報をもとに、技術的な相性やキャリア観の一致度を100点満点で評価してください。

【ユーザー1: #{user1_name}】
自己紹介: #{user1_description}
技術情報: #{user1_skills}
年齢: #{user1.age.present? ? "#{user1.age}歳" : "非公開"}

【ユーザー2: #{user2_name}】
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
[気をつけるべき点があれば]"

    prompt = safe_encode(prompt_text)

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
        # レスポンスボディを安全にエンコード
        response_body = safe_encode(response.body)
        result = JSON.parse(response_body)
        
        if result["candidates"] && result["candidates"].first && result["candidates"].first["content"]
          text_result = result["candidates"].first["content"]["parts"].first["text"]
          Rails.logger.info "✅ Gemini API Success: Generated compatibility analysis"
          # UTF-8エンコーディングを確保
          return safe_encode(text_result)
        else
          Rails.logger.warn "⚠️ Gemini API: No valid content in response"
          return "診断結果の生成に失敗しました。APIレスポンスに問題があります。"
        end
      else
        Rails.logger.error "❌ Gemini API Error: Status #{response.code}, Body: #{response.body}"
        
        # API制限やサーバー問題の場合はモック診断にフォールバック
        fallback_codes = ["503", "429", "500", "502", "504"]
        if fallback_codes.include?(response.code)
          error_type = case response.code
                      when "503" then "サーバー過負荷"
                      when "429" then "レート制限"
                      when "500" then "内部サーバーエラー"
                      when "502" then "ゲートウェイエラー"
                      when "504" then "ゲートウェイタイムアウト"
                      else "サーバーエラー"
                      end
          
          Rails.logger.warn "⚠️ Gemini API #{error_type}, falling back to mock analysis"
          return generate_mock_compatibility(user1, user2)
        end
        
        # その他のエラーもモック診断にフォールバック
        Rails.logger.warn "⚠️ Gemini API error, falling back to mock analysis"
        return generate_mock_compatibility(user1, user2)
      end
      
    rescue Timeout::Error, Net::ReadTimeout, Net::OpenTimeout => e
      Rails.logger.warn "⚠️ API timeout, using mock analysis"
      return generate_mock_compatibility(user1, user2)
    rescue JSON::ParserError => e
      Rails.logger.warn "⚠️ JSON parse error, using mock analysis"
      return generate_mock_compatibility(user1, user2)
    rescue Encoding::CompatibilityError => e
      Rails.logger.warn "⚠️ Encoding error, using mock analysis"
      return generate_mock_compatibility(user1, user2)
    rescue => e
      Rails.logger.warn "⚠️ Unexpected error, using mock analysis: #{e.message}"
      return generate_mock_compatibility(user1, user2)
    end
  end

  private

  def self.sanitize(text)
    return "" if text.blank?
    
    begin
      # 文字列を UTF-8 に変換
      text_str = text.to_s
      if text_str.encoding != Encoding::UTF_8
        text_str = text_str.force_encoding('UTF-8')
      end
      
      # 無効な文字を置換
      text_str = text_str.scrub('?')
      
      # HTMLタグを除去し、改行を保持
      sanitized_text = ActionView::Base.full_sanitizer.sanitize(text_str).strip
      sanitized_text.force_encoding('UTF-8')
    rescue Encoding::CompatibilityError, Encoding::InvalidByteSequenceError => e
      Rails.logger.warn "⚠️ Encoding error in sanitize: #{e.message}"
      # フォールバック: 無効な文字を除去
      text.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').strip
    end
  end

  def self.safe_encode(text)
    return "" if text.blank?
    
    begin
      # まず文字列に変換
      str = text.to_s
      
      # 既にUTF-8の場合はそのまま返す
      return str if str.encoding == Encoding::UTF_8 && str.valid_encoding?
      
      # UTF-8に変換を試行
      if str.encoding == Encoding::ASCII_8BIT
        # バイナリデータの場合、UTF-8として解釈を試行
        str = str.force_encoding('UTF-8')
      end
      
      # 無効な文字をクリーンアップ
      str.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    rescue Encoding::CompatibilityError, Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError => e
      Rails.logger.warn "⚠️ Safe encoding failed: #{e.message}"
      # 最後の手段：強制的にUTF-8に変換し、無効な文字を除去
      text.to_s.force_encoding('UTF-8').scrub('?')
    rescue => e
      Rails.logger.error "❌ Unexpected encoding error: #{e.message}"
      # 緊急フォールバック
      text.to_s.inspect[1..-2] # 文字列リテラル表現から引用符を除去
    end
  end

  def self.generate_mock_compatibility(user1, user2)
    Rails.logger.debug "🎭 Generating mock compatibility analysis"
    
    # 基本的な相性計算のロジック
    score = calculate_basic_compatibility(user1, user2)
    
    user1_description = user1.description.present? ? user1.description : "自己紹介なし"
    user2_description = user2.description.present? ? user2.description : "自己紹介なし"

    result_text = "🎯 相性スコア: #{score}点

📊 詳細評価:
・技術相性: #{get_tech_compatibility_comment(user1, user2)}
・キャリア相性: #{get_career_compatibility_comment(user1, user2)}
・コミュニケーション: #{get_communication_comment(user1, user2)}

💡 おすすめポイント:
#{get_positive_points(user1, user2)}

⚠️ 注意点:
#{get_attention_points(user1, user2)}

※ この診断結果はAI相性診断機能のデモ版です。"

    Rails.logger.debug "🎭 Mock result generated successfully"
    safe_encode(result_text)
  end

  def self.calculate_basic_compatibility(user1, user2)
    score = 60 # ベーススコア（最低スコアを60点に引き上げ）
    
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
    comment = if user1.github.present? && user2.github.present?
                "両方がGitHubアカウントを設定しており、技術への関心が高いと推測されます"
              elsif user1.github.present? || user2.github.present?
                "片方がGitHubアカウントを設定しており、技術レベルに差がある可能性があります"
              else
                "GitHub情報が不足しているため、技術相性の判断が困難です"
              end
    safe_encode(comment)
  end

  def self.get_career_compatibility_comment(user1, user2)
    age_diff = if user1.age.present? && user2.age.present?
                 (user1.age - user2.age).abs
               else
                 nil
               end

    comment = if age_diff && age_diff <= 3
                "年齢が近く、似たようなキャリアステージにあると考えられます"
              elsif age_diff && age_diff > 10
                "年齢差があるため、メンター・メンティー関係が築けるかもしれません"
              else
                "キャリア情報が限られているため、詳細な分析は困難です"
              end
    safe_encode(comment)
  end

  def self.get_communication_comment(user1, user2)
    desc1_length = user1.description&.length || 0
    desc2_length = user2.description&.length || 0

    comment = if desc1_length > 100 && desc2_length > 100
                "両方とも詳細な自己紹介を書いており、コミュニケーション意欲が高いと思われます"
              elsif desc1_length > 50 || desc2_length > 50
                "適度な自己紹介があり、基本的なコミュニケーションは期待できます"
              else
                "自己紹介が簡潔なため、コミュニケーションスタイルの把握が困難です"
              end
    safe_encode(comment)
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

    result = points.any? ? points.join("、") : "お互いを知ることで新しい発見がありそうです"
    safe_encode(result)
  end

  def self.get_attention_points(user1, user2)
    points = []
    
    if user1.description.blank? || user2.description.blank?
      points << "自己紹介が不足しているため、まずはお互いをよく知ることから始めましょう"
    end

    if user1.github.blank? && user2.github.blank?
      points << "技術的なバックグラウンドが不明なため、スキルレベルの確認が必要かもしれません"
    end

    result = points.any? ? points.join("、") : "特に大きな懸念点はありません。積極的にコミュニケーションを取ってみてください"
    safe_encode(result)
  end
end