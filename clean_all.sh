#!/bin/bash

clear
echo "======================================"
echo "  一键清理: build bin lib install packages"
echo "======================================"

# 静默删除目录，不存在也不报错
rm -rf build
rm -rf bin
rm -rf lib
rm -rf install
rm -rf packages

echo ""
echo "✅ 清理完成！"