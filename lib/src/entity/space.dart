part of '../baidu_netdisk_base.dart';

/// Netdisk space
/// @see https://pan.baidu.com/union/doc/Cksg0s9ic
class DiskSpace {
  final int total;
  final bool expire;
  final int used;
  final int free;

  DiskSpace({
    required this.total,
    required this.expire,
    required this.used,
    required this.free,
  });

  factory DiskSpace.fromJson(Map<String, dynamic> json) {
    return DiskSpace(
      total: json['total'],
      expire: json['expire'],
      used: json['used'],
      free: json['free'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'expire': expire,
      'used': used,
      'free': free,
    };
  }

  @override
  String toString() {
    return 'DiskSpace{total: $total, expire: $expire, used: $used, free: $free}';
  }
}

extension BaiduNetdiskClientExtQuota on BaiduNetdiskClient {
  /// Get netdisk space
  Future<DiskSpace?> getQuota(String accessToken) async {
    final resp = await requestRestApi("https://pan.baidu.com/api/quota",
        queryParameters: {
          'access_token': accessToken,
          'checkfree': 1,
          'checkexpire': 1
        });
    return DiskSpace.fromJson(resp.data!);
  }
}
