import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:qinglong_app/utils/extension.dart';

class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage>
    with LazyLoadState<UpdatePasswordPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        actions: [
          CommitButton(
            onTap: () {
              submit();
            },
          ),
        ],
        title: "修改用户名密码",
      ),
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const TitleWidget(
                    "用户名",
                    required: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    focusNode: focusNode,
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "请输入用户名",
                    ),
                    autofocus: false,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const TitleWidget(
                    "新密码",
                    required: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    obscureText: true,
                    controller: _passwordController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: "请输入新密码",
                    ),
                    autofocus: false,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const TitleWidget(
                    "再次输入新密码",
                    required: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    obscureText: true,
                    maxLines: 1,
                    controller: _passwordAgainController,
                    decoration: const InputDecoration(
                      hintText: "再次输入新密码",
                    ),
                    autofocus: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submit() async {
    if (_nameController.text.isEmpty) {
      "用户名不能为空".toast();
      return;
    }
    if (_passwordController.text.isEmpty ||
        _passwordAgainController.text.isEmpty) {
      "密码不能为空".toast();
      return;
    }

    if (_passwordAgainController.text != _passwordController.text) {
      "两次输入的密码不一致".toast();
      return;
    }

    commitReal();
  }

  void commitReal() async {
    String name = _nameController.text;
    String password = _passwordController.text;
    HttpResponse<NullResponse> response =
        await SingleAccountPageState.ofApi(context)
            .updatePassword(name, password);

    if (response.success) {
      "更新成功".toast();

      if (!SingleAccountPageState.ofUserInfo(context).useSecretLogined) {
        SingleAccountPageState.ofUserInfo(context).updateUserName(
          SingleAccountPageState.ofUserInfo(context).host ?? "",
          name,
          password,
          false,
          SingleAccountPageState.ofUserInfo(context).alias,
        );
      }
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.routeLogin, (route) => false);
    } else {
      response.message.toast();
    }
  }

  @override
  void onLazyLoad() {
    focusNode.requestFocus();
  }
}
