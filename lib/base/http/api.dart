import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/http/url.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/config/config_bean.dart';
import 'package:qinglong_app/module/env/env_bean.dart';
import 'package:qinglong_app/module/home/system_bean.dart';
import 'package:qinglong_app/module/login/login_bean.dart';
import 'package:qinglong_app/module/login/user_bean.dart';
import 'package:qinglong_app/module/others/LogDelBean.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_bean.dart';
import 'package:qinglong_app/module/others/login_log/login_log_bean.dart';
import 'package:qinglong_app/module/others/scripts/script_bean.dart';
import 'package:qinglong_app/module/others/task_log/task_log_bean.dart';
import 'package:qinglong_app/module/others/update/check_update_bean.dart';
import 'package:qinglong_app/module/task/task_bean.dart';

import '../../module/task/TaskBean2.dart';
import '../ui/tree/models/script_data.dart';

class Api {
  int index;

  Api(this.index);

  Future<HttpResponse<LogDelBean>> logDel() async {
    return await getIt<Http>(instanceName: index.toString()).get<LogDelBean>(
      getIt<Url>(instanceName: index.toString()).logDel,
      {},
    );
  }

  Future<HttpResponse<String>> logDelTime(int time) async {
    return await getIt<Http>(instanceName: index.toString()).put<String>(
      getIt<Url>(instanceName: index.toString()).logDel,
      {"frequency": time},
    );
  }

  Future<HttpResponse<SystemBean>> system() async {
    return await getIt<Http>(instanceName: index.toString()).get<SystemBean>(
      Url.system,
      {},
    );
  }

  Future<HttpResponse<LoginBean>> login(
    String userName,
    String passWord,
  ) async {
    return await getIt<Http>(instanceName: index.toString()).post<LoginBean>(
      Url.login,
      {
        "username": userName,
        "password": passWord,
      },
    );
  }

  Future<HttpResponse<LoginBean>> loginOld(
    String userName,
    String passWord,
  ) async {
    return await getIt<Http>(instanceName: index.toString()).post<LoginBean>(
      Url.loginOld,
      {
        "username": userName,
        "password": passWord,
      },
    );
  }

  Future<HttpResponse<LoginBean>> loginTwo(
    String userName,
    String passWord,
    String code,
  ) async {
    return await getIt<Http>(instanceName: index.toString()).put<LoginBean>(
      Url.loginTwo,
      {
        "username": userName,
        "password": passWord,
        "code": code,
      },
    );
  }

  Future<HttpResponse<LoginBean>> loginByClientId(
    String id,
    String secret,
  ) async {
    return await getIt<Http>(instanceName: index.toString()).get<LoginBean>(
      Url.loginByClientId,
      {
        "client_id": id,
        "client_secret": secret,
      },
    );
  }

  Future<HttpResponse<UserBean>> user() async {
    return await getIt<Http>(instanceName: index.toString()).get<UserBean>(
      Url.user,
      null,
    );
  }

  Future<HttpResponse<TaskBean2>> crons2_13_09() async {
    return await getIt<Http>(instanceName: index.toString()).get<TaskBean2>(
      getIt<Url>(instanceName: index.toString()).tasks,
      {"page": "1", "size": "10000", "searchText": ""},
    );
  }

