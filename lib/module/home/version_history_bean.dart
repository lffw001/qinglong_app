class VersionHistoryBean {
  String? host;
  String? version;

  VersionHistoryBean({this.host, this.version});

  VersionHistoryBean.fromJson(Map<String, dynamic> json) {
    host = json['host'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['host'] = this.host;
    data['version'] = this.version;
    return data;
  }
}
