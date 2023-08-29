class MeetingDetail {
  String? id;
  String? hostId;
  String? hostName;

  MeetingDetail({this.hostId, this.hostName, this.id});

  factory MeetingDetail.fromJson(Map<String, dynamic> json) => MeetingDetail(
    id: json['id'],
    hostId: json['hostId'],
    hostName: json['hostName'],
  );
}