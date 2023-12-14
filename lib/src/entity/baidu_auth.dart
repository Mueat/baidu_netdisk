part of '../baidu_netdisk_base.dart';

/// Authorize response type
enum AuthorizeResponseType {
  /// Authorization code
  code,

  /// Access token
  token
}

/// Accesstoken grant type
enum AccesstokenGrantType {
  /// Authorization code
  /// @see https://pan.baidu.com/union/doc/al0rwqzzl
  authorizationCode,

  /// Device token
  /// @see https://pan.baidu.com/union/doc/fl1x114ti
  deviceToken,

  /// Refresh token
  refreshToken
}

class BaiduAuth {
  final int expiresIn;
  final String refreshToken;
  final String accessToken;
  final String sessionSecret;
  final String sessionKey;
  final String scope;

  BaiduAuth({
    required this.expiresIn,
    required this.refreshToken,
    required this.accessToken,
    required this.sessionSecret,
    required this.sessionKey,
    required this.scope,
  });

  static BaiduAuth fromJson(Map<String, dynamic> json) {
    return BaiduAuth(
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
      accessToken: json['access_token'],
      sessionSecret: json['session_secret'] ?? '',
      sessionKey: json['session_key'] ?? '',
      scope: json['scope'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expires_in': expiresIn,
      'refresh_token': refreshToken,
      'access_token': accessToken,
      'session_secret': sessionSecret,
      'session_key': sessionKey,
      'scope': scope
    };
  }

  @override
  String toString() {
    return 'AuthToken{expiresIn: $expiresIn, refreshToken: $refreshToken, accessToken: $accessToken, sessionSecret: $sessionSecret, sessionKey: $sessionKey, scope: $scope}';
  }
}

extension BaiduNetdiskClientExtAuth on BaiduNetdiskClient {
  /// Get authorization url
  /// Authorization code url: https://pan.baidu.com/union/doc/al0rwqzzl
  /// Implicit Grant url: https://pan.baidu.com/union/doc/6l0ryrjzv
  Uri getAuthorizationUri(
      {AuthorizeResponseType responseType = AuthorizeResponseType.code,
      String redirectUrl = 'oob',
      String scope = 'basic,netdisk',
      String? deviceID}) {
    return Uri.parse("http://openapi.baidu.com/oauth/2.0/authorize")
        .replace(queryParameters: {
      'response_type': responseType.name,
      'client_id': appKey,
      'redirect_uri': redirectUrl,
      'scope': scope,
      'device_id': deviceID ?? ''
    });
  }

  /// Get or refresh access token
  Future<BaiduAuth> getAccessToken(
    String codeOrRefreshToken, {
    AccesstokenGrantType grantType = AccesstokenGrantType.authorizationCode,
    String redirectUri = 'oob',
  }) async {
    Map<String, dynamic> queryParameters = {
      'client_id': appKey,
      'client_secret': secretKey,
    };
    if (grantType == AccesstokenGrantType.authorizationCode) {
      queryParameters["grant_type"] = "authorization_code";
      queryParameters["code"] = codeOrRefreshToken;
      queryParameters['redirect_uri'] = redirectUri;
    } else if (grantType == AccesstokenGrantType.deviceToken) {
      queryParameters["grant_type"] = "device_token";
      queryParameters["code"] = codeOrRefreshToken;
    } else if (grantType == AccesstokenGrantType.refreshToken) {
      queryParameters["grant_type"] = "refresh_token";
      queryParameters["refresh_token"] = codeOrRefreshToken;
    }

    final resp = await get<Map<String, dynamic>>(
        'https://openapi.baidu.com/oauth/2.0/token',
        queryParameters: queryParameters);
    if (resp.statusCode != 200 || resp.data == null) {
      throw DioException(
          requestOptions: resp.requestOptions,
          response: resp,
          type: DioExceptionType.badResponse,
          error: resp.statusMessage);
    }
    var expiresIn = resp.data!['expires_in'] as int;
    resp.data!['expires_in'] =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor() + expiresIn;
    return BaiduAuth.fromJson(resp.data!);
  }

  /// Refresh access token
  Future<BaiduAuth> refreshToken(String refreshToken) {
    return getAccessToken(refreshToken,
        grantType: AccesstokenGrantType.refreshToken);
  }
}
