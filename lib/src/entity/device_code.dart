part of '../baidu_netdisk_base.dart';

/// Dvice code
/// @see https://pan.baidu.com/union/doc/fl1x114ti
class DeviceCode {
  final String deviceCode;
  final String userCode;
  final String verificationUrl;
  final String qrcodeUrl;
  final int expiresIn;
  final int interval;

  DeviceCode(
      {required this.deviceCode,
      required this.userCode,
      required this.verificationUrl,
      required this.qrcodeUrl,
      required this.expiresIn,
      required this.interval});

  factory DeviceCode.fromJson(Map<String, dynamic> json) {
    return DeviceCode(
        deviceCode: json["device_code"] as String,
        userCode: json["user_code"] as String,
        verificationUrl: json["verification_url"] as String,
        qrcodeUrl: json["qrcode_url"] as String,
        expiresIn: json["expires_in"] as int,
        interval: json["interval"] as int);
  }

  Map<String, dynamic> toJson() {
    return {
      'device_code': deviceCode,
      'user_code': userCode,
      'verification_url': verificationUrl,
      'qrcode_url': qrcodeUrl,
      'expires_in': expiresIn,
      'interval': interval,
    };
  }

  @override
  String toString() {
    return 'DeviceCode{deviceCode: $deviceCode, userCode: $userCode, verificationUrl: $verificationUrl, qrcodeUrl: $qrcodeUrl, expiresIn: $expiresIn, interval: $interval}';
  }
}

extension BaiduNetdiskClientExtDeviceCode on BaiduNetdiskClient {
  /// Get device code
  Future<DeviceCode> getDeviceCode({String scope = 'basic,netdisk'}) async {
    final resp = await get<Map<String, dynamic>>(
      "https://openapi.baidu.com/oauth/2.0/device/code",
      queryParameters: {
        'response_type': 'device_code',
        'client_id': appKey,
        'scope': scope
      },
    );
    if (resp.statusCode != 200 || resp.data == null) {
      throw DioException(
          requestOptions: resp.requestOptions,
          response: resp,
          type: DioExceptionType.badResponse,
          error: resp.statusMessage);
    }
    return DeviceCode.fromJson(resp.data!);
  }
}
