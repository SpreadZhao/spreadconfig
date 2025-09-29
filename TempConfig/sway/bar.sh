#!/bin/bash

#!/bin/bash

# 1. 输出协议版本
echo '{"version":1}'

# 2. 输出开始数组符号
echo '['

# 3. 进入无限循环，每秒更新一次状态
while true; do
    # 获取各个状态信息，确保这些脚本是可执行的，并且输出单行字符串
    volume_status=$(~/scripts/get_volume.sh)
    battery_status=$(~/scripts/get_battery.sh)
    date_info=$(~/scripts/get_date.sh)
    # 构造 JSON 数组中的元素
    # 每个 { ... } 是一个模块，full_text 是显示内容
    # 可以根据需要为每个模块添加 'name' 属性，以便将来用于点击事件等
    echo "[{\"full_text\":\"${volume_status}\", \"name\":\"volume\"},{\"full_text\":\"${battery_status}\", \"name\":\"battery\"},{\"full_text\":\"${date_info}\", \"name\":\"date\"}],"

    # 暂停一秒，避免占用过多CPU
    # 你可以根据需要调整这个值，例如 sleep 2 或 sleep 5
    sleep 1
done
