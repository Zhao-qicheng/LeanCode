#!/bin/bash

# Code2NL + CodeT5 训练脚本
# 使用方法：bash start_training_code2nl_codet5.sh

LOGDIR="/home/u2023312269/LeanCode/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGFILE="$LOGDIR/code2nl_codet5_training_${TIMESTAMP}.log"

# 创建日志目录
mkdir -p "$LOGDIR"

echo "正在创建 tmux 会话并启动训练..."
echo "日志文件: $LOGFILE"

tmux new-session -d -s code2nl_codet5 "
    source ~/.bashrc
    conda activate leancode
    cd /home/u2023312269/LeanCode
    
    echo '训练开始时间: $(date)' | tee -a $LOGFILE
    echo '任务: Code2NL + CodeT5 Base' | tee -a $LOGFILE
    echo '===========================================' | tee -a $LOGFILE
    
    python code2nl/CodeT5/run_gen.py \
      --model_type codet5 \
      --task summarize \
      --sub_task java \
      --tokenizer_name Salesforce/codet5-base \
      --model_name_or_path Salesforce/codet5-base \
      --do_train --do_eval --do_eval_bleu \
      --prune_strategy None \
      --data_num -1 \
      --num_train_epochs 8 \
      --warmup_steps 1000 \
      --learning_rate 5e-5 \
      --patience 2 \
      --data_dir ./data/code2nl/CodeSearchNet/java \
      --cache_path ./models/code2nl/codet5/base/cache_data \
      --output_dir ./models/code2nl/codet5/base \
      --save_last_checkpoints \
      --always_save_model \
      --res_dir ./models/code2nl/codet5/base/prediction \
      --res_fn ./models/code2nl/codet5/base/result.txt \
      --train_batch_size 32 \
      --eval_batch_size 8 \
      --beam_size 5 \
      --max_source_length 512 \
      --max_target_length 128 \
      --summary_dir ./models/code2nl/codet5/base/tensorboard 2>&1 | tee -a $LOGFILE
    
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
echo "✓ 训练已在 tmux 会话 'code2nl_codet5' 中启动"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 查看日志："
echo "  实时查看: tail -f $LOGFILE"
echo "  查看最后100行: tail -100 $LOGFILE"
echo "  查看错误: grep -i error $LOGFILE"
echo ""
echo "🔧 管理会话："
echo "  进入会话: tmux attach -t code2nl_codet5"
echo "  查看所有会话: tmux ls"
echo "  分离会话: 在会话内按 Ctrl+B 然后按 D"
echo "  停止训练: tmux kill-session -t code2nl_codet5"
echo ""
echo "📊 查看进程状态："
echo "  ps aux | grep run_gen.py"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ 现在可以安全地断开 SSH 连接，训练会继续运行。"



