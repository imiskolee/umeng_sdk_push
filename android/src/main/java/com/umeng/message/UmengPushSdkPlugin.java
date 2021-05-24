package com.umeng.message;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.umeng.message.common.inter.ITagManager;
import com.umeng.message.entity.UMessage;
import com.umeng.message.tag.TagManager;

import java.util.Collections;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * UmengPushSdkPlugin
 */
public class UmengPushSdkPlugin implements FlutterPlugin, MethodCallHandler {
    private static final String TAG = "UPush";

    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        mContext = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "u-push");
        channel.setMethodCallHandler(this);
    }

    public static void registerWith(Registrar registrar) {
        MethodChannel channel = new MethodChannel(registrar.messenger(), "u-push");
        UmengPushSdkPlugin plugin = new UmengPushSdkPlugin();
        plugin.mContext = registrar.context();
        plugin.channel = channel;
        channel.setMethodCallHandler(plugin);
    }

    private Context mContext = null;

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            if (!pushMethodCall(call, result)) {
                result.notImplemented();
            }
        } catch (Exception e) {
            Log.e(TAG, "Exception:" + e.getMessage());
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    private boolean pushMethodCall(MethodCall call, Result result) {
        if ("register".equals(call.method)) {
            register(result);
            return true;
        }
        if ("getDeviceToken".equals(call.method)) {
            getDeviceToken(call, result);
            return true;
        }
        if ("enable".equals(call.method)) {
            setPushEnable(call, result);
            return true;
        }
        if ("setAlias".equals(call.method)) {
            setAlias(call, result);
            return true;
        }
        if ("addAlias".equals(call.method)) {
            addAlias(call, result);
            return true;
        }
        if ("removeAlias".equals(call.method)) {
            removeAlias(call, result);
            return true;
        }
        if ("addTag".equals(call.method)) {
            addTags(call, result);
            return true;
        }
        if ("removeTag".equals(call.method)) {
            removeTags(call, result);
            return true;
        }
        if ("getTags".equals(call.method)) {
            getTags(call, result);
            return true;
        }
        return false;
    }

    private void getTags(MethodCall call, final Result result) {
        PushAgent.getInstance(mContext).getTagManager().getTags(new TagManager.TagListCallBack() {
            @Override
            public void onMessage(final boolean b, final List<String> list) {
                if (b) {
                    executeOnMain(result, list);
                } else {
                    executeOnMain(result, Collections.emptyList());
                }
            }
        });
    }

    private void removeTags(MethodCall call, final Result result) {
        List<String> arguments = call.arguments();
        String[] tags = new String[arguments.size()];
        arguments.toArray(tags);
        PushAgent.getInstance(mContext).getTagManager().deleteTags(new TagManager.TCallBack() {
            @Override
            public void onMessage(final boolean b, ITagManager.Result ret) {
                executeOnMain(result, b);
            }
        }, tags);
    }

    private void addTags(MethodCall call, final Result result) {
        List<String> arguments = call.arguments();
        String[] tags = new String[arguments.size()];
        arguments.toArray(tags);
        PushAgent.getInstance(mContext).getTagManager().addTags(new TagManager.TCallBack() {
            @Override
            public void onMessage(final boolean b, ITagManager.Result ret) {
                executeOnMain(result, b);
            }
        }, tags);
    }

    private void removeAlias(MethodCall call, final Result result) {
        String alias = getParam(call, result, "alias");
        String type = getParam(call, result, "type");
        PushAgent.getInstance(mContext).deleteAlias(alias, type, new UTrack.ICallBack() {
            @Override
            public void onMessage(final boolean b, String s) {
                Log.i(TAG, "onMessage:" + b + " s:" + s);
                executeOnMain(result, b);
            }
        });
    }

    private void addAlias(MethodCall call, final Result result) {
        String alias = getParam(call, result, "alias");
        String type = getParam(call, result, "type");
        PushAgent.getInstance(mContext).addAlias(alias, type, new UTrack.ICallBack() {
            @Override
            public void onMessage(boolean b, String s) {
                Log.i(TAG, "onMessage:" + b + " s:" + s);
                executeOnMain(result, b);
            }
        });
    }

    private void setAlias(MethodCall call, final Result result) {
        String alias = getParam(call, result, "alias");
        String type = getParam(call, result, "type");
        PushAgent.getInstance(mContext).setAlias(alias, type, new UTrack.ICallBack() {
            @Override
            public void onMessage(final boolean b, String s) {
                Log.i(TAG, "onMessage:" + b + " s:" + s);
                executeOnMain(result, b);
            }
        });
    }

    private void setPushEnable(MethodCall call, Result result) {
        final boolean enable = call.arguments();
        IUmengCallback callback = new IUmengCallback() {
            @Override
            public void onSuccess() {
                Log.i(TAG, "setPushEnable success:" + enable);
            }

            @Override
            public void onFailure(String s, String s1) {
                Log.i(TAG, "setPushEnable failure:" + enable);
            }
        };
        if (enable) {
            PushAgent.getInstance(mContext).enable(callback);
        } else {
            PushAgent.getInstance(mContext).disable(callback);
        }
        executeOnMain(result, null);
    }

    private void getDeviceToken(MethodCall call, Result result) {
        result.success(PushAgent.getInstance(mContext).getRegistrationId());
    }

    private void register(final Result result) {
        UmengMessageHandler messageHandler = new UmengMessageHandler() {
            @Override
            public void dealWithCustomMessage(Context context, final UMessage uMessage) {
                super.dealWithCustomMessage(context, uMessage);
                Log.i(TAG, "dealWithCustomMessage");
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            if (channel != null) {
                                channel.invokeMethod("onMessage", uMessage.getRaw().toString());
                            }
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                    }
                });
            }
        };
        PushAgent.getInstance(mContext).setMessageHandler(messageHandler);
        PushAgent.getInstance(mContext).register(new IUmengRegisterCallback() {
            @Override
            public void onSuccess(final String deviceToken) {
                Log.i(TAG, "register success deviceToken:" + deviceToken);
                mHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            if (channel != null) {
                                channel.invokeMethod("onToken", deviceToken);
                            }
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                    }
                });

            }

            @Override
            public void onFailure(String s, String s1) {
                Log.i(TAG, "register failure s:" + s + " s1:" + s1);
            }
        });
        executeOnMain(result, null);
    }

    private final Handler mHandler = new Handler(Looper.getMainLooper());

    private void executeOnMain(final Result result, final Object param) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            try {
                result.success(param);
            } catch (Throwable throwable) {
                throwable.printStackTrace();
            }
            return;
        }
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    result.success(param);
                } catch (Throwable throwable) {
                    throwable.printStackTrace();
                }
            }
        });
    }

    public static <T> T getParam(MethodCall methodCall, MethodChannel.Result result, String param) {
        T value = methodCall.argument(param);
        if (value == null) {
            result.error("missing param", "cannot find param:" + param, 1);
        }
        return value;
    }

    //-----  PUSH END -----
}
