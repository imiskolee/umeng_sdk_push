import 'dart:async';

import 'package:flutter/services.dart';

class UmengPushSdk {
  static MethodChannel _channel = const MethodChannel('u-push');

  static _Callbacks _callback = _Callbacks(_channel);

  ///设置token回调
  static void setTokenCallback(Callback callback) {
    _callback.tokenCallback = callback;
  }

  ///设置自定义消息回调
  static void setMessageCallback(Callback callback) {
    _callback.messageCallback = callback;
  }

  ///初始化推送
  static Future<void> register() async {
    return await _channel.invokeMethod(_METHOD_REGISTER);
  }

  ///获取推送id
  static Future<String> getRegisteredId() async {
    return await _channel.invokeMethod(_METHOD_DEVICE_TOKEN);
  }

  static Future<void> setPushEnable(bool enable) async {
    return await _channel.invokeMethod(_METHOD_PUSH_ENABLE, enable);
  }

  static Future<bool> setAlias(String alias, String type) async {
    return await _channel
        .invokeMethod(_METHOD_SET_ALIAS, {'alias': alias, 'type': type});
  }

  static Future<bool> addAlias(String alias, String type) async {
    return await _channel
        .invokeMethod(_METHOD_ADD_ALIAS, {'alias': alias, 'type': type});
  }

  static Future<bool> removeAlias(String alias, String type) async {
    return await _channel
        .invokeMethod(_METHOD_REMOVE_ALIAS, {'alias': alias, 'type': type});
  }

  static Future<bool> addTags(List<String> tags) async {
    return await _channel.invokeMethod(_METHOD_ADD_TAG, tags);
  }

  static Future<bool> removeTags(List<String> tags) async {
    return await _channel.invokeMethod(_METHOD_REMOVE_TAG, tags);
  }

  static Future<List<dynamic>> getTags() async {
    return await _channel.invokeMethod(_METHOD_GET_ALL_TAG);
  }
}

///定义回调
typedef Callback = void Function(String result);

const _METHOD_REGISTER = 'register';
const _METHOD_DEVICE_TOKEN = 'getDeviceToken';
const _METHOD_PUSH_ENABLE = 'enable';

const _METHOD_ADD_ALIAS = 'addAlias';
const _METHOD_SET_ALIAS = 'setAlias';
const _METHOD_REMOVE_ALIAS = 'removeAlias';

const _METHOD_ADD_TAG = 'addTag';
const _METHOD_REMOVE_TAG = 'removeTag';
const _METHOD_GET_ALL_TAG = 'getTags';

class _Callbacks {
  Callback tokenCallback;
  Callback messageCallback;

  _Callbacks(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      if (call.method == "onToken") {
        var token = call.arguments;
        if (tokenCallback != null) {
          tokenCallback(token);
        }
        return;
      }
      if (call.method == "onMessage") {
        var message = call.arguments;
        if (messageCallback != null) {
          messageCallback(message);
        }
        return;
      }
    });
  }
}