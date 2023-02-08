import 'package:dio_log/dio_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/multi_account_userinfo_viewmodel.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/in_app_purchase_page.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/login_helper.dart';
import 'package:qinglong_app/utils/sp_utils.dart';
import 'package:qinglong_app/utils/utils.dart';
import 'package:flip_card/flip_card.dart';

import '../others/change_account_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  final bool fromAddNewAccount;

  const LoginPage({
    Key? key,
    this.fromAddNewAccount = false,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cIdController = TextEditingController();
  final TextEditingController _cSecretController = TextEditingController();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  bool rememberPassword = false;

  @override
  void initState() {
    super.initState();
    if (!widget.fromAddNewAccount) {
      _hostController.text = SingleAccountPageState.ofUserInfo(context).host ?? "";
      if (SingleAccountPageState.ofUserInfo(context).userName != null &&
          SingleAccountPageState.ofUserInfo(context).userName!.isNotEmpty) {
        if (SingleAccountPageState.ofUserInfo(context).useSecretLogined) {
          _cIdController.text = SingleAccountPageState.ofUserInfo(context).userName!;
        } else {
          _userNameController.text = SingleAccountPageState.ofUserInfo(context).userName!;
        }
        rememberPassword = true;
      } else {
        rememberPassword = false;
      }
      if (SingleAccountPageState.ofUserInfo(context).passWord != null &&
          SingleAccountPageState.ofUserInfo(context).passWord!.isNotEmpty) {
        if (SingleAccountPageState.ofUserInfo(context).useSecretLogined) {
          _cSecretController.text = SingleAccountPageState.ofUserInfo(context).passWord!;
        } else {
          _passwordController.text = SingleAccountPageState.ofUserInfo(context).passWord!;
        }
      }

      if (SingleAccountPageState.ofUserInfo(context).alias != null &&
          SingleAccountPageState.ofUserInfo(context).alias!.isNotEmpty) {
        _aliasController.text = SingleAccountPageState.ofUserInfo(context).alias!;
      }
    }
  }

  GlobalKey<AnimatorWidgetState> loginKey = GlobalKey<AnimatorWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: ref.watch(themeProvider).themeMode == modeDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            primary: true,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeNormal) {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => const InAppPurchasePage(
                                  fromDirectly: true,
                                ),
                              ),
                            );
                            return;
                          } else {
                            if (SpUtil.getBool(spSingleInstance, defValue: false)) {
                              Navigator.pop(context);
                              return;
                            }
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) =>
                                    const ChangeAccountPage(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Visibility(
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  CupertinoIcons.chevron_back,
                                  color: ref.watch(themeProvider).primaryColor,
                                  size: 26,
                                ),
                              ),
                              visible:SpUtil.getBool(spSingleInstance,defValue: false) ,
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "账号登录",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: ref.watch(themeProvider).themeColor.title2Color(),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onDoubleTap: () {
                                if (debugBtnIsShow()) {
                                  dismissDebugBtn();
                                } else {
                                  showDebugBtn(context,
                                      btnColor: ref.watch(themeProvider).primaryColor);
                                }
                                WidgetsBinding.instance.endOfFrame;
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset(
                                  "assets/images/ql.png",
                                  height: 45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 40,
                            child: Text(
                              "域名",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: TextField(
                              onChanged: (_) {
                                setState(() {});
                              },
                              controller: _hostController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(4),
                                hintText: "http://1.1.1.1:5700",
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: ref.watch(themeProvider).themeColor.hintColor(),
                                ),
                              ),
                              autofocus: false,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Color(0xff999999),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                child: Text(
                                  "账户",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                width: 40,
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                child: TextField(
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  controller: _userNameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(4),
                                    hintText: "请输入账户",
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: ref.watch(themeProvider).themeColor.hintColor(),
                                    ),
                                  ),
                                  autofocus: false,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Color(0xff999999),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 40,
                                child: Text(
                                  "密码",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                child: TextField(
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(4),
                                    hintText: "请输入密码",
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: ref.watch(themeProvider).themeColor.hintColor(),
                                    ),
                                  ),
                                  autofocus: false,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Color(0xff999999),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 40,
                            child: Text(
                              "别名",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: TextField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              controller: _aliasController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(4),
                                hintText: "请输入别名(选填),仅用于展示",
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: ref.watch(themeProvider).themeColor.hintColor(),
                                ),
                              ),
                              autofocus: false,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Color(0xff999999),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: rememberPassword,
                        onChanged: (checked) {
                          rememberPassword = checked ?? false;
                          setState(() {});
                        },
                      ),
                      const Text(
                        "记住密码",
                        style: TextStyle(
                          color: Color(0xff555555),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Shake(
                  preferences: const AnimationPreferences(autoPlay: AnimationPlayStates.None),
                  key: loginKey,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: canClickLoginBtn()
                              ? [
                                  const Color(0xff5DD16F),
                                  const Color(0xff089556),
                                ]
                              : [
                                  const Color(0xff5DD16F).withOpacity(0.6),
                                  const Color(0xff089556).withOpacity(0.6),
                                ],
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 80,
                        child: IgnorePointer(
                          ignoring: !canClickLoginBtn(),
                          child: Builder(builder: (context) {
                            return CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: isLoading
                                  ? const LoadingWidget(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "登 录",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                              onPressed: () async {
                                //检测是否已经存在host登录

                                if (!_hostController.text.startsWith("http://") &&
                                    !_hostController.text.startsWith("https://")) {
                                  "域名必须以http://或者https://开头".toast();
                                  return;
                                }
                                SingleAccountPageState.of(context)
                                    ?.registerHttp(_hostController.text);
                                SingleAccountPageState.ofHttp(context)?.pushedLoginPage = false;
                                Utils.hideKeyBoard(context);
                                if (loginByUserName()) {
                                  login(_userNameController.text, _passwordController.text);
                                } else {
                                  login(_cIdController.text, _cSecretController.text);
                                }
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                (getIt<MultiAccountUserInfoViewModel>().historyAccounts.isEmpty)
                    ? const SizedBox.shrink()
                    : SafeArea(
                        top: false,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Material(
                              color: Colors.transparent,
                              child: PopupMenuButton<UserInfoBean>(
                                onSelected: (UserInfoBean result) {
                                  selected(result);
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<UserInfoBean>>[
                                  ...getIt<MultiAccountUserInfoViewModel>()
                                      .historyAccounts
                                      .map((e) => PopupMenuItem<UserInfoBean>(
                                            value: e,
                                            child: buildCell(context, e),
                                          ))
                                      .toList(),
                                ],
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/images/icon_history.png",
                                      fit: BoxFit.cover,
                                      width: 16,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "历史账号",
                                      style: TextStyle(
                                        color: Color(0xff555555),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isLoading = false;

  bool loginByUserName() {
    return true;
  }

  LoginHelper? helper;

  Future<void> login(String userName, String password) async {
    isLoading = true;
    setState(() {});

    helper = LoginHelper(
      _hostController.text,
      userName,
      password,
      rememberPassword,
      _aliasController.text,
    );
    var response = await helper!.login(context);
    dealLoginResponse(response);
  }

  void dealLoginResponse(int response) {
    if (response == LoginHelper.success) {
      Navigator.of(context).pushReplacementNamed(Routes.routeHomePage);
    } else if (response == LoginHelper.failed) {
      loginFailed();
    } else {
      twoFact();
    }
  }

  void loginFailed() {
    isLoading = false;
    loginKey.currentState?.forward();
    setState(() {});
  }

  bool canClickLoginBtn() {
    if (isLoading) return false;

    if (_hostController.text.isEmpty) return false;
    if (!loginByUserName()) {
      return _cIdController.text.isNotEmpty && _cSecretController.text.isNotEmpty;
    } else {
      return _userNameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    }
  }

  void twoFact() {
    String twoFact = "";
    showCupertinoDialog(
        useRootNavigator: false,
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: const Text("两步验证"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: TextField(
                      onChanged: (value) {
                        twoFact = value;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        hintText: "请输入code",
                      ),
                      autofocus: true,
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text(
                    "取消",
                    style: TextStyle(
                      color: Color(0xff999999),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    "确定",
                    style: TextStyle(
                      color: ref.watch(themeProvider).primaryColor,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    if (helper != null) {
                      var response = await helper!.loginTwice(context, twoFact);
                      dealLoginResponse(response);
                    } else {
                      "状态异常，请重新点登录按钮".toast();
                    }
                  },
                ),
              ],
            )).then((value) {
      if (value == null) {
        isLoading = false;
        setState(() {});
      }
    });
  }

  Widget buildCell(BuildContext context, UserInfoBean bean) {
    return ListTile(
      title: Text(
        bean.host ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(
          (bean.alias == null || bean.alias!.isEmpty) ? (bean.userName ?? "") : bean.alias!,
        ),
      ),
      contentPadding: EdgeInsets.zero,
      trailing: GestureDetector(
          onTap: () {
            getIt<MultiAccountUserInfoViewModel>().removeHistoryAccount(bean.host);
            Navigator.pop(context);

            setState(() {});
          },
          child: const Icon(
            CupertinoIcons.clear_thick,
            size: 20,
          )),
    );
  }

  void selected(UserInfoBean result) {
    _hostController.text = result.host ?? "";
    if (result.useSecretLogined) {
      _cIdController.text = result.userName ?? "";
      _cSecretController.text = result.password ?? "";
      if (cardKey.currentState?.isFront ?? false) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          cardKey.currentState?.toggleCard();
        });
      }
    } else {
      _userNameController.text = result.userName ?? "";
      _passwordController.text = result.password ?? "";
      if (!(cardKey.currentState?.isFront ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          cardKey.currentState?.toggleCard();
        });
      }
    }
    _aliasController.text = result.alias ?? "";
    rememberPassword = true;
    setState(() {});
  }
}
