part of '../baidu_netdisk_base.dart';

class BaiduUser {
  /// 百度账号
  final String baiduName;

  /// 网盘账号
  final String netdiskName;

  /// 头像地址
  final String avatarUrl;

  /// 会员类型，0普通用户、1普通会员、2超级会员
  final int vipType;

  /// 用户ID
  final int uk;

  BaiduUser(
      {required this.baiduName,
      required this.netdiskName,
      required this.avatarUrl,
      required this.vipType,
      required this.uk});

  factory BaiduUser.fromJson(Map<String, dynamic> json) {
    return BaiduUser(
        baiduName: json['baidu_name'] ?? '',
        netdiskName: json['netdisk_name'] ?? '',
        avatarUrl: json['avatar_url'] ?? '',
        vipType: json['vip_type'] ?? 0,
        uk: json['uk'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "baidu_name": baiduName,
      "netdisk_name": netdiskName,
      "avatar_url": avatarUrl,
      "vip_type": vipType,
      "uk": uk
    };
  }
}

extension BaiduNetdiskClientExtUser on BaiduNetdiskClient {
  Future<BaiduUser> getUserInfo(String accessToken) async {
    final resp = await requestRestApi("https://pan.baidu.com/rest/2.0/xpan/nas",
        queryParameters: {
          'method': 'uinfo',
          'access_token': accessToken,
        });
    return BaiduUser.fromJson(resp.data!);
  }
}
