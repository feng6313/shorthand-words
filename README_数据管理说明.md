# 数据管理说明

## 概述

现在App已经完全移除了硬编码的文件名，支持动态加载OSS中的任何JSON数据文件。

## 使用方法

### 方法一：使用索引文件（推荐）

1. **创建索引文件**
   - 将 `example_index.json` 重命名为 `index.json`
   - 编辑文件内容，在 `groups` 数组中列出所有可用的数据文件名（不包含.json后缀）
   
   ```json
   {
     "groups": [
       "best_words",
       "advanced_vocabulary",
       "business_terms"
     ],
     "last_updated": "2025-01-27T10:00:00Z"
   }
   ```

2. **上传文件到OSS**
   - 将 `index.json` 上传到OSS根目录
   - 将你的数据文件上传到 `words/` 目录下
   - 例如：`words/best_words.json`、`words/advanced_vocabulary.json`

### 方法二：自动发现（备用）

如果不想维护索引文件，App会自动尝试发现以下文件名模式：

- 数字模式：`out_001` 到 `out_020`
- 字母模式：`words_a`, `words_b`, `words_c`, `words_d`, `words_e`
- 级别模式：`basic`, `advanced`, `intermediate`, `expert`
- 等级模式：`level1` 到 `level5`

## 数据文件格式

你的JSON文件必须遵循以下格式：

```json
{
  "metadata": {
    "version": "1.0",
    "total_words": 11,
    "core_word_position": 1,
    "created_date": "2024-01-15",
    "description": "本地单词数据 - best系列单词"
  },
  "core_word": {
    "english": "best",
    "phonetic": "/bɛst/",
    "chinese": "最好的"
  },
  "home_page_words": [
    "best",
    "test",
    "rest"
  ],
  "all_words": [
    {
      "id": 1,
      "english": "best",
      "phonetic": "/bɛst/",
      "chinese": "最好的",
      "phrases": [],
      "examples": []
    }
    // ... 更多单词
  ]
}
```

## 图片文件

思维图图片应该放在 `image/` 目录下，文件名与数据组名称相同：
- 数据文件：`words/best_words.json`
- 对应图片：`image/best_words.png`

## 故障排除

1. **App显示"没有数据"**
   - 检查OSS中是否有 `index.json` 文件
   - 确认 `index.json` 中的文件名与实际文件名匹配
   - 确认数据文件在 `words/` 目录下

2. **部分数据组加载失败**
   - 检查文件名是否正确
   - 确认JSON格式是否有效
   - 检查OSS访问权限

3. **图片不显示**
   - 确认图片文件在 `image/` 目录下
   - 确认图片文件名与数据组名称匹配
   - 确认图片格式为PNG

## 优势

- ✅ 无需修改App代码即可添加新数据
- ✅ 支持任意文件名
- ✅ 自动发现机制作为备用
- ✅ 灵活的数据组织方式
- ✅ 完全移除硬编码依赖