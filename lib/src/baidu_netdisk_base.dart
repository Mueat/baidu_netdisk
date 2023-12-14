import 'package:dio/dio.dart';

part 'entity/baidu_auth.dart';
part 'entity/baidu_user.dart';
part 'entity/device_code.dart';
part 'entity/space.dart';
part 'entity/file_list.dart';

class BaiduNetdiskClient with DioMixin implements Dio {
  /// baidu netdisk application app key
  final String appKey;

  /// baidu netdisk application secret key
  final String secretKey;

  /// Interceptors
  final List<Interceptor>? interceptorList;

  /// debug
  final bool debug;

  BaiduNetdiskClient({
    required this.appKey,
    required this.secretKey,
    BaseOptions? options,
    HttpClientAdapter? httpClientAdapter,
    this.interceptorList,
    this.debug = false,
  }) {
    this.options = options ?? BaseOptions();
    this.options.headers['User-Agent'] = 'pan.baidu.com';

    // 禁止重定向
    this.options.followRedirects = false;

    // 状态码错误视为成功
    this.options.validateStatus = (status) => true;

    this.httpClientAdapter = httpClientAdapter ?? HttpClientAdapter();

    // 拦截器
    if (interceptorList != null) {
      for (var item in interceptorList!) {
        interceptors.add(item);
      }
    }

    // debug
    if (debug == true) {
      interceptors.add(LogInterceptor(responseBody: true));
    }
  }

  /// Set the public request headers
  void setHeaders(Map<String, dynamic> headers) => options.headers = headers;

  /// Set the connection server timeout time in milliseconds.
  void setConnectTimeout(int timeout) =>
      options.connectTimeout = Duration(milliseconds: timeout);

  /// Set send data timeout time in milliseconds.
  void setSendTimeout(int timeout) =>
      options.sendTimeout = Duration(milliseconds: timeout);

  /// Set transfer data time in milliseconds.
  void setReceiveTimeout(int timeout) =>
      options.receiveTimeout = Duration(milliseconds: timeout);

  /// check response
  void checkApiResponse(Response<Map<String, dynamic>> resp) {
    if (resp.statusCode != 200 || resp.data == null) {
      throw DioException(
          requestOptions: resp.requestOptions,
          response: resp,
          type: DioExceptionType.badResponse,
          error: resp.statusMessage);
    }
    if (resp.data!["errno"] != 0) {
      throw DioException(
          requestOptions: resp.requestOptions,
          response: resp,
          type: DioExceptionType.badResponse,
          error: resp.data?['errmsg'] ?? resp.statusMessage);
    }
  }

  /// request rest api
  Future<Response<Map<String, dynamic>>> requestRestApi(
    String path, {
    String method = "get",
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (!path.startsWith("https://pan.baidu.com")) {
      path = "https://pan.baidu.com${path.startsWith("/") ? path : "/$path"}";
    }
    var opts = options ?? Options();
    opts.method = method;
    final uri = Uri.parse(path).replace(queryParameters: queryParameters);
    final resp = await requestUri<Map<String, dynamic>>(
      uri,
      data: data,
      options: opts,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
    checkApiResponse(resp);
    return resp;
  }
}
