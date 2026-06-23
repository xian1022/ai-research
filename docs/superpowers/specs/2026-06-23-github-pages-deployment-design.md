# GitHub Pages 公開部署設計

## 目標

將 AI 產業研究庫部署為 `xian1022/ai-research` 公開 GitHub Pages 專案站，讓首頁與四份報告都有固定、可分享的 HTTPS 網址。

## 網址結構

- 首頁：`https://xian1022.github.io/ai-research/`
- 台積電：`https://xian1022.github.io/ai-research/reports/tsmc/`
- 主被動元件：`https://xian1022.github.io/ai-research/reports/components/`
- AI Server CPU：`https://xian1022.github.io/ai-research/reports/server-cpu/`
- AI PCB：`https://xian1022.github.io/ai-research/reports/ai-pcb/`

## 發佈邊界

公開 repository 只追蹤首頁、四份報告、部署標記、測試與必要文件。研究原稿、簡報、試算表、預覽圖、備份與工作檔不加入 Git。

## 連結策略

首頁保留原本的本機 `href` 作為無 JavaScript 回退，並把各筆 `data-public-url` 設為正式 HTTPS 網址。JavaScript 啟用時優先導向公開乾淨網址。

## 驗證

本機先驗證四個發佈入口存在、首頁正式網址完整且沒有多餘公開檔案。推送後等待 Pages 狀態為 `built`，再確認五個網址皆回傳 HTTP 200 並含預期標題。
