part of '../baidu_netdisk_base.dart';

class BaiduFile {
  final int category;
  final int fsId;
  final int isdir;
  final String md5;
  final String path;
  final String serverFilename;
  final int serverCtime;
  final int serverMtime;
  final int size;

  const BaiduFile({
    required this.category,
    required this.fsId,
    required this.isdir,
    required this.md5,
    required this.path,
    required this.serverFilename,
    required this.serverCtime,
    required this.serverMtime,
    required this.size,
  });

  factory BaiduFile.fromJson(Map<String, dynamic> json) {
    return BaiduFile(
      category: json['category'] as int,
      fsId: json['fs_id'] as int,
      isdir: json['isdir'] as int,
      md5: json['md5'] ?? "",
      path: json['path'] as String,
      serverCtime: json['server_ctime'] as int,
      serverFilename: json['server_filename'] as String,
      serverMtime: json['server_mtime'] as int,
      size: json['size'] as int,
    );
  }

  @override
  String toString() {
    return 'CategoryItem{category: $category, fsId: $fsId, isdir: $isdir, md5: $md5, path: $path, serverCtime: $serverCtime, serverFilename: $serverFilename, serverMtime: $serverMtime, size: $size}';
  }
}

class BaiduFileList {
  final int start;
  final int limit;
  final int hasMore;
  final int cursor;
  final List<BaiduFile> list;

  BaiduFileList({
    required this.start,
    required this.limit,
    required this.hasMore,
    required this.cursor,
    required this.list,
  });

  static BaiduFileList fromJson(Map<String, dynamic> json) {
    return BaiduFileList(
      start: json['start'],
      limit: json['limit'],
      hasMore: json['has_more'],
      cursor: json['cursor'],
      list: (json['list'] as List).map((e) => BaiduFile.fromJson(e)).toList(),
    );
  }
}

extension BaiduNetdiskClientExtFileList on BaiduNetdiskClient {
  Future<BaiduFileList> getFileList(
    String accessToken, {
    String dir = '/',
    int recursion = 0,
    String? order = 'name',
    int? desc = 0,
    int start = 0,
    int limit = 1000,
    int web = 0,
  }) async {
    var queryParameters = {
      'method': 'listall',
      'access_token': accessToken,
      'path': dir,
      'recursion': '$recursion',
      'order': order ?? 'name',
      'desc': '$desc',
      'start': '$start',
      'limit': '$limit',
      'web': '$web'
    };
    final resp = await requestRestApi("/rest/2.0/xpan/multimedia",
        queryParameters: queryParameters);
    resp.data?["start"] = start;
    resp.data?["limit"] = limit;
    return BaiduFileList.fromJson(resp.data!);
  }

  // https://pan.baidu.com/rest/2.0/xpan/file?method=list&access_token=126.1e6c816eff113f3b5980e8e9a9aa62f5.YsNBfB81OsLkumHUbx1l2V424kNdT72dPqrUJq8.CQFYgw&recursion=0&order=size&desc=1&start=0&limit=1000&web=0
  // https://pan.baidu.com/rest/2.0/xpan/file?method=list&access_token=126.1cd30343af8b21b34396c19c7f5cf3d5.YCXZFs9FHTtG77qZzDqSeoVCEWgaHJFB7AuBjLO.fNjmVA&dir&recursion=0&order=name&desc=1&start=0&limit=1000&web=0

  /// 查找文件
  Future<BaiduFileList> searchFiles(
    String key,
    String accessToken, {
    String dir = '/',
    int? category,
    int? page,
    int recursion = 0,
    int web = 0,
  }) async {
    final resp = await requestRestApi("/rest/2.0/xpan/file", queryParameters: {
      'method': 'search ',
      'access_token': accessToken,
      'key': key,
      'dir': dir,
      'recursion': recursion,
      'category': category ?? '',
      'page': page ?? '',
      'num': 500,
      'web': web
    });
    resp.data?["start"] = page != null ? page * 500 : 0;
    resp.data?["limit"] = 500;
    return BaiduFileList.fromJson(resp.data!);
  }
}