  Future<HttpResponse<List<TaskBean>>> crons() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<TaskBean>>(
      getIt<Url>(instanceName: index.toString()).tasks,
      {"searchValue": ""},
    );
  }

  Future<HttpResponse<NullResponse>> deleteLogFold(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).logFoldDelete,
      {"filename": fileName, "path": path, "type": "directory"},
    );
  }

  Future<HttpResponse<NullResponse>> deleteLog(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).logFoldDelete,
      {"filename": fileName, "path": path, "type": "file"},
    );
  }

  Future<HttpResponse<String>> subscribes() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).subscribes,
      {"searchValue": ""},
    );
  }

  Future<HttpResponse<NullResponse>> updateNotifcation(Map<String, dynamic> params) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).notifcations,
      params,
    );
  }

  Future<HttpResponse<String>> getNotifcation() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).notifcations,
      {},
    );
  }

  Future<HttpResponse<String>> updateSubscribes(Map<String, dynamic> params) async {
    return await getIt<Http>(instanceName: index.toString()).put<String>(
      getIt<Url>(instanceName: index.toString()).subscribes,
      params,
    );
  }

  Future<HttpResponse<String>> addSubscribes(Map<String, dynamic> params) async {
    return await getIt<Http>(instanceName: index.toString()).post<String>(
      getIt<Url>(instanceName: index.toString()).subscribes,
      params,
    );
  }

  Future<HttpResponse<NullResponse>> startTasks(List<String> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).runTasks,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> stopTasks(List<String> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).stopTasks,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> startSubscribes(List<int> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).runSubscribes,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> stopSubscribes(List<int> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).stopSubscribes,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> updatePassword(String name, String password) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      Url.updatePassword,
      {
        "username": name,
        "password": password,
      },
    );
  }

  Future<HttpResponse<String>> inTimeLog(String cron) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).intimeLog(cron),
      null,
    );
  }

  Future<HttpResponse<String>> inTimeDepLog(String cron) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).intimeDepLog(cron),
      null,
    );
  }

  Future<HttpResponse<String>> inTimeSubscribeLog(int cron) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).intimeSubscribeLog(cron),
      null,
    );
  }

  Future<HttpResponse<NullResponse>> addTask(
    String name,
    String command,
    String cron, {
    int? id,
    String? nId,
  }) async {
    var data = <String, dynamic>{"name": name, "command": command, "schedule": cron};

    if (id != null || nId != null) {
      if (id != null) {
        data["id"] = id;
      } else if (nId != null) {
        data["_id"] = nId;
      }
      return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
        getIt<Url>(instanceName: index.toString()).addTask,
        data,
      );
    }
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addTask,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> delSubscribe(int cron) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addSubscribes,
      [cron],
    );
  }

  Future<HttpResponse<NullResponse>> delTask(List<String> crons) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addTask,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> pinTask(List<String> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).pinTask,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> unpinTask(List<String> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).unpinTask,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> enableTask(List<String> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).enableTask,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> disableTask(List<String> crons) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).disableTask,
      crons,
    );
  }

  Future<HttpResponse<NullResponse>> enableSubscribe(int id) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).enableSubscribes,
      [id],
    );
  }

  Future<HttpResponse<NullResponse>> disableSubscribe(int id) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).disableSubscribes,
      [id],
    );
  }

  Future<HttpResponse<List<ConfigBean>>> files() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<ConfigBean>>(
      getIt<Url>(instanceName: index.toString()).files,
      null,
    );
  }

  Future<HttpResponse<String>> content(String name) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).configContent + name,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> saveFile(String name, String content) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).saveFile,
      {"content": content, "name": name},
    );
  }

  Future<HttpResponse<List<EnvBean>>> envs(String search) async {
    return await getIt<Http>(instanceName: index.toString()).get<List<EnvBean>>(
      getIt<Url>(instanceName: index.toString()).envs,
      {"searchValue": search},
    );
  }

  Future<HttpResponse<NullResponse>> enableEnv(List<String> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).enableEnvs,
      ids,
    );
  }

  Future<HttpResponse<NullResponse>> disableEnv(List<String> ids) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).disableEnvs,
      ids,
    );
  }

  Future<HttpResponse<NullResponse>> delEnvs(List<String> ids) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).delEnv,
      ids,
    );
  }

  Future<HttpResponse<NullResponse>> delEnv(String id) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).delEnv,
      [id],
    );
  }

  Future<HttpResponse<NullResponse>> addEnv(
    String name,
    String value,
    String remarks, {
    int? id,
    String? nId,
  }) async {
    var data = <String, dynamic>{
      "value": value,
      "remarks": remarks,
      "name": name,
    };

    if (id != null || nId != null) {
      if (id != null) {
        data["id"] = id;
      } else if (nId != null) {
        data["_id"] = nId;
      }
      return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
        getIt<Url>(instanceName: index.toString()).addEnv,
        data,
      );
    }
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addEnv,
      [data],
    );
  }

  Future<HttpResponse<NullResponse>> moveEnv(String id, int fromIndex, int toIndex) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).envMove(id),
      {"fromIndex": fromIndex, "toIndex": toIndex},
    );
  }

  Future<HttpResponse<List<LoginLogBean>>> loginLog() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<LoginLogBean>>(
      getIt<Url>(instanceName: index.toString()).loginLog,
      null,
    );
  }

  Future<HttpResponse<List<TaskLogBean>>> taskLog() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<TaskLogBean>>(getIt<Url>(instanceName: index.toString()).taskLog, null,
        serializationName: getIt<SystemBean>(instanceName: index.toString()).isUpperVersion2_12_2() ? "data" : "dirs");
  }

  Future<HttpResponse<String>> taskLogDetail(String name, String path) async {
    if (getIt<SystemBean>(instanceName: index.toString()).isUpperVersion2_13_0()) {
      return await getIt<Http>(instanceName: index.toString()).get<String>(
        getIt<Url>(instanceName: index.toString()).taskLogDetail + name + "?path=" + path,
        null,
      );
    } else {
      return await getIt<Http>(instanceName: index.toString()).get<String>(
        getIt<Url>(instanceName: index.toString()).taskLogDetail + path + "/" + name,
        null,
      );
    }
  }

  Future<HttpResponse<List<ScriptData>>> scripts() async {
    return await getIt<Http>(instanceName: index.toString()).get<List<ScriptData>>(
      getIt<SystemBean>(instanceName: index.toString()).isUpperVersion2_13_0()
          ? getIt<Url>(instanceName: index.toString()).scripts2
          : getIt<Url>(instanceName: index.toString()).scripts,
      null,
    );
  }

  Future<HttpResponse<NullResponse>> updateScript(String name, String path, String content) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {
        "filename": name,
        "path": path,
        "content": content,
      },
    );
  }

  Future<HttpResponse<NullResponse>> delScript(String name, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {
        "filename": name,
        "path": path,
      },
    );
  }

  Future<HttpResponse<NullResponse>> delScriptFold(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {"filename": fileName, "path": path, "type": "directory"},
    );
  }

  Future<HttpResponse<NullResponse>> addScriptFolder(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {
        "directory": fileName,
        "path": path,
      },
    );
  }

  Future<HttpResponse<NullResponse>> delScriptNewVersion(String fileName, String path) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).scriptDetail,
      {"filename": fileName, "path": path, "type": "file"},
    );
  }

  Future<HttpResponse<String>> scriptDetail(String name, String? path) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).scriptDetailForReadFile + name,
      {
        "path": path,
      },
    );
  }

  Future<HttpResponse<List<DependencyBean>>> dependencies(String type) async {
    return await getIt<Http>(instanceName: index.toString()).get<List<DependencyBean>>(
      getIt<Url>(instanceName: index.toString()).dependencies,
      {
        "type": type.toString(),
      },
    );
  }

  Future<HttpResponse<NullResponse>> dependencyReinstall(
    List<String?>? sId,
    List<int?>? id,
  ) async {
    if (sId != null && sId.isNotEmpty && sId[0] != null) {
      return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
        getIt<Url>(instanceName: index.toString()).dependenciesReinstall,
        sId,
      );
    } else {
      return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
        getIt<Url>(instanceName: index.toString()).dependenciesReinstall,
        id,
      );
    }
  }

  Future<HttpResponse<String>> dependencyLog(String id) async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).dependencies + "/" + id,
      null,
    );
  }

  Future<HttpResponse<String>> addDependency(List<Map<String, dynamic>> list) async {
    return await getIt<Http>(instanceName: index.toString()).post<String>(
      getIt<Url>(instanceName: index.toString()).dependencies,
      list,
    );
  }

  Future<HttpResponse<NullResponse>> addScript(String name, String path, String content) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).addScript,
      {
        "filename": name,
        "path": path,
        "content": content,
      },
    );
  }

  Future<HttpResponse<NullResponse>> delDependency(List<String?>? sIds, List<int?>? ids) async {
    bool focus = getIt<SystemBean>(instanceName: index.toString()).isUpperVersion2_13_0();

    String url = "";
    if (focus) {
      url = getIt<Url>(instanceName: index.toString()).dependenciesDeleteFocus;
    } else {
      url = getIt<Url>(instanceName: index.toString()).dependencies;
    }

    HttpResponse<NullResponse> response;
    if (sIds != null && sIds.isNotEmpty && sIds[0] != null) {
      response = await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
        url,
        sIds,
      );
    } else {
      response = await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
        url,
        ids,
      );
    }

    if (response.success == false && focus) {
      url = getIt<Url>(instanceName: index.toString()).dependencies;
      if (sIds != null && sIds.isNotEmpty && sIds[0] != null) {
        response = await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
          url,
          sIds,
        );
      } else {
        response = await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
          url,
          ids,
        );
      }
    }
    return response;
  }

  Future<HttpResponse<CheckUpdateBean>> checkUpdate() async {
    return await getIt<Http>(instanceName: index.toString()).put<CheckUpdateBean>(
      getIt<Url>(instanceName: index.toString()).checkUpdate,
      {},
    );
  }

  Future<HttpResponse<String>> appKeys() async {
    return await getIt<Http>(instanceName: index.toString()).get<String>(
      getIt<Url>(instanceName: index.toString()).appkeys,
      {},
    );
  }

  Future<HttpResponse<NullResponse>> addAppKey(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).post<NullResponse>(
      getIt<Url>(instanceName: index.toString()).appkeys,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> updateAppKey(Map<String, dynamic> data) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).appkeys,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> deleteAppKey(List<String> data) async {
    return await getIt<Http>(instanceName: index.toString()).delete<NullResponse>(
      getIt<Url>(instanceName: index.toString()).appkeys,
      data,
    );
  }

  Future<HttpResponse<NullResponse>> resetAppKey(dynamic id) async {
    return await getIt<Http>(instanceName: index.toString()).put<NullResponse>(
      getIt<Url>(instanceName: index.toString()).resetAppKey(id),
      {},
    );
  }
}
