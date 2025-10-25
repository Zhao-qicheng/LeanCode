#!/bin/bash

# 日志查看工具
# 使用方法：bash view_logs.sh [选项]
# 选项：
#   live    - 实时查看最新日志
#   error   - 查看错误信息
#   latest  - 查看最新日志文件的最后100行
#   all     - 列出所有日志文件

LOGDIR="/home/u2023312269/LeanCode/logs"
NOHUP_LOG="/home/u2023312269/LeanCode/nohup.out"

function show_help() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 日志查看工具"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "使用方法："
    echo "  bash view_logs.sh [选项]"
    echo ""
    echo "选项："
    echo "  live    - 实时查看训练日志 (Ctrl+C 退出)"
    echo "  error   - 查看错误信息"
    echo "  latest  - 查看最后100行"
    echo "  all     - 列出所有日志文件"
    echo "  nohup   - 查看 nohup.out 日志"
    echo ""
}

case "$1" in
    live)
        echo "📊 实时查看训练日志 (按 Ctrl+C 退出)..."
        echo ""
        if [ -f "$NOHUP_LOG" ]; then
            tail -f "$NOHUP_LOG"
        elif [ -d "$LOGDIR" ]; then
            LATEST_LOG=$(ls -t "$LOGDIR"/*.log 2>/dev/null | head -1)
            if [ -n "$LATEST_LOG" ]; then
                echo "查看文件: $LATEST_LOG"
                tail -f "$LATEST_LOG"
            else
                echo "❌ 未找到日志文件"
            fi
        else
            echo "❌ 日志目录不存在"
        fi
        ;;
    
    error)
        echo "🔍 搜索错误信息..."
        echo ""
        if [ -f "$NOHUP_LOG" ]; then
            echo "━━━━ nohup.out 中的错误 ━━━━"
            grep -i "error\|exception\|failed\|traceback" "$NOHUP_LOG" | tail -30
        fi
        if [ -d "$LOGDIR" ]; then
            for logfile in "$LOGDIR"/*.log; do
                if [ -f "$logfile" ]; then
                    echo ""
                    echo "━━━━ $(basename $logfile) 中的错误 ━━━━"
                    grep -i "error\|exception\|failed\|traceback" "$logfile" | tail -20
                fi
            done
        fi
        ;;
    
    latest)
        if [ -f "$NOHUP_LOG" ]; then
            echo "📄 查看 nohup.out 最后100行..."
            echo ""
            tail -100 "$NOHUP_LOG"
        elif [ -d "$LOGDIR" ]; then
            LATEST_LOG=$(ls -t "$LOGDIR"/*.log 2>/dev/null | head -1)
            if [ -n "$LATEST_LOG" ]; then
                echo "📄 查看最新日志: $(basename $LATEST_LOG)"
                echo ""
                tail -100 "$LATEST_LOG"
            else
                echo "❌ 未找到日志文件"
            fi
        fi
        ;;
    
    all)
        echo "📁 所有日志文件："
        echo ""
        if [ -f "$NOHUP_LOG" ]; then
            echo "  $(ls -lh $NOHUP_LOG)"
        fi
        if [ -d "$LOGDIR" ] && [ -n "$(ls -A $LOGDIR 2>/dev/null)" ]; then
            ls -lht "$LOGDIR"/*.log 2>/dev/null
        else
            echo "  logs/ 目录为空"
        fi
        ;;
    
    nohup)
        if [ -f "$NOHUP_LOG" ]; then
            echo "📊 实时查看 nohup.out (按 Ctrl+C 退出)..."
            echo ""
            tail -f "$NOHUP_LOG"
        else
            echo "❌ nohup.out 文件不存在"
        fi
        ;;
    
    *)
        show_help
        ;;
esac

