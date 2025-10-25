#!/bin/bash

# 训练状态检查脚本
# 使用方法：bash check_training_status.sh

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 LeanCode 训练状态总览"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 tmux 会话
echo "🔧 Tmux 会话状态："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if tmux ls 2>/dev/null; then
    echo ""
else
    echo "  ⚠️  没有运行中的 tmux 会话"
    echo ""
fi

# 检查训练进程
echo "🏃 训练进程状态："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CODESEARCH_PROCESS=$(ps aux | grep "run_classifier.py" | grep -v grep | wc -l)
CODE2NL_BERT_PROCESS=$(ps aux | grep "code2nl/CodeBERT/run.py" | grep -v grep | wc -l)
CODE2NL_T5_PROCESS=$(ps aux | grep "code2nl/CodeT5/run_gen.py" | grep -v grep | wc -l)

if [ $CODESEARCH_PROCESS -gt 0 ]; then
    echo "  ✓ CodeSearch 训练正在运行 ($CODESEARCH_PROCESS 个进程)"
else
    echo "  ✗ CodeSearch 训练未运行"
fi

if [ $CODE2NL_BERT_PROCESS -gt 0 ]; then
    echo "  ✓ Code2NL CodeBERT 训练正在运行"
else
    echo "  ✗ Code2NL CodeBERT 训练未运行"
fi

if [ $CODE2NL_T5_PROCESS -gt 0 ]; then
    echo "  ✓ Code2NL CodeT5 训练正在运行"
else
    echo "  ✗ Code2NL CodeT5 训练未运行"
fi

echo ""

# 检查 GPU 使用情况
echo "🎮 GPU 使用情况："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits | \
while IFS=',' read -r idx name util mem_used mem_total; do
    printf "  GPU %s (%s): 利用率 %s%%, 显存 %s/%s MB\n" "$idx" "$(echo $name | xargs)" "$util" "$mem_used" "$mem_total"
done
echo ""

# 检查最新日志
echo "📋 最新训练日志："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -d "logs" ]; then
    ls -lt logs/*.log 2>/dev/null | head -5 | while read -r line; do
        # 提取文件名
        filename=$(echo "$line" | awk '{print $NF}')
        if [ -n "$filename" ]; then
            # 获取文件大小
            size=$(du -h "$filename" 2>/dev/null | cut -f1)
            # 获取最后修改时间
            mod_time=$(stat -c '%y' "$filename" 2>/dev/null | cut -d'.' -f1)
            echo "  📄 $(basename $filename)"
            echo "      大小: $size | 最后更新: $mod_time"
            echo ""
        fi
    done
else
    echo "  ⚠️  日志目录不存在"
    echo ""
fi

# 检查模型输出
echo "💾 训练模型状态："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_model() {
    local path=$1
    local name=$2
    if [ -d "$path" ]; then
        if [ -f "$path/pytorch_model.bin" ] || [ -f "$path/model.bin" ] || [ -f "$path/checkpoint-*/pytorch_model.bin" ]; then
            size=$(du -sh "$path" 2>/dev/null | cut -f1)
            echo "  ✓ $name (大小: $size)"
        else
            echo "  ⚠️  $name (目录存在但未找到模型文件)"
        fi
    else
        echo "  ✗ $name (未开始训练)"
    fi
}

check_model "models/codesearch/codebert/base" "CodeSearch + CodeBERT"
check_model "models/codesearch/codet5/base" "CodeSearch + CodeT5"
check_model "models/code2nl/codebert/base" "Code2NL + CodeBERT"
check_model "models/code2nl/codet5/base" "Code2NL + CodeT5"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 快捷命令："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  查看所有会话: tmux ls"
echo "  进入会话: tmux attach -t <会话名>"
echo "  查看日志: tail -f logs/<日志文件>"
echo "  实时 GPU: watch -n 1 nvidia-smi"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

