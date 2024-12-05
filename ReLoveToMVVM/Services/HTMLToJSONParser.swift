import Foundation

struct HTMLToJSONParser {
    /// 從 HTML 中提取可能的 JSON 內容
    /// - Parameter htmlString: 包含 JSON 的 HTML 字串
    /// - Returns: 解析後的 JSON 數據
    static func extractJSONFromHTML(_ htmlString: String) -> [String: Any]? {
        // 更廣泛的 JSON 模式匹配
        let jsonPatterns = [
            "\\{[^{}]*\\}", // 基本 JSON 對象
            "\\{.*?\\}", // 非貪婪匹配
            "\\{[\\s\\S]*?\\}" // 跨行匹配
        ]
        
        for pattern in jsonPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
                let nsString = htmlString as NSString
                let matches = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: nsString.length))
                
                // 找到第一個匹配的 JSON 字串
                for match in matches {
                    let jsonString = nsString.substring(with: match.range)
                    
                    // 將找到的 JSON 字串轉換為字典
                    if let jsonData = jsonString.data(using: .utf8),
                       let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        // 驗證 JSON 的有效性
                        if !jsonObject.isEmpty {
                            return jsonObject
                        }
                    }
                }
            } catch {
                print("正則表達式錯誤: \(error)")
            }
        }
        
        return nil
    }
    
    /// 從包含重定向腳本的 HTML 中提取 URL
    /// - Parameter htmlString: 包含重定向腳本的 HTML 字串
    /// - Returns: 提取的 URL
    static func extractRedirectURL(_ htmlString: String) -> String? {
        // 多個 URL 提取模式
        let urlPatterns = [
            #"fetch\("([^"]+)"\)"#, // JavaScript fetch
            #"window\.location\.href\s*=\s*"([^"]+)"#, // 直接的 window.location 設置
            #"<meta\s+http-equiv="refresh"\s+content="\d+;url=([^"]+)"# // meta 重定向
        ]
        
        for pattern in urlPatterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let nsString = htmlString as NSString
                let matches = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: nsString.length))
                
                // 找到第一個匹配的 URL
                if let match = matches.first {
                    let urlRange = match.range(at: 1)
                    return nsString.substring(with: urlRange)
                }
            } catch {
                print("正則表達式錯誤: \(error)")
            }
        }
        
        return nil
    }
    
    /// 處理包含重定向的 HTML
    /// - Parameter htmlString: 重定向的 HTML 內容
    /// - Returns: 重定向的 URL
    static func handleRedirectHTML(_ htmlString: String) -> String? {
        return extractRedirectURL(htmlString)
    }
}



