#!/bin/bash

# Code2NL + CodeBERT 训练脚本（极限GPU优化版）
# 使用方法：bash start_training_code2nl_codebert.sh

LOGDIR="/home/u2023312269/LeanCode/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGFILE="$LOGDIR/code2nl_codebert_training_${TIMESTAMP}.log"

# 创建日志目录
mkdir -p "$LOGDIR"

echo "正在创建 tmux 会话并启动训练..."
echo "日志文件: $LOGFILE"

tmux new-session -d -s code2nl_codebert "
    source ~/.bashrc
    conda activate leancode
    cd /home/u2023312269/LeanCode
    
    echo '训练开始时间: $(date)' | tee -a $LOGFILE
    echo '任务: Code2NL + CodeBERT Base (极限GPU优化版 - Batch 96)' | tee -a $LOGFILE
    echo '===========================================' | tee -a $LOGFILE
    
    python code2nl/CodeBERT/run.py \
      --model_type roberta \
      --tokenizer_name microsoft/codebert-base \
      --model_name_or_path microsoft/codebert-base \
      --do_train --do_eval \
      --prune_strategy None \
      --train_filename ./data/code2nl/CodeSearchNet/java/train.jsonl \
      --dev_filename ./data/code2nl/CodeSearchNet/java/valid.jsonl \
      --output_dir ./models/code2nl/codebert/base \
      --max_source_length 512 \
      --max_target_length 128 \
      --beam_size 10 \
      --train_batch_size 96 \
      --eval_batch_size 96 \
      --gradient_accumulation_steps 2 \
      --learning_rate 5e-5 \
      --num_train_epochs 15 2>&1 | tee -a $LOGFILE
    
    EXIT_CODE=\${PIPESTATUS[0]}
    echo '===========================================' | tee -a $LOGFILE
    echo \"训练结束时间: \$(date)\" | tee -a $LOGFILE
    echo \"退出代码: \$EXIT_CODE\" | tee -a $LOGFILE
    
    if [ \$EXIT_CODE -eq 0 ]; then
        echo '✓ 训练成功完成！' | tee -a $LOGFILE
    else
        echo '✗ 训练失败，请检查日志' | tee -a $LOGFILE
    fi
    
    echo ''
    echo '按 Enter 键关闭此窗口，或按 Ctrl+B D 保持会话'
    read
"

echo ""
echo "✓ 训练已在 tmux 会话 'code2nl_codebert' 中启动"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 查看日志："
echo "  实时查看: tail -f $LOGFILE"
echo ""
echo "🔧 管理会话："
echo "  进入会话: tmux attach -t code2nl_codebert"
echo "  停止训练: tmux kill-session -t code2nl_codebert"
echo ""
echo "🎮 监控GPU："
echo "  watch -n 1 nvidia-smi"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"