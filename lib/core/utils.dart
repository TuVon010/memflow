/// MemFlow 工具函数
///
/// 日期格式化、字符串处理等通用工具函数。

/// 获取当天的开始时间（00:00:00）
DateTime startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// 获取当天的结束时间（23:59:59.999）
DateTime endOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}

/// 格式化日期为简短显示
String formatDateShort(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return '今天';
  } else if (difference.inDays == 1) {
    return '昨天';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}天前';
  } else {
    return '${date.month}/${date.day}';
  }
}

/// 格式化日期为完整显示
String formatDateFull(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// 格式化学习时长
String formatDuration(Duration duration) {
  if (duration.inHours > 0) {
    return '${duration.inHours}小时${duration.inMinutes % 60}分钟';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes}分钟';
  } else {
    return '不到1分钟';
  }
}
