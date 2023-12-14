import 'package:baidu_netdisk/baidu_netdisk.dart';

void main() {
  var client = BaiduNetdiskClient(appKey: "App key", secretKey: "Secret key");

  var authCodeUri = client.getAuthorizationUri();

  print("authCodeUri:$authCodeUri");
}
