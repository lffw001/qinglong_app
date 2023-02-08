import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_log/dio_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:qinglong_app/base/http/token_interceptor.dart';
import 'package:qinglong_app/base/http/url.dart';
import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../../json.jc.dart';
import '../../main.dart';
import '../routes.dart';

class Http {
  Dio? _dio;
  bool pushedLoginPage = false;

  String host;
  int index;

  Http(
    this.host,
    this.index,
  ) {
    _init();
  }

  void initDioConfig(
    String host,
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: host,
        connectTimeout: 50000,
        receiveTimeout: 50000,
        sendTimeout: 50000,
        contentType: "application/json",
      ),
    );
    _dio?.interceptors.add(DioLogInterceptor());
    _dio?.interceptors.add(PrettyDioLogger());

    _dio?.interceptors.add(TokenInterceptor(
      host,
      index,
    ));
    (_dio?.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  void _init() {
    if (_dio == null) {
      initDioConfig(host);
    }
  }

  void clear() {
    _dio = null;
  }

  Future<HttpResponse<T>> get<T>(
    String uri,
    Map<String, String?>? json, {
    bool compute = true,
    String serializationName = "data",
  }) async {
    try {
      _init();
      var response = await _dio!.get(uri, queryParameters: json);
      return decodeResponse<T>(response, serializationName, compute);
    } on DioError catch (e) {
      return exceptionHandler<T>(e, uri);
    }
  }

  Future<HttpResponse<T>> post<T>(
    String uri,
    dynamic json, {
    bool compute = true,
    String serializationName = "data",
  }) async {
    try {
      _init();
      var response = await _dio!.post(uri, data: json);

      return decodeResponse<T>(
        response,
        serializationName,
        compute,
      );
    } on DioError catch (e) {
      return exceptionHandler<T>(e, uri);
    }
  }

  Future<HttpResponse<T>> delete<T>(
    String uri,
    dynamic json, {
    bool compute = true,
    String serializationName = "data",
  }) async {
    try {
      _init();
      var response = await _dio!.delete(uri, data: json);

      return decodeResponse<T>(
        response,
        serializationName,
        compute,
      );
    } on DioError catch (e) {
      return exceptionHandler<T>(e, uri);
    }
  }

  Future<HttpResponse<T>> put<T>(
    String uri,
    dynamic json, {
    bool compute = true,
    String serializationName = "data",
  }) async {
    try {
      _init();
      var response = await _dio!.put(uri, data: json);
      return decodeResponse<T>(
        response,
        serializationName,
        compute,
      );
    } on DioError catch (e) {
      return exceptionHandler<T>(e, uri);
    }
  }

  void exitLogin() {
    if (!pushedLoginPage) {
      "身份已过期,请重新登录".toast();
      pushedLoginPage = true;

      getIt<UserInfoViewModel>(instanceName: index.toString()).exitLoginFocus(index);

      getIt<GlobalKey<NavigatorState>>(instanceName: index.toString()).currentState?.pushNamedAndRemoveUntil(Routes.routeLogin, (route) => false);
    }
  }

  HttpResponse<T> exceptionHandler<T>(DioError e, String path) {
    try {
      logger.e(e);
      if (e.response?.statusCode == 401 && !Url.inWhiteList(path)) {
        if (!getIt<UserInfoViewModel>(instanceName: index.toString()).useSecretLogined) {
          exitLogin();
        }
        return HttpResponse(success: false, message: "没有该模块的访问权限", code: 401);
      }

      if (e.response != null && e.response!.data != null) {
        return HttpResponse(success: false, message: e.response?.data["message"] ?? e.message, code: e.response?.data["code"] ?? 0);
      } else {
        return HttpResponse(success: false, message: e.message, code: e.response?.statusCode ?? 0);
      }
    } catch (e) {
      return HttpResponse(success: false, message: e.toString(), code: 400);
    }
  }

  static HttpResponse<T> decodeResponse<T>(
    Response<dynamic> response,
    String serializationName,
    bool compute,
  ) {
    int code = 0;
    if (response.statusCode == 200) {
      try {
        if (response.data["code"] == 200) {
          if (response.data[serializationName] != null) {
            if (T == NullResponse) {
              return HttpResponse<T>(
                success: true,
                code: 200,
              );
            }

            dynamic data = response.data[serializationName];
            T t;
            if (T == String) {
              if (data is String) {
                t = data as T;
              } else {
                t = jsonEncode(data) as T;
              }
              return HttpResponse<T>(
                success: true,
                code: 200,
                bean: t,
              );
            } else {
              T bean;
              if (compute) {
                bean = DeserializeAction.invokeJson(DeserializeAction<T>(data));
              } else {
                bean = JsonConversion$Json.fromJson<T>(data);
              }
              return HttpResponse<T>(
                success: true,
                code: 200,
                bean: bean,
              );
            }
          } else {
            return HttpResponse<T>(
              success: true,
              code: 200,
            );
          }
        } else {
          return HttpResponse<T>(
            success: false,
            code: response.data["code"],
            message: response.data["message"],
          );
        }
      } catch (e) {
        logger.e(e);
        return HttpResponse<T>(
          success: false,
          code: -1000,
          message: "json解析失败",
        );
      }
    } else {
      code = response.statusCode ?? 0;
      return HttpResponse(
        success: false,
        code: code,
        message: response.statusMessage,
      );
    }
  }
}

class HttpResponse<T> {
  late bool success;
  String? message;
  late int code;
  T? bean;

  HttpResponse({required this.success, this.message, required this.code, this.bean});
}

class DeserializeAction<T> {
  final dynamic json;

  DeserializeAction(this.json);

  T invoke() {
    return JsonConversion$Json.fromJson<T>(json);
  }

  static dynamic invokeJson(DeserializeAction a) => a.invoke();
}

mixin BaseBean<T> {
  T fromJson(Map<String, dynamic> json);
}

class CronBean with BaseBean<CronBean> {
  @override
  CronBean fromJson(Map<String, dynamic> json) {
    return CronBean();
  }
}

void decode<T>() async {
  compute(DeserializeAction.invokeJson, DeserializeAction<T>({}));
}

class NullResponse {}

class NotLoginException implements Exception {}
